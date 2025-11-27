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

extension RFC_791.IHL {
    /// Errors that can occur when parsing an IHL value
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input was empty
        case empty

        /// The IHL value is less than the minimum (5)
        ///
        /// - Parameter value: The invalid IHL value
        case tooSmall(_ value: UInt8)
    }
}

extension RFC_791.IHL.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "IHL data cannot be empty"

        case .tooSmall(let value):
            return "IHL value \(value) is too small (minimum is 5)"
        }
    }
}
