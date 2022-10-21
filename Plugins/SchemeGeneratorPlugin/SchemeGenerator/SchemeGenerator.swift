import Foundation

public struct SchemeGenerator {
  
  public static func process(
    _ configurationFileURL: URL,
    _ productNamesFileURL: URL
  ) {
    var config: SchemeGeneratorConfiguration
    do {
      config = try JSONDecoder().decode(SchemeGeneratorConfiguration.self, from: try Data(contentsOf: configurationFileURL))
    } catch {
      fatalError("Failed to decode JSON file \(configurationFileURL.path)")
    }

    if config.verbose { print(config) }
    var fullContent: String? = nil
    do {
      fullContent = String(data: try Data(contentsOf: productNamesFileURL), encoding: .utf8)
    } catch {
      fatalError("Failed to read \(productNamesFileURL.path)")
    }
    guard let fullContent = fullContent else {
      fatalError("\(productNamesFileURL.path) data cannot be nil.")
    }
    if fullContent.isEmpty { fatalError("No product found in fullContent.") }
    let productNames = fullContent.split(separator: "\n").map(String.init)
    if productNames.isEmpty { fatalError("No product found in productNames.") }
    
    let filteredProductNames = filterUsefullProducts(productNames, config)
    if config.verbose {
      print("Schemes that will be created:")
      print(filteredProductNames.joined(separator: "\n"))
    }
    
    self.generateSchemes(filteredProductNames, config)
  }
  
  // MARK: - Private
  private static func filterUsefullProducts(
    _ productNames: [String],
    _ config: SchemeGeneratorConfiguration
  ) -> [String] {
    if FileManager.default.fileExists(atPath: config.schemesDirectory.path) == false {
      do {
        try FileManager.default.createDirectory(at: config.schemesDirectory, withIntermediateDirectories: true)
      } catch {
        fatalError("Schemes output directory(\(config.schemesDirectory)) don't exist and failed to created it.")
      }
    }
    
    // List all the already present schemes files
    // Compare to what to generate and following config update only what necessary
    var content: [URL]
    do {
      content = try FileManager.default.contentsOfDirectory(at: config.schemesDirectory, includingPropertiesForKeys: nil)
    } catch {
      fatalError("Failed to get contentsOfDirectory at \(config.schemesDirectory.path)")
    }
    let schemes = content.filter { fileURL in
      fileURL.pathExtension == xcschemeExtension
    }.map { $0.lastPathComponent.replacingOccurrences(of: ".\($0.pathExtension)", with: "") }
    
    let schemesSet = Set<String>(schemes)
    let productNamesSet = Set<String>(productNames)
    var output: [String] = Array(productNamesSet.subtracting(schemesSet))
    
    if config.overwriteAlreadyGeneratedSchemes {
      output.append(contentsOf: schemesSet.intersection(productNamesSet))
    }
    if config.removeNotGeneratedSchemes {
      let toRemoveSchemes = schemesSet.subtracting(productNamesSet)
      if toRemoveSchemes.isEmpty == false, config.verbose {
        print("Schemes that will be removed:")
        print(toRemoveSchemes.joined(separator: "\n"))
      }
      for libraryName in toRemoveSchemes {
        let schemeToDeleteURL = config.schemesDirectory.appendingPathComponent("\(libraryName).\(xcschemeExtension)")
        do {
          try FileManager.default.removeItem(at: schemeToDeleteURL)
        } catch {
          print("Failed to delete scheme \(libraryName) at \(schemeToDeleteURL.path)")
        }
      }
    }
    return output
  }
  
  private static func generateSchemes(
    _ productNames: [String],
    _ config: SchemeGeneratorConfiguration
  ) {
    for libraryName in productNames {
      let librarySchemeURL = config.schemesDirectory.appendingPathComponent("\(libraryName).\(xcschemeExtension)")
      FileManager.default.createFile(atPath: librarySchemeURL.path, contents: nil)
      var libraryScemeFileHandle: FileHandle
      do {
        libraryScemeFileHandle = try FileHandle(forWritingTo: librarySchemeURL)
      } catch {
        fatalError("Failed to create fileHandle for \(libraryName) at \(librarySchemeURL.path)")
      }
      
      if let outputData = xcscheme.replacingOccurrences(of: "__LIBRARY__", with: libraryName).data(using: .utf8) {
        do {
          try libraryScemeFileHandle.write(contentsOf: outputData)
        } catch {
          let bf = ByteCountFormatter()
          fatalError("Failed to write \(bf.string(fromByteCount: Int64(outputData.count))) in fileHandle for \(libraryName) at \(librarySchemeURL.path)")
        }
      }
      do {
        try libraryScemeFileHandle.close()
      } catch {
        fatalError("Failed to close fileHandle for \(libraryName) at \(librarySchemeURL.path)")
      }
    }
  }
}
