import Foundation
import PackagePlugin
import CryptoKit

@main
struct SchemeGeneratorPlugin: CommandPlugin {
  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    let productNames = context.package.products.map(\.name)
    let packageTempFolder = URL(fileURLWithPath: context.pluginWorkDirectory.string)
    let packageDirectory = URL(fileURLWithPath: context.package.directory.string)
    let configurationFileURL = packageDirectory.appendingPathComponent("scheme_generator.yaml")
    
    if FileManager.default.fileExists(atPath: configurationFileURL.path) == false {
      Diagnostics.emit(.error, "Please add a configuration file at \(configurationFileURL.path)")
    }
    
    guard let data = productNames
      .joined(separator: "\n")
      .data(using: .utf8)
    else { return }
    
    let hash = SHA256.hash(data: data)
      .compactMap { String(format: "%02x", $0) }
      .joined()
    
    Diagnostics.emit(.remark, "packageTempFolder: \(packageTempFolder.path)")

    let productNamesFileURL = packageTempFolder.appendingPathComponent(hash)
    if FileManager.default.fileExists(atPath: packageTempFolder.path) { return }
    
    try data.write(to: packageTempFolder)

    try generateSchemes(
      context: context,
      arguments: [
        "--configuration-file-url \"\(configurationFileURL.path)\"",
        "--product-names-file-url \"\(productNamesFileURL.path)\"",
      ]
    )
    
    Diagnostics.emit(.remark, "Finished")
  }
}
