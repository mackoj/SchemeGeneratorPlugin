import Foundation
import PackagePlugin
import CryptoKit

@main
struct SchemeGeneratorPlugin: CommandPlugin {
  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    let productNames = context.package.products.map(\.name)
    let packageTempFolder = FileURL(fileURLWithPath: context.pluginWorkDirectory.string)
    let packageDirectory = FileURL(fileURLWithPath: context.package.directory.string)
    
    SchemeGenerator.generateSchemes(packageDirectory, arguments, productNames, packageTempFolder)
    
    Diagnostics.emit(.remark, "Finished")
  }
}

public func fatalError(_ severity: PackagePlugin.Diagnostics.Severity, _ description: String, file: StaticString = #file, line: UInt = #line) -> Never {
  Diagnostics.emit(severity, description)
  fatalError(file: file, line: line)
}
