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

@Suite("RFC 791: Precedence Tests")
struct PrecedenceTests {

    // MARK: - Initialization Tests

    @Test("Precedence from raw value - valid")
    func initFromRawValueValid() {
        for value: UInt8 in 0...7 {
            let precedence = RFC_791.Precedence(rawValue: value)
            #expect(precedence != nil)
            #expect(precedence?.rawValue == value)
        }
    }

    @Test("Precedence from raw value - invalid")
    func initFromRawValueInvalid() {
        #expect(RFC_791.Precedence(rawValue: 8) == nil)
        #expect(RFC_791.Precedence(rawValue: 255) == nil)
    }

    // MARK: - Static Constants Tests

    @Test("Precedence static constants")
    func staticConstants() {
        #expect(RFC_791.Precedence.routine.rawValue == 0)
        #expect(RFC_791.Precedence.priority.rawValue == 1)
        #expect(RFC_791.Precedence.immediate.rawValue == 2)
        #expect(RFC_791.Precedence.flash.rawValue == 3)
        #expect(RFC_791.Precedence.flashOverride.rawValue == 4)
        #expect(RFC_791.Precedence.criticEcp.rawValue == 5)
        #expect(RFC_791.Precedence.internetworkControl.rawValue == 6)
        #expect(RFC_791.Precedence.networkControl.rawValue == 7)
    }

    // MARK: - Byte Parsing Tests

    @Test("Precedence from bytes - valid")
    func initFromBytesValid() throws {
        let precedence = try RFC_791.Precedence(bytes: [0x03])
        #expect(precedence == .flash)
    }

    @Test("Precedence from bytes - empty")
    func initFromBytesEmpty() {
        #expect(throws: RFC_791.Precedence.Error.self) {
            _ = try RFC_791.Precedence(bytes: [] as [UInt8])
        }
    }

    @Test("Precedence from bytes - out of range")
    func initFromBytesOutOfRange() {
        #expect(throws: RFC_791.Precedence.Error.self) {
            _ = try RFC_791.Precedence(bytes: [0x08])
        }
    }

    // MARK: - Serialization Tests

    @Test("Precedence serialization")
    func serialization() {
        let precedence = RFC_791.Precedence.immediate
        var buffer: [UInt8] = []
        precedence.serialize(into: &buffer)
        #expect(buffer == [0x02])
    }

    @Test("Precedence bytes property")
    func bytesProperty() {
        let precedence = RFC_791.Precedence.flash
        #expect(precedence.bytes == [0x03])
    }

    // MARK: - Comparable Tests

    @Test("Precedence comparable")
    func comparable() {
        #expect(RFC_791.Precedence.routine < .priority)
        #expect(RFC_791.Precedence.priority < .immediate)
        #expect(RFC_791.Precedence.immediate < .flash)
        #expect(RFC_791.Precedence.flash < .flashOverride)
        #expect(RFC_791.Precedence.flashOverride < .criticEcp)
        #expect(RFC_791.Precedence.criticEcp < .internetworkControl)
        #expect(RFC_791.Precedence.internetworkControl < .networkControl)
    }

    // MARK: - Description Tests

    @Test("Precedence description")
    func description() {
        #expect(RFC_791.Precedence.routine.description == "Routine")
        #expect(RFC_791.Precedence.priority.description == "Priority")
        #expect(RFC_791.Precedence.immediate.description == "Immediate")
        #expect(RFC_791.Precedence.flash.description == "Flash")
        #expect(RFC_791.Precedence.flashOverride.description == "Flash Override")
        #expect(RFC_791.Precedence.criticEcp.description == "CRITIC/ECP")
        #expect(RFC_791.Precedence.internetworkControl.description == "Internetwork Control")
        #expect(RFC_791.Precedence.networkControl.description == "Network Control")
    }

    // MARK: - Equality Tests

    @Test("Precedence equality")
    func equality() {
        let prec1 = RFC_791.Precedence.flash
        let prec2 = RFC_791.Precedence(rawValue: 3)!
        let prec3 = RFC_791.Precedence.immediate

        #expect(prec1 == prec2)
        #expect(prec1 != prec3)
    }

    // MARK: - Hashable Tests

    @Test("Precedence hashable")
    func hashable() {
        var set: Set<RFC_791.Precedence> = []
        set.insert(.routine)
        set.insert(.priority)
        set.insert(.routine)  // Duplicate

        #expect(set.count == 2)
        #expect(set.contains(.routine))
        #expect(set.contains(.priority))
    }
}
