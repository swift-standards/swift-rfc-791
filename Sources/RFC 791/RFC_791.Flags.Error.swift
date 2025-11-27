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

extension RFC_791.Flags {
    /// Errors that can occur when parsing IP Flags
    ///
    /// These errors follow the ERR-1 pattern from STANDARD_IMPLEMENTATION_PATTERNS.md,
    /// providing detailed context about parsing failures.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input was empty
        case empty

        /// The reserved bit (bit 0) is set when it must be zero
        ///
        /// - Parameter value: The invalid raw value
        case reservedBitSet(_ value: UInt8)
    }
}

extension RFC_791.Flags.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "IP Flags data cannot be empty"

        case .reservedBitSet(let value):
            let hex = String(value, radix: 16, uppercase: true)
            return "IP Flags value 0x\(hex) has reserved bit set (bit 0 must be zero)"
        }
    }
}
