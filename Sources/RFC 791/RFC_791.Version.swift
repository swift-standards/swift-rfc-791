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
    /// IP Version (RFC 791)
    ///
    /// A 4-bit field indicating the format of the internet header.
    /// For IPv4, this value is always 4.
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1:
    /// ```
    /// +-----+-----+-----+-----+
    /// | V3  | V2  | V1  | V0  |
    /// +-----+-----+-----+-----+
    ///   0     1     2     3
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let version = RFC_791.Version.v4
    /// print(version.rawValue)  // 4
    /// ```
    public struct Version: RawRepresentable, Hashable, Sendable, Codable {
        /// The 4-bit raw value (0-15)
        public let rawValue: UInt8

        /// Creates a Version value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates a Version from a raw 4-bit value
        ///
        /// - Parameter rawValue: The version number (0-15)
        /// - Returns: `nil` if the value exceeds 15
        public init?(rawValue: UInt8) {
            guard rawValue <= 15 else {
                return nil
            }
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Standard Versions

extension RFC_791.Version {
    /// IPv4 (version 4)
    ///
    /// The standard Internet Protocol version defined by RFC 791.
    public static let v4 = RFC_791.Version(__unchecked: (), rawValue: 4)

    /// IPv6 (version 6)
    ///
    /// Next generation Internet Protocol (RFC 8200).
    /// Note: IPv6 headers have a different format than IPv4.
    public static let v6 = RFC_791.Version(__unchecked: (), rawValue: 6)
}

// MARK: - Byte Parsing

extension RFC_791.Version {
    /// Creates a Version from bytes
    ///
    /// The version is extracted from the upper 4 bits of the first byte.
    ///
    /// - Parameter bytes: Binary data containing the version
    /// - Throws: `Error` if the input is empty
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        guard let firstByte = bytes.first else {
            throw .empty
        }

        // Version is in upper 4 bits
        let version = firstByte >> 4

        self.init(__unchecked: (), rawValue: version)
    }
}

// MARK: - UInt8.Serializable Conformance

extension RFC_791.Version: UInt8.Serializable {
    static public func serialize<Buffer>(
        _ version: RFC_791.Version,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == UInt8 {
        buffer.append(version.rawValue << 4)
    }
}

// MARK: - Computed Properties

extension RFC_791.Version {
    /// Whether this is IPv4 (version 4)
    public var isIPv4: Bool {
        rawValue == 4
    }

    /// Whether this is IPv6 (version 6)
    public var isIPv6: Bool {
        rawValue == 6
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.Version: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 4: return "IPv4"
        case 6: return "IPv6"
        default: return "Version(\(rawValue))"
        }
    }
}

// MARK: - Comparable

extension RFC_791.Version: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
