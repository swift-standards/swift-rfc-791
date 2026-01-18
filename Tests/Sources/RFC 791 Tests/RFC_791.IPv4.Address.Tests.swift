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

@Suite("RFC 791: IPv4 Address Tests")
struct IPv4AddressTests {

    // MARK: - Initialization Tests

    @Test("IPv4 Address from octets")
    func initFromOctets() throws {
        let address = RFC_791.IPv4.Address(192, 168, 1, 1)

        #expect(address.octets.0 == 192)
        #expect(address.octets.1 == 168)
        #expect(address.octets.2 == 1)
        #expect(address.octets.3 == 1)
    }

    @Test("IPv4 Address from raw value")
    func initFromRawValue() throws {
        // 192.168.1.1 = 0xC0A80101
        let address = RFC_791.IPv4.Address(rawValue: 0xC0A8_0101)

        let (a, b, c, d) = address.octets
        #expect(a == 192)
        #expect(b == 168)
        #expect(c == 1)
        #expect(d == 1)
    }

    @Test("IPv4 Address from string - valid")
    func initFromStringValid() throws {
        let address: RFC_791.IPv4.Address = try .init("192.168.1.1")

        #expect(address.octets.0 == 192)
        #expect(address.octets.1 == 168)
        #expect(address.octets.2 == 1)
        #expect(address.octets.3 == 1)
    }

    @Test("IPv4 Address from string - edge cases")
    func initFromStringEdgeCases() throws {
        // All zeros
        let zeros: RFC_791.IPv4.Address = try .init("0.0.0.0")
        #expect(zeros.rawValue == 0)

        // All 255s
        let broadcast: RFC_791.IPv4.Address = try .init("255.255.255.255")
        #expect(broadcast.rawValue == 0xFFFF_FFFF)

        // Localhost
        let localhost: RFC_791.IPv4.Address = try .init("127.0.0.1")
        #expect(localhost.octets.0 == 127)
        #expect(localhost.octets.3 == 1)
    }

    @Test("IPv4 Address from string - invalid format")
    func initFromStringInvalidFormat() throws {
        let invalid1 = "192.168.1"
        #expect(throws: RFC_791.IPv4.Address.Error.self) {
            let _: RFC_791.IPv4.Address = try .init(invalid1)
        }

