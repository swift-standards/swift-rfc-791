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
    /// IP Precedence (RFC 791)
    ///
    /// A 3-bit field within the Type of Service byte that indicates the
    /// relative importance or priority of a datagram. Higher precedence
    /// values indicate more important traffic.
    ///
    /// ## Binary Format
    ///
    /// The precedence field occupies bits 0-2 (most significant) of the
    /// Type of Service byte:
    /// ```
    /// +-----+-----+-----+-----+-----+-----+-----+-----+
    /// | P2  | P1  | P0  | ... | ... | ... | ... | ... |
    /// +-----+-----+-----+-----+-----+-----+-----+-----+
    ///   0     1     2     3     4     5     6     7
    /// ```
    ///
    /// ## Precedence Levels
    ///
    /// Per RFC 791:
    /// - 111 (7): Network Control
    /// - 110 (6): Internetwork Control
    /// - 101 (5): CRITIC/ECP
    /// - 100 (4): Flash Override
    /// - 011 (3): Flash
    /// - 010 (2): Immediate
    /// - 001 (1): Priority
    /// - 000 (0): Routine
    ///
    /// ## Example
    ///
    /// ```swift
    /// let precedence = RFC_791.Precedence.flash
    /// print(precedence.rawValue)  // 3
    /// ```
    public struct Precedence: RawRepresentable, Hashable, Sendable, Codable {
        /// The 3-bit raw value (0-7)
        public let rawValue: UInt8

        /// Creates a precedence value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates a precedence value from a raw 3-bit value
        ///
        /// - Parameter rawValue: The precedence value (0-7)
        /// - Returns: `nil` if the value exceeds 7
        public init?(rawValue: UInt8) {
            guard rawValue <= 7 else {
                return nil
            }
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Standard Precedence Levels

extension RFC_791.Precedence {
    /// Routine precedence (0)
    ///
    /// Default precedence for normal traffic with no special handling.
    public static let routine = RFC_791.Precedence(__unchecked: (), rawValue: 0)

    /// Priority precedence (1)
    ///
    /// Higher than routine but lower than immediate.
    public static let priority = RFC_791.Precedence(__unchecked: (), rawValue: 1)

    /// Immediate precedence (2)
    ///
    /// Traffic requiring quick handling.
    public static let immediate = RFC_791.Precedence(__unchecked: (), rawValue: 2)

    /// Flash precedence (3)
    ///
    /// High-priority traffic requiring very fast handling.
    public static let flash = RFC_791.Precedence(__unchecked: (), rawValue: 3)

    /// Flash Override precedence (4)
    ///
    /// Emergency traffic that overrides flash precedence.
    public static let flashOverride = RFC_791.Precedence(__unchecked: (), rawValue: 4)

    /// CRITIC/ECP precedence (5)
    ///
    /// Critical traffic (Critical and Emergency Communications Processing).
    public static let criticEcp = RFC_791.Precedence(__unchecked: (), rawValue: 5)

    /// Internetwork Control precedence (6)
    ///
    /// Reserved for internetwork control traffic (e.g., routing protocols).
    public static let internetworkControl = RFC_791.Precedence(__unchecked: (), rawValue: 6)

    /// Network Control precedence (7)
    ///
    /// Highest precedence, reserved for network control traffic.
    public static let networkControl = RFC_791.Precedence(__unchecked: (), rawValue: 7)
}

// MARK: - Byte Parsing

extension RFC_791.Precedence {
    /// Creates a precedence value from bytes
    ///
    /// This is the canonical parsing transformation for binary data.
    /// The first byte is interpreted as the precedence value.
    ///
    /// ## Category Theory
    ///
    /// Parsing transformation:
    /// - **Domain**: Collection<UInt8> (bytes)
    /// - **Codomain**: RFC_791.Precedence (structured data)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let precedence = try RFC_791.Precedence(bytes: [0x03])  // flash
    /// ```
    ///
    /// - Parameter bytes: Binary data containing the precedence value
    /// - Throws: `Error` if the format is invalid
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        guard let firstByte = bytes.first else {
            throw .empty
        }

        guard firstByte <= 7 else {
            throw .valueOutOfRange(firstByte)
        }

        self.init(__unchecked: (), rawValue: firstByte)
    }
}

// MARK: - Binary.Serializable Conformance

extension RFC_791.Precedence: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ precedence: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(precedence.rawValue)
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.Precedence: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 0: return "Routine"
        case 1: return "Priority"
        case 2: return "Immediate"
        case 3: return "Flash"
        case 4: return "Flash Override"
        case 5: return "CRITIC/ECP"
        case 6: return "Internetwork Control"
        case 7: return "Network Control"
        default: return "Unknown(\(rawValue))"
        }
    }
}

// MARK: - Comparable

extension RFC_791.Precedence: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - [UInt8] Conversion

extension [UInt8] {
    /// Creates byte representation of a Precedence value
    ///
    /// Writes the raw precedence value.
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.Precedence → [UInt8]
    ///
    /// - Parameter precedence: The Precedence value to serialize
    public init(_ precedence: RFC_791.Precedence) {
        self = [precedence.rawValue]
    }
}
