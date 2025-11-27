// swift-tools-version: 6.2
import PackageDescription

extension String {
    static let rfc791 = "RFC 791"
    var tests: Self { "\(self) Tests" }
}

extension Target.Dependency {
    static let rfc791 = Self.target(name: .rfc791)
    static let standards = Self.product(name: "Standards", package: "swift-standards")
    static let incits41986 = Self.product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
}

let package = Package(
    name: "swift-rfc-791",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(name: .rfc791, targets: [.rfc791]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.4.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.4.1"),
    ],
    targets: [
        .target(
            name: .rfc791,
            dependencies: [.standards, .incits41986]
        ),
        .testTarget(
            name: .rfc791.tests,
            dependencies: [.rfc791]
        ),
    ],
    swiftLanguageModes: [.v6]
)
