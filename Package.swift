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
      url: "https://github.com/mackoj/SchemeGenerator/releases/download/0.4.0/scheme-generator.artifactbundle.zip",
      checksum: "e5e6d3d66419d2d09215c572fd11432f151889ff307c46410c5a2bc1fbaadf97"
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
