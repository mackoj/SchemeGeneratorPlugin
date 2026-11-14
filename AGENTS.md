# Agent notes

`SchemeGeneratorPlugin` is a SwiftPM command plugin (`swift package scheme-generator`) that writes an Xcode
`.xcscheme` for every product of a package into the `schemesDirectory` of `schemeGenerator.json`. Usage is in
`README.md`; review rules in `CODING_STANDARDS.md`.

## Build and test
- `swift build --build-tests` and `swift test`. The tests compile `Plugins/SchemeGeneratorPlugin/Core` through the
  `Tests/SchemeGeneratorTests/Core` symlink.
- Architecture rules: `swift test --package-path Architecture` (macOS) runs the mechanical part of
  `CODING_STANDARDS.md` as [swift-llm-check](https://github.com/mackoj/swift-llm-check) rules, listed in
  `docs/architecture-rules.md`. Fix the code, never add a baseline. A new or changed rule needs its rationale, bad and
  good examples, a `DetectorTests` case, and `LLM_CHECK_RECORD=1 swift test --package-path Architecture` to regenerate
  the document.
- Benchmarks: `swift package --package-path Benchmarks benchmark`; measuring and profiling in `docs/performance.md`.
- `site/index.html` is the landing page (GitHub Pages). Its install snippet and claims repeat the README: update both.
