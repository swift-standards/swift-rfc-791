// swift-tools-version: 6.2
import PackageDescription

extension String {
    static let rfc791 = "RFC 791"
}

extension Target.Dependency {
    static let rfc791 = Self.target(name: .rfc791)
    static let standards = Self.product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    static let binary = Self.product(name: "Binary Primitives", package: "swift-binary-primitives")
    static let incits41986 = Self.product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
}

let package = Package(
    name: "swift-rfc-791",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(name: .rfc791, targets: [.rfc791])
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-binary-primitives"),
        .package(path: "../swift-incits-4-1986"),
    ],
    targets: [
        .target(
            name: .rfc791,
            dependencies: [.standards, .binary, .incits41986]
        ),
        .testTarget(
            name: .rfc791.tests,
            dependencies: [.rfc791]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}
