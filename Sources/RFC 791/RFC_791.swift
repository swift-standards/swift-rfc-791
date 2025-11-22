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

// RFC_791.swift
// swift-rfc-791
//
// RFC 791: Internet Protocol (September 1981)
// https://www.rfc-editor.org/rfc/rfc791.html
//
// This package implements the Internet Protocol specification (RFC 791)
// which defines the IPv4 addressing and packet structure.
//
// Key types:
// - RFC_791.IPv4.Address - IPv4 address with dotted-decimal notation

/// Internet Protocol namespace (RFC 791)
///
/// This namespace contains types representing IPv4 as defined in RFC 791,
/// the foundational Internet Protocol specification from September 1981.
public enum RFC_791 {}

/// IPv4 namespace
///
/// Contains types for IPv4 addressing
extension RFC_791 {
    public enum IPv4 {}
}
