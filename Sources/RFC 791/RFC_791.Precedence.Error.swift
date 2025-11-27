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

extension RFC_791.Precedence {
    /// Errors that can occur when parsing a Precedence value
    ///
    /// These errors follow the ERR-1 pattern from STANDARD_IMPLEMENTATION_PATTERNS.md,
    /// providing detailed context about parsing failures.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input was empty
        case empty

        /// The value exceeds the valid range (0-7)
        ///
        /// - Parameter value: The invalid value
        case valueOutOfRange(_ value: UInt8)
    }
}

extension RFC_791.Precedence.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Precedence data cannot be empty"

        case .valueOutOfRange(let value):
            return "Precedence value \(value) is out of range (must be 0-7)"
        }
    }
}
