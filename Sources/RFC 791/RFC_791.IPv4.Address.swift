// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

extension RFC_791.IPv4 {
    /// IPv4 Address (RFC 791)
    ///
    /// A 32-bit address used to identify hosts on an IP network.
    /// Addresses are commonly represented in dotted-decimal notation (e.g., "192.168.1.1").
    ///
    /// ## Storage
    ///
    /// Internally stored as a single `UInt32` in network byte order (big-endian),
    /// providing efficient comparisons and operations.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Parse from ASCII bytes (canonical)
    /// let address = try RFC_791.IPv4.Address(ascii: Array("192.168.1.1".utf8))
    ///
    /// // Parse from string (convenience)
    /// let address = try RFC_791.IPv4.Address("192.168.1.1")
    ///
    /// // Create from octets
    /// let address = RFC_791.IPv4.Address(192, 168, 1, 1)
    ///
    /// // Serialize to bytes
    /// let bytes = [UInt8](address)
    /// ```
    public struct Address: Hashable, Sendable, Codable {
        /// The 32-bit address value in network byte order (big-endian)
        public let rawValue: UInt32

        /// Creates an IPv4 address WITHOUT validation
        ///
        /// **Warning**: Bypasses RFC validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// Creates an IPv4 address from a 32-bit value
        ///
        /// - Parameter rawValue: The 32-bit address in network byte order
        public init(rawValue: UInt32) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Initialization from Octets

extension RFC_791.IPv4.Address {
    /// Creates an IPv4 address from four octets
    ///
    /// Constructs the address from four 8-bit values in standard dotted-decimal order.
    ///
    /// - Parameters:
    ///   - octet1: First octet (most significant byte)
    ///   - octet2: Second octet
    ///   - octet3: Third octet
    ///   - octet4: Fourth octet (least significant byte)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address = RFC_791.IPv4.Address(192, 168, 1, 1)
    /// ```
    public init(_ octet1: UInt8, _ octet2: UInt8, _ octet3: UInt8, _ octet4: UInt8) {
        let value = UInt32(octet1) << 24
            | UInt32(octet2) << 16
            | UInt32(octet3) << 8
            | UInt32(octet4)
        self.init(__unchecked: (), rawValue: value)
    }
}

// MARK: - Octet Access

extension RFC_791.IPv4.Address {
    /// The four octets of the address in standard order
    ///
    /// Returns the address as a tuple of four 8-bit values in the order
    /// they appear in dotted-decimal notation.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address = RFC_791.IPv4.Address(192, 168, 1, 1)
    /// let (a, b, c, d) = address.octets
    /// // a = 192, b = 168, c = 1, d = 1
    /// ```
    public var octets: (UInt8, UInt8, UInt8, UInt8) {
        (
            UInt8((rawValue >> 24) & 0xFF),
            UInt8((rawValue >> 16) & 0xFF),
            UInt8((rawValue >> 8) & 0xFF),
            UInt8(rawValue & 0xFF)
        )
    }
}

// MARK: - UInt8.ASCII.Serializable Conformance

extension RFC_791.IPv4.Address: UInt8.ASCII.Serializable {
    /// Serialization function for ASCII byte output
    public static let serialize: @Sendable (Self) -> [UInt8] = [UInt8].init

    /// Creates an IPv4 address from ASCII bytes in dotted-decimal notation
    ///
    /// This is the canonical parsing transformation per STANDARD_IMPLEMENTATION_PATTERNS.md.
    /// String parsing is derived from this as composition:
    /// ```
    /// String → [UInt8] (UTF-8) → IPv4.Address
    /// ```
    ///
    /// ## Category Theory
    ///
    /// Parsing transformation:
    /// - **Domain**: [UInt8] (ASCII bytes)
    /// - **Codomain**: RFC_791.IPv4.Address (structured data)
    ///
    /// ## Constraints
    ///
    /// Per RFC 791 Section 3.2:
    /// - Four decimal octets separated by periods
    /// - Each octet in range 0-255
    /// - No leading zeros (strict mode)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array("192.168.1.1".utf8)
    /// let address = try RFC_791.IPv4.Address(ascii: bytes)
    /// ```
    ///
    /// - Parameters:
    ///   - bytes: ASCII bytes representing dotted-decimal notation
    ///   - context: Parsing context (unused for context-free parsing)
    /// - Throws: `Error` if the format is invalid
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == UInt8 {
        guard !bytes.isEmpty else {
            throw .empty
        }

        var octets: [UInt8] = []
        octets.reserveCapacity(4)

        var currentOctet: Int = 0
        var digitCount = 0
        var position = 0

        for byte in bytes {
            if byte == UInt8.ascii.period {
                // End of octet
                guard digitCount > 0 else {
                    throw .invalidFormat(String(decoding: bytes, as: UTF8.self))
                }
                guard currentOctet <= 255 else {
                    throw .octetOutOfRange(currentOctet, position: position)
                }
                octets.append(UInt8(currentOctet))
                currentOctet = 0
                digitCount = 0
                position += 1
            } else if byte.ascii.isDigit {
                // Check for leading zeros (except for "0" itself)
                if digitCount == 1, currentOctet == 0 {
                    throw .leadingZero(String(decoding: bytes, as: UTF8.self), position: position)
                }
                currentOctet = currentOctet * 10 + Int(byte - UInt8.ascii.`0`)
                digitCount += 1

                // Early overflow check
                if currentOctet > 255 {
                    throw .octetOutOfRange(currentOctet, position: position)
                }
            } else {
                throw .invalidCharacter(
                    String(decoding: bytes, as: UTF8.self),
                    byte: byte,
                    position: position
                )
            }
        }

        // Handle final octet
        guard digitCount > 0 else {
            throw .invalidFormat(String(decoding: bytes, as: UTF8.self))
        }
        guard currentOctet <= 255 else {
            throw .octetOutOfRange(currentOctet, position: position)
        }
        octets.append(UInt8(currentOctet))

        // Must have exactly 4 octets
        guard octets.count == 4 else {
            throw .invalidFormat(String(decoding: bytes, as: UTF8.self))
        }

        self.init(octets[0], octets[1], octets[2], octets[3])
    }
}

extension RFC_791.IPv4.Address: CustomStringConvertible {}

// MARK: - Comparable

extension RFC_791.IPv4.Address: Comparable {
    /// Compares two IPv4 addresses numerically
    ///
    /// Addresses are compared by their 32-bit numeric value, allowing
    /// for range operations and sorting.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let start = RFC_791.IPv4.Address(192, 168, 1, 1)
    /// let end = RFC_791.IPv4.Address(192, 168, 1, 255)
    /// if address >= start && address <= end {
    ///     print("Address is in range")
    /// }
    /// ```
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension RFC_791.IPv4.Address: ExpressibleByStringLiteral {}

// MARK: - Static Constants

extension RFC_791.IPv4.Address {
    /// The unspecified address (0.0.0.0)
    public static let `any` = RFC_791.IPv4.Address(__unchecked: (), rawValue: 0)

    /// The broadcast address (255.255.255.255)
    public static let broadcast = RFC_791.IPv4.Address(__unchecked: (), rawValue: 0xFFFF_FFFF)

    /// The loopback address (127.0.0.1)
    public static let loopback = RFC_791.IPv4.Address(__unchecked: (), rawValue: 0x7F00_0001)
}
