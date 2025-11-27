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

/// RFC 791: Internet Protocol
///
/// This namespace implements the Internet Protocol (IP) specification as defined
/// in RFC 791 (September 1981), edited by Jon Postel. IP provides the foundation
/// for datagram transmission across interconnected networks.
///
/// ## Key Types
///
/// - ``IPv4``: IPv4 protocol namespace
/// - ``IPv4/Address``: 32-bit IPv4 address with dotted-decimal notation
/// - ``IPv4/Address/Class-swift.enum``: Address class (A, B, C, D, E)
/// - ``TypeOfService``: Quality of service indicators (8-bit)
/// - ``Precedence``: Traffic precedence levels (3-bit)
/// - ``Flags``: Fragmentation control flags (3-bit)
/// - ``Protocol``: Upper-layer protocol identifiers (8-bit)
///
/// ## Protocol Overview
///
/// Per RFC 791, IP implements two primary mechanisms:
/// 1. **Addressing**: 32-bit addresses identify sources and destinations
/// 2. **Fragmentation**: Datagrams can be divided for smaller MTU networks
///
/// ## Example
///
/// ```swift
/// // Parse an IPv4 address from dotted-decimal notation
/// let address = try RFC_791.IPv4.Address(ascii: Array("192.168.1.1".utf8))
///
/// // Check address class
/// print(address.addressClass)  // .classC
///
/// // Create from octets
/// let localhost = RFC_791.IPv4.Address(127, 0, 0, 1)
///
/// // Type of Service
/// let tos = RFC_791.TypeOfService(
///     precedence: .immediate,
///     lowDelay: true
/// )
/// ```
///
/// ## See Also
///
/// - [RFC 791](https://www.rfc-editor.org/rfc/rfc791)
public enum RFC_791 {}

extension RFC_791 {
    /// IPv4 protocol namespace
    ///
    /// Contains types for IPv4 addressing and header fields as defined in RFC 791.
    public enum IPv4 {}
}
