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

@Suite("RFC_791.FragmentOffset Tests")
struct FragmentOffsetTests {

    // MARK: - Raw Value Initialization

    @Test("Valid fragment offset values (0-8191) are accepted")
    func validRawValues() {
        #expect(RFC_791.FragmentOffset(rawValue: 0)?.rawValue == 0)
        #expect(RFC_791.FragmentOffset(rawValue: 185)?.rawValue == 185)  // 1480 bytes
        #expect(RFC_791.FragmentOffset(rawValue: 0x1FFF)?.rawValue == 8191)
    }

    @Test("Invalid fragment offset values (>8191) are rejected")
    func invalidRawValues() {
        #expect(RFC_791.FragmentOffset(rawValue: 0x2000) == nil)
        #expect(RFC_791.FragmentOffset(rawValue: 0xFFFF) == nil)
    }

    // MARK: - Static Constants

    @Test("Zero offset constant")
    func zeroConstant() {
        #expect(RFC_791.FragmentOffset.zero.rawValue == 0)
        #expect(RFC_791.FragmentOffset.zero.byteOffset == 0)
        #expect(RFC_791.FragmentOffset.zero.isFirstFragment)
    }

    @Test("Maximum offset constant")
    func maximumConstant() {
        #expect(RFC_791.FragmentOffset.maximum.rawValue == 8191)
        #expect(RFC_791.FragmentOffset.maximum.byteOffset == 65528)
    }

    // MARK: - Computed Properties

    @Test("byteOffset calculation")
    func byteOffsetCalculation() {
        #expect(RFC_791.FragmentOffset(rawValue: 0)?.byteOffset == 0)
        #expect(RFC_791.FragmentOffset(rawValue: 1)?.byteOffset == 8)
        #expect(RFC_791.FragmentOffset(rawValue: 185)?.byteOffset == 1480)  // Typical MTU boundary
        #expect(RFC_791.FragmentOffset(rawValue: 8191)?.byteOffset == 65528)
    }

    @Test("isFirstFragment property")
    func isFirstFragmentProperty() {
        #expect(RFC_791.FragmentOffset(rawValue: 0)?.isFirstFragment == true)
        #expect(RFC_791.FragmentOffset(rawValue: 1)?.isFirstFragment == false)
        #expect(RFC_791.FragmentOffset(rawValue: 185)?.isFirstFragment == false)
    }

    // MARK: - Factory Methods

    @Test("Create from byte offset")
    func createFromByteOffset() {
        #expect(RFC_791.FragmentOffset.fromByteOffset(0)?.rawValue == 0)
        #expect(RFC_791.FragmentOffset.fromByteOffset(8)?.rawValue == 1)
        #expect(RFC_791.FragmentOffset.fromByteOffset(1480)?.rawValue == 185)
        #expect(RFC_791.FragmentOffset.fromByteOffset(65528)?.rawValue == 8191)
    }

    @Test("Create from invalid byte offset")
    func createFromInvalidByteOffset() {
        #expect(RFC_791.FragmentOffset.fromByteOffset(-1) == nil)     // Negative
        #expect(RFC_791.FragmentOffset.fromByteOffset(7) == nil)      // Not divisible by 8
        #expect(RFC_791.FragmentOffset.fromByteOffset(65536) == nil)  // Too large
    }

    // MARK: - Byte Parsing

    @Test("Parse fragment offset from bytes")
    func parseFromBytes() throws {
        // Fragment offset is in lower 13 bits
        let bytes: [UInt8] = [0x00, 0xB9]  // Offset 185
        let offset = try RFC_791.FragmentOffset(bytes: bytes)
        #expect(offset.rawValue == 185)
    }

    @Test("Parse with flags in upper bits")
    func parseWithFlags() throws {
        // Flags DF=1, MF=0 in upper 3 bits, offset 185
        let bytes: [UInt8] = [0x40, 0xB9]  // DF set, offset 185
        let offset = try RFC_791.FragmentOffset(bytes: bytes)
        #expect(offset.rawValue == 185)  // Flags should be masked out
    }

    @Test("Parse maximum offset from bytes")
    func parseMaxFromBytes() throws {
        let bytes: [UInt8] = [0x1F, 0xFF]  // Maximum 13-bit value
        let offset = try RFC_791.FragmentOffset(bytes: bytes)
        #expect(offset.rawValue == 8191)
    }

    @Test("Parse from empty bytes throws error")
    func parseEmptyBytesThrows() {
        let bytes: [UInt8] = []
        #expect(throws: RFC_791.FragmentOffset.Error.empty) {
            try RFC_791.FragmentOffset(bytes: bytes)
        }
    }

    @Test("Parse from insufficient bytes throws error")
    func parseInsufficientBytesThrows() {
        let bytes: [UInt8] = [0x00]
        #expect(throws: RFC_791.FragmentOffset.Error.insufficientBytes) {
            try RFC_791.FragmentOffset(bytes: bytes)
        }
    }

    // MARK: - Serialization

    @Test("Serialize fragment offset to bytes")
    func serializeToBytes() {
        var buffer: [UInt8] = []
        RFC_791.FragmentOffset(rawValue: 185)!.serialize(into: &buffer)
        #expect(buffer == [0x00, 0xB9])
    }

    @Test("Serialize maximum offset")
    func serializeMaxOffset() {
        var buffer: [UInt8] = []
        RFC_791.FragmentOffset.maximum.serialize(into: &buffer)
        #expect(buffer == [0x1F, 0xFF])
    }

    @Test("Round-trip serialization")
    func roundTripSerialization() throws {
        let original = RFC_791.FragmentOffset(rawValue: 370)!  // 2960 bytes
        var buffer: [UInt8] = []
        original.serialize(into: &buffer)

        let parsed = try RFC_791.FragmentOffset(bytes: buffer)
        #expect(parsed == original)
    }

    // MARK: - CustomStringConvertible

    @Test("Description format")
    func descriptionFormat() {
        #expect(RFC_791.FragmentOffset(rawValue: 0)?.description == "FragmentOffset(0 = 0 bytes)")
        #expect(RFC_791.FragmentOffset(rawValue: 185)?.description == "FragmentOffset(185 = 1480 bytes)")
    }

    // MARK: - Comparable

    @Test("Fragment offsets are comparable")
    func comparable() {
        #expect(RFC_791.FragmentOffset.zero < RFC_791.FragmentOffset.maximum)
        #expect(RFC_791.FragmentOffset(rawValue: 100)! < RFC_791.FragmentOffset(rawValue: 200)!)
    }

    // MARK: - Error Tests

    @Test("Error descriptions")
    func errorDescriptions() {
        #expect(RFC_791.FragmentOffset.Error.empty.description == "FragmentOffset data cannot be empty")
        #expect(RFC_791.FragmentOffset.Error.insufficientBytes.description == "FragmentOffset requires 2 bytes")
    }
}
