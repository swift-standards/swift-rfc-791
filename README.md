# RFC 791

[![CI](https://github.com/swift-standards/swift-rfc-791/workflows/CI/badge.svg)](https://github.com/swift-standards/swift-rfc-791/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Swift implementation of RFC 791: Internet Protocol (IPv4).

## Overview

This package provides type-safe Swift representations of all Internet Protocol version 4 header fields as defined in RFC 791. Each field is modeled as a distinct type with validation, serialization, and parsing capabilities.

The implementation follows RFC 791 (September 1981), the foundational specification for IPv4 that remains the basis of Internet routing today.

## Features

- Complete IPv4 header field coverage (Version, IHL, TOS, Total Length, Identification, Flags, Fragment Offset, TTL, Protocol, Header Checksum, Source/Destination Address)
- Type-safe IPv4 address representation with dotted-decimal parsing and serialization
- Address classification (Class A, B, C, D, E) per RFC 791 Section 3.2
- Type of Service with Precedence levels and D/T/R flags
- Fragment handling with offset calculations (8-octet units)
- Header checksum computation and verification (one's complement algorithm)
- Binary serialization via `Binary.Serializable` protocol
- ASCII serialization for addresses via `Binary.ASCII.Serializable` protocol
- 202 tests covering parsing, serialization, validation, and edge cases

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-rfc-791.git", from: "0.1.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 791", package: "swift-rfc-791")
    ]
)
```

## Quick Start

```swift
import RFC_791

// Create an IPv4 address from dotted-decimal notation
let address: RFC_791.IPv4.Address = "192.168.1.1"
print(address.octets)       // (192, 168, 1, 1)
print(address.addressClass) // .classC

// Create header fields
let ttl = RFC_791.TTL.default64  // 64 hops (Linux/macOS default)
let proto = RFC_791.`Protocol`.tcp  // Protocol number 6
let flags = RFC_791.Flags(dontFragment: true, moreFragments: false)

// Serialize address to ASCII bytes (dotted-decimal)
let bytes = [UInt8](address)  // "192.168.1.1" as ASCII
```

## Usage Examples

### IPv4 Addresses

Create and manipulate IPv4 addresses:

```swift
import RFC_791

// From string literal
let addr1: RFC_791.IPv4.Address = "10.0.0.1"

// From raw 32-bit value
let addr2 = RFC_791.IPv4.Address(rawValue: 0xC0A80001)  // 192.168.0.1

// From individual octets
let addr3 = RFC_791.IPv4.Address(127, 0, 0, 1)

// Access octets
let (a, b, c, d) = addr1.octets
print("\(a).\(b).\(c).\(d)")  // "10.0.0.1"

// Address classification (RFC 791 Section 3.2)
addr1.addressClass  // .classA (10.x.x.x)
addr1.isMulticast   // false
addr1.isReserved    // false

// Special addresses
RFC_791.IPv4.Address.any        // 0.0.0.0
RFC_791.IPv4.Address.broadcast  // 255.255.255.255
RFC_791.IPv4.Address.loopback   // 127.0.0.1
```

### IP Header Fields

Work with individual header fields:

```swift
import RFC_791

// Version (4-bit)
let version = RFC_791.Version.v4
version.isIPv4  // true

// Internet Header Length (4-bit, in 32-bit words)
let ihl = RFC_791.IHL.minimum       // 5 (20 bytes, no options)
ihl.byteLength                      // 20
ihl.hasOptions                      // false

// Time to Live (8-bit)
let ttl = RFC_791.TTL(rawValue: 64)
ttl.isExpired                       // false
ttl.decremented?.rawValue           // 63

// Protocol (8-bit) - use backticks for reserved keyword
RFC_791.`Protocol`.icmp.rawValue    // 1
RFC_791.`Protocol`.tcp.rawValue     // 6
RFC_791.`Protocol`.udp.rawValue     // 17

// Identification (16-bit)
let id = RFC_791.Identification(rawValue: 0x1234)

// Total Length (16-bit)
let length = RFC_791.TotalLength(rawValue: 1500)!
length.maximumDataLength            // 1480 (minus minimum header)
```

### Type of Service

Configure QoS parameters:

```swift
import RFC_791

// Create with precedence and flags
let tos = RFC_791.TypeOfService(
    precedence: .immediate,
    lowDelay: true,
    highThroughput: false,
    highReliability: true
)

// Extract components
tos.precedence          // .immediate
tos.lowDelay            // true
tos.highThroughput      // false
tos.highReliability     // true

// Precedence levels (RFC 791 Section 3.1)
RFC_791.Precedence.routine           // 0
RFC_791.Precedence.priority          // 1
RFC_791.Precedence.immediate         // 2
RFC_791.Precedence.flash             // 3
RFC_791.Precedence.flashOverride     // 4
RFC_791.Precedence.criticEcp         // 5
RFC_791.Precedence.internetworkControl  // 6
RFC_791.Precedence.networkControl    // 7
```

### Fragmentation

Handle IP fragmentation:

```swift
import RFC_791

// Fragment flags
let flags = RFC_791.Flags(dontFragment: false, moreFragments: true)
flags.dontFragment      // false
flags.moreFragments     // true

// Fragment offset (13-bit, in 8-octet units)
let offset = RFC_791.FragmentOffset(rawValue: 185)!
offset.byteOffset       // 1480 (typical MTU boundary)
offset.isFirstFragment  // false

// Create from byte offset
let firstFrag = RFC_791.FragmentOffset.fromByteOffset(0)!
firstFrag.isFirstFragment  // true
```

### Header Checksum

Compute and verify checksums:

```swift
import RFC_791

// Compute checksum for a header (with checksum field zeroed)
let header: [UInt8] = [
    0x45, 0x00,  // Version, IHL, TOS
    0x00, 0x73,  // Total Length
    0x00, 0x00,  // Identification
    0x40, 0x00,  // Flags, Fragment Offset
    0x40, 0x11,  // TTL, Protocol
    0x00, 0x00,  // Checksum (zero for computation)
    0xC0, 0xA8, 0x00, 0x01,  // Source: 192.168.0.1
    0xC0, 0xA8, 0x00, 0xC7,  // Destination: 192.168.0.199
]

let checksum = RFC_791.HeaderChecksum.compute(over: header)
print(checksum.rawValue)  // 0xB861

// Verify a header with checksum included
let completeHeader: [UInt8] = [
    0x45, 0x00, 0x00, 0x73, 0x00, 0x00, 0x40, 0x00,
    0x40, 0x11, 0xB8, 0x61,  // Checksum at bytes 10-11
    0xC0, 0xA8, 0x00, 0x01, 0xC0, 0xA8, 0x00, 0xC7,
]

RFC_791.HeaderChecksum.verify(header: completeHeader)  // true
```

### Binary Serialization

Serialize fields to bytes:

```swift
import RFC_791

var buffer: [UInt8] = []

// 16-bit fields (2 bytes each, big-endian)
RFC_791.TotalLength(rawValue: 1500)!.serialize(into: &buffer)
RFC_791.Identification(rawValue: 0x1234).serialize(into: &buffer)
RFC_791.HeaderChecksum(rawValue: 0xABCD).serialize(into: &buffer)

// 8-bit fields (1 byte each)
RFC_791.TTL(rawValue: 64).serialize(into: &buffer)
RFC_791.`Protocol`.tcp.serialize(into: &buffer)

// Address serializes to ASCII dotted-decimal (variable length)
let address: RFC_791.IPv4.Address = "192.168.1.1"
let addressBytes = [UInt8](address)  // "192.168.1.1" as ASCII
```

### Binary Parsing

Parse fields from bytes:

```swift
import RFC_791

// Parse address from ASCII dotted-decimal bytes
let addrBytes: [UInt8] = Array("192.168.1.1".utf8)
let address = try RFC_791.IPv4.Address(ascii: addrBytes, in: ())

// Parse 16-bit fields from binary
let lengthBytes: [UInt8] = [0x05, 0xDC]  // 1500
let length = try RFC_791.TotalLength(bytes: lengthBytes)

// Parse with error handling
do {
    let ttl = try RFC_791.TTL(bytes: [])
} catch RFC_791.TTL.Error.empty {
    print("No data")
}
```

## Standards Compliance

Conforms to **RFC 791** (September 1981): Internet Protocol - DARPA Internet Program Protocol Specification.

### Header Format

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |Type of Service|          Total Length         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|      Fragment Offset    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Time to Live |    Protocol   |         Header Checksum       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source Address                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

### Type Coverage

| Field | Bits | Type |
|-------|------|------|
| Version | 4 | `RFC_791.Version` |
| IHL | 4 | `RFC_791.IHL` |
| Type of Service | 8 | `RFC_791.TypeOfService` |
| Total Length | 16 | `RFC_791.TotalLength` |
| Identification | 16 | `RFC_791.Identification` |
| Flags | 3 | `RFC_791.Flags` |
| Fragment Offset | 13 | `RFC_791.FragmentOffset` |
| Time to Live | 8 | `RFC_791.TTL` |
| Protocol | 8 | `RFC_791.Protocol` |
| Header Checksum | 16 | `RFC_791.HeaderChecksum` |
| Source Address | 32 | `RFC_791.IPv4.Address` |
| Destination Address | 32 | `RFC_791.IPv4.Address` |

## Testing

Test suite: 202 tests covering all types.

Run tests:

```bash
swift test
```

## Requirements

- Swift 6.0 or later
- macOS 15.0+ / iOS 18.0+ / tvOS 18.0+ / watchOS 11.0+

## Related Packages

- [swift-standards](https://github.com/swift-standards/swift-standards) - Foundation utilities for standards implementations
- [swift-incits-4-1986](https://github.com/swift-standards/swift-incits-4-1986) - US-ASCII character set implementation

## License

This package is licensed under the Apache License 2.0. See [LICENSE.md](LICENSE.md) for details.

## Contributing

Contributions are welcome. Please ensure all tests pass and new features include test coverage.
