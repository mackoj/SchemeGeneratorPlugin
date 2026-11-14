import LLMCheck
import Testing

/// The rules, run on the repository. A failure prints the rule, why it exists and how to fix it.
@Suite("Architecture rules")
struct ArchitectureRules {
  static func plugin() throws -> Scope { try repository().productionCode.in("/Plugins") }
  static func core() throws -> Scope { try plugin().in("Plugins/SchemeGeneratorPlugin/Core") }
  static func tests() throws -> Scope { try repository().testCode.in("/Tests") }

  @Test func coreIsPure() throws {
    let core = try Self.core()
    #expect(core.relativePaths.count >= 4)
    expectNone(Detect.impureCode(in: core), rule: .coreIsPure)
  }

  @Test func coreImportsStayWithinBudget() throws {
    expectNone(Detect.importsOverBudget(in: try Self.core()), rule: .coreImportsStayWithinBudget)
  }

  @Test func fatalErrorsEmitDiagnostics() throws {
    let plugin = try Self.plugin()
    #expect(plugin.containing("fatalError(.error").relativePaths.count >= 1)
    expectNone(Detect.bareFatalErrors(in: plugin), rule: .fatalErrorsEmitDiagnostics)
  }

  @Test func testsUseSwiftTesting() throws {
    let tests = try Self.tests()
    #expect(tests.containing("import Testing").relativePaths.count >= 1)
    expectNone(Detect.xcTestImports(in: tests), rule: .testsUseSwiftTesting)
  }

  @Test func testsAreNotDisabled() throws {
    expectNone(Detect.disabledTests(in: try Self.tests()), rule: .testsAreNotDisabled)
  }
}

/// Keeps `docs/architecture-rules.md` in step with the rules. Regenerate with
/// `LLM_CHECK_RECORD=1 swift test --package-path Architecture`.
@Test func rulesDocumentIsUpToDate() throws {
  let catalog = RuleCatalog(allRules)
  #expect(catalog.duplicateIDs.isEmpty)
  try expectFile(
    "docs/architecture-rules.md", in: repository(),
    matches: catalog.markdown(
      title: "Architecture rules",
      introduction: """
        The mechanical part of `CODING_STANDARDS.md`, enforced by the `Architecture/` package with \
        [swift-llm-check](https://github.com/mackoj/swift-llm-check): `swift test --package-path Architecture` \
        (macOS). Generated from its rules; do not edit by hand.
        """))
}
