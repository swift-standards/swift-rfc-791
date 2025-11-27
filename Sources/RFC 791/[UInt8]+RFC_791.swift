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

// MARK: - IPv4.Address Serialization

extension [UInt8] {
    /// Creates ASCII byte representation of an IPv4 address (RFC 791 dotted-decimal notation)
    ///
    /// This is the canonical serialization of IPv4 addresses to bytes.
    /// The format is defined by RFC 791 as dotted-decimal notation:
    /// ```
    /// <decimal>.<decimal>.<decimal>.<decimal>
    /// ```
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.IPv4.Address → [UInt8]
    /// ```
    /// IPv4.Address → [UInt8] (ASCII) → String (UTF-8)
    /// ```
    ///
    /// ## Performance
    ///
    /// Direct ASCII generation without intermediate String allocations:
    /// - Pre-allocated capacity (15 bytes max: "255.255.255.255")
    /// - ASCII digit computation via division/modulo
    /// - No string interpolation overhead
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address = RFC_791.IPv4.Address(192, 168, 1, 1)
    /// let bytes = [UInt8](address)
    /// // bytes == [49, 57, 50, 46, 49, 54, 56, 46, 49, 46, 49]
    /// // ASCII:     '1' '9' '2' '.' '1' '6' '8' '.' '1' '.' '1'
    /// ```
    ///
    /// - Parameter address: The IPv4 address to serialize
    public init(_ address: RFC_791.IPv4.Address) {
        let (a, b, c, d) = address.octets

        // Maximum length: "255.255.255.255" = 15 bytes
        self = []
        self.reserveCapacity(15)

        // Helper to append decimal ASCII digits for a UInt8
        func appendDecimal(_ value: UInt8) {
            // Fast path for single digit (0-9)
            if value < 10 {
                self.append(UInt8.ascii.`0` + value)
                return
            }

            // Fast path for two digits (10-99)
            if value < 100 {
                let tens = value / 10
                let ones = value % 10
                self.append(UInt8.ascii.`0` + tens)
                self.append(UInt8.ascii.`0` + ones)
                return
            }

            // Three digits (100-255)
            let hundreds = value / 100
            let remainder = value % 100
            let tens = remainder / 10
            let ones = remainder % 10

            self.append(UInt8.ascii.`0` + hundreds)
            self.append(UInt8.ascii.`0` + tens)
            self.append(UInt8.ascii.`0` + ones)
        }

        // Serialize: <a>.<b>.<c>.<d>
        appendDecimal(a)
        self.append(UInt8.ascii.period)
        appendDecimal(b)
        self.append(UInt8.ascii.period)
        appendDecimal(c)
        self.append(UInt8.ascii.period)
        appendDecimal(d)
    }
}

// MARK: - TypeOfService Serialization

extension [UInt8] {
    /// Creates byte representation of a Type of Service field
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.TypeOfService → [UInt8]
    ///
    /// - Parameter tos: The Type of Service value to serialize
    public init(_ tos: RFC_791.TypeOfService) {
        self = [tos.rawValue]
    }
}

// MARK: - Flags Serialization

extension [UInt8] {
    /// Creates byte representation of IP Flags
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.Flags → [UInt8]
    ///
    /// - Parameter flags: The Flags value to serialize
    public init(_ flags: RFC_791.Flags) {
        self = [flags.rawValue]
    }
}

// MARK: - Protocol Serialization

extension [UInt8] {
    /// Creates byte representation of a Protocol field
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.Protocol → [UInt8]
    ///
    /// - Parameter proto: The Protocol value to serialize
    public init(_ proto: RFC_791.`Protocol`) {
        self = [proto.rawValue]
    }
}

// MARK: - Precedence Serialization

extension [UInt8] {
    /// Creates byte representation of a Precedence value
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
