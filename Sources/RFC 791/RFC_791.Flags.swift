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

extension RFC_791 {
    /// IP Flags (RFC 791)
    ///
    /// A 3-bit field used to control or identify fragments. These flags
    /// are part of the IP header and control datagram fragmentation.
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1:
    /// ```
    /// +-----+-----+-----+
    /// |  0  | DF  | MF  |
    /// +-----+-----+-----+
    ///   0     1     2
    /// ```
    ///
    /// Where:
    /// - Bit 0: Reserved (must be zero)
    /// - Bit 1: Don't Fragment (DF)
    /// - Bit 2: More Fragments (MF)
    ///
    /// ## Flag Meanings
    ///
    /// - **DF (Don't Fragment)**: When set, the datagram must not be
    ///   fragmented. If it cannot be forwarded without fragmentation,
    ///   it is discarded and an ICMP error is returned.
    ///
    /// - **MF (More Fragments)**: When set, indicates this is not the
    ///   last fragment. The last fragment has MF=0.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Don't fragment this datagram
    /// let flags = RFC_791.Flags(dontFragment: true)
    ///
    /// // Parse from byte
    /// let flags = try RFC_791.Flags(bytes: [0x40])  // DF set
    /// ```
    public struct Flags: Hashable, Sendable, Codable {
        /// The raw 3-bit value (stored in upper 3 bits)
        public let rawValue: UInt8

        /// Creates a Flags value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates flags from a raw value
        ///
        /// - Parameter rawValue: The flags byte (upper 3 bits significant)
        /// - Returns: `nil` if reserved bit is set
        public init?(rawValue: UInt8) {
            // Reserved bit (0) must be zero when in 3-bit position
            // Since we store with DF in bit 1, MF in bit 2, check bit 0
            guard rawValue & 0b100 == 0 else {
                return nil
            }
            self.init(__unchecked: (), rawValue: rawValue)
        }

        /// Creates flags from individual components
        ///
        /// - Parameters:
        ///   - dontFragment: If true, the datagram must not be fragmented
        ///   - moreFragments: If true, more fragments follow this one
        public init(
            dontFragment: Bool = false,
            moreFragments: Bool = false
        ) {
            var value: UInt8 = 0
            if dontFragment { value |= 0b010 }
            if moreFragments { value |= 0b001 }
            self.init(__unchecked: (), rawValue: value)
        }
    }
}

// MARK: - Flag Access

extension RFC_791.Flags {
    /// Don't Fragment flag (bit 1)
    ///
    /// When true, the datagram must not be fragmented. If it cannot
    /// be delivered without fragmentation, it will be discarded.
    public var dontFragment: Bool {
        (rawValue & 0b010) != 0
    }

    /// More Fragments flag (bit 2)
    ///
    /// When true, this fragment is followed by more fragments.
    /// The last fragment of a datagram has this bit clear.
    public var moreFragments: Bool {
        (rawValue & 0b001) != 0
    }
}

// MARK: - Static Constants

extension RFC_791.Flags {
    /// No flags set (may fragment, last fragment)
    public static let none = RFC_791.Flags(__unchecked: (), rawValue: 0)

    /// Don't Fragment flag set
    public static let dontFragment = RFC_791.Flags(__unchecked: (), rawValue: 0b010)

    /// More Fragments flag set
    public static let moreFragments = RFC_791.Flags(__unchecked: (), rawValue: 0b001)
}

// MARK: - Byte Parsing

extension RFC_791.Flags {
    /// Creates flags from bytes
    ///
    /// This is the canonical parsing transformation for binary data.
    /// The flags are expected in the upper 3 bits of the first byte.
    ///
    /// ## Category Theory
    ///
    /// Parsing transformation:
    /// - **Domain**: Collection<UInt8> (bytes)
    /// - **Codomain**: RFC_791.Flags (structured data)
    ///
    /// ## Format
    ///
    /// The input byte has flags in the upper 3 bits:
    /// ```
    /// +-----+-----+-----+-----+-----+-----+-----+-----+
    /// |  0  | DF  | MF  |          (ignored)         |
    /// +-----+-----+-----+-----+-----+-----+-----+-----+
    ///   7     6     5     4     3     2     1     0
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let flags = try RFC_791.Flags(bytes: [0x40])  // DF set
    /// print(flags.dontFragment)  // true
    /// ```
    ///
    /// - Parameter bytes: Binary data containing the flags
    /// - Throws: `Error` if the format is invalid
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        guard let firstByte = bytes.first else {
            throw .empty
        }

        // Extract upper 3 bits and shift down
        let flags = firstByte >> 5

        // Reserved bit (now bit 2 after shift) must be zero
        guard flags & 0b100 == 0 else {
            throw .reservedBitSet(firstByte)
        }

        self.init(__unchecked: (), rawValue: flags)
    }
}

// MARK: - UInt8.Serializable Conformance

extension RFC_791.Flags: UInt8.Serializable {
    static public func serialize<Buffer>(
        _ flags: RFC_791.Flags,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == UInt8 {
        buffer.append(contentsOf: [flags.rawValue << 5])
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.Flags: CustomStringConvertible {
    public var description: String {
        var flags: [String] = []
        if dontFragment { flags.append("DF") }
        if moreFragments { flags.append("MF") }

        if flags.isEmpty {
            return "Flags(none)"
        }
        return "Flags(\(flags.joined(separator: ", ")))"
    }
}

// MARK: - [UInt8] Conversion

extension [UInt8] {
    /// Creates byte representation of IP Flags
    ///
    /// Writes the flags as a single byte with flags in upper 3 bits.
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_791.Flags → [UInt8]
    ///
    /// - Parameter flags: The Flags value to serialize
    public init(_ flags: RFC_791.Flags) {
        self = [flags.rawValue << 5]
    }
}
