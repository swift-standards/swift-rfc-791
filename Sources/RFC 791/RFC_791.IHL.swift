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
    /// Internet Header Length (RFC 791)
    ///
    /// A 4-bit field indicating the length of the IP header in 32-bit words.
    /// The minimum value is 5 (20 bytes), and the maximum is 15 (60 bytes).
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1, IHL is in the lower 4 bits of the first byte:
    /// ```
    /// +-----+-----+-----+-----+-----+-----+-----+-----+
    /// |    Version    |       IHL         |
    /// +-----+-----+-----+-----+-----+-----+-----+-----+
    ///   0     1     2     3     4     5     6     7
    /// ```
    ///
    /// ## Values
    ///
    /// - Minimum: 5 (20 bytes, no options)
    /// - Maximum: 15 (60 bytes, maximum options)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let ihl = RFC_791.IHL.minimum
    /// print(ihl.byteLength)  // 20
    /// ```
    public struct IHL: RawRepresentable, Hashable, Sendable, Codable {
        /// The 4-bit raw value (number of 32-bit words)
        public let rawValue: UInt8

        /// Creates an IHL value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates an IHL from a raw 4-bit value
        ///
        /// - Parameter rawValue: The header length in 32-bit words (5-15)
        /// - Returns: `nil` if the value is less than 5 or greater than 15
        public init?(rawValue: UInt8) {
            guard rawValue >= 5, rawValue <= 15 else {
                return nil
            }
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Computed Properties

extension RFC_791.IHL {
    /// The header length in bytes
    ///
    /// Converts from 32-bit words to bytes by multiplying by 4.
    public var byteLength: Int {
        Int(rawValue) * 4
    }

    /// The options length in bytes
    ///
    /// Returns the number of bytes available for options (total - 20).
    public var optionsLength: Int {
        byteLength - 20
    }

    /// Whether this header has options
    public var hasOptions: Bool {
        rawValue > 5
    }
}

// MARK: - Standard Values

extension RFC_791.IHL {
    /// Minimum header length (5 words = 20 bytes, no options)
    public static let minimum = RFC_791.IHL(__unchecked: (), rawValue: 5)

    /// Maximum header length (15 words = 60 bytes)
    public static let maximum = RFC_791.IHL(__unchecked: (), rawValue: 15)
}

// MARK: - Factory Methods

extension RFC_791.IHL {
    /// Creates an IHL from a byte length
    ///
    /// - Parameter bytes: The header length in bytes (must be 20-60 and divisible by 4)
    /// - Returns: `nil` if the byte length is invalid
    public static func fromByteLength(_ bytes: Int) -> RFC_791.IHL? {
        guard bytes >= 20, bytes <= 60, bytes % 4 == 0 else {
            return nil
        }
        return RFC_791.IHL(rawValue: UInt8(bytes / 4))
    }
}

// MARK: - Byte Parsing

extension RFC_791.IHL {
    /// Creates an IHL from bytes
    ///
    /// The IHL is extracted from the lower 4 bits of the first byte.
    ///
    /// - Parameter bytes: Binary data containing the IHL
    /// - Throws: `Error` if the format is invalid
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        guard let firstByte = bytes.first else {
            throw .empty
        }

        // IHL is in lower 4 bits
        let ihl = firstByte & 0x0F

        guard ihl >= 5 else {
            throw .tooSmall(ihl)
        }

        self.init(__unchecked: (), rawValue: ihl)
    }
}

// MARK: - UInt8.Serializable Conformance

extension RFC_791.IHL: UInt8.Serializable {
    static public func serialize<Buffer>(
        _ ihl: RFC_791.IHL,
        into buffer: inout Buffer
    ) where Buffer : RangeReplaceableCollection, Buffer.Element == UInt8 {
        buffer.append(ihl.rawValue)
    }
}


// MARK: - CustomStringConvertible

extension RFC_791.IHL: CustomStringConvertible {
    public var description: String {
        "IHL(\(rawValue) words, \(byteLength) bytes)"
    }
}

// MARK: - Comparable

extension RFC_791.IHL: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
