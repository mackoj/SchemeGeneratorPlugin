// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SchemeGeneratorPlugin",
  products: [
    .plugin(name: "SchemeGeneratorPlugin", targets: ["SchemeGeneratorPlugin"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.2"),
    .package(url: "https://github.com/mackoj/SchemeGenerator.git", from: "0.3.0"),
  ],
  targets: [
    .binaryTarget(
      name: "scheme-generator",
      url: "https://github.com/mackoj/SchemeGenerator/releases/download/0.3.0/scheme-generator.zip",
      checksum: "6002c6bb6730c58af2a683bbe8d5e949d54528b932271608fd53ff193e5ef814"
    ),
    .plugin(
      name: "SchemeGeneratorPlugin",
      capability: .command(
        intent: .custom(verb: "Verb", description: "Description"),
        permissions: [.writeToPackageDirectory(reason: "This plug-in need to update the scheme in the schemesDirectory folder definied in the configuration file.")]
      ),
      dependencies: [
        .target(name: "scheme-generator")
      ]
    ),
//    .testTarget(
//      name: "SchemeGeneratorPluginTests",
//      dependencies: [
//        "SchemeGeneratorPlugin"
//      ]
//    ),
  ]
)
