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

@Suite("RFC_791.IHL Tests")
struct IHLTests {

    // MARK: - Raw Value Initialization

    @Test("Valid IHL values (5-15) are accepted")
    func validRawValues() {
        for value: UInt8 in 5...15 {
            let ihl = RFC_791.IHL(rawValue: value)
            #expect(ihl != nil)
            #expect(ihl?.rawValue == value)
        }
    }

    @Test("Invalid IHL values (<5) are rejected")
    func invalidRawValuesTooSmall() {
        for value: UInt8 in 0..<5 {
            let ihl = RFC_791.IHL(rawValue: value)
            #expect(ihl == nil)
        }
    }

    @Test("Invalid IHL values (>15) are rejected")
    func invalidRawValuesTooLarge() {
        for value: UInt8 in 16...255 {
            let ihl = RFC_791.IHL(rawValue: value)
            #expect(ihl == nil)
        }
    }

    // MARK: - Static Constants

    @Test("Minimum IHL constant")
    func minimumConstant() {
        #expect(RFC_791.IHL.minimum.rawValue == 5)
        #expect(RFC_791.IHL.minimum.byteLength == 20)
    }

    @Test("Maximum IHL constant")
    func maximumConstant() {
        #expect(RFC_791.IHL.maximum.rawValue == 15)
        #expect(RFC_791.IHL.maximum.byteLength == 60)
    }

    // MARK: - Computed Properties

    @Test("byteLength calculation")
    func byteLengthCalculation() {
        #expect(RFC_791.IHL(rawValue: 5)?.byteLength == 20)
        #expect(RFC_791.IHL(rawValue: 6)?.byteLength == 24)
        #expect(RFC_791.IHL(rawValue: 10)?.byteLength == 40)
        #expect(RFC_791.IHL(rawValue: 15)?.byteLength == 60)
    }

    @Test("optionsLength calculation")
    func optionsLengthCalculation() {
        #expect(RFC_791.IHL(rawValue: 5)?.optionsLength == 0)
        #expect(RFC_791.IHL(rawValue: 6)?.optionsLength == 4)
        #expect(RFC_791.IHL(rawValue: 10)?.optionsLength == 20)
        #expect(RFC_791.IHL(rawValue: 15)?.optionsLength == 40)
    }

    @Test("hasOptions property")
    func hasOptionsProperty() {
        #expect(RFC_791.IHL(rawValue: 5)?.hasOptions == false)
        #expect(RFC_791.IHL(rawValue: 6)?.hasOptions == true)
        #expect(RFC_791.IHL(rawValue: 15)?.hasOptions == true)
    }

    // MARK: - Factory Methods

    @Test("Create from byte length")
    func createFromByteLength() {
        #expect(RFC_791.IHL.fromByteLength(20)?.rawValue == 5)
        #expect(RFC_791.IHL.fromByteLength(24)?.rawValue == 6)
        #expect(RFC_791.IHL.fromByteLength(60)?.rawValue == 15)
    }

    @Test("Create from invalid byte length")
    func createFromInvalidByteLength() {
        #expect(RFC_791.IHL.fromByteLength(16) == nil)  // Too small
        #expect(RFC_791.IHL.fromByteLength(64) == nil)  // Too large
        #expect(RFC_791.IHL.fromByteLength(21) == nil)  // Not divisible by 4
    }

    // MARK: - Byte Parsing

    @Test("Parse IHL from bytes")
    func parseFromBytes() throws {
        // IHL is in lower 4 bits
        let bytes: [UInt8] = [0x45]  // Version 4, IHL 5
        let ihl = try RFC_791.IHL(bytes: bytes)
        #expect(ihl.rawValue == 5)
    }

    @Test("Parse IHL 15 from bytes")
    func parseMaxFromBytes() throws {
        let bytes: [UInt8] = [0x4F]  // Version 4, IHL 15
        let ihl = try RFC_791.IHL(bytes: bytes)
        #expect(ihl.rawValue == 15)
    }

    @Test("Parse from empty bytes throws error")
    func parseEmptyBytesThrows() {
        let bytes: [UInt8] = []
        #expect(throws: RFC_791.IHL.Error.empty) {
            try RFC_791.IHL(bytes: bytes)
        }
    }

    @Test("Parse invalid IHL from bytes throws error")
    func parseInvalidBytesThrows() {
        let bytes: [UInt8] = [0x43]  // Version 4, IHL 3 (invalid)
        #expect(throws: RFC_791.IHL.Error.tooSmall(3)) {
            try RFC_791.IHL(bytes: bytes)
        }
    }

    // MARK: - Serialization

    @Test("Serialize IHL to bytes")
    func serializeToBytes() {
        var buffer: [UInt8] = []
        RFC_791.IHL.minimum.serialize(into: &buffer)
        #expect(buffer == [0x05])  // Lower nibble only
    }

    @Test("Round-trip serialization")
    func roundTripSerialization() throws {
        let original = RFC_791.IHL(rawValue: 10)!
        var buffer: [UInt8] = []
        original.serialize(into: &buffer)

        let parsed = try RFC_791.IHL(bytes: buffer)
        #expect(parsed == original)
    }

    // MARK: - CustomStringConvertible

    @Test("Description format")
    func descriptionFormat() {
        #expect(RFC_791.IHL(rawValue: 5)?.description == "IHL(5 words, 20 bytes)")
        #expect(RFC_791.IHL(rawValue: 15)?.description == "IHL(15 words, 60 bytes)")
    }

    // MARK: - Comparable

    @Test("IHL values are comparable")
    func comparable() {
        #expect(RFC_791.IHL.minimum < RFC_791.IHL.maximum)
        #expect(RFC_791.IHL(rawValue: 6)! < RFC_791.IHL(rawValue: 10)!)
    }

    // MARK: - Error Tests

    @Test("Error descriptions")
    func errorDescriptions() {
        #expect(RFC_791.IHL.Error.empty.description == "IHL data cannot be empty")
        #expect(RFC_791.IHL.Error.tooSmall(3).description == "IHL value 3 is too small (minimum is 5)")
    }
}
