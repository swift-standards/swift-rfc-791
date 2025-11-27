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
    /// IPv4 Address Class (RFC 791)
    ///
    /// The original IPv4 addressing scheme defined five address classes based
    /// on the leading bits of the address. While classless inter-domain routing
    /// (CIDR) has largely superseded classful addressing, understanding address
    /// classes remains important for historical compatibility and certain
    /// network configurations.
    ///
    /// ## Class Definitions
    ///
    /// Per RFC 791 Section 3.2:
    ///
    /// | Class | Leading Bits | First Octet Range | Network/Host Split |
    /// |-------|--------------|-------------------|-------------------|
    /// | A     | 0            | 0-127             | 8/24 bits         |
    /// | B     | 10           | 128-191           | 16/16 bits        |
    /// | C     | 110          | 192-223           | 24/8 bits         |
    /// | D     | 1110         | 224-239           | Multicast         |
    /// | E     | 1111         | 240-255           | Reserved          |
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address = RFC_791.IPv4.Address(192, 168, 1, 1)
    /// print(address.addressClass)  // .classC
    ///
    /// let multicast = RFC_791.IPv4.Address(224, 0, 0, 1)
    /// print(multicast.addressClass)  // .classD
    /// ```
    public enum Class: Sendable, Codable, Hashable {
        /// Class A: Leading bit 0 (0.0.0.0 - 127.255.255.255)
        ///
        /// 8-bit network prefix, 24-bit host identifier.
        /// Supports up to 126 networks with ~16 million hosts each.
        case classA

        /// Class B: Leading bits 10 (128.0.0.0 - 191.255.255.255)
        ///
        /// 16-bit network prefix, 16-bit host identifier.
        /// Supports up to 16,384 networks with ~65,000 hosts each.
        case classB

        /// Class C: Leading bits 110 (192.0.0.0 - 223.255.255.255)
        ///
        /// 24-bit network prefix, 8-bit host identifier.
        /// Supports up to 2 million networks with 254 hosts each.
        case classC

        /// Class D: Leading bits 1110 (224.0.0.0 - 239.255.255.255)
        ///
        /// Reserved for multicast group addresses.
        /// No network/host distinction.
        case classD

        /// Class E: Leading bits 1111 (240.0.0.0 - 255.255.255.255)
        ///
        /// Reserved for experimental use.
        case classE
    }
}

// MARK: - Address Class Detection

extension RFC_791.IPv4.Address {
    /// The address class determined by the leading bits
    ///
    /// Returns the historical address class based on RFC 791's classful
    /// addressing scheme. The class is determined by examining the leading
    /// bits of the first octet.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address = RFC_791.IPv4.Address(10, 0, 0, 1)
    /// print(address.addressClass)  // .classA
    ///
    /// let address2 = RFC_791.IPv4.Address(172, 16, 0, 1)
    /// print(address2.addressClass)  // .classB
    /// ```
    public var addressClass: Class {
        let firstOctet = UInt8((rawValue >> 24) & 0xFF)

        // Check leading bits
        if firstOctet & 0b1000_0000 == 0 {
            // 0xxxxxxx - Class A
            return .classA
        } else if firstOctet & 0b1100_0000 == 0b1000_0000 {
            // 10xxxxxx - Class B
            return .classB
        } else if firstOctet & 0b1110_0000 == 0b1100_0000 {
            // 110xxxxx - Class C
            return .classC
        } else if firstOctet & 0b1111_0000 == 0b1110_0000 {
            // 1110xxxx - Class D (Multicast)
            return .classD
        } else {
            // 1111xxxx - Class E (Reserved)
            return .classE
        }
    }

    /// Whether this address is a multicast address (Class D)
    ///
    /// Multicast addresses are used to send a single packet to multiple
    /// destinations simultaneously.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let multicast = RFC_791.IPv4.Address(224, 0, 0, 1)
    /// print(multicast.isMulticast)  // true
    /// ```
    public var isMulticast: Bool {
        addressClass == .classD
    }

    /// Whether this address is reserved (Class E)
    ///
    /// Class E addresses are reserved for experimental purposes and
    /// should not be used on the public Internet.
    public var isReserved: Bool {
        addressClass == .classE
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.IPv4.Address.Class: CustomStringConvertible {
    public var description: String {
        switch self {
        case .classA: return "Class A"
        case .classB: return "Class B"
        case .classC: return "Class C"
        case .classD: return "Class D (Multicast)"
        case .classE: return "Class E (Reserved)"
        }
    }
}
