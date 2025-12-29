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

/// Tests that verify code examples in README.md compile and work correctly.
@Suite("README Verification")
struct ReadmeVerificationTests {

    // MARK: - Quick Start Examples

    @Test("Quick Start - Create IPv4 address")
    func quickStartAddress() {
        // Create an IPv4 address from dotted-decimal notation
        let address: RFC_791.IPv4.Address = "192.168.1.1"
        #expect(address.octets == (192, 168, 1, 1))
        #expect(address.class == .c)
    }

    @Test("Quick Start - Header fields")
    func quickStartHeaderFields() {
        // Create header fields
        let ttl = RFC_791.TTL.default64  // 64 hops (Linux/macOS default)
        let proto = IPProtocol.tcp  // Protocol number 6
        let flags = RFC_791.Flags(dontFragment: true, moreFragments: false)

        #expect(ttl.rawValue == 64)
        #expect(proto.rawValue == 6)
        #expect(flags.dontFragment == true)
        #expect(flags.moreFragments == false)
    }

    @Test("Quick Start - Serialize to ASCII bytes")
    func quickStartSerialization() {
        var buffer: [UInt8] = []

        // Address serializes to ASCII (dotted-decimal)
        let address: RFC_791.IPv4.Address = "192.168.1.1"
        address.ascii.serialize(into: &buffer)

        // Verify it produces ASCII dotted-decimal
        #expect(String(ascii: buffer) == "192.168.1.1")
    }

    // MARK: - IPv4 Addresses Examples

    @Test("IPv4 Addresses - Creation methods")
    func ipv4AddressCreation() {
        // From string literal
        let addr1: RFC_791.IPv4.Address = "10.0.0.1"

        // From raw 32-bit value
        let addr2 = RFC_791.IPv4.Address(rawValue: 0xC0A8_0001)  // 192.168.0.1

        // From individual octets
        let addr3 = RFC_791.IPv4.Address(127, 0, 0, 1)

        #expect(addr1.octets == (10, 0, 0, 1))
        #expect(addr2.octets == (192, 168, 0, 1))
        #expect(addr3.octets == (127, 0, 0, 1))
    }

    @Test("IPv4 Addresses - Access octets")
    func ipv4AddressOctets() {
        let addr: RFC_791.IPv4.Address = "10.0.0.1"

        // Access octets
        let (a, b, c, d) = addr.octets
        let description = "\(a).\(b).\(c).\(d)"

        #expect(description == "10.0.0.1")
    }

    @Test("IPv4 Addresses - Classification")
    func ipv4AddressClassification() {
        let addr: RFC_791.IPv4.Address = "10.0.0.1"

        // Address classification (RFC 791 Section 3.2)
        #expect(addr.class == .a)  // 10.x.x.x
        #expect(addr.is.multicast == false)
        #expect(addr.is.reserved == false)
    }

    @Test("IPv4 Addresses - Special addresses")
    func ipv4SpecialAddresses() {
        // Special addresses
        #expect(RFC_791.IPv4.Address.any.rawValue == 0)  // 0.0.0.0
        #expect(RFC_791.IPv4.Address.broadcast.rawValue == 0xFFFF_FFFF)  // 255.255.255.255
        #expect(RFC_791.IPv4.Address.loopback.octets == (127, 0, 0, 1))
    }

    // MARK: - IP Header Fields Examples

    @Test("Header Fields - Version")
    func headerFieldVersion() {
        // Version (4-bit)
        let version = RFC_791.Version.v4
        #expect(version.isIPv4 == true)
    }

    @Test("Header Fields - IHL")
    func headerFieldIHL() {
        // Internet Header Length (4-bit, in 32-bit words)
        let ihl = RFC_791.IHL.minimum  // 5 (20 bytes, no options)
        #expect(ihl.byteLength == 20)
        #expect(ihl.hasOptions == false)
    }

    @Test("Header Fields - TTL")
    func headerFieldTTL() {
        // Time to Live (8-bit)
        let ttl = RFC_791.TTL(rawValue: 64)
        #expect(ttl.isExpired == false)
        #expect(ttl.decremented?.rawValue == 63)
    }

    @Test("Header Fields - Protocol")
    func headerFieldProtocol() {
        // Protocol (8-bit)
        #expect(IPProtocol.icmp.rawValue == 1)
        #expect(IPProtocol.tcp.rawValue == 6)
        #expect(IPProtocol.udp.rawValue == 17)
    }

    @Test("Header Fields - Identification and TotalLength")
    func headerFieldIdentificationAndLength() {
        // Identification (16-bit)
        let id = RFC_791.Identification(rawValue: 0x1234)
        #expect(id.rawValue == 0x1234)

        // Total Length (16-bit)
        let length = RFC_791.TotalLength(rawValue: 1500)!
        #expect(length.maximumDataLength == 1480)  // minus minimum header
    }

    // MARK: - Type of Service Examples

    @Test("Type of Service - Creation and components")
    func typeOfServiceExample() {
        // Create with precedence and flags
        let tos = RFC_791.TypeOfService(
            precedence: .immediate,
            lowDelay: true,
            highThroughput: false,
            highReliability: true
        )

        // Extract components
        #expect(tos.precedence == .immediate)
        #expect(tos.lowDelay == true)
        #expect(tos.highThroughput == false)
        #expect(tos.highReliability == true)
    }

