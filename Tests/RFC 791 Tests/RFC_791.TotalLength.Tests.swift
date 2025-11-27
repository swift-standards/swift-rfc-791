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

@Suite("RFC_791.TotalLength Tests")
struct TotalLengthTests {

    // MARK: - Raw Value Initialization

    @Test("Valid total length values (20-65535) are accepted")
    func validRawValues() {
        #expect(RFC_791.TotalLength(rawValue: 20)?.rawValue == 20)
        #expect(RFC_791.TotalLength(rawValue: 576)?.rawValue == 576)
        #expect(RFC_791.TotalLength(rawValue: 1500)?.rawValue == 1500)
        #expect(RFC_791.TotalLength(rawValue: 65535)?.rawValue == 65535)
    }

    @Test("Invalid total length values (<20) are rejected")
    func invalidRawValues() {
        for value: UInt16 in 0..<20 {
            let length = RFC_791.TotalLength(rawValue: value)
            #expect(length == nil)
        }
    }

    // MARK: - Static Constants

    @Test("Minimum constant")
    func minimumConstant() {
        #expect(RFC_791.TotalLength.minimum.rawValue == 20)
        #expect(RFC_791.TotalLength.minimum.isMinimum)
    }

    @Test("Maximum constant")
    func maximumConstant() {
        #expect(RFC_791.TotalLength.maximum.rawValue == 65535)
    }

    @Test("Minimum reassembly buffer constant")
    func minimumReassemblyBufferConstant() {
        #expect(RFC_791.TotalLength.minimumReassemblyBuffer.rawValue == 576)
    }

    @Test("Ethernet MTU constant")
    func ethernetMTUConstant() {
        #expect(RFC_791.TotalLength.ethernetMTU.rawValue == 1500)
    }

    // MARK: - Computed Properties

    @Test("maximumDataLength calculation")
    func maximumDataLengthCalculation() {
        #expect(RFC_791.TotalLength(rawValue: 20)?.maximumDataLength == 0)
        #expect(RFC_791.TotalLength(rawValue: 1500)?.maximumDataLength == 1480)
        #expect(RFC_791.TotalLength(rawValue: 65535)?.maximumDataLength == 65515)
    }

    @Test("isMinimum property")
    func isMinimumProperty() {
        #expect(RFC_791.TotalLength(rawValue: 20)?.isMinimum == true)
        #expect(RFC_791.TotalLength(rawValue: 21)?.isMinimum == false)
        #expect(RFC_791.TotalLength(rawValue: 1500)?.isMinimum == false)
    }

    // MARK: - Byte Parsing

    @Test("Parse total length from bytes (big-endian)")
    func parseFromBytes() throws {
        let bytes: [UInt8] = [0x05, 0xDC]  // 1500
        let length = try RFC_791.TotalLength(bytes: bytes)
        #expect(length.rawValue == 1500)
    }

    @Test("Parse minimum from bytes")
    func parseMinFromBytes() throws {
        let bytes: [UInt8] = [0x00, 0x14]  // 20
        let length = try RFC_791.TotalLength(bytes: bytes)
        #expect(length.rawValue == 20)
    }

    @Test("Parse from empty bytes throws error")
    func parseEmptyBytesThrows() {
        let bytes: [UInt8] = []
        #expect(throws: RFC_791.TotalLength.Error.empty) {
            try RFC_791.TotalLength(bytes: bytes)
        }
    }

    @Test("Parse from insufficient bytes throws error")
    func parseInsufficientBytesThrows() {
        let bytes: [UInt8] = [0x05]
        #expect(throws: RFC_791.TotalLength.Error.insufficientBytes) {
            try RFC_791.TotalLength(bytes: bytes)
        }
    }

    @Test("Parse too small value throws error")
    func parseTooSmallThrows() {
        let bytes: [UInt8] = [0x00, 0x10]  // 16 (less than minimum 20)
        #expect(throws: RFC_791.TotalLength.Error.tooSmall(16)) {
            try RFC_791.TotalLength(bytes: bytes)
        }
    }

    // MARK: - Serialization

    @Test("Serialize total length to bytes (big-endian)")
    func serializeToBytes() {
        var buffer: [UInt8] = []
        RFC_791.TotalLength(rawValue: 1500)!.serialize(into: &buffer)
        #expect(buffer == [0x05, 0xDC])
    }

    @Test("Round-trip serialization")
    func roundTripSerialization() throws {
        let original = RFC_791.TotalLength(rawValue: 576)!
        var buffer: [UInt8] = []
        original.serialize(into: &buffer)

        let parsed = try RFC_791.TotalLength(bytes: buffer)
        #expect(parsed == original)
    }

    // MARK: - CustomStringConvertible

    @Test("Description format")
    func descriptionFormat() {
        #expect(RFC_791.TotalLength(rawValue: 1500)?.description == "1500 bytes")
        #expect(RFC_791.TotalLength(rawValue: 20)?.description == "20 bytes")
    }

    // MARK: - Comparable

    @Test("Total lengths are comparable")
    func comparable() {
        #expect(RFC_791.TotalLength.minimum < RFC_791.TotalLength.ethernetMTU)
        #expect(RFC_791.TotalLength.ethernetMTU < RFC_791.TotalLength.maximum)
    }

    // MARK: - Error Tests

    @Test("Error descriptions")
    func errorDescriptions() {
        #expect(RFC_791.TotalLength.Error.empty.description == "TotalLength data cannot be empty")
        #expect(RFC_791.TotalLength.Error.insufficientBytes.description == "TotalLength requires 2 bytes")
        #expect(RFC_791.TotalLength.Error.tooSmall(10).description == "TotalLength 10 is less than minimum header size of 20")
    }
}
