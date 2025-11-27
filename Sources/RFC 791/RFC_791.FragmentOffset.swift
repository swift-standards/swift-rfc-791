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

extension RFC_791 {
    /// Fragment Offset (RFC 791)
    ///
    /// A 13-bit field indicating where in the original datagram this fragment
    /// belongs. The offset is measured in units of 8 octets (64 bits).
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1, Fragment Offset shares two bytes with Flags:
    /// ```
    /// +-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+
    /// |  0  | DF  | MF  |          Fragment Offset (13 bits)                                        |
    /// +-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+
    ///   0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
    /// ```
    ///
    /// ## Calculation
    ///
    /// - Value is in 8-octet units
    /// - Byte offset = rawValue * 8
    /// - Maximum byte offset = 8191 * 8 = 65,528 bytes
    ///
    /// ## Example
    ///
    /// ```swift
    /// let offset = RFC_791.FragmentOffset(rawValue: 185)!
    /// print(offset.byteOffset)  // 1480 (typical MTU fragment boundary)
    /// ```
    public struct FragmentOffset: RawRepresentable, Hashable, Sendable, Codable {
        /// The 13-bit raw value (in 8-octet units)
        public let rawValue: UInt16

        /// Creates a FragmentOffset value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates a FragmentOffset from a raw 13-bit value
        ///
        /// - Parameter rawValue: The offset in 8-octet units (0-8191)
        /// - Returns: `nil` if the value exceeds 8191
        public init?(rawValue: UInt16) {
            guard rawValue <= 0x1FFF else {
                return nil
            }
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Computed Properties

extension RFC_791.FragmentOffset {
    /// The offset in bytes
    ///
    /// Converts from 8-octet units to bytes.
    public var byteOffset: Int {
        Int(rawValue) * 8
    }

    /// Whether this is the first fragment (offset is zero)
    public var isFirstFragment: Bool {
        rawValue == 0
    }
}

// MARK: - Factory Methods

extension RFC_791.FragmentOffset {
    /// Creates a FragmentOffset from a byte offset
    ///
    /// - Parameter bytes: The byte offset (must be divisible by 8 and <= 65528)
    /// - Returns: `nil` if the byte offset is invalid
    public static func fromByteOffset(_ bytes: Int) -> RFC_791.FragmentOffset? {
        guard bytes >= 0, bytes <= 65528, bytes % 8 == 0 else {
            return nil
        }
        return RFC_791.FragmentOffset(rawValue: UInt16(bytes / 8))
    }
}

// MARK: - Static Constants

extension RFC_791.FragmentOffset {
    /// Zero offset (first fragment or unfragmented datagram)
    public static let zero = RFC_791.FragmentOffset(__unchecked: (), rawValue: 0)

    /// Maximum fragment offset (8191 * 8 = 65528 bytes)
    public static let maximum = RFC_791.FragmentOffset(__unchecked: (), rawValue: 0x1FFF)
}

// MARK: - Byte Parsing

extension RFC_791.FragmentOffset {
    /// Creates a FragmentOffset from bytes
    ///
    /// The offset is extracted from the lower 13 bits of a 16-bit value.
    ///
    /// - Parameter bytes: Binary data containing the offset (2 bytes, big-endian)
    /// - Throws: `Error` if there are insufficient bytes
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        var iterator = bytes.makeIterator()

        guard let high = iterator.next() else {
            throw .empty
        }
        guard let low = iterator.next() else {
            throw .insufficientBytes
        }

        // Extract lower 13 bits (mask out flags in upper 3 bits)
        let value = (UInt16(high) << 8 | UInt16(low)) & 0x1FFF
        self.init(__unchecked: (), rawValue: value)
    }
}

// MARK: - UInt8.Serializable Conformance

extension RFC_791.FragmentOffset: UInt8.Serializable {
    public static let serialize: @Sendable (Self) -> [UInt8] = [UInt8].init
}

// MARK: - [UInt8] Conversion

extension [UInt8] {
    /// Creates byte representation of a FragmentOffset field (big-endian, lower 13 bits only)
    ///
    /// Note: This only serializes the offset portion. The flags must be
    /// combined separately when building a complete header.
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.FragmentOffset → [UInt8]
    ///
    /// - Parameter fragmentOffset: The FragmentOffset value to serialize
    public init(_ fragmentOffset: RFC_791.FragmentOffset) {
        self = [
            UInt8((fragmentOffset.rawValue >> 8) & 0x1F),  // Upper 5 bits of offset
            UInt8(fragmentOffset.rawValue & 0xFF),  // Lower 8 bits of offset
        ]
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.FragmentOffset: CustomStringConvertible {
    public var description: String {
        "FragmentOffset(\(rawValue) = \(byteOffset) bytes)"
    }
}

// MARK: - Comparable

extension RFC_791.FragmentOffset: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
