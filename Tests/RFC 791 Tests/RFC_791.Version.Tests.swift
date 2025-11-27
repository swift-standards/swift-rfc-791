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

@Suite("RFC_791.Version Tests")
struct VersionTests {

    // MARK: - Raw Value Initialization

    @Test("Valid version values (0-15) are accepted")
    func validRawValues() {
        for value: UInt8 in 0...15 {
            let version = RFC_791.Version(rawValue: value)
            #expect(version != nil)
            #expect(version?.rawValue == value)
        }
    }

    @Test("Invalid version values (>15) are rejected")
    func invalidRawValues() {
        for value: UInt8 in 16...255 {
            let version = RFC_791.Version(rawValue: value)
            #expect(version == nil)
        }
    }

    // MARK: - Static Constants

    @Test("IPv4 version constant")
    func ipv4Constant() {
        #expect(RFC_791.Version.v4.rawValue == 4)
        #expect(RFC_791.Version.v4.isIPv4)
    }

    @Test("IPv6 version constant")
    func ipv6Constant() {
        #expect(RFC_791.Version.v6.rawValue == 6)
        #expect(RFC_791.Version.v6.isIPv6)
    }

    // MARK: - Computed Properties

    @Test("isIPv4 property")
    func isIPv4Property() {
        #expect(RFC_791.Version(rawValue: 4)?.isIPv4 == true)
        #expect(RFC_791.Version(rawValue: 6)?.isIPv4 == false)
        #expect(RFC_791.Version(rawValue: 0)?.isIPv4 == false)
    }

    @Test("isIPv6 property")
    func isIPv6Property() {
        #expect(RFC_791.Version(rawValue: 6)?.isIPv6 == true)
        #expect(RFC_791.Version(rawValue: 4)?.isIPv6 == false)
        #expect(RFC_791.Version(rawValue: 0)?.isIPv6 == false)
    }

    // MARK: - Byte Parsing

    @Test("Parse version from bytes")
    func parseFromBytes() throws {
        // Version is in upper 4 bits
        let bytes: [UInt8] = [0x45]  // Version 4, IHL 5
        let version = try RFC_791.Version(bytes: bytes)
        #expect(version.rawValue == 4)
    }

    @Test("Parse version 6 from bytes")
    func parseVersion6FromBytes() throws {
        let bytes: [UInt8] = [0x60]  // Version 6
        let version = try RFC_791.Version(bytes: bytes)
        #expect(version.rawValue == 6)
    }

    @Test("Parse from empty bytes throws error")
    func parseEmptyBytesThrows() {
        let bytes: [UInt8] = []
        #expect(throws: RFC_791.Version.Error.empty) {
            try RFC_791.Version(bytes: bytes)
        }
    }

    // MARK: - Serialization

    @Test("Serialize version to bytes")
    func serializeToBytes() {
        var buffer: [UInt8] = []
        RFC_791.Version.v4.serialize(into: &buffer)
        #expect(buffer == [0x40])  // Upper nibble only
    }

    @Test("Round-trip serialization")
    func roundTripSerialization() throws {
        let original = RFC_791.Version.v4
        var buffer: [UInt8] = []
        original.serialize(into: &buffer)

        let parsed = try RFC_791.Version(bytes: buffer)
        #expect(parsed == original)
    }

    // MARK: - CustomStringConvertible

    @Test("Description format")
    func descriptionFormat() {
        #expect(RFC_791.Version.v4.description == "IPv4")
        #expect(RFC_791.Version.v6.description == "IPv6")
        #expect(RFC_791.Version(rawValue: 0)?.description == "Version(0)")
    }

    // MARK: - Comparable

    @Test("Versions are comparable")
    func comparable() {
        #expect(RFC_791.Version.v4 < RFC_791.Version.v6)
        #expect(RFC_791.Version(rawValue: 0)! < RFC_791.Version.v4)
    }

    // MARK: - Equatable

    @Test("Versions are equatable")
    func equatable() {
        #expect(RFC_791.Version.v4 == RFC_791.Version(rawValue: 4))
        #expect(RFC_791.Version.v6 == RFC_791.Version(rawValue: 6))
    }

    // MARK: - Error Tests

    @Test("Error descriptions")
    func errorDescriptions() {
        #expect(RFC_791.Version.Error.empty.description == "Version data cannot be empty")
    }
}
