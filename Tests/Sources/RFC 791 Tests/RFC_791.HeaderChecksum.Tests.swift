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

@Suite("RFC_791.HeaderChecksum Tests")
struct HeaderChecksumTests {

    // MARK: - Raw Value Initialization

    @Test("All 16-bit values are valid checksums")
    func allValuesValid() {
        #expect(RFC_791.HeaderChecksum(rawValue: 0).rawValue == 0)
        #expect(RFC_791.HeaderChecksum(rawValue: 0xFFFF).rawValue == 65535)
        #expect(RFC_791.HeaderChecksum(rawValue: 0xB861).rawValue == 0xB861)
    }

    // MARK: - Static Constants

    @Test("Zero constant")
    func zeroConstant() {
        #expect(RFC_791.HeaderChecksum.zero.rawValue == 0)
    }

    // MARK: - Checksum Computation

    @Test("Compute checksum for simple header")
    func computeChecksum() {
        // Example from RFC 1071: Simple header with checksum field zeroed
        // 4500 0073 0000 4000 4011 [0000] c0a8 0001 c0a8 00c7
        let header: [UInt8] = [
            0x45, 0x00,  // Version, IHL, TOS
            0x00, 0x73,  // Total Length
            0x00, 0x00,  // Identification
            0x40, 0x00,  // Flags, Fragment Offset
            0x40, 0x11,  // TTL, Protocol
            0x00, 0x00,  // Checksum (zero for computation)
            0xC0, 0xA8, 0x00, 0x01,  // Source IP (192.168.0.1)
            0xC0, 0xA8, 0x00, 0xC7,  // Destination IP (192.168.0.199)
        ]

        let checksum = RFC_791.HeaderChecksum.compute(over: header)
        #expect(checksum.rawValue == 0xB861)
    }

    @Test("Verify valid checksum")
    func verifyValidChecksum() {
        // Same header with correct checksum included
        let header: [UInt8] = [
            0x45, 0x00,
            0x00, 0x73,
            0x00, 0x00,
            0x40, 0x00,
            0x40, 0x11,
            0xB8, 0x61,  // Correct checksum
            0xC0, 0xA8, 0x00, 0x01,
            0xC0, 0xA8, 0x00, 0xC7,
        ]

        #expect(RFC_791.HeaderChecksum.verify(header: header))
    }

    @Test("Verify invalid checksum")
    func verifyInvalidChecksum() {
        let header: [UInt8] = [
            0x45, 0x00,
            0x00, 0x73,
            0x00, 0x00,
            0x40, 0x00,
            0x40, 0x11,
            0x00, 0x00,  // Wrong checksum
            0xC0, 0xA8, 0x00, 0x01,
            0xC0, 0xA8, 0x00, 0xC7,
        ]

        #expect(!RFC_791.HeaderChecksum.verify(header: header))
    }

    @Test("Compute checksum for all zeros")
    func computeAllZeros() {
        let header: [UInt8] = Array(repeating: 0, count: 20)
        let checksum = RFC_791.HeaderChecksum.compute(over: header)
        #expect(checksum.rawValue == 0xFFFF)
    }

    @Test("Compute checksum for all ones")
    func computeAllOnes() {
        var header: [UInt8] = Array(repeating: 0xFF, count: 20)
        // Zero out checksum field (bytes 10-11)
        header[10] = 0
        header[11] = 0
        let checksum = RFC_791.HeaderChecksum.compute(over: header)
        // Sum of 9 words of 0xFFFF plus one 0x0000
        // = 9 * 0xFFFF = 0x8FFF7
        // Folding: 0x8FFF7 = 0x8 carry + 0xFFF7 = 0xFFFF
        // One's complement of 0xFFFF = 0x0000
        #expect(checksum.rawValue == 0x0000)
    }

    // MARK: - Byte Parsing

    @Test("Parse checksum from bytes (big-endian)")
    func parseFromBytes() throws {
        let bytes: [UInt8] = [0xB8, 0x61]
        let checksum = try RFC_791.HeaderChecksum(bytes: bytes)
        #expect(checksum.rawValue == 0xB861)
    }

    @Test("Parse from empty bytes throws error")
    func parseEmptyBytesThrows() {
        let bytes: [UInt8] = []
        #expect(throws: RFC_791.HeaderChecksum.Error.empty) {
            try RFC_791.HeaderChecksum(bytes: bytes)
        }
    }

    @Test("Parse from insufficient bytes throws error")
    func parseInsufficientBytesThrows() {
        let bytes: [UInt8] = [0xB8]
        #expect(throws: RFC_791.HeaderChecksum.Error.insufficientBytes) {
            try RFC_791.HeaderChecksum(bytes: bytes)
        }
    }

    // MARK: - Serialization

    @Test("Serialize checksum to bytes (big-endian)")
    func serializeToBytes() {
        var buffer: [UInt8] = []
        RFC_791.HeaderChecksum(rawValue: 0xB861).serialize(into: &buffer)
        #expect(buffer == [0xB8, 0x61])
    }

    @Test("Round-trip serialization")
    func roundTripSerialization() throws {
        let original = RFC_791.HeaderChecksum(rawValue: 0x1234)
        var buffer: [UInt8] = []
        original.serialize(into: &buffer)

        let parsed = try RFC_791.HeaderChecksum(bytes: buffer)
        #expect(parsed == original)
    }

    // MARK: - CustomStringConvertible

    @Test("Description format (hexadecimal)")
    func descriptionFormat() {
        #expect(RFC_791.HeaderChecksum(rawValue: 0xB861).description == "0xB861")
        #expect(RFC_791.HeaderChecksum(rawValue: 0x0001).description == "0x1")
        #expect(RFC_791.HeaderChecksum(rawValue: 0xFFFF).description == "0xFFFF")
    }

    // MARK: - Error Tests

    @Test("Error descriptions")
    func errorDescriptions() {
        let emptyDesc = RFC_791.HeaderChecksum.Error.empty.description
        #expect(emptyDesc == "HeaderChecksum data cannot be empty")
        let insufficientDesc = RFC_791.HeaderChecksum.Error.insufficientBytes.description
        #expect(insufficientDesc == "HeaderChecksum requires 2 bytes")
    }
}
