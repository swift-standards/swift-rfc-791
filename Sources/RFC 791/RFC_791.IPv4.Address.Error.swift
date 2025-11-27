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

extension RFC_791.IPv4.Address {
    /// Errors that can occur when parsing an IPv4 address
    ///
    /// These errors follow the ERR-1 pattern from STANDARD_IMPLEMENTATION_PATTERNS.md,
    /// providing detailed context about parsing failures.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input was empty
        case empty

        /// The input format is invalid (wrong number of octets)
        ///
        /// - Parameter value: The invalid input string
        case invalidFormat(_ value: String)

        /// An octet contains invalid characters
        ///
        /// - Parameters:
        ///   - value: The full input string
        ///   - byte: The invalid byte encountered
        ///   - position: The octet position (0-3)
        case invalidCharacter(_ value: String, byte: UInt8, position: Int)

        /// An octet value is out of the valid range (0-255)
        ///
        /// - Parameters:
        ///   - value: The parsed numeric value
        ///   - position: The octet position (0-3)
        case octetOutOfRange(_ value: Int, position: Int)

        /// An octet has leading zeros (invalid per strict parsing)
        ///
        /// - Parameters:
        ///   - value: The full input string
        ///   - position: The octet position (0-3)
        case leadingZero(_ value: String, position: Int)
    }
}

extension RFC_791.IPv4.Address.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "IPv4 address cannot be empty"

        case .invalidFormat(let value):
            return "Invalid IPv4 address format '\(value)': expected dotted-decimal"

        case .invalidCharacter(let value, let byte, let position):
            let hex = String(byte, radix: 16, uppercase: true)
            return "Invalid character 0x\(hex) in octet \(position + 1) of '\(value)'"

        case .octetOutOfRange(let value, let position):
            return "Octet \(position + 1) value \(value) is out of range (must be 0-255)"

        case .leadingZero(let value, let position):
            return "Octet \(position + 1) in '\(value)' has invalid leading zero"
        }
    }
}
