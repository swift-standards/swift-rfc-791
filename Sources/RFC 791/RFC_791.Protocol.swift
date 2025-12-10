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

extension RFC_791 {
    /// IP Protocol Number (RFC 791)
    ///
    /// An 8-bit field indicating the next level protocol used in the data
    /// portion of the IP datagram. Protocol numbers are assigned by IANA.
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1, the Protocol field is a single octet
    /// indicating which upper-layer protocol receives the data.
    ///
    /// ## Common Protocols
    ///
    /// | Number | Protocol |
    /// |--------|----------|
    /// | 1      | ICMP     |
    /// | 6      | TCP      |
    /// | 17     | UDP      |
    /// | 41     | IPv6     |
    ///
    /// ## Example
    ///
    /// ```swift
    /// let proto = RFC_791.`Protocol`.tcp
    /// print(proto.rawValue)  // 6
    ///
    /// // Parse from byte
    /// let proto = RFC_791.`Protocol`(bytes: [0x06])  // TCP
    /// ```
    ///
    /// - Note: `Protocol` is a Swift keyword, so backticks are required
    ///   when using this type directly.
    public struct `Protocol`: RawRepresentable, Hashable, Sendable, Codable {
        /// The 8-bit protocol number
        public let rawValue: UInt8

        /// Creates a Protocol value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates a Protocol from a raw value
        ///
        /// All 8-bit values are valid protocol numbers.
        ///
        /// - Parameter rawValue: The protocol number (0-255)
        public init(rawValue: UInt8) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Common Protocols

extension RFC_791.`Protocol` {
    /// ICMP (Internet Control Message Protocol)
    ///
    /// Protocol number 1. Used for diagnostic and control messages.
    public static let icmp = Self(__unchecked: (), rawValue: 1)

    /// IGMP (Internet Group Management Protocol)
    ///
    /// Protocol number 2. Used for multicast group management.
    public static let igmp = Self(__unchecked: (), rawValue: 2)

    /// TCP (Transmission Control Protocol)
    ///
    /// Protocol number 6. Reliable, ordered, connection-oriented transport.
    public static let tcp = Self(__unchecked: (), rawValue: 6)

    /// UDP (User Datagram Protocol)
    ///
    /// Protocol number 17. Connectionless, best-effort transport.
    public static let udp = Self(__unchecked: (), rawValue: 17)

    /// IPv6 encapsulation
    ///
    /// Protocol number 41. IPv6 packets encapsulated in IPv4.
    public static let ipv6 = Self(__unchecked: (), rawValue: 41)

    /// GRE (Generic Routing Encapsulation)
    ///
    /// Protocol number 47. Tunneling protocol.
    public static let gre = Self(__unchecked: (), rawValue: 47)

    /// ESP (Encapsulating Security Payload)
    ///
    /// Protocol number 50. IPsec encryption.
    public static let esp = Self(__unchecked: (), rawValue: 50)

    /// AH (Authentication Header)
    ///
    /// Protocol number 51. IPsec authentication.
    public static let ah = Self(__unchecked: (), rawValue: 51)

    /// ICMPv6 (ICMP for IPv6)
    ///
    /// Protocol number 58. Control messages for IPv6.
    public static let icmpv6 = Self(__unchecked: (), rawValue: 58)

    /// SCTP (Stream Control Transmission Protocol)
    ///
    /// Protocol number 132. Message-oriented transport.
    public static let sctp = Self(__unchecked: (), rawValue: 132)
}

// MARK: - Byte Parsing

extension RFC_791.`Protocol` {
    /// Creates a Protocol from bytes
    ///
    /// This is the canonical parsing transformation for binary data.
    ///
    /// ## Category Theory
    ///
    /// Parsing transformation:
    /// - **Domain**: Collection<UInt8> (bytes)
    /// - **Codomain**: RFC_791.Protocol (structured data)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let proto = try RFC_791.`Protocol`(bytes: [0x06])
    /// print(proto == .tcp)  // true
    /// ```
    ///
    /// - Parameter bytes: Binary data containing the protocol number
    /// - Throws: `Error` if the input is empty
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        guard let firstByte = bytes.first else {
            throw .empty
        }

        self.init(__unchecked: (), rawValue: firstByte)
    }
}

// MARK: - Binary.Serializable Conformance

extension RFC_791.`Protocol`: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ proto: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(proto.rawValue)
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.`Protocol`: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 1: return "ICMP"
        case 2: return "IGMP"
        case 6: return "TCP"
        case 17: return "UDP"
        case 41: return "IPv6"
        case 47: return "GRE"
        case 50: return "ESP"
        case 51: return "AH"
        case 58: return "ICMPv6"
        case 132: return "SCTP"
        default: return "Protocol(\(rawValue))"
        }
    }
}

// MARK: - [UInt8] Conversion

extension [UInt8] {
    /// Creates byte representation of a Protocol field
    ///
    /// Writes the protocol number.
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.Protocol → [UInt8]
    ///
    /// - Parameter proto: The Protocol value to serialize
    public init(_ proto: RFC_791.`Protocol`) {
        self = [proto.rawValue]
    }
}
