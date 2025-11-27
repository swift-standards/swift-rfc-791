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
    /// Total Length (RFC 791)
    ///
    /// A 16-bit field indicating the total length of the datagram in octets,
    /// including header and data. The minimum value is 20 (header only with
    /// no options and no data).
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1, Total Length is a 16-bit field.
    ///
    /// ## Constraints
    ///
    /// - Minimum: 20 (minimum header size)
    /// - Maximum: 65535 (16-bit maximum)
    /// - All hosts must accept datagrams of at least 576 octets
    ///
    /// ## Example
    ///
    /// ```swift
    /// let length = RFC_791.TotalLength(rawValue: 1500)!
    /// print(length.rawValue)  // 1500
    /// ```
    public struct TotalLength: RawRepresentable, Hashable, Sendable, Codable {
        /// The 16-bit raw value (in octets)
        public let rawValue: UInt16

        /// Creates a TotalLength value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates a TotalLength from a raw value
        ///
        /// - Parameter rawValue: The total length in octets (20-65535)
        /// - Returns: `nil` if the value is less than 20 (minimum header size)
        public init?(rawValue: UInt16) {
            guard rawValue >= 20 else {
                return nil
            }
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Computed Properties

extension RFC_791.TotalLength {
    /// The data length (total length minus minimum header)
    ///
    /// Note: This assumes minimum header size. For accurate data length,
    /// subtract the actual IHL value.
    public var maximumDataLength: Int {
        Int(rawValue) - 20
    }

    /// Whether this is the minimum size (header only, no options, no data)
    public var isMinimum: Bool {
        rawValue == 20
    }
}

// MARK: - Static Constants

extension RFC_791.TotalLength {
    /// Minimum total length (20 bytes, header only)
    public static let minimum = RFC_791.TotalLength(__unchecked: (), rawValue: 20)

    /// Maximum total length (65535 bytes)
    public static let maximum = RFC_791.TotalLength(__unchecked: (), rawValue: 65535)

    /// Minimum reassembly buffer size all hosts must accept (576 bytes)
    public static let minimumReassemblyBuffer = RFC_791.TotalLength(__unchecked: (), rawValue: 576)

    /// Typical Ethernet MTU (1500 bytes)
    public static let ethernetMTU = RFC_791.TotalLength(__unchecked: (), rawValue: 1500)
}

// MARK: - Byte Parsing

extension RFC_791.TotalLength {
    /// Creates a TotalLength from bytes (big-endian)
    ///
    /// - Parameter bytes: Binary data containing the total length (2 bytes, big-endian)
    /// - Throws: `Error` if there are insufficient bytes or value is invalid
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
        guard value >= 20 else {
            throw .tooSmall(value)
        }

        self.init(__unchecked: (), rawValue: value)
    }
}

// MARK: - UInt8.Serializable Conformance

extension RFC_791.TotalLength: UInt8.Serializable {
    public static let serialize: @Sendable (Self) -> [UInt8] = [UInt8].init
}

// MARK: - [UInt8] Conversion

extension [UInt8] {
    /// Creates byte representation of a TotalLength field (big-endian)
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.TotalLength → [UInt8]
    ///
    /// - Parameter totalLength: The TotalLength value to serialize
    public init(_ totalLength: RFC_791.TotalLength) {
        self = [
            UInt8(totalLength.rawValue >> 8),
            UInt8(totalLength.rawValue & 0xFF),
        ]
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.TotalLength: CustomStringConvertible {
    public var description: String {
        "\(rawValue) bytes"
    }
}

// MARK: - Comparable

extension RFC_791.TotalLength: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
