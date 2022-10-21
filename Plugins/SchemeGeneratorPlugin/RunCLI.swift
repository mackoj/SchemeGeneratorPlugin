import Foundation
import PackagePlugin

extension SchemeGeneratorPlugin {
  func generateSchemes(context: PackagePlugin.PluginContext, arguments: [String]) throws {
    var tool: PluginContext.Tool!
    do {
      tool = try context.tool(named: "scheme-generator")
    } catch {
      Diagnostics.emit(.error, "Failed to find tool scheme-generator.")
    }
    
    let toolURL = URL(fileURLWithPath: tool.path.string)
    
    var processArguments: [String] = []
    processArguments.append(contentsOf: arguments)
    
    let process = Process()
    process.executableURL = toolURL
    process.arguments = processArguments
    do {
      try process.run()
    } catch {
      Diagnostics.emit(.error, "Failed run process \(process.description).")
    }
    process.waitUntilExit()
    
    if process.terminationReason == .exit, process.terminationStatus == 0 {
      Diagnostics.emit(.remark, "Schemes generated.")
    } else {
      let problem = "\(process.terminationReason):\(process.terminationStatus)"
      Diagnostics.emit(.error, "scheme-generator invocation failed: \(problem)")
    }
  }
}
