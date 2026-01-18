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

@Suite("RFC 791: Type of Service Tests")
struct TypeOfServiceTests {

    // MARK: - Initialization Tests

    @Test("TypeOfService from raw value - valid")
    func initFromRawValueValid() {
        // Valid: reserved bits (6-7) are zero
        let tos = RFC_791.TypeOfService(rawValue: 0b1110_0100)
        #expect(tos != nil)
        #expect(tos?.rawValue == 0b1110_0100)
    }

    @Test("TypeOfService from raw value - invalid (reserved bits set)")
    func initFromRawValueInvalid() {
        // Invalid: reserved bit 0 set
        #expect(RFC_791.TypeOfService(rawValue: 0b0000_0001) == nil)
        // Invalid: reserved bit 1 set
        #expect(RFC_791.TypeOfService(rawValue: 0b0000_0010) == nil)
        // Invalid: both reserved bits set
        #expect(RFC_791.TypeOfService(rawValue: 0b0000_0011) == nil)
    }

    @Test("TypeOfService from components")
    func initFromComponents() {
        let tos = RFC_791.TypeOfService(
            precedence: .immediate,
            lowDelay: true,
            highThroughput: false,
            highReliability: true
        )

        #expect(tos.precedence == .immediate)
        #expect(tos.lowDelay == true)
        #expect(tos.highThroughput == false)
        #expect(tos.highReliability == true)
    }

    @Test("TypeOfService default values")
    func initDefaultValues() {
        let tos = RFC_791.TypeOfService()

        #expect(tos.precedence == .routine)
        #expect(tos.lowDelay == false)
        #expect(tos.highThroughput == false)
        #expect(tos.highReliability == false)
    }

    // MARK: - Component Access Tests

    @Test("TypeOfService precedence extraction")
    func precedenceExtraction() {
        // Precedence in bits 0-2 (most significant)
        // 0b111_00000 = Network Control (7)
        let tos = RFC_791.TypeOfService(rawValue: 0b1110_0000)!
        #expect(tos.precedence == .networkControl)

        // 0b010_00000 = Immediate (2)
        let tos2 = RFC_791.TypeOfService(rawValue: 0b0100_0000)!
        #expect(tos2.precedence == .immediate)
    }

    @Test("TypeOfService flag extraction")
    func flagExtraction() {
        // Bit 3 = Low Delay (0b0001_0000)
        let lowDelay = RFC_791.TypeOfService(rawValue: 0b0001_0000)!
        #expect(lowDelay.lowDelay == true)
        #expect(lowDelay.highThroughput == false)
        #expect(lowDelay.highReliability == false)

        // Bit 4 = High Throughput (0b0000_1000)
        let highThroughput = RFC_791.TypeOfService(rawValue: 0b0000_1000)!
        #expect(highThroughput.lowDelay == false)
        #expect(highThroughput.highThroughput == true)
        #expect(highThroughput.highReliability == false)

        // Bit 5 = High Reliability (0b0000_0100)
        let highReliability = RFC_791.TypeOfService(rawValue: 0b0000_0100)!
        #expect(highReliability.lowDelay == false)
        #expect(highReliability.highThroughput == false)
        #expect(highReliability.highReliability == true)

        // All flags set
        let allFlags = RFC_791.TypeOfService(rawValue: 0b0001_1100)!
        #expect(allFlags.lowDelay == true)
        #expect(allFlags.highThroughput == true)
        #expect(allFlags.highReliability == true)
    }

    // MARK: - Static Constants Tests

    @Test("TypeOfService static constants")
    func staticConstants() {
        #expect(RFC_791.TypeOfService.default.rawValue == 0)
        #expect(RFC_791.TypeOfService.minimizeDelay.lowDelay == true)
        #expect(RFC_791.TypeOfService.maximizeThroughput.highThroughput == true)
        #expect(RFC_791.TypeOfService.maximizeReliability.highReliability == true)
    }

    // MARK: - Byte Parsing Tests

    @Test("TypeOfService from bytes - valid")
    func initFromBytesValid() throws {
        let tos = try RFC_791.TypeOfService(bytes: [0b0101_1100])
        #expect(tos.precedence == .immediate)
        #expect(tos.lowDelay == true)
        #expect(tos.highThroughput == true)
        #expect(tos.highReliability == true)
    }

    @Test("TypeOfService from bytes - empty")
    func initFromBytesEmpty() {
        #expect(throws: RFC_791.TypeOfService.Error.self) {
            _ = try RFC_791.TypeOfService(bytes: [] as [UInt8])
        }
    }

    @Test("TypeOfService from bytes - reserved bits set")
    func initFromBytesReservedBits() {
        #expect(throws: RFC_791.TypeOfService.Error.self) {
            _ = try RFC_791.TypeOfService(bytes: [0b0000_0001])
        }
    }

    // MARK: - Serialization Tests

    @Test("TypeOfService serialization")
    func serialization() {
        let tos = RFC_791.TypeOfService(
            precedence: .flash,
            lowDelay: true,
            highThroughput: false,
            highReliability: false
        )
        var buffer: [UInt8] = []
        tos.serialize(into: &buffer)

        // Flash (3) = 0b011, Low Delay = 0b1
        // Result: 0b0111_0000 = 0x70
        #expect(buffer == [0x70])
    }

    @Test("TypeOfService bytes property")
    func bytesProperty() {
        let tos = RFC_791.TypeOfService.minimizeDelay
        #expect(tos.bytes == [0b0001_0000])
    }

    // MARK: - Round Trip Tests

    @Test("TypeOfService round trip")
    func roundTrip() throws {
        let original = RFC_791.TypeOfService(
            precedence: .criticEcp,
            lowDelay: true,
            highThroughput: true,
            highReliability: false
        )

        let bytes = original.bytes
        let parsed = try RFC_791.TypeOfService(bytes: bytes)

        #expect(parsed == original)
        #expect(parsed.precedence == .criticEcp)
        #expect(parsed.lowDelay == true)
        #expect(parsed.highThroughput == true)
        #expect(parsed.highReliability == false)
    }

    // MARK: - Equality Tests

    @Test("TypeOfService equality")
    func equality() {
        let tos1 = RFC_791.TypeOfService(precedence: .flash, lowDelay: true)
        let tos2 = RFC_791.TypeOfService(precedence: .flash, lowDelay: true)
        let tos3 = RFC_791.TypeOfService(precedence: .flash, lowDelay: false)

        #expect(tos1 == tos2)
        #expect(tos1 != tos3)
    }

    // MARK: - Hashable Tests

    @Test("TypeOfService hashable")
    func hashable() {
        var set: Set<RFC_791.TypeOfService> = []
        set.insert(.default)
        set.insert(.minimizeDelay)
        set.insert(.default)  // Duplicate

        #expect(set.count == 2)
    }

    // MARK: - Description Tests

    @Test("TypeOfService description")
    func description() {
        let tos = RFC_791.TypeOfService(
            precedence: .immediate,
            lowDelay: true,
            highThroughput: false,
            highReliability: true
        )
        let desc = tos.description
        #expect(desc.contains("Immediate"))
        #expect(desc.contains("LowDelay"))
        #expect(desc.contains("HighReliability"))
        #expect(!desc.contains("HighThroughput"))
    }
}
