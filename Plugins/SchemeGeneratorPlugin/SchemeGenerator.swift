import Foundation
import PackagePlugin
import CryptoKit

public struct SchemeGenerator {
  // MARK: - Public
  public static func generateSchemes(_ packageDirectory: FileURL, _ arguments: [String], _ productNames: [String], _ packageTempFolder: FileURL) {
    /// Load Tool Configuration
    let toolConfigFileURL: FileURL = packageTempFolder.appendingPathComponent("config.json")
    var toolConfig = getDefaultConfigurationName(toolConfigFileURL)
    
    /// Prepare configuration
    toolConfig = updateDefaultConfigFileName(arguments, toolConfig)
    saveToolConfig(toolConfig, toolConfigFileURL)
    let configurationFileURL = getConfigurationFileURL(packageDirectory, arguments, toolConfig.defaultConfigFileName)
    if FileManager.default.fileExists(atPath: configurationFileURL.path) == false {
      createDefaultConfiguration(configurationFileURL)
    }
    let config = loadConfiguration(configurationFileURL)
    validateConfiguration(config, configurationFileURL)
    
//    if config.verbose { print("toolConfigFileURL:", toolConfigFileURL.path) }
    if config.verbose { print(toolConfig) }

    /// Prepare productNames
    toolConfig = testProductNamesContent(productNames, packageTempFolder, toolConfig)
    saveToolConfig(toolConfig, toolConfigFileURL)

    let filteredProductNames = filterUsefullProducts(productNames, config)
    if config.verbose {
      print("Schemes that will be created:")
      print(filteredProductNames.joined(separator: "\n"))
    }
    
    // Generate Schemes Files
    generateSchemesFiles(filteredProductNames, config)    
  }
  
  // MARK: - Private

  // MARK: Tool Configuration
  private static func saveToolConfig(_ toolConfig: ToolConfiguration, _ toolConfigFileURL: FileURL) {
    do {
      let data = try JSONEncoder().encode(toolConfig)
      try data.write(to: toolConfigFileURL, options: [.atomic])
    } catch {
      Diagnostics.emit(.warning, "Failed to write ToolConfiguration file.")
    }
  }
  
  private static func getDefaultConfigurationName(_ toolConfigFileURL: FileURL) -> ToolConfiguration {
    if FileManager.default.fileExists(atPath: toolConfigFileURL.path) {
      do {
        let data = try Data(contentsOf: toolConfigFileURL)
        let toolConfig = try JSONDecoder().decode(ToolConfiguration.self, from: data)
        return toolConfig
      } catch {
        Diagnostics.emit(.error, "Failed to load ToolConfiguration file.")
      }
    }
    let toolConfig = ToolConfiguration()
    saveToolConfig(toolConfig, toolConfigFileURL)
    return toolConfig
  }

  // MARK: Configuration
  private static func updateDefaultConfigFileName(_ arguments: [String], _ toolConfig: ToolConfiguration) -> ToolConfiguration {
    var toolConfig = toolConfig
    var configurationFileName = toolConfig.defaultConfigFileName
    if let cf = arguments.firstIndex(of: "--confFile") {
      let param = arguments.index(after: cf)
      if param != cf {
        let confFile = arguments[param]
        configurationFileName = confFile
      }
    }
    toolConfig.defaultConfigFileName = configurationFileName
    return toolConfig
  }
  
  private static func getConfigurationFileURL(_ packageDirectory: FileURL, _ arguments: [String], _ configurationFileName: String) -> FileURL {
    let configurationFileURL = packageDirectory.appendingPathComponent(configurationFileName)
    return configurationFileURL
  }

