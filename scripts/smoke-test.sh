#!/bin/sh
# Runs the plugin on a throwaway package with two products and one obsolete scheme, and checks what it wrote.
# Usage, from the repository root: scripts/smoke-test.sh
set -eu

plugin=$(pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/Sources/Alpha" "$work/Sources/Beta" "$work/Generated"
echo 'public let alpha = 1' > "$work/Sources/Alpha/Alpha.swift"
echo 'public let beta = 1' > "$work/Sources/Beta/Beta.swift"
touch "$work/Generated/Obsolete.xcscheme"
cat > "$work/Package.swift" <<MANIFEST
// swift-tools-version: 5.7
import PackageDescription
let package = Package(
  name: "Sample",
  products: [.library(name: "Alpha", targets: ["Alpha"]), .library(name: "Beta", targets: ["Beta"])],
  dependencies: [.package(path: "$plugin")],
  targets: [.target(name: "Alpha"), .target(name: "Beta")]
)
MANIFEST
cat > "$work/schemeGenerator.json" <<'JSON'
{ "schemesDirectory": "Generated", "excludedSchemes": [], "removeNotGeneratedSchemes": true,
  "overwriteAlreadyGeneratedSchemes": false, "verbose": true }
JSON

cd "$work"
swift package --allow-writing-to-package-directory scheme-generator
test -f Generated/Alpha.xcscheme
test -f Generated/Beta.xcscheme
test ! -e Generated/Obsolete.xcscheme
grep -q 'BlueprintName = "Alpha"' Generated/Alpha.xcscheme
echo "smoke test passed"
