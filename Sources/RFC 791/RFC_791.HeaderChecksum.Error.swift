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

extension RFC_791.HeaderChecksum {
    /// Errors that can occur when parsing a HeaderChecksum value
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input was empty
        case empty

        /// Insufficient bytes (need 2)
        case insufficientBytes
    }
}

extension RFC_791.HeaderChecksum.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "HeaderChecksum data cannot be empty"

        case .insufficientBytes:
            return "HeaderChecksum requires 2 bytes"
        }
    }
}