  private static func createDefaultConfiguration(_ configurationFileURL: FileURL) {
    if FileManager.default.fileExists(atPath: configurationFileURL.path) == false {
      Diagnostics.emit(.error, "Missing a configuration file at \(configurationFileURL.path)(example: https://github.com/mackoj/SchemeGeneratorPlugin/blob/main/schemeGenerator.json).")
      Diagnostics.emit(.error, "We will generate a default one for you but you will need to set it schemesDirectory value.")
      var defaultConf: Data!
      do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        defaultConf = try encoder.encode(SchemeGeneratorConfiguration())
      } catch {
        fatalError(.error, "Failed to encode a default configuration.")
      }
      do {
        try defaultConf.write(to: configurationFileURL, options: [.atomic])
      } catch {
        fatalError(.error, "Failed to encode write a default configuration at \(configurationFileURL.path)")
      }
    }
  }

  private static func loadConfiguration(_ configurationFileURL: FileURL) -> SchemeGeneratorConfiguration{
    var config: SchemeGeneratorConfiguration
    do {
      config = try JSONDecoder().decode(SchemeGeneratorConfiguration.self, from: try Data(contentsOf: configurationFileURL))
    } catch {
      fatalError(.error, "Failed to decode JSON file \(configurationFileURL.path)")
    }
    
    if config.verbose { print(config) }
    return config
  }

  private static func validateConfiguration(_ config: SchemeGeneratorConfiguration, _ configurationFileURL: FileURL) {
    if config.schemesDirectory == nil {
      fatalError(.error, "schemesDirectory in \(configurationFileURL.path) should not be empty")
    }
  }
  
  // MARK: Product Names
  private static func testProductNamesContent(_ productNames: [String], _ packageTempFolder: FileURL, _ toolConfig: ToolConfiguration) -> ToolConfiguration {
    var toolConfig = toolConfig
    if productNames.isEmpty {
      fatalError(.warning, "No products found.")
    }
    Diagnostics.emit(.remark, "Found \(productNames.count) products.")
    
    guard let data = productNames
      .joined(separator: "\n")
      .data(using: .utf8)
    else {
      fatalError(.error, "Failed to convert data.")
    }
    
    let hash = SHA256.hash(data: data)
      .compactMap { String(format: "%02x", $0) }
      .joined()
    
    if toolConfig.lastProductNamesHash != hash {
      toolConfig.lastProductNamesHash = hash
    } else {
      fatalError(.remark, "There is no change in products list.")
    }
    return toolConfig
  }

  private static func filterUsefullProducts(_ productNames: [String], _ config: SchemeGeneratorConfiguration) -> [String] {
    if FileManager.default.fileExists(atPath: config.schemesDirectory!.path) == false {
      do {
        try FileManager.default.createDirectory(at: config.schemesDirectory!, withIntermediateDirectories: true)
      } catch {
        fatalError(.error, "Schemes output directory(\(String(describing: config.schemesDirectory))) don't exist and failed to created it.")
      }
    }
    
    // List all the already present schemes files
    // Compare to what to generate and following config update only what necessary
    var content: [FileURL]
    do {
      content = try FileManager.default.contentsOfDirectory(at: config.schemesDirectory!, includingPropertiesForKeys: nil)
    } catch {
      fatalError(.error, "Failed to get contentsOfDirectory at \(config.schemesDirectory!.path)")
    }
    let schemes = content.filter { fileURL in
      fileURL.pathExtension == xcschemeExtension
    }.map { $0.lastPathComponent.replacingOccurrences(of: ".\($0.pathExtension)", with: "") }
    
    var schemesSet = Set<String>(schemes)
    let productNamesSet = Set<String>(productNames)
    
    // exclude from processing schemes that already exist
    schemesSet.subtract(config.excludedSchemes)
    
    var output: [String] = Array(productNamesSet.subtracting(schemesSet))

    // force overwrite already existing schemes
    if config.overwriteAlreadyGeneratedSchemes {
      output.append(contentsOf: schemesSet.intersection(productNamesSet))
    }
    
    // remove obsolete schemes
    if config.removeNotGeneratedSchemes {
      let toRemoveSchemes = schemesSet.subtracting(productNamesSet)
      if toRemoveSchemes.isEmpty == false, config.verbose {
        print("Schemes that will be removed:")
        print(toRemoveSchemes.joined(separator: "\n"))
      }
      for libraryName in toRemoveSchemes {
        let schemeToDeleteURL = config.schemesDirectory!.appendingPathComponent("\(libraryName).\(xcschemeExtension)")
        do {
          try FileManager.default.removeItem(at: schemeToDeleteURL)
        } catch {
          Diagnostics.emit(.error, "Failed to delete scheme \(libraryName) at \(schemeToDeleteURL.path)")
        }
      }
    }
    return output
  }
  
  // MARK: Generate Schemes
  private static func generateSchemesFiles(_ productNames: [String], _ config: SchemeGeneratorConfiguration) {
    for libraryName in productNames {
      let librarySchemeURL = config.schemesDirectory!.appendingPathComponent("\(libraryName).\(xcschemeExtension)")
      FileManager.default.createFile(atPath: librarySchemeURL.path, contents: nil)
      var libraryScemeFileHandle: FileHandle
      do {
        libraryScemeFileHandle = try FileHandle(forWritingTo: librarySchemeURL)
      } catch {
        fatalError(.error, "Failed to create fileHandle for \(libraryName) at \(librarySchemeURL.path)")
      }
      
      if let outputData = xcscheme.replacingOccurrences(of: "__LIBRARY__", with: libraryName).data(using: .utf8) {
        do {
          try libraryScemeFileHandle.write(contentsOf: outputData)
        } catch {
          let bf = ByteCountFormatter()
          fatalError(.error, "Failed to write \(bf.string(fromByteCount: Int64(outputData.count))) in fileHandle for \(libraryName) at \(librarySchemeURL.path)")
        }
      }
      do {
        try libraryScemeFileHandle.close()
      } catch {
        fatalError(.error, "Failed to close fileHandle for \(libraryName) at \(librarySchemeURL.path)")
      }
    }
  }
}
