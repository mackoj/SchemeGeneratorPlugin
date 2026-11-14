# Measuring and profiling

The benchmarks live in `Benchmarks/`, a separate package on
[package-benchmark](https://github.com/ordo-one/package-benchmark), so the plugin never depends on it. A plugin target
cannot be imported, so the benchmark target compiles the plugin's pure core itself:
`Benchmarks/Benchmarks/SchemeGeneratorBenchmarks/Core` is a symlink to `Plugins/SchemeGeneratorPlugin/Core`. What is
measured is everything the plugin does per run except touching the disk: hash the product list, plan which schemes to
create, overwrite and remove, render each `.xcscheme`. Reading the configuration and writing files stay in
`SchemeGenerator.swift` and are not benchmarked.

Run everything from the repository root. package-benchmark uses jemalloc for malloc counts (`brew install jemalloc`);
`BENCHMARK_DISABLE_JEMALLOC=true` builds without it, as CI does.

## Measure a change

Save `main`'s numbers before you change code, then compare the same harness after:

```sh
swift package --package-path Benchmarks benchmark --format markdown --no-progress > .build/before.md
# … change the code …
swift package --package-path Benchmarks benchmark --format markdown --no-progress > .build/after.md
swift run --package-path Benchmarks -c release p50 .build/before.md .build/after.md
```

`p50` prints a Markdown table of each benchmark's median wall clock and mallocs, before → after, ready for the pull
request. Malloc and retain counts are deterministic; wall clock moves a few percent between runs.

- `--filter` takes one regular expression per flag; repeat the flag rather than writing `A|B`.
- The per-operation benchmarks (`scalingFactor: .kilo`) are marked `*` in package-benchmark's tables.

## Profile a benchmark

```sh
Benchmarks/scripts/profile.sh 'Full run without disk, 1000 products' 20
```

It runs that one benchmark under Instruments' Time Profiler and prints the functions the samples were in (**Self**) and
the core functions with the most samples under them (**Inclusive**). The trace stays in `Benchmarks/.build/profiles/`.

## What has paid off

Measured on an M-series Mac, Swift 6.4, release build (0.5.9):

| Benchmark | Wall clock p50 (µs) | Mallocs p50 |
|---|---|---|
| Full run without disk, 1000 products | 15368 → 1731 (0.11x) | 6388 → 3026 (0.47x) |
| Render schemes, 1000 products | 13369 → 519 (0.04x) | 4100 → 1000 (0.24x) |
| Render and encode schemes, 1000 products | 14066 → 729 (0.05x) | 6100 → 3000 (0.49x) |
| Hash product names, 100 products | 48 → 7 (0.15x) | 273 → 11 (0.04x) |
| Read scheme names, 1000 files | 371 → 267 (0.72x) | 1912 → 1912 |
| Plan schemes, 1000 products | 803 → 782 | 19 → 19 |

- **Cut the template once, append per product.** `replacingOccurrences(of:with:)` bridged to `NSString` and searched
  the 2.4 KB template again for every product. The template is now split at `__LIBRARY__` once (`XcschemeTemplate.pieces`)
  and each scheme is appended into a string reserved at its final size. `renderData` encodes with `Data(string.utf8)`
  instead of `data(using:)`.
- **Hex without `String(format:)`.** The product-list hash formatted each of its 32 bytes with `String(format: "%02x")`,
  one Foundation formatter call and allocation per byte; a lookup table into a reserved byte buffer is one allocation.
- **Count UTF-8, not Characters.** `String.count` walks grapheme clusters; the scheme-file suffix is ASCII, so
  `utf8.count` is the same number in O(1).
- **Not worth it here:** the plan is now dominated by sorting (the order schemes are written and listed in), under a
  millisecond for 1,000 products; writing the files dominates a real run.
