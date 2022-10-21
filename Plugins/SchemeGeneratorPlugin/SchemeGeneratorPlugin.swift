import Foundation
import PackagePlugin
import CryptoKit

@main
struct SchemeGeneratorPlugin: CommandPlugin {
  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    let productNames = context.package.products.map(\.name)
    let packageTempFolder = URL(fileURLWithPath: context.pluginWorkDirectory.string)
    let packageDirectory = URL(fileURLWithPath: context.package.directory.string)
    let configurationFileName = (arguments.first != nil && arguments.first!.isEmpty == false) ? arguments.first! : "conf_scheme_generator.json"
    let configurationFileURL = packageDirectory.appendingPathComponent(configurationFileName)
    
    if FileManager.default.fileExists(atPath: configurationFileURL.path) == false {
      Diagnostics.emit(.error, "Please add a configuration file at \(configurationFileURL.path)(example: https://github.com/mackoj/SchemeGeneratorPlugin/blob/main/conf_scheme_generator.json).")
      Diagnostics.emit(.error, "We will generate a default one for you but you will need to set the schemesDirectory.")
      var defaultConf: Data!
      do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        defaultConf = try encoder.encode(SchemeGeneratorConfiguration())
      } catch {
        Diagnostics.emit(.error, "Failed to encode a default configuration.")
      }
      do {
        try defaultConf.write(to: configurationFileURL)
      } catch {
        Diagnostics.emit(.error, "Failed to encode write a default configuration at \(configurationFileURL.path)")
      }
    }

    if productNames.isEmpty {
      Diagnostics.emit(.warning, "No products found.")
      return
    }
    Diagnostics.emit(.remark, "Found \(productNames.count) products.")

    guard let data = productNames
      .joined(separator: "\n")
      .data(using: .utf8)
    else {
      Diagnostics.emit(.error, "Failed to convert data.")
      return
    }
    
    let hash = SHA256.hash(data: data)
      .compactMap { String(format: "%02x", $0) }
      .joined()

    let productNamesFileURL = packageTempFolder.appendingPathComponent(hash)

    if FileManager.default.fileExists(atPath: productNamesFileURL.path) {
      Diagnostics.emit(.remark, "There is no change in products list.")
      return
    }

    do {
      try data.write(to: productNamesFileURL)
    } catch {
      Diagnostics.emit(.error, "Failed to write temporary product list in \(productNamesFileURL.path).")
    }

    SchemeGenerator.process(configurationFileURL, productNamesFileURL)

    Diagnostics.emit(.remark, "Finished")
  }
}
