// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SchemeGeneratorPlugin",
  platforms: [.macOS(.v12)],
  products: [
    .plugin(name: "SchemeGeneratorPlugin", targets: ["SchemeGeneratorPlugin"]),
  ],
  targets: [
    .binaryTarget(
      name: "scheme-generator",
      url: "https://github.com/mackoj/SchemeGenerator/releases/download/0.3.0/scheme-generator.artifactbundle.zip",
      checksum: "80767ae49f38b46ed23e76dca668599a7d2b4b86cb823842967391ffb04b131f"
    ),
    .plugin(
      name: "SchemeGeneratorPlugin",
      capability: .command(
        intent: .custom(
          verb: "scheme-generator",
          description: "This tool generate the schemes."
        ),
        permissions: [
          .writeToPackageDirectory(reason: "This plug-in need to update the schemes in the schemesDirectory folder definied in your configuration file."),
        ]
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
