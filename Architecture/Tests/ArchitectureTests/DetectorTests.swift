import LLMCheck
import Testing

/// Each detector on snippets: it finds what its rule forbids and nothing its rule allows.
@Suite struct DetectorTests {
  func scope(_ source: String, at path: String = "Plugins/SchemeGeneratorPlugin/Core/File.swift") -> Scope {
    Scope(files: [SourceFile(path: path, source: source)])
  }

  @Test func impureCodeIsFound() {
    let found = Detect.impureCode(
      in: scope(
        """
        let files = FileManager.default.contentsOfDirectory(atPath: "x")
        print("plan")
        Diagnostics.emit(.remark, "x")
        let data = try Data(contentsOf: url)
        let text = try String(contentsOfFile: path)
        func write(_ handle: FileHandle) {}
        """))
    #expect(found.map(\.location.line).sorted() == [1, 2, 3, 4, 5, 6])
  }

  @Test func pureCodePasses() {
    let found = Detect.impureCode(
      in: scope(
        """
        // FileManager and print are fine in a comment.
        let message = "FileManager.default and print() are fine in a string"
        let data = Data(names.joined(separator: "\\n").utf8)
        let text = String(decoding: bytes, as: UTF8.self)
        logger.print(plan)
        """))
    #expect(found.isEmpty)
  }

  @Test func importsOverBudgetAreFound() {
    let found = Detect.importsOverBudget(in: scope("import Foundation\nimport PackagePlugin\nimport CryptoKit\nimport Yams"))
    #expect(found.map(\.node.moduleName) == ["PackagePlugin", "Yams"])
  }

  @Test func bareFatalErrorsAreFound() {
    let found = Detect.bareFatalErrors(
      in: scope(
        """
        fatalError("Failed to decode")
        fatalError()
        fatalError(.error, "Failed to decode \\(path)")
        fatalError(.remark, "There is no change in products list.")
        public func fatalError(_ severity: Severity, _ description: String, file: StaticString = #file, line: UInt = #line) -> Never {
          Diagnostics.emit(severity, description)
          fatalError(file: file, line: line)
        }
        logger.fatalError("x")
        """, at: "Plugins/SchemeGeneratorPlugin/SchemeGenerator.swift"))
    #expect(found.map(\.location.line) == [1, 2])
  }

  @Test func xcTestImportsAreFound() {
    let found = Detect.xcTestImports(in: scope("import XCTest\nimport Testing", at: "Tests/T/A.swift"))
    #expect(found.map(\.location.line) == [1])
  }

  @Test func disabledTestsAreFound() {
    let found = Detect.disabledTests(
      in: scope(
        """
        @Test(.disabled("flaky")) func a() {}
        @Suite(.disabled()) struct B {}
        @Test func c() { rule.disabled() }
        """, at: "Tests/T/A.swift"))
    #expect(found.map(\.location.line) == [1, 2])
  }
}
