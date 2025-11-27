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

extension RFC_791.Version {
    /// Errors that can occur when parsing a Version value
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input was empty
        case empty
    }
}

extension RFC_791.Version.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Version data cannot be empty"
        }
    }
}
