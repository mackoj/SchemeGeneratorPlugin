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
      )
    ),
    //    .testTarget(
    //      name: "SchemeGeneratorPluginTests",
    //      dependencies: [
    //        "SchemeGeneratorPlugin"
    //      ]
    //    ),
  ]
)
