import LLMCheck

/// The SchemeGeneratorPlugin repository, rooted where `.llm-check.yaml` is. Its file list and every parsed file are
/// shared by all suites, which Swift Testing runs in parallel.
func repository() throws -> Codebase { try Codebase() }

extension RuleCategory {
  static let core = RuleCategory(
    "core",
    description: "The pure core shared with tests and benchmarks. Read before you add code to `Core/`."
  )
  static let plugin = RuleCategory(
    "plugin",
    description: "The plugin shell that talks to SwiftPM and the disk. Read before you add a failure path."
  )
  static let testing = RuleCategory(
    "testing",
    description: "Swift Testing, and no silenced tests. Read before you add or skip a test."
  )
}
