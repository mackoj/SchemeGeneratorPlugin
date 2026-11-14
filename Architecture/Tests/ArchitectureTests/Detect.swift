import LLMCheck
import SwiftSyntax

/// The repository-specific detectors (the shared ones are swift-llm-check built-ins), separate from the codebase so `DetectorTests` can run them on snippets.
enum Detect {
  /// Types whose every use is I/O, process state or plugin output.
  static let impureTypes: Set<String> = [
    "FileManager", "FileHandle", "ProcessInfo", "Process", "Diagnostics", "URLSession", "UserDefaults", "Bundle",
  ]

  /// Uses of an impure type, and `print(…)`, `Data(contentsOf:)`, `String(contentsOf…:)`.
  static func impureCode(in scope: Scope) -> [Match<Syntax>] {
    let calls = scope.calls(named: "print", "Data", "String").filter { call in
      guard call.node.calledExpression.is(DeclReferenceExprSyntax.self) else { return false }
      if call.node.calledName == "print" { return true }
      return call.node.arguments.first?.label?.text.hasPrefix("contentsOf") == true
    }
    return scope.references(to: impureTypes) + calls.map(\.erased)
  }

  /// What `Core/` may import.
  static let coreModules: Set<String> = ["Foundation", "CryptoKit"]

  /// Imports in `Core/` outside its budget.
  static func importsOverBudget(in scope: Scope) -> [Match<ImportDeclSyntax>] {
    scope.imports.filter { !coreModules.contains($0.node.moduleName) }
  }

  /// `fatalError(…)` calls whose first argument is not a severity such as `.error`, outside the `fatalError`
  /// helper that wraps Swift's own.
  static func bareFatalErrors(in scope: Scope) -> [Match<FunctionCallExprSyntax>] {
    scope.calls(named: "fatalError").filter { call in
      guard call.node.receiver == nil else { return false }
      if let first = call.node.arguments.first, first.label == nil,
        let member = first.expression.as(MemberAccessExprSyntax.self), member.base == nil
      {
        return false
      }
      let function = sequence(first: Syntax(call.node), next: \.parent)
        .lazy.compactMap { $0.as(FunctionDeclSyntax.self) }.first
      return function?.name.text != "fatalError"
    }
  }
}