        let invalid2 = "192.168.1.1.1"
        #expect(throws: RFC_791.IPv4.Address.Error.self) {
            let _: RFC_791.IPv4.Address = try .init(invalid2)
        }

        let invalid3 = "not.an.ip.address"
        #expect(throws: RFC_791.IPv4.Address.Error.self) {
            let _: RFC_791.IPv4.Address = try .init(invalid3)
        }
    }

    @Test("IPv4 Address from string - out of range")
    func initFromStringOutOfRange() throws {
        let outOfRange1 = "256.0.0.1"
        #expect(throws: RFC_791.IPv4.Address.Error.self) {
            let _: RFC_791.IPv4.Address = try .init(outOfRange1)
        }

        let outOfRange2 = "192.168.1.300"
        #expect(throws: RFC_791.IPv4.Address.Error.self) {
            let _: RFC_791.IPv4.Address = try .init(outOfRange2)
        }

        let outOfRange3 = "-1.0.0.1"
        #expect(throws: RFC_791.IPv4.Address.Error.self) {
            let _: RFC_791.IPv4.Address = try .init(outOfRange3)
        }
    }

    @Test("IPv4 Address from string literal")
    func initStringLiteral() throws {
        let address: RFC_791.IPv4.Address = "192.168.1.1"
        #expect(address.description == "192.168.1.1")
    }

    // MARK: - String Conversion Tests

    @Test("IPv4 Address description")
    func description() throws {
        let address = RFC_791.IPv4.Address(192, 168, 1, 1)
        #expect(address.description == "192.168.1.1")

        let zeros = RFC_791.IPv4.Address(0, 0, 0, 0)
        #expect(zeros.description == "0.0.0.0")

        let broadcast = RFC_791.IPv4.Address(255, 255, 255, 255)
        #expect(broadcast.description == "255.255.255.255")
    }

    @Test("IPv4 Address round-trip through string")
    func roundTripString() throws {
        let original = "192.168.1.1"
        let address: RFC_791.IPv4.Address = try .init(original)
        let serialized = address.description

        #expect(serialized == original)
    }

    // MARK: - Equality Tests

    @Test("IPv4 Address equality")
    func equality() throws {
        let addr1 = RFC_791.IPv4.Address(192, 168, 1, 1)
        let addr2 = RFC_791.IPv4.Address(192, 168, 1, 1)
        let addr3 = RFC_791.IPv4.Address(192, 168, 1, 2)

        #expect(addr1 == addr2)
        #expect(addr1 != addr3)
    }

    @Test("IPv4 Address hashable")
    func hashable() throws {
        let addr1 = RFC_791.IPv4.Address(192, 168, 1, 1)
        let addr2 = RFC_791.IPv4.Address(192, 168, 1, 1)
        let addr3 = RFC_791.IPv4.Address(192, 168, 1, 2)

        var set: Set<RFC_791.IPv4.Address> = []
        set.insert(addr1)
        set.insert(addr2)
        set.insert(addr3)

        #expect(set.count == 2)
        #expect(set.contains(addr1))
        #expect(set.contains(addr3))
    }

    // MARK: - Comparison Tests

    @Test("IPv4 Address comparable")
    func comparable() throws {
        let addr1 = RFC_791.IPv4.Address(192, 168, 1, 1)
        let addr2 = RFC_791.IPv4.Address(192, 168, 1, 10)
        let addr3 = RFC_791.IPv4.Address(192, 168, 2, 1)

        #expect(addr1 < addr2)
        #expect(addr2 < addr3)
        #expect(addr1 < addr3)
    }

    @Test("IPv4 Address sorting")
    func sorting() throws {
        let addresses = [
            RFC_791.IPv4.Address(192, 168, 1, 100),
            RFC_791.IPv4.Address(192, 168, 1, 1),
            RFC_791.IPv4.Address(192, 168, 1, 50),
            RFC_791.IPv4.Address(10, 0, 0, 1),
        ]

        let sorted = addresses.sorted()

        #expect(sorted[0].description == "10.0.0.1")
        #expect(sorted[1].description == "192.168.1.1")
        #expect(sorted[2].description == "192.168.1.50")
        #expect(sorted[3].description == "192.168.1.100")
    }

    @Test("IPv4 Address range operations")
    func rangeOperations() throws {
        let start = RFC_791.IPv4.Address(192, 168, 1, 1)
        let end = RFC_791.IPv4.Address(192, 168, 1, 255)
        let inRange = RFC_791.IPv4.Address(192, 168, 1, 100)
        let outOfRange = RFC_791.IPv4.Address(192, 168, 2, 1)

        #expect(inRange >= start)
        #expect(inRange <= end)
        #expect(outOfRange > end)
    }

    // MARK: - Codable Tests
    // Note: Codable tests removed as Foundation is not available
    // Codable conformance exists for compatibility with systems that have Foundation

    // MARK: - Special Addresses Tests

    @Test("IPv4 Address special addresses")
    func specialAddresses() throws {
        // Loopback
        let loopback = RFC_791.IPv4.Address(127, 0, 0, 1)
        #expect(loopback.description == "127.0.0.1")

        // Broadcast
        let broadcast = RFC_791.IPv4.Address(255, 255, 255, 255)
        #expect(broadcast.description == "255.255.255.255")

        // Unspecified
        let unspecified = RFC_791.IPv4.Address(0, 0, 0, 0)
        #expect(unspecified.description == "0.0.0.0")

        // Private network (RFC 1918)
        let private1 = RFC_791.IPv4.Address(10, 0, 0, 1)
        #expect(private1.description == "10.0.0.1")

        let private2 = RFC_791.IPv4.Address(172, 16, 0, 1)
        #expect(private2.description == "172.16.0.1")

        let private3 = RFC_791.IPv4.Address(192, 168, 0, 1)
        #expect(private3.description == "192.168.0.1")
    }

    // MARK: - Raw Value Tests

    @Test("IPv4 Address raw value consistency")
    func rawValueConsistency() throws {
        let address = RFC_791.IPv4.Address(192, 168, 1, 1)
        let fromRaw = RFC_791.IPv4.Address(rawValue: address.rawValue)

        #expect(address == fromRaw)
        #expect(address.octets == fromRaw.octets)
    }

    @Test("IPv4 Address octet extraction")
    func octetExtraction() throws {
        let address = RFC_791.IPv4.Address(rawValue: 0xC0A8_0101)
        let (a, b, c, d) = address.octets

        #expect(a == 0xC0)  // 192
        #expect(b == 0xA8)  // 168
        #expect(c == 0x01)  // 1
        #expect(d == 0x01)  // 1
    }
}
