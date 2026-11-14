# Architecture rules

The mechanical part of `CODING_STANDARDS.md`, enforced by the `Architecture/` package with [swift-llm-check](https://github.com/mackoj/swift-llm-check): `swift test --package-path Architecture` (macOS). Generated from its rules; do not edit by hand.

## core

The pure core shared with tests and benchmarks. Read before you add code to `Core/`.

### `Plugins/SchemeGeneratorPlugin/Core` performs no I/O and emits no output.

`core-is-pure`: `Core/` holds the plugin's decisions (which schemes to write, overwrite or remove, the scheme XML, the product-list hash, argument parsing). It is compiled a second time by the test target and the benchmarks through a symlink (CODING_STANDARDS.md, "Pure core, thin shell"), so it must give the same answer for the same input with no package, no disk and no Xcode around. A `FileManager`, `FileHandle`, `ProcessInfo`, `print` or `Diagnostics` call there makes the tests touch the machine and the benchmarks measure the disk.

**How to fix:** Pass the value in (the existing scheme names, the arguments) and return a value the shell in `SchemeGenerator.swift` acts on. Reading, writing, deleting and reporting stay in the shell.

Bad:

```swift
// Core/SchemePlanning.swift
let existing = try FileManager.default.contentsOfDirectory(atPath: directory)
```

Good:

```swift
// SchemeGenerator.swift reads the directory, Core decides:
let plan = SchemePlan(productNames: names, existingSchemes: existing, …)
```

### `Core/` imports only Foundation and CryptoKit.

`core-imports-stay-within-budget`: A plugin target cannot be imported, so tests and benchmarks compile `Core/` as their own sources. They can do that only while it needs nothing but the SDK: `import PackagePlugin` exists only inside a running plugin, and any other module would be a dependency the plugin's users never asked for.

**How to fix:** Keep `PackagePlugin` (`Diagnostics`, `PluginContext`, `Path`) in `SchemeGenerator.swift` or `SchemeGeneratorPlugin.swift` and pass plain values (`String`, `URL`, `[String]`) into `Core/`.

Bad:

```swift
// Core/SchemePlanning.swift
import PackagePlugin
```

Good:

```swift
// Core/SchemePlanning.swift
import CryptoKit
import Foundation
```

## plugin

The plugin shell that talks to SwiftPM and the disk. Read before you add a failure path.

### The plugin stops with `fatalError(.error, "…")`, never a bare `fatalError("…")`.

`fatal-errors-emit-diagnostics`: Users run the plugin from Xcode, where a bare `fatalError` shows only "plug-in crashed". The module's `fatalError(_:_:)` first emits the message through `Diagnostics`, so it appears in Xcode's Report navigator and in `swift package` output with its severity (CODING_STANDARDS.md, "Report through Diagnostics").

**How to fix:** Pass a severity and a message that names the file or setting at fault.

Bad:

```swift
fatalError("Failed to decode JSON file")
```

Good:

```swift
fatalError(.error, "Failed to decode JSON file \(configurationFileURL.path)")
```

## testing

Swift Testing, and no silenced tests. Read before you add or skip a test.

### Tests use Swift Testing, never XCTest.

`tests-use-swift-testing`: The suite is Swift Testing only (CODING_STANDARDS.md, "Tests"): `@Test`, `#expect` and `#require` give one failure message style, parameterised tests and parallel runs.

**How to fix:** Write an `@Suite` of `@Test` functions with `#expect` and `#require`, and `import Testing`.

Bad:

```swift
import XCTest
final class SchemePlanTests: XCTestCase { func testCreate() { XCTAssertEqual(…) } }
```

Good:

```swift
import Testing
@Suite struct SchemePlanTests { @Test func create() { #expect(…) } }
```

### No test or suite is `.disabled`.

`tests-are-not-disabled`: A disabled test still reads as coverage while checking nothing. A failing behaviour is either fixed, or asserted as a known issue that names its tracking issue.

**How to fix:** Fix the code or the test. If the bug must wait, wrap the failing part in `withKnownIssue("…#N")`.

Bad:

```swift
@Test(.disabled("flaky")) func removesObsoleteSchemes() {
```

Good:

```swift
@Test func removesObsoleteSchemes() {
```
