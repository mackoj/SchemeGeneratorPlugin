// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SchemeGeneratorPlugin",
  products: [
    .plugin(name: "Scheme Generator", targets: ["SchemeGeneratorPlugin"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.2"),
    .package(url: "https://github.com/mackoj/SchemeGenerator.git", from: "0.1.0"),
  ],
  targets: [
    .binaryTarget(
      name: "scheme-generator",
      url: "https://github.com/mackoj/GenerateSchemes/releases/download/0.1.0/scheme-generator.zip",
      checksum: "86589bee4f6212446f6fa646d0fd8b874bf7c5fac079637aad40f71c9583876a"
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
