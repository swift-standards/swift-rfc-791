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

@Suite("RFC_791.TTL Tests")
struct TTLTests {

    // MARK: - Raw Value Initialization

    @Test("All 8-bit values are valid TTL values")
    func allValuesValid() {
        for value: UInt8 in 0...255 {
            let ttl = RFC_791.TTL(rawValue: value)
            #expect(ttl.rawValue == value)
        }
    }

    // MARK: - Static Constants

    @Test("Default64 constant (Linux/macOS)")
    func default64Constant() {
        #expect(RFC_791.TTL.default64.rawValue == 64)
    }

    @Test("Default128 constant (Windows)")
    func default128Constant() {
        #expect(RFC_791.TTL.default128.rawValue == 128)
    }

    @Test("Maximum constant")
    func maximumConstant() {
        #expect(RFC_791.TTL.maximum.rawValue == 255)
    }

    @Test("Expired constant")
    func expiredConstant() {
        #expect(RFC_791.TTL.expired.rawValue == 0)
        #expect(RFC_791.TTL.expired.isExpired)
    }

    @Test("LinkLocal constant")
    func linkLocalConstant() {
        #expect(RFC_791.TTL.linkLocal.rawValue == 1)
    }

    // MARK: - Computed Properties

    @Test("isExpired property")
    func isExpiredProperty() {
        #expect(RFC_791.TTL(rawValue: 0).isExpired == true)
        #expect(RFC_791.TTL(rawValue: 1).isExpired == false)
        #expect(RFC_791.TTL(rawValue: 255).isExpired == false)
    }

    @Test("decremented property")
    func decrementedProperty() {
        #expect(RFC_791.TTL(rawValue: 64).decremented?.rawValue == 63)
        #expect(RFC_791.TTL(rawValue: 1).decremented?.rawValue == 0)
        #expect(RFC_791.TTL(rawValue: 0).decremented == nil)
    }

    @Test("Decrement chain simulation")
    func decrementChain() {
        var ttl: RFC_791.TTL? = RFC_791.TTL(rawValue: 5)
        var hops = 0

        while let current = ttl {
            ttl = current.decremented
            hops += 1
        }

        // Starting at 5, we decrement through 4, 3, 2, 1, 0, then nil
        // That's 6 iterations (including the 0 state)
        #expect(hops == 6)
    }

    // MARK: - Byte Parsing

    @Test("Parse TTL from bytes")
    func parseFromBytes() throws {
        let bytes: [UInt8] = [64]
        let ttl = try RFC_791.TTL(bytes: bytes)
        #expect(ttl.rawValue == 64)
    }

    @Test("Parse from empty bytes throws error")
    func parseEmptyBytesThrows() {
        let bytes: [UInt8] = []
        #expect(throws: RFC_791.TTL.Error.empty) {
            try RFC_791.TTL(bytes: bytes)
        }
    }

    // MARK: - Serialization

    @Test("Serialize TTL to bytes")
    func serializeToBytes() {
        var buffer: [UInt8] = []
        RFC_791.TTL.default64.serialize(into: &buffer)
        #expect(buffer == [64])
    }

    @Test("Round-trip serialization")
    func roundTripSerialization() throws {
        let original = RFC_791.TTL(rawValue: 128)
        var buffer: [UInt8] = []
        original.serialize(into: &buffer)

        let parsed = try RFC_791.TTL(bytes: buffer)
        #expect(parsed == original)
    }

    // MARK: - CustomStringConvertible

    @Test("Description format")
    func descriptionFormat() {
        #expect(RFC_791.TTL(rawValue: 64).description == "TTL(64)")
        #expect(RFC_791.TTL(rawValue: 0).description == "TTL(0)")
    }

    // MARK: - Comparable

    @Test("TTL values are comparable")
    func comparable() {
        #expect(RFC_791.TTL.expired < RFC_791.TTL.default64)
        #expect(RFC_791.TTL.default64 < RFC_791.TTL.maximum)
    }

    // MARK: - ExpressibleByIntegerLiteral

    @Test("Integer literal initialization")
    func integerLiteral() {
        let ttl: RFC_791.TTL = 64
        #expect(ttl.rawValue == 64)
    }

    // MARK: - Error Tests

    @Test("Error descriptions")
    func errorDescriptions() {
        #expect(RFC_791.TTL.Error.empty.description == "TTL data cannot be empty")
    }
}
