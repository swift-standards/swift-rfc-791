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
    /// Identification Field (RFC 791)
    ///
    /// A 16-bit field used to identify fragments of an original datagram.
    /// All fragments of a datagram have the same identification value,
    /// allowing the destination to reassemble them.
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1, Identification is a 16-bit field.
    ///
    /// ## Usage
    ///
    /// - Set by the sender to uniquely identify the datagram
    /// - Used with source address, destination address, and protocol
    ///   to identify all fragments belonging to the same datagram
    /// - Typically incremented for each datagram sent
    ///
    /// ## Example
    ///
    /// ```swift
    /// let id = RFC_791.Identification(rawValue: 0x1234)
    /// print(id.rawValue)  // 4660
    /// ```
    public struct Identification: RawRepresentable, Hashable, Sendable, Codable {
        /// The 16-bit raw value
        public let rawValue: UInt16

        /// Creates an Identification value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates an Identification from a raw value
        ///
        /// All 16-bit values are valid.
        ///
        /// - Parameter rawValue: The identification value (0-65535)
        public init(rawValue: UInt16) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Byte Parsing

extension RFC_791.Identification {
    /// Creates an Identification from bytes (big-endian)
    ///
    /// - Parameter bytes: Binary data containing the identification (2 bytes, big-endian)
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

        let value = UInt16(high) << 8 | UInt16(low)
        self.init(__unchecked: (), rawValue: value)
    }
}

// MARK: - UInt8.Serializable Conformance

extension RFC_791.Identification: UInt8.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ identification: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(UInt8(identification.rawValue >> 8))
        buffer.append(UInt8(identification.rawValue & 0xFF))
    }
}

// MARK: - [UInt8] Conversion

extension [UInt8] {
    /// Creates byte representation of an Identification field (big-endian)
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.Identification → [UInt8]
    ///
    /// - Parameter identification: The Identification value to serialize
    public init(_ identification: RFC_791.Identification) {
        self = [
            UInt8(identification.rawValue >> 8),
            UInt8(identification.rawValue & 0xFF),
        ]
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.Identification: CustomStringConvertible {
    public var description: String {
        "0x\(String(rawValue, radix: 16, uppercase: true))"
    }
}

// MARK: - Comparable

extension RFC_791.Identification: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension RFC_791.Identification: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt16) {
        self.init(__unchecked: (), rawValue: value)
    }
}
