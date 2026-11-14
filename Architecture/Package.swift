// swift-tools-version: 6.0
import PackageDescription

// SchemeGeneratorPlugin's mechanical rules (CODING_STANDARDS.md) as tests, written with swift-llm-check.
// Test-only and macOS-only, so the plugin never builds it and its swift-tools-version 5.7 support is unaffected.
// Run from the repository root: `swift test --package-path Architecture`.
let package = Package(
  name: "Architecture",
  platforms: [.macOS(.v14)],
  dependencies: [
    .package(url: "https://github.com/mackoj/swift-llm-check.git", from: "0.5.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", "601.0.0"..<"700.0.0"),
  ],
  targets: [
    .testTarget(
      name: "ArchitectureTests",
      dependencies: [
        .product(name: "LLMCheck", package: "swift-llm-check"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
      ]
    )
  ]
)
