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

extension RFC_791.TotalLength {
    /// Errors that can occur when parsing a TotalLength value
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input was empty
        case empty

        /// Insufficient bytes (need 2)
        case insufficientBytes

        /// Value is too small (less than minimum header size of 20)
        case tooSmall(UInt16)
    }
}

extension RFC_791.TotalLength.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "TotalLength data cannot be empty"

        case .insufficientBytes:
            return "TotalLength requires 2 bytes"

        case .tooSmall(let value):
            return "TotalLength \(value) is less than minimum header size of 20"
        }
    }
}
