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
    /// Time to Live (RFC 791)
    ///
    /// An 8-bit field indicating the maximum time a datagram is allowed to
    /// remain in the internet system. While originally specified in seconds,
    /// in practice each router decrements this value by 1 (hop count).
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1, TTL is a single octet field.
    ///
    /// ## Behavior
    ///
    /// - Each router decrements the TTL by at least 1
    /// - When TTL reaches 0, the datagram is discarded
    /// - An ICMP Time Exceeded message is sent to the source
    ///
    /// ## Common Values
    ///
    /// | OS/System | Default TTL |
    /// |-----------|-------------|
    /// | Linux     | 64          |
    /// | Windows   | 128         |
    /// | macOS     | 64          |
    /// | Cisco     | 255         |
    ///
    /// ## Example
    ///
    /// ```swift
    /// let ttl = RFC_791.TTL.default64
    /// print(ttl.rawValue)  // 64
    /// ```
    public struct TTL: RawRepresentable, Hashable, Sendable, Codable {
        /// The 8-bit raw value
        public let rawValue: UInt8

        /// Creates a TTL value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates a TTL from a raw value
        ///
        /// All 8-bit values are valid TTL values.
        ///
        /// - Parameter rawValue: The TTL value (0-255)
        public init(rawValue: UInt8) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Computed Properties

extension RFC_791.TTL {
    /// Whether this TTL has expired (is zero)
    public var isExpired: Bool {
        rawValue == 0
    }

    /// Returns the TTL after decrementing by one hop
    ///
    /// Returns `nil` if the TTL would become negative.
    public var decremented: RFC_791.TTL? {
        guard rawValue > 0 else { return nil }
        return RFC_791.TTL(__unchecked: (), rawValue: rawValue - 1)
    }
}

// MARK: - Common Values

extension RFC_791.TTL {
    /// Default TTL for Linux/macOS (64)
    public static let default64 = RFC_791.TTL(__unchecked: (), rawValue: 64)

    /// Default TTL for Windows (128)
    public static let default128 = RFC_791.TTL(__unchecked: (), rawValue: 128)

    /// Maximum TTL (255)
    public static let maximum = RFC_791.TTL(__unchecked: (), rawValue: 255)

    /// Expired TTL (0)
    public static let expired = RFC_791.TTL(__unchecked: (), rawValue: 0)

    /// TTL of 1 (link-local only)
    public static let linkLocal = RFC_791.TTL(__unchecked: (), rawValue: 1)
}

// MARK: - Byte Parsing

extension RFC_791.TTL {
    /// Creates a TTL from bytes
    ///
    /// - Parameter bytes: Binary data containing the TTL
    /// - Throws: `Error` if the input is empty
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        guard let firstByte = bytes.first else {
            throw .empty
        }

        self.init(__unchecked: (), rawValue: firstByte)
    }
}

// MARK: - UInt8.Serializable Conformance

extension RFC_791.TTL: UInt8.Serializable {
    /// Serialize to a byte buffer
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(rawValue)
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.TTL: CustomStringConvertible {
    public var description: String {
        "TTL(\(rawValue))"
    }
}

// MARK: - Comparable

extension RFC_791.TTL: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension RFC_791.TTL: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt8) {
        self.init(__unchecked: (), rawValue: value)
    }
}
