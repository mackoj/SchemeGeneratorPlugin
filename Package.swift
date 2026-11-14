// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SchemeGeneratorPlugin",
  platforms: [.macOS(.v12)],
  products: [
    .plugin(name: "SchemeGeneratorPlugin", targets: ["Scheme Generator"]),
  ],
  targets: [
    .plugin(
      name: "Scheme Generator",
      capability: .command(
        intent: .custom(
          verb: "scheme-generator",
          description: "Generate Xcode Schemes based on Package.swift products and schemeGenerator.json"
        ),
        permissions: [
          .writeToPackageDirectory(reason: "This plug-in need to update the schemes in the schemesDirectory folder definied in your configuration file."),
        ]
      ),
      path: "Plugins/SchemeGeneratorPlugin"
    ),
    // The plugin's pure logic, tested on its own: Tests/SchemeGeneratorTests/Core is a symlink to
    // Plugins/SchemeGeneratorPlugin/Core, since a test target cannot depend on a plugin target.
    .testTarget(
      name: "SchemeGeneratorTests",
      path: "Tests/SchemeGeneratorTests"
    ),
  ]
)
