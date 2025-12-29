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

@Suite("RFC 791: IPv4 Address Class Tests")
struct IPv4AddressClassTests {

    // MARK: - Class A Tests

    @Test("Class A detection - first octet 0-127")
    func classADetection() {
        // Class A: leading bit 0 (0.x.x.x - 127.x.x.x)
        let addr0 = RFC_791.IPv4.Address(0, 0, 0, 1)
        #expect(addr0.class == .a)

        let addr10 = RFC_791.IPv4.Address(10, 0, 0, 1)
        #expect(addr10.class == .a)

        let addr127 = RFC_791.IPv4.Address(127, 255, 255, 255)
        #expect(addr127.class == .a)
    }

    // MARK: - Class B Tests

    @Test("Class B detection - first octet 128-191")
    func classBDetection() {
        // Class B: leading bits 10 (128.x.x.x - 191.x.x.x)
        let addr128 = RFC_791.IPv4.Address(128, 0, 0, 1)
        #expect(addr128.class == .b)

        let addr172 = RFC_791.IPv4.Address(172, 16, 0, 1)
        #expect(addr172.class == .b)

        let addr191 = RFC_791.IPv4.Address(191, 255, 255, 255)
        #expect(addr191.class == .b)
    }

    // MARK: - Class C Tests

    @Test("Class C detection - first octet 192-223")
    func classCDetection() {
        // Class C: leading bits 110 (192.x.x.x - 223.x.x.x)
        let addr192 = RFC_791.IPv4.Address(192, 0, 0, 1)
        #expect(addr192.class == .c)

        let addr192x168 = RFC_791.IPv4.Address(192, 168, 1, 1)
        #expect(addr192x168.class == .c)

        let addr223 = RFC_791.IPv4.Address(223, 255, 255, 255)
        #expect(addr223.class == .c)
    }

    // MARK: - Class D Tests (Multicast)

    @Test("Class D detection - first octet 224-239 (multicast)")
    func classDDetection() {
        // Class D: leading bits 1110 (224.x.x.x - 239.x.x.x)
        let addr224 = RFC_791.IPv4.Address(224, 0, 0, 1)
        #expect(addr224.class == .d)
        #expect(addr224.is.multicast)

        let addr239 = RFC_791.IPv4.Address(239, 255, 255, 255)
        #expect(addr239.class == .d)
        #expect(addr239.is.multicast)
    }

    // MARK: - Class E Tests (Reserved)

    @Test("Class E detection - first octet 240-255 (reserved)")
    func classEDetection() {
        // Class E: leading bits 1111 (240.x.x.x - 255.x.x.x)
        let addr240 = RFC_791.IPv4.Address(240, 0, 0, 1)
        #expect(addr240.class == .e)
        #expect(addr240.is.reserved)

        let addr255 = RFC_791.IPv4.Address(255, 255, 255, 255)
        #expect(addr255.class == .e)
        #expect(addr255.is.reserved)
    }

    // MARK: - Boundary Tests

    @Test("Class boundaries")
    func classBoundaries() {
        // A/B boundary at 127/128
        #expect(RFC_791.IPv4.Address(127, 0, 0, 0).class == .a)
        #expect(RFC_791.IPv4.Address(128, 0, 0, 0).class == .b)

        // B/C boundary at 191/192
        #expect(RFC_791.IPv4.Address(191, 0, 0, 0).class == .b)
        #expect(RFC_791.IPv4.Address(192, 0, 0, 0).class == .c)

        // C/D boundary at 223/224
        #expect(RFC_791.IPv4.Address(223, 0, 0, 0).class == .c)
        #expect(RFC_791.IPv4.Address(224, 0, 0, 0).class == .d)

        // D/E boundary at 239/240
        #expect(RFC_791.IPv4.Address(239, 0, 0, 0).class == .d)
        #expect(RFC_791.IPv4.Address(240, 0, 0, 0).class == .e)
    }

    // MARK: - Helper Property Tests

    @Test("is.multicast property")
    func isMulticastProperty() {
        #expect(!RFC_791.IPv4.Address(192, 168, 1, 1).is.multicast)
        #expect(RFC_791.IPv4.Address(224, 0, 0, 1).is.multicast)
        #expect(!RFC_791.IPv4.Address(255, 255, 255, 255).is.multicast)
    }

    @Test("is.reserved property")
    func isReservedProperty() {
        #expect(!RFC_791.IPv4.Address(192, 168, 1, 1).is.reserved)
        #expect(!RFC_791.IPv4.Address(224, 0, 0, 1).is.reserved)
        #expect(RFC_791.IPv4.Address(240, 0, 0, 1).is.reserved)
        #expect(RFC_791.IPv4.Address(255, 255, 255, 255).is.reserved)
    }

    // MARK: - Description Tests

    @Test("Class description")
    func classDescription() {
        #expect(RFC_791.IPv4.Address.Class.a.description == "Class A")
        #expect(RFC_791.IPv4.Address.Class.b.description == "Class B")
        #expect(RFC_791.IPv4.Address.Class.c.description == "Class C")
        #expect(RFC_791.IPv4.Address.Class.d.description == "Class D (Multicast)")
        #expect(RFC_791.IPv4.Address.Class.e.description == "Class E (Reserved)")
    }
}
