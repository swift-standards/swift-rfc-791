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
    /// Type of Service (RFC 791)
    ///
    /// An 8-bit field in the IP header that indicates quality of service
    /// parameters for the datagram. It provides an indication of the
    /// abstract parameters of the quality of service desired.
    ///
    /// ## Binary Format
    ///
    /// Per RFC 791 Section 3.1:
    /// ```
    /// +-----+-----+-----+-----+-----+-----+-----+-----+
    /// |  PRECEDENCE   |  D  |  T  |  R  |  0  |  0  |
    /// +-----+-----+-----+-----+-----+-----+-----+-----+
    ///   0     1     2     3     4     5     6     7
    /// ```
    ///
    /// Where:
    /// - Bits 0-2: Precedence (3 bits)
    /// - Bit 3: Low Delay (D)
    /// - Bit 4: High Throughput (T)
    /// - Bit 5: High Reliability (R)
    /// - Bits 6-7: Reserved (must be zero)
    ///
    /// ## Service Tradeoffs
    ///
    /// Per RFC 791, the network may make tradeoffs between these parameters:
    /// - **Delay**: Minimize time to deliver the datagram
    /// - **Throughput**: Maximize data rate
    /// - **Reliability**: Minimize probability of loss or corruption
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create with specific flags
    /// let tos = RFC_791.TypeOfService(
    ///     precedence: .immediate,
    ///     lowDelay: true,
    ///     highThroughput: false,
    ///     highReliability: true
    /// )
    ///
    /// // Parse from byte
    /// let tos = try RFC_791.TypeOfService(bytes: [0x48])
    /// ```
    public struct TypeOfService: Hashable, Sendable, Codable {
        /// The raw 8-bit value
        public let rawValue: UInt8

        /// Creates a Type of Service value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates a Type of Service from a raw 8-bit value
        ///
        /// - Parameter rawValue: The raw TOS byte
        /// - Returns: `nil` if reserved bits are set
        public init?(rawValue: UInt8) {
            // Reserved bits (6-7) must be zero
            guard rawValue & 0b0000_0011 == 0 else {
                return nil
            }
            self.init(__unchecked: (), rawValue: rawValue)
        }

        /// Creates a Type of Service from individual components
        ///
        /// - Parameters:
        ///   - precedence: The traffic precedence level
        ///   - lowDelay: Request low delay handling
        ///   - highThroughput: Request high throughput handling
        ///   - highReliability: Request high reliability handling
        public init(
            precedence: Precedence = .routine,
            lowDelay: Bool = false,
            highThroughput: Bool = false,
            highReliability: Bool = false
        ) {
            var value = precedence.rawValue << 5
            if lowDelay { value |= 0b0001_0000 }
            if highThroughput { value |= 0b0000_1000 }
            if highReliability { value |= 0b0000_0100 }
            self.init(__unchecked: (), rawValue: value)
        }
    }
}

// MARK: - Component Access

extension RFC_791.TypeOfService {
    /// The precedence level (bits 0-2)
    ///
    /// Indicates the relative importance of the datagram.
    public var precedence: RFC_791.Precedence {
        RFC_791.Precedence(__unchecked: (), rawValue: rawValue >> 5)
    }

    /// Low delay flag (bit 3)
    ///
    /// When set, indicates the datagram should be handled with
    /// minimal delay, potentially at the expense of throughput
    /// or reliability.
    public var lowDelay: Bool {
        (rawValue & 0b0001_0000) != 0
    }

    /// High throughput flag (bit 4)
    ///
    /// When set, indicates the datagram should be handled for
    /// maximum throughput, potentially at the expense of delay
    /// or reliability.
    public var highThroughput: Bool {
        (rawValue & 0b0000_1000) != 0
    }

    /// High reliability flag (bit 5)
    ///
    /// When set, indicates the datagram should be handled with
    /// maximum reliability, potentially at the expense of delay
    /// or throughput.
    public var highReliability: Bool {
        (rawValue & 0b0000_0100) != 0
    }
}

// MARK: - Static Constants

extension RFC_791.TypeOfService {
    /// Default Type of Service (routine, no special handling)
    public static let `default` = RFC_791.TypeOfService(__unchecked: (), rawValue: 0)

    /// Minimize delay
    public static let minimizeDelay = RFC_791.TypeOfService(lowDelay: true)

    /// Maximize throughput
    public static let maximizeThroughput = RFC_791.TypeOfService(highThroughput: true)

    /// Maximize reliability
    public static let maximizeReliability = RFC_791.TypeOfService(highReliability: true)
}

// MARK: - Byte Parsing

extension RFC_791.TypeOfService {
    /// Creates a Type of Service from bytes
    ///
    /// This is the canonical parsing transformation for binary data.
    ///
    /// ## Category Theory
    ///
    /// Parsing transformation:
    /// - **Domain**: Collection<UInt8> (bytes)
    /// - **Codomain**: RFC_791.TypeOfService (structured data)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let tos = try RFC_791.TypeOfService(bytes: [0x48])
    /// print(tos.precedence)  // .immediate
    /// print(tos.lowDelay)    // true
    /// ```
    ///
    /// - Parameter bytes: Binary data containing the TOS byte
    /// - Throws: `Error` if the format is invalid
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        guard let firstByte = bytes.first else {
            throw .empty
        }

        // Reserved bits must be zero
        guard firstByte & 0b0000_0011 == 0 else {
            throw .reservedBitsSet(firstByte)
        }

        self.init(__unchecked: (), rawValue: firstByte)
    }
}

// MARK: - UInt8.Serializable Conformance

extension RFC_791.TypeOfService: UInt8.Serializable {
    /// Serialize to a byte buffer
    ///
    /// Writes the raw TOS byte to the buffer.
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(rawValue)
    }
}

// MARK: - CustomStringConvertible

extension RFC_791.TypeOfService: CustomStringConvertible {
    public var description: String {
        var flags: [String] = []
        if lowDelay { flags.append("LowDelay") }
        if highThroughput { flags.append("HighThroughput") }
        if highReliability { flags.append("HighReliability") }

        let flagsString = flags.isEmpty ? "None" : flags.joined(separator: ", ")
        return "TypeOfService(precedence: \(precedence), flags: [\(flagsString)])"
    }
}
