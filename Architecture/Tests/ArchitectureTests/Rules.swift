import LLMCheck

extension Rule {
  static let coreIsPure = Rule(
    id: "core-is-pure",
    title: "`Plugins/SchemeGeneratorPlugin/Core` performs no I/O and emits no output.",
    category: .core,
    rationale: """
      `Core/` holds the plugin's decisions (which schemes to write, overwrite or remove, the scheme XML, the \
      product-list hash, argument parsing). It is compiled a second time by the test target and the benchmarks \
      through a symlink (CODING_STANDARDS.md, "Pure core, thin shell"), so it must give the same answer for the same \
      input with no package, no disk and no Xcode around. A `FileManager`, `FileHandle`, `ProcessInfo`, `print` or \
      `Diagnostics` call there makes the tests touch the machine and the benchmarks measure the disk.
      """,
    howToFix: """
      Pass the value in (the existing scheme names, the arguments) and return a value the shell in \
      `SchemeGenerator.swift` acts on. Reading, writing, deleting and reporting stay in the shell.
      """,
    badExample: """
      // Core/SchemePlanning.swift
      let existing = try FileManager.default.contentsOfDirectory(atPath: directory)
      """,
    goodExample: """
      // SchemeGenerator.swift reads the directory, Core decides:
      let plan = SchemePlan(productNames: names, existingSchemes: existing, …)
      """
  )

  static let coreImportsStayWithinBudget = Rule(
    id: "core-imports-stay-within-budget",
    title: "`Core/` imports only Foundation and CryptoKit.",
    category: .core,
    rationale: """
      A plugin target cannot be imported, so tests and benchmarks compile `Core/` as their own sources. They can \
      do that only while it needs nothing but the SDK: `import PackagePlugin` exists only inside a running plugin, \
      and any other module would be a dependency the plugin's users never asked for.
      """,
    howToFix: """
      Keep `PackagePlugin` (`Diagnostics`, `PluginContext`, `Path`) in `SchemeGenerator.swift` or \
      `SchemeGeneratorPlugin.swift` and pass plain values (`String`, `URL`, `[String]`) into `Core/`.
      """,
    badExample: """
      // Core/SchemePlanning.swift
      import PackagePlugin
      """,
    goodExample: """
      // Core/SchemePlanning.swift
      import CryptoKit
      import Foundation
      """
  )

  static let fatalErrorsEmitDiagnostics = Rule(
    id: "fatal-errors-emit-diagnostics",
    title: "The plugin stops with `fatalError(.error, \"…\")`, never a bare `fatalError(\"…\")`.",
    category: .plugin,
    rationale: """
      Users run the plugin from Xcode, where a bare `fatalError` shows only "plug-in crashed". The module's \
      `fatalError(_:_:)` first emits the message through `Diagnostics`, so it appears in Xcode's Report navigator \
      and in `swift package` output with its severity (CODING_STANDARDS.md, "Report through Diagnostics").
      """,
    howToFix: "Pass a severity and a message that names the file or setting at fault.",
    badExample: #"fatalError("Failed to decode JSON file")"#,
    goodExample: #"fatalError(.error, "Failed to decode JSON file \(configurationFileURL.path)")"#
  )

  static let testsUseSwiftTesting = Rule(
    id: "tests-use-swift-testing",
    title: "Tests use Swift Testing, never XCTest.",
    category: .testing,
    rationale: """
      The suite is Swift Testing only (CODING_STANDARDS.md, "Tests"): `@Test`, `#expect` and `#require` give one \
      failure message style, parameterised tests and parallel runs.
      """,
    howToFix: "Write an `@Suite` of `@Test` functions with `#expect` and `#require`, and `import Testing`.",
    badExample: """
      import XCTest
      final class SchemePlanTests: XCTestCase { func testCreate() { XCTAssertEqual(…) } }
      """,
    goodExample: """
      import Testing
      @Suite struct SchemePlanTests { @Test func create() { #expect(…) } }
      """
  )

  static let testsAreNotDisabled = Rule(
    id: "tests-are-not-disabled",
    title: "No test or suite is `.disabled`.",
    category: .testing,
    rationale: """
      A disabled test still reads as coverage while checking nothing. A failing behaviour is either fixed, or \
      asserted as a known issue that names its tracking issue.
      """,
    howToFix: "Fix the code or the test. If the bug must wait, wrap the failing part in `withKnownIssue(\"…#N\")`.",
    badExample: "@Test(.disabled(\"flaky\")) func removesObsoleteSchemes() {",
    goodExample: "@Test func removesObsoleteSchemes() {"
  )
}

/// Every rule, in the order `docs/architecture-rules.md` lists them.
let allRules: [Rule] = [
  .coreIsPure, .coreImportsStayWithinBudget, .fatalErrorsEmitDiagnostics, .testsUseSwiftTesting,
  .testsAreNotDisabled,
]
