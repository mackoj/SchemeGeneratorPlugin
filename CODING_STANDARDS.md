# Coding standards

Read during review. The mechanical part is enforced by `swift test --package-path Architecture` and listed in
[`docs/architecture-rules.md`](docs/architecture-rules.md).

## Shape of the plugin

- **Pure core, thin shell.** `Plugins/SchemeGeneratorPlugin/Core/` holds every decision: which schemes to create,
  overwrite or remove (`SchemePlan`), the scheme XML (`XcschemeTemplate`), the product-list hash, argument parsing and
  the configuration types. It imports only Foundation and CryptoKit and performs no I/O. `SchemeGenerator.swift` reads
  the configuration and the schemes directory, calls the core, then writes and deletes files.
- **One copy of the core.** A plugin target cannot be imported, so `Tests/SchemeGeneratorTests/Core` and
  `Benchmarks/Sources/SchemeGeneratorCore/Core` are symlinks to `Plugins/SchemeGeneratorPlugin/Core`. Never copy a file
  instead of linking it; a new core file is picked up by both automatically.
- **Report through Diagnostics.** Messages users must see go through `Diagnostics.emit`, which Xcode shows in the
  Report navigator. The plugin stops with the module's `fatalError(.error, "…")`, which emits first; a bare
  `fatalError("…")` shows only "plug-in crashed". Messages name the file or setting at fault.
- **No new dependencies.** The package has none, and users pull it into their app's package graph.
- **Supported toolchains.** `swift-tools-version: 5.7` and macOS 12 stay as they are: raising either is a breaking
  change for users and a minor version bump.

## Simplicity

- **Boring code.** The minimum that solves the problem; no option nobody asked for.
- **Surgical diffs.** Every changed line traces to the request; match the surrounding file (two-space indent).
- **Behaviour is the contract.** Users' `schemeGenerator.json` files and generated schemes must keep working: a change
  to what is written, overwritten or removed is called out in the pull request and the release notes.

## Tests

- **Swift Testing only.** `@Suite`, `@Test`, `#expect`, `#require`; no XCTest.
- **Test the core.** A decision that can be made without the disk belongs in `Core/` and gets a test in
  `Tests/SchemeGeneratorTests`. CI also runs the plugin end to end on a sample package.
