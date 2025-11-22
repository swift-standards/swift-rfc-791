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

// RFC_791.IPv4.Address.swift
// swift-rfc-791
//
// RFC 791: Internet Protocol - IPv4 Address
// https://www.rfc-editor.org/rfc/rfc791.html
//
// Defines the 32-bit IPv4 address structure

import INCITS_4_1986
import Standards

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
    /// // Parse from dotted-decimal notation
    /// let address = try RFC_791.IPv4.Address("192.168.1.1")
    ///
    /// // Create from octets
    /// let address = RFC_791.IPv4.Address(192, 168, 1, 1)
    ///
    /// // Create from UInt32
    /// let address = RFC_791.IPv4.Address(rawValue: 0xC0A80101)
    ///
    /// // Serialize to string
    /// let string = address.description  // "192.168.1.1"
    /// ```
    public struct Address: Hashable, Sendable {
        /// The 32-bit address value in network byte order (big-endian)
        public let rawValue: UInt32

        /// Creates an IPv4 address from a 32-bit value
        ///
        /// - Parameter rawValue: The 32-bit address in network byte order
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
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
        self.rawValue =
            UInt32(octet1) << 24 |
            UInt32(octet2) << 16 |
            UInt32(octet3) << 8 |
            UInt32(octet4)
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

// MARK: - String Parsing (Dotted-Decimal Notation)

extension RFC_791.IPv4.Address {
    /// Parsing errors for IPv4 addresses
    public enum ParseError: Error, Equatable {
        case invalidFormat
        case invalidOctet(String)
        case octetOutOfRange(Int)
    }

    /// Creates an IPv4 address from a dotted-decimal string
    ///
    /// Parses a string in the format "a.b.c.d" where each component is a decimal
    /// number from 0 to 255.
    ///
    /// - Parameter string: A dotted-decimal IPv4 address string
    /// - Throws: `ParseError` if the string format is invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address = try RFC_791.IPv4.Address("192.168.1.1")
    /// ```
    public init(_ string: some StringProtocol) throws {
        let components = string.split(separator: ".")

        guard components.count == 4 else {
            throw ParseError.invalidFormat
        }

        var octets: [UInt8] = []
        octets.reserveCapacity(4)

        for component in components {
            // Convert substring to string for parsing
            guard let value = Int(component) else {
                throw ParseError.invalidOctet(String(component))
            }

            guard (0...255).contains(value) else {
                throw ParseError.octetOutOfRange(value)
            }

            octets.append(UInt8(value))
        }

        self.init(octets[0], octets[1], octets[2], octets[3])
    }
}

// MARK: - String Conversion

extension RFC_791.IPv4.Address: CustomStringConvertible {
    /// Returns the dotted-decimal string representation
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address = RFC_791.IPv4.Address(192, 168, 1, 1)
    /// print(address.description)  // "192.168.1.1"
    /// ```
    public var description: String { .init(self) }
}

extension String {
    /// Creates a string representation of an IPv4 address
    ///
    /// This is a convenience transformation that composes through the canonical
    /// byte representation:
    /// ```
    /// IPv4.Address → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Category Theory
    ///
    /// This is functor composition - the String transformation is derived from
    /// the more universal [UInt8] transformation. ASCII is a subset of UTF-8,
    /// so this conversion is always safe.
    ///
    /// - Parameter address: The IPv4 address to represent
    public init(
        _ address: RFC_791.IPv4.Address
    ) {
        // Compose through canonical byte representation
        // ASCII ⊂ UTF-8, so this is always valid
        self.init(decoding: [UInt8](ascii: address), as: UTF8.self)
    }
}

// MARK: - Codable

extension RFC_791.IPv4.Address: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

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

// MARK: - ExpressibleByStringLiteral

extension RFC_791.IPv4.Address: ExpressibleByStringLiteral {
    /// Creates an IPv4 address from a string literal
    ///
    /// Allows creating addresses using string literal syntax. Invalid addresses
    /// will cause a runtime error.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address: RFC_791.IPv4.Address = "192.168.1.1"
    /// ```
    public init(stringLiteral value: String) {
        do {
            try self.init(value)
        } catch {
            fatalError("Invalid IPv4 address literal: \(value)")
        }
    }
}
