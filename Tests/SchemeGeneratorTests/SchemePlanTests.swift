import Testing
import CryptoKit
import Foundation

@Suite struct SchemePlanTests {
  func plan(
    products: [String], existing: [String] = [], excluded: [String] = [], overwrite: Bool = false,
    remove: Bool = false
  ) -> SchemePlan {
    SchemePlan(
      productNames: products, existingSchemes: existing, excludedSchemes: excluded,
      overwriteAlreadyGeneratedSchemes: overwrite, removeNotGeneratedSchemes: remove)
  }

  @Test func createsSchemesForNewProductsOnly() {
    let plan = plan(products: ["B", "A", "C"], existing: ["A"])
    #expect(plan.toCreate == ["B", "C"])
    #expect(plan.toOverwrite.isEmpty)
    #expect(plan.toRemove.isEmpty)
    #expect(plan.toWrite == ["B", "C"])
  }

  @Test func overwritesExistingProductSchemesWhenAsked() {
    let plan = plan(products: ["A", "B"], existing: ["A", "Old"], overwrite: true)
    #expect(plan.toCreate == ["B"])
    #expect(plan.toOverwrite == ["A"])
    #expect(plan.toWrite == ["B", "A"])
  }

  @Test func removesSchemesWithoutAProductWhenAsked() {
    #expect(plan(products: ["A"], existing: ["A", "Old", "Older"], remove: true).toRemove == ["Old", "Older"])
    #expect(plan(products: ["A"], existing: ["A", "Old"], remove: false).toRemove.isEmpty)
  }

  @Test func neverRemovesExcludedSchemes() {
    let plan = plan(products: ["A"], existing: ["A", "ATests", "Old"], excluded: ["ATests"], remove: true)
    #expect(plan.toRemove == ["Old"])
  }

  @Test func duplicateProductNamesAreWrittenOnce() {
    #expect(plan(products: ["A", "A"]).toWrite == ["A"])
  }

  @Test func manyProducts() {
    let products = (0..<500).map { "Feature\($0)" }
    let plan = plan(products: products, existing: Array(products.prefix(100)) + ["Gone"], remove: true)
    #expect(plan.toCreate.count == 400)
    #expect(plan.toRemove == ["Gone"])
  }
}

@Suite struct SchemeNamingTests {
  @Test func readsSchemeNamesFromFileNames() {
    #expect(SchemeNaming.schemeName(fileName: "App.xcscheme") == "App")
    #expect(SchemeNaming.schemeName(fileName: "My.Feature.xcscheme") == "My.Feature")
    #expect(SchemeNaming.schemeName(fileName: "README.md") == nil)
    #expect(SchemeNaming.schemeName(fileName: ".xcscheme") == nil)
    #expect(SchemeNaming.schemeName(fileName: "Café.xcscheme") == "Café")
    #expect(SchemeNaming.schemeName(fileName: "App.xcscheme.bak") == nil)
  }

  @Test func fileNameRoundTrips() {
    #expect(SchemeNaming.fileName(scheme: "App") == "App.xcscheme")
    #expect(SchemeNaming.schemeName(fileName: SchemeNaming.fileName(scheme: "App")) == "App")
  }
}

@Suite struct PluginArgumentsTests {
  @Test func readsTheConfigurationFileName() {
    #expect(
      PluginArguments.configurationFileName(["--confFile", "other.json"], current: "schemeGenerator.json")
        == "other.json")
    #expect(PluginArguments.configurationFileName([], current: "schemeGenerator.json") == "schemeGenerator.json")
  }

  @Test func aTrailingFlagKeepsTheCurrentName() {
    #expect(PluginArguments.configurationFileName(["--confFile"], current: "a.json") == "a.json")
  }
}

@Suite struct ProductNamesHashTests {
  @Test func isTheHexSHA256OfTheNewlineJoinedNames() {
    // printf 'A\nB' | shasum -a 256
    #expect(
      ProductNamesHash.hash(["A", "B"]) == "23519a43c66b4c342f25b32e09797ec5f3fc0be388cd8243fb3449afbdce4013")
    #expect(ProductNamesHash.hash(["A", "B"]) != ProductNamesHash.hash(["B", "A"]))
  }

  @Test(arguments: [[], ["App"], ["Feature", "Café", "日本"], (0..<300).map { "Module\($0)" }])
  func matchesTheFormatBasedEncoding(names: [String]) {
    let reference = SHA256.hash(data: Data(names.joined(separator: "\n").utf8))
      .map { String(format: "%02x", $0) }.joined()
    #expect(ProductNamesHash.hash(names) == reference)
  }
}

@Suite struct XcschemeTemplateTests {
  @Test func replacesEveryPlaceholder() {
    let scheme = XcschemeTemplate.render(productName: "Feature")
    #expect(!scheme.contains("__LIBRARY__"))
    #expect(scheme.components(separatedBy: "BlueprintName = \"Feature\"").count == 3)
    #expect(scheme == xcscheme.replacingOccurrences(of: "__LIBRARY__", with: "Feature"))
    #expect(scheme.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
  }

  @Test(arguments: ["", "A", "Café", "日本Module", "Has__LIBRARY__Inside"])
  func matchesStringReplacement(productName: String) {
    let reference = xcscheme.replacingOccurrences(of: "__LIBRARY__", with: productName)
    #expect(XcschemeTemplate.render(productName: productName) == reference)
    #expect(XcschemeTemplate.renderData(productName: productName) == reference.data(using: .utf8))
  }
}

@Suite struct ConfigurationCodingTests {
  @Test func decodesTheDocumentedConfiguration() throws {
    let json = """
      {
        "schemesDirectory": "Project/project.xcworkspace/xcshareddata/xcschemes",
        "excludedSchemes": ["Target1Tests", "Target2Tests"],
        "removeNotGeneratedSchemes": true,
        "overwriteAlreadyGeneratedSchemes": false,
        "verbose": true
      }
      """
    let config = try JSONDecoder().decode(SchemeGeneratorConfiguration.self, from: Data(json.utf8))
    #expect(config.schemesDirectory?.path.hasSuffix("Project/project.xcworkspace/xcshareddata/xcschemes") == true)
    #expect(config.excludedSchemes == ["Target1Tests", "Target2Tests"])
    #expect(config.removeNotGeneratedSchemes)
    #expect(!config.overwriteAlreadyGeneratedSchemes)
    #expect(config.verbose)
  }

  @Test func toolConfigurationRoundTrips() throws {
    let tool = ToolConfiguration(defaultConfigFileName: "a.json", lastProductNamesHash: "abc")
    let decoded = try JSONDecoder().decode(ToolConfiguration.self, from: JSONEncoder().encode(tool))
    #expect(decoded.defaultConfigFileName == "a.json")
    #expect(decoded.lastProductNamesHash == "abc")
  }
}
