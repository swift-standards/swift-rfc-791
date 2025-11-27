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
    /// Header Checksum (RFC 791)
    ///
    /// A 16-bit one's complement of the one's complement sum of all 16-bit
    /// words in the header. For purposes of computing the checksum, the value
    /// of the checksum field is zero.
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1, Header Checksum is a 16-bit field.
    ///
    /// ## Algorithm
    ///
    /// 1. Set checksum field to zero
    /// 2. Sum all 16-bit words in the header (using one's complement arithmetic)
    /// 3. Take the one's complement of the result
    ///
    /// ## Verification
    ///
    /// When verifying, sum all 16-bit words including the checksum.
    /// If valid, the result should be all 1s (0xFFFF in one's complement).
    ///
    /// ## Note
    ///
    /// The checksum must be recomputed at each router since TTL changes.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let checksum = RFC_791.HeaderChecksum(rawValue: 0xB861)
    /// ```
    public struct HeaderChecksum: RawRepresentable, Hashable, Sendable, Codable {
        /// The 16-bit raw value
        public let rawValue: UInt16

        /// Creates a HeaderChecksum value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates a HeaderChecksum from a raw value
        ///
        /// All 16-bit values are valid checksums.
        ///
        /// - Parameter rawValue: The checksum value (0-65535)
        public init(rawValue: UInt16) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Checksum Computation

extension RFC_791.HeaderChecksum {
    /// Computes the checksum for a header
    ///
    /// - Parameter header: The header bytes (checksum field should be zero)
    /// - Returns: The computed checksum
    public static func compute<Bytes: Collection>(
        over header: Bytes
    ) -> RFC_791.HeaderChecksum where Bytes.Element == UInt8 {
        var sum: UInt32 = 0
        var iterator = header.makeIterator()

        // Sum all 16-bit words
        while let high = iterator.next() {
            let low = iterator.next() ?? 0
            sum += UInt32(high) << 8 | UInt32(low)
        }

        // Fold 32-bit sum to 16 bits (add carry bits)
        while sum > 0xFFFF {
            sum = (sum & 0xFFFF) + (sum >> 16)
        }

        // One's complement
        let checksum = UInt16(~sum & 0xFFFF)
        return RFC_791.HeaderChecksum(__unchecked: (), rawValue: checksum)
    }

    /// Verifies that a header's checksum is correct
    ///
    /// - Parameter header: The complete header bytes including checksum
    /// - Returns: `true` if the checksum is valid
    public static func verify<Bytes: Collection>(
        header: Bytes
    ) -> Bool where Bytes.Element == UInt8 {
        var sum: UInt32 = 0
        var iterator = header.makeIterator()

        // Sum all 16-bit words including checksum
        while let high = iterator.next() {
            let low = iterator.next() ?? 0
            sum += UInt32(high) << 8 | UInt32(low)
        }

        // Fold 32-bit sum to 16 bits
        while sum > 0xFFFF {
            sum = (sum & 0xFFFF) + (sum >> 16)
        }

        // Valid checksum should produce 0xFFFF
        return sum == 0xFFFF
    }
}

// MARK: - Byte Parsing

extension RFC_791.HeaderChecksum {
    /// Creates a HeaderChecksum from bytes (big-endian)
    ///
    /// - Parameter bytes: Binary data containing the checksum (2 bytes, big-endian)
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

extension RFC_791.HeaderChecksum: UInt8.Serializable {
    /// Serialize to a byte buffer (big-endian)
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(UInt8(rawValue >> 8))
        buffer.append(UInt8(rawValue & 0xFF))
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.HeaderChecksum: CustomStringConvertible {
    public var description: String {
        "0x\(String(rawValue, radix: 16, uppercase: true))"
    }
}

// MARK: - Static Constants

extension RFC_791.HeaderChecksum {
    /// Zero checksum (used during computation)
    public static let zero = RFC_791.HeaderChecksum(__unchecked: (), rawValue: 0)
}
