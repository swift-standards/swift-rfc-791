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

import Testing

@testable import RFC_791

// Typealias to avoid backtick issues with reserved keyword
private typealias IPProtocol = RFC_791.`Protocol`

@Suite("RFC 791: Protocol Tests")
struct ProtocolTests {

    // MARK: - Initialization Tests

    @Test("Protocol from raw value")
    func initFromRawValue() {
        let proto = IPProtocol(rawValue: 6)
        #expect(proto.rawValue == 6)
        #expect(proto == .tcp)
    }

    @Test("Protocol all values valid")
    func allValuesValid() {
        // All UInt8 values are valid protocol numbers
        for value: UInt8 in 0...255 {
            let proto = IPProtocol(rawValue: value)
            #expect(proto.rawValue == value)
        }
    }

    // MARK: - Static Constants Tests

    @Test("Protocol static constants")
    func staticConstants() {
        #expect(IPProtocol.icmp.rawValue == 1)
        #expect(IPProtocol.igmp.rawValue == 2)
        #expect(IPProtocol.tcp.rawValue == 6)
        #expect(IPProtocol.udp.rawValue == 17)
        #expect(IPProtocol.ipv6.rawValue == 41)
        #expect(IPProtocol.gre.rawValue == 47)
        #expect(IPProtocol.esp.rawValue == 50)
        #expect(IPProtocol.ah.rawValue == 51)
        #expect(IPProtocol.icmpv6.rawValue == 58)
        #expect(IPProtocol.sctp.rawValue == 132)
    }

    // MARK: - Byte Parsing Tests

    @Test("Protocol from bytes - valid")
    func initFromBytesValid() throws {
        let proto = try IPProtocol(bytes: [0x06])
        #expect(proto == .tcp)
    }

    @Test("Protocol from bytes - UDP")
    func initFromBytesUDP() throws {
        let proto = try IPProtocol(bytes: [0x11])
        #expect(proto == .udp)
    }

    @Test("Protocol from bytes - empty")
    func initFromBytesEmpty() {
        #expect(throws: IPProtocol.Error.self) {
            _ = try IPProtocol(bytes: [] as [UInt8])
        }
    }

    @Test("Protocol from bytes - multiple bytes (uses first)")
    func initFromBytesMultiple() throws {
        // Should only use first byte
        let proto = try IPProtocol(bytes: [0x06, 0x11, 0x01])
        #expect(proto == .tcp)
    }

    // MARK: - Serialization Tests

    @Test("Protocol serialization")
    func serialization() {
        let proto = IPProtocol.tcp
        var buffer: [UInt8] = []
        proto.serialize(into: &buffer)
        #expect(buffer == [0x06])
    }

    @Test("Protocol bytes property")
    func bytesProperty() {
        let proto = IPProtocol.udp
        #expect(proto.bytes == [0x11])
    }

    // MARK: - Round Trip Tests

    @Test("Protocol round trip")
    func roundTrip() throws {
        let original = IPProtocol.icmp
        let bytes = original.bytes
        let parsed = try IPProtocol(bytes: bytes)
        #expect(parsed == original)
    }

    @Test("Protocol round trip all values")
    func roundTripAllValues() throws {
        for value: UInt8 in 0...255 {
            let original = IPProtocol(rawValue: value)
            let bytes = original.bytes
            let parsed = try IPProtocol(bytes: bytes)
            #expect(parsed == original)
        }
    }

    // MARK: - Equality Tests

    @Test("Protocol equality")
    func equality() {
        let proto1 = IPProtocol.tcp
        let proto2 = IPProtocol(rawValue: 6)
        let proto3 = IPProtocol.udp

        #expect(proto1 == proto2)
        #expect(proto1 != proto3)
    }

    // MARK: - Hashable Tests

    @Test("Protocol hashable")
    func hashable() {
        var set: Set<IPProtocol> = []
        set.insert(.tcp)
        set.insert(.udp)
        set.insert(.tcp)  // Duplicate

        #expect(set.count == 2)
        #expect(set.contains(.tcp))
        #expect(set.contains(.udp))
    }

    // MARK: - Description Tests

    @Test("Protocol description - known protocols")
    func descriptionKnown() {
        #expect(IPProtocol.icmp.description == "ICMP")
        #expect(IPProtocol.igmp.description == "IGMP")
        #expect(IPProtocol.tcp.description == "TCP")
        #expect(IPProtocol.udp.description == "UDP")
        #expect(IPProtocol.ipv6.description == "IPv6")
        #expect(IPProtocol.gre.description == "GRE")
        #expect(IPProtocol.esp.description == "ESP")
        #expect(IPProtocol.ah.description == "AH")
        #expect(IPProtocol.icmpv6.description == "ICMPv6")
        #expect(IPProtocol.sctp.description == "SCTP")
    }

    @Test("Protocol description - unknown protocols")
    func descriptionUnknown() {
        let proto = IPProtocol(rawValue: 99)
        #expect(proto.description == "Protocol(99)")

        let proto0 = IPProtocol(rawValue: 0)
        #expect(proto0.description == "Protocol(0)")
    }

    // MARK: - Codable Tests

    @Test("Protocol codable")
    func codable() throws {
        let original = IPProtocol.tcp

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(IPProtocol.self, from: data)

        #expect(decoded == original)
    }
}

// Helper for JSON encoding/decoding in tests
import Foundation

private struct JSONEncoder {
    func encode<T: Encodable>(_ value: T) throws -> Data {
        try Foundation.JSONEncoder().encode(value)
    }
}

private struct JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try Foundation.JSONDecoder().decode(type, from: data)
    }
}
