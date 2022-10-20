import Foundation
import PackagePlugin

extension SchemeGeneratorPlugin {
  func generateSchemes(context: PackagePlugin.PluginContext, arguments: [String]) throws {
    let tool = try context.tool(named: "scheme-generator")
    let toolURL = URL(fileURLWithPath: tool.path.string)
    
    var processArguments: [String] = []
    processArguments.append(contentsOf: arguments)
    
    let process = Process()
    process.executableURL = toolURL
    process.arguments = processArguments
    
    try process.run()
    process.waitUntilExit()
    
    if process.terminationReason == .exit, process.terminationStatus == 0 {
      Diagnostics.emit(.remark, "Schemes generated.")
    } else {
      let problem = "\(process.terminationReason):\(process.terminationStatus)"
      Diagnostics.error("scheme-generator invocation failed: \(problem)")
    }
  }
}
