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

extension RFC_791.TypeOfService {
    /// Errors that can occur when parsing a Type of Service value
    ///
    /// These errors follow the ERR-1 pattern from STANDARD_IMPLEMENTATION_PATTERNS.md,
    /// providing detailed context about parsing failures.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input was empty
        case empty

        /// Reserved bits (6-7) are set when they must be zero
        ///
        /// - Parameter value: The invalid raw value
        case reservedBitsSet(_ value: UInt8)
    }
}

extension RFC_791.TypeOfService.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Type of Service data cannot be empty"

        case .reservedBitsSet(let value):
            return "Type of Service value 0x\(String(value, radix: 16, uppercase: true)) has reserved bits set (bits 6-7 must be zero)"
        }
    }
}
