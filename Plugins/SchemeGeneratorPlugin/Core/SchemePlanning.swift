import CryptoKit
import Foundation

// The plugin's decisions, kept free of I/O and of PackagePlugin so the test target and the benchmarks can compile
// this folder as it is: Tests/SchemeGeneratorTests/Core and Benchmarks/Benchmarks/SchemeGeneratorBenchmarks/Core are
// symlinks to it. SchemeGenerator.swift reads the disk, calls these functions and writes the result.

/// Which scheme files to write and which to delete.
struct SchemePlan: Equatable {
  /// Products that have no scheme yet (or whose scheme is excluded), sorted.
  var toCreate: [String]
  /// Products whose existing scheme is regenerated because `overwriteAlreadyGeneratedSchemes` is on, sorted.
  var toOverwrite: [String]
  /// Existing schemes that match no product, deleted when `removeNotGeneratedSchemes` is on, sorted.
  var toRemove: [String]

  /// Every scheme to write: new ones, then overwritten ones.
  var toWrite: [String] { toCreate + toOverwrite }

  /// - Parameters:
  ///   - productNames: The package's product names.
  ///   - existingSchemes: The names of the `.xcscheme` files already in `schemesDirectory`, without extension.
  init(
    productNames: [String],
    existingSchemes: [String],
    excludedSchemes: [String],
    overwriteAlreadyGeneratedSchemes: Bool,
    removeNotGeneratedSchemes: Bool
  ) {
    var existing = Set(existingSchemes)
    // An excluded scheme is never removed nor counted as existing, so one that is also a product is written again
    // (behaviour kept from 0.5.x).
    existing.subtract(excludedSchemes)
    let products = Set(productNames)

    toCreate = products.subtracting(existing).sorted()
    toOverwrite = overwriteAlreadyGeneratedSchemes ? existing.intersection(products).sorted() : []
    toRemove = removeNotGeneratedSchemes ? existing.subtracting(products).sorted() : []
  }
}

enum SchemeNaming {
  private static let schemeSuffix = ".\(xcschemeExtension)"

  /// The scheme name of a file in `schemesDirectory`, or nil when it is not an `.xcscheme` file.
  static func schemeName(fileName: String) -> String? {
    // UTF-8 counts are O(1); `count` walks every Character. The suffix is ASCII, so both counts agree for it.
    guard fileName.utf8.count > schemeSuffix.utf8.count, fileName.hasSuffix(schemeSuffix) else { return nil }
    return String(fileName.dropLast(schemeSuffix.utf8.count))
  }

  /// The file name of the scheme for `productName`.
  static func fileName(scheme productName: String) -> String {
    "\(productName).\(xcschemeExtension)"
  }
}

enum PluginArguments {
  /// The configuration file name: the value after `--confFile`, else `current`. A trailing `--confFile` with no
  /// value keeps `current`.
  static func configurationFileName(_ arguments: [String], current: String) -> String {
    guard let flag = arguments.firstIndex(of: "--confFile") else { return current }
    let value = arguments.index(after: flag)
    guard value < arguments.endIndex else { return current }
    return arguments[value]
  }
}

enum ProductNamesHash {
  /// The lowercase hex SHA-256 of the product names joined by newlines. Stored in the tool configuration to skip a
  /// run when the product list has not changed.
  static func hash(_ productNames: [String]) -> String {
    let digest = SHA256.hash(data: Data(productNames.joined(separator: "\n").utf8))
    var hex = [UInt8]()
    hex.reserveCapacity(SHA256.byteCount * 2)
    for byte in digest {
      hex.append(hexDigits[Int(byte >> 4)])
      hex.append(hexDigits[Int(byte & 0x0F)])
    }
    return String(decoding: hex, as: UTF8.self)
  }

  private static let hexDigits = Array("0123456789abcdef".utf8)
}
