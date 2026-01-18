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

@Suite("RFC 791: Flags Tests")
struct FlagsTests {

    // MARK: - Initialization Tests

    @Test("Flags from raw value - valid")
    func initFromRawValueValid() {
        // Valid: reserved bit (0) is zero
        let flags = RFC_791.Flags(rawValue: 0b011)
        #expect(flags != nil)
        #expect(flags?.dontFragment == true)
        #expect(flags?.moreFragments == true)
    }

    @Test("Flags from raw value - invalid (reserved bit set)")
    func initFromRawValueInvalid() {
        // Invalid: reserved bit set
        #expect(RFC_791.Flags(rawValue: 0b100) == nil)
        #expect(RFC_791.Flags(rawValue: 0b111) == nil)
    }

    @Test("Flags from components")
    func initFromComponents() {
        let flags = RFC_791.Flags(dontFragment: true, moreFragments: false)

        #expect(flags.dontFragment == true)
        #expect(flags.moreFragments == false)
    }

    @Test("Flags default values")
    func initDefaultValues() {
        let flags = RFC_791.Flags()

        #expect(flags.dontFragment == false)
        #expect(flags.moreFragments == false)
    }

    // MARK: - Flag Access Tests

    @Test("Flags individual flag access")
    func individualFlagAccess() {
        // Don't Fragment only
        let df = RFC_791.Flags(dontFragment: true, moreFragments: false)
        #expect(df.dontFragment == true)
        #expect(df.moreFragments == false)

        // More Fragments only
        let mf = RFC_791.Flags(dontFragment: false, moreFragments: true)
        #expect(mf.dontFragment == false)
        #expect(mf.moreFragments == true)

        // Both flags
        let both = RFC_791.Flags(dontFragment: true, moreFragments: true)
        #expect(both.dontFragment == true)
        #expect(both.moreFragments == true)
    }

    // MARK: - Static Constants Tests

    @Test("Flags static constants")
    func staticConstants() {
        #expect(RFC_791.Flags.none.rawValue == 0)
        #expect(RFC_791.Flags.none.dontFragment == false)
        #expect(RFC_791.Flags.none.moreFragments == false)

        #expect(RFC_791.Flags.dontFragment.dontFragment == true)
        #expect(RFC_791.Flags.dontFragment.moreFragments == false)

        #expect(RFC_791.Flags.moreFragments.dontFragment == false)
        #expect(RFC_791.Flags.moreFragments.moreFragments == true)
    }

    // MARK: - Byte Parsing Tests

    @Test("Flags from bytes - valid")
    func initFromBytesValid() throws {
        // Flags in upper 3 bits: 0b010_00000 = DF set
        let flags = try RFC_791.Flags(bytes: [0b0100_0000])
        #expect(flags.dontFragment == true)
        #expect(flags.moreFragments == false)
    }

    @Test("Flags from bytes - MF set")
    func initFromBytesMF() throws {
        // Flags in upper 3 bits: 0b001_00000 = MF set
        let flags = try RFC_791.Flags(bytes: [0b0010_0000])
        #expect(flags.dontFragment == false)
        #expect(flags.moreFragments == true)
    }

    @Test("Flags from bytes - both set")
    func initFromBytesBoth() throws {
        // Flags in upper 3 bits: 0b011_00000 = DF and MF set
        let flags = try RFC_791.Flags(bytes: [0b0110_0000])
        #expect(flags.dontFragment == true)
        #expect(flags.moreFragments == true)
    }

    @Test("Flags from bytes - empty")
    func initFromBytesEmpty() {
        #expect(throws: RFC_791.Flags.Error.self) {
            _ = try RFC_791.Flags(bytes: [] as [UInt8])
        }
    }

    @Test("Flags from bytes - reserved bit set")
    func initFromBytesReservedBit() {
        // Reserved bit in upper 3 bits: 0b100_00000
        #expect(throws: RFC_791.Flags.Error.self) {
            _ = try RFC_791.Flags(bytes: [0b1000_0000])
        }
    }

    // MARK: - Serialization Tests

    @Test("Flags serialization")
    func serialization() {
        let flags = RFC_791.Flags(dontFragment: true, moreFragments: false)
        var buffer: [UInt8] = []
        flags.serialize(into: &buffer)

        // DF = bit 1 = 0b010, shifted left 5 = 0b0100_0000
        #expect(buffer == [0b0100_0000])
    }

    @Test("Flags bytes property")
    func bytesProperty() {
        let flags = RFC_791.Flags.moreFragments
        // MF = bit 0 = 0b001, shifted left 5 = 0b0010_0000
        #expect(flags.bytes == [0b0010_0000])
    }

    // MARK: - Round Trip Tests

    @Test("Flags round trip")
    func roundTrip() throws {
        let original = RFC_791.Flags(dontFragment: true, moreFragments: true)
        let bytes = original.bytes
        let parsed = try RFC_791.Flags(bytes: bytes)

        #expect(parsed.dontFragment == original.dontFragment)
        #expect(parsed.moreFragments == original.moreFragments)
    }

    // MARK: - Equality Tests

    @Test("Flags equality")
    func equality() {
        let flags1 = RFC_791.Flags(dontFragment: true, moreFragments: false)
        let flags2 = RFC_791.Flags(dontFragment: true, moreFragments: false)
        let flags3 = RFC_791.Flags(dontFragment: false, moreFragments: true)

        #expect(flags1 == flags2)
        #expect(flags1 != flags3)
    }

    // MARK: - Hashable Tests

    @Test("Flags hashable")
    func hashable() {
        var set: Set<RFC_791.Flags> = []
        set.insert(.none)
        set.insert(.dontFragment)
        set.insert(.none)  // Duplicate

        #expect(set.count == 2)
    }

    // MARK: - Description Tests

    @Test("Flags description")
    func description() {
        #expect(RFC_791.Flags.none.description == "Flags(none)")
        #expect(RFC_791.Flags.dontFragment.description == "Flags(DF)")
        #expect(RFC_791.Flags.moreFragments.description == "Flags(MF)")

        let both = RFC_791.Flags(dontFragment: true, moreFragments: true)
        #expect(both.description.contains("DF"))
        #expect(both.description.contains("MF"))
    }
}