    @Test("Type of Service - Precedence levels")
    func precedenceLevels() {
        // Precedence levels (RFC 791 Section 3.1)
        #expect(RFC_791.Precedence.routine.rawValue == 0)
        #expect(RFC_791.Precedence.priority.rawValue == 1)
        #expect(RFC_791.Precedence.immediate.rawValue == 2)
        #expect(RFC_791.Precedence.flash.rawValue == 3)
        #expect(RFC_791.Precedence.flashOverride.rawValue == 4)
        #expect(RFC_791.Precedence.criticEcp.rawValue == 5)
        #expect(RFC_791.Precedence.internetworkControl.rawValue == 6)
        #expect(RFC_791.Precedence.networkControl.rawValue == 7)
    }

    // MARK: - Fragmentation Examples

    @Test("Fragmentation - Flags")
    func fragmentationFlags() {
        // Fragment flags
        let flags = RFC_791.Flags(dontFragment: false, moreFragments: true)
        #expect(flags.dontFragment == false)
        #expect(flags.moreFragments == true)
    }

    @Test("Fragmentation - Fragment offset")
    func fragmentationOffset() {
        // Fragment offset (13-bit, in 8-octet units)
        let offset = RFC_791.FragmentOffset(rawValue: 185)!
        #expect(offset.byteOffset == 1480)  // typical MTU boundary
        #expect(offset.isFirstFragment == false)

        // Create from byte offset
        let firstFrag = RFC_791.FragmentOffset.fromByteOffset(0)!
        #expect(firstFrag.isFirstFragment == true)
    }

    // MARK: - Header Checksum Examples

    @Test("Header Checksum - Compute")
    func headerChecksumCompute() {
        // Compute checksum for a header (with checksum field zeroed)
        let header: [UInt8] = [
            0x45, 0x00,  // Version, IHL, TOS
            0x00, 0x73,  // Total Length
            0x00, 0x00,  // Identification
            0x40, 0x00,  // Flags, Fragment Offset
            0x40, 0x11,  // TTL, Protocol
            0x00, 0x00,  // Checksum (zero for computation)
            0xC0, 0xA8, 0x00, 0x01,  // Source: 192.168.0.1
            0xC0, 0xA8, 0x00, 0xC7,  // Destination: 192.168.0.199
        ]

        let checksum = RFC_791.HeaderChecksum.compute(over: header)
        #expect(checksum.rawValue == 0xB861)
    }

    @Test("Header Checksum - Verify")
    func headerChecksumVerify() {
        // Verify a header with checksum included
        let completeHeader: [UInt8] = [
            0x45, 0x00, 0x00, 0x73, 0x00, 0x00, 0x40, 0x00,
            0x40, 0x11, 0xB8, 0x61,  // Checksum at bytes 10-11
            0xC0, 0xA8, 0x00, 0x01, 0xC0, 0xA8, 0x00, 0xC7,
        ]

        #expect(RFC_791.HeaderChecksum.verify(header: completeHeader) == true)
    }

    // MARK: - Binary Serialization Examples

    @Test("Binary Serialization - 16-bit and 8-bit fields")
    func binarySerialization() {
        var buffer: [UInt8] = []

        // 16-bit fields (2 bytes each, big-endian)
        RFC_791.TotalLength(rawValue: 1500)!.serialize(into: &buffer)
        #expect(buffer == [0x05, 0xDC])

        RFC_791.Identification(rawValue: 0x1234).serialize(into: &buffer)
        RFC_791.HeaderChecksum(rawValue: 0xABCD).serialize(into: &buffer)

        // 8-bit fields (1 byte each)
        RFC_791.TTL(rawValue: 64).serialize(into: &buffer)
        IPProtocol.tcp.serialize(into: &buffer)

        // Verify sizes (2 + 2 + 2 + 1 + 1 = 8 bytes)
        #expect(buffer.count == 8)
    }

    @Test("Binary Serialization - Address to ASCII")
    func addressSerialization() {
        // Address serializes to ASCII dotted-decimal (variable length)
        let address: RFC_791.IPv4.Address = "192.168.1.1"
        let bytes = [UInt8](ascii: address)

        // Verify ASCII output
        #expect(String(ascii: bytes) == "192.168.1.1")
    }

    // MARK: - Binary Parsing Examples

    @Test("Binary Parsing - Address from ASCII")
    func binaryParsingAddress() throws {
        // Parse address from ASCII dotted-decimal bytes
        let addrBytes: [UInt8] = Array("192.168.1.1".utf8)
        let address = try RFC_791.IPv4.Address(ascii: addrBytes, in: ())
        #expect(address.octets == (192, 168, 1, 1))
    }

    @Test("Binary Parsing - 16-bit fields")
    func binaryParsing16Bit() throws {
        // Parse 16-bit fields from binary
        let lengthBytes: [UInt8] = [0x05, 0xDC]  // 1500
        let length = try RFC_791.TotalLength(bytes: lengthBytes)
        #expect(length.rawValue == 1500)
    }

    @Test("Binary Parsing - Error handling")
    func binaryParsingError() {
        // Parse with error handling
        #expect(throws: RFC_791.TTL.Error.empty) {
            _ = try RFC_791.TTL(bytes: [] as [UInt8])
        }
    }
}
