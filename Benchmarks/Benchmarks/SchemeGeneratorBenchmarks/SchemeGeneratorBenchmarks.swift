import Benchmark
import Foundation

// The plugin's work per run, minus the disk: hash the product list, plan which schemes to write, render each one.
// A modular app has tens to hundreds of products; 1,000 shows how the cost grows.

func products(_ count: Int) -> [String] { (0..<count).map { "Feature\($0)Module" } }

let benchmarks: @Sendable () -> Void = {
  Benchmark.defaultConfiguration = .init(
    metrics: [.wallClock, .cpuTotal, .mallocCountTotal, .peakMemoryResident, .retainCount],
    // Exact counts and microseconds, so a change of a few percent shows up in a comparison.
    timeUnits: .microseconds,
    units: [.mallocCountTotal: .count, .retainCount: .count],
    maxDuration: .seconds(2),
    maxIterations: 1_000
  )

  let hundred = products(100)
  let thousand = products(1_000)

  Benchmark("Render scheme, one product", configuration: .init(scalingFactor: .kilo)) { benchmark in
    for _ in benchmark.scaledIterations { blackHole(XcschemeTemplate.render(productName: "FeatureModule")) }
  }

  Benchmark("Render schemes, 1000 products") { benchmark in
    for name in thousand { blackHole(XcschemeTemplate.render(productName: name)) }
  }

  Benchmark("Render and encode schemes, 1000 products") { benchmark in
    for name in thousand { blackHole(XcschemeTemplate.renderData(productName: name)) }
  }

  Benchmark("Hash product names, 100 products", configuration: .init(scalingFactor: .kilo)) { benchmark in
    for _ in benchmark.scaledIterations { blackHole(ProductNamesHash.hash(hundred)) }
  }

  Benchmark("Plan schemes, 1000 products") { benchmark in
    // A third exist already, a few are obsolete, overwrite and removal on: every branch of the plan.
    let existing = Array(thousand.prefix(333)) + (0..<20).map { "Obsolete\($0)" }
    blackHole(
      SchemePlan(
        productNames: thousand, existingSchemes: existing, excludedSchemes: ["Obsolete0"],
        overwriteAlreadyGeneratedSchemes: true, removeNotGeneratedSchemes: true))
  }

  Benchmark("Read scheme names, 1000 files") { benchmark in
    let files = thousand.map { SchemeNaming.fileName(scheme: $0) } + ["README.md", ".DS_Store"]
    blackHole(files.compactMap(SchemeNaming.schemeName(fileName:)))
  }

  Benchmark("Full run without disk, 1000 products") { benchmark in
    let existing = Array(thousand.prefix(500))
    blackHole(ProductNamesHash.hash(thousand))
    let plan = SchemePlan(
      productNames: thousand, existingSchemes: existing, excludedSchemes: [],
      overwriteAlreadyGeneratedSchemes: true, removeNotGeneratedSchemes: true)
    for name in plan.toWrite { blackHole(XcschemeTemplate.renderData(productName: name)) }
  }
}
