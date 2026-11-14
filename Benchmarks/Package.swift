// swift-tools-version: 6.1
import PackageDescription

// SchemeGeneratorPlugin's benchmarks, on ordo-one/package-benchmark (https://www.swift.org/blog/benchmarks/). A
// separate package so the plugin never depends on it. A plugin target cannot be imported, so the benchmark target
// compiles the plugin's pure core itself: Benchmarks/SchemeGeneratorBenchmarks/Core is a symlink to
// Plugins/SchemeGeneratorPlugin/Core. Run from the repository root: `swift package --package-path Benchmarks benchmark`.
let package = Package(
  name: "Benchmarks",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(url: "https://github.com/ordo-one/package-benchmark.git", from: "1.38.0")
  ],
  targets: [
    .executableTarget(
      name: "SchemeGeneratorBenchmarks",
      dependencies: [
        .product(name: "Benchmark", package: "package-benchmark")
      ],
      path: "Benchmarks/SchemeGeneratorBenchmarks",
      swiftSettings: [.swiftLanguageMode(.v5)],
      plugins: [
        .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
      ]
    ),
    // Reads two `benchmark --format markdown` outputs and prints each benchmark's p50 before and after.
    .executableTarget(name: "p50", path: "Tools/P50"),
    // Reads an exported Time Profiler table and prints the hottest functions (scripts/profile.sh).
    .executableTarget(name: "hotspots", path: "Tools/Hotspots"),
  ]
)
