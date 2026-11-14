import Foundation

public struct SchemeGeneratorConfiguration: Codable, CustomStringConvertible {
  var schemesDirectory: FileURL?
  var verbose: Bool
  var excludedSchemes: [String]
  var overwriteAlreadyGeneratedSchemes: Bool
  var removeNotGeneratedSchemes: Bool
  
  public var description: String {
    """
SchemeGeneratorConfiguration:
schemesDirectory: \(schemesDirectory?.path ?? "nil")
verbose: \(verbose)
overwriteAlreadyGeneratedSchemes: \(overwriteAlreadyGeneratedSchemes)
removeNotGeneratedSchemes: \(removeNotGeneratedSchemes)
"""
  }
  
  public init(schemesDirectory: FileURL? = nil, verbose: Bool = false, excludedSchemes: [String] = [], overwriteAlreadyGeneratedSchemes: Bool = false, removeNotGeneratedSchemes: Bool = false) {
    self.schemesDirectory = schemesDirectory
    self.verbose = verbose
    self.excludedSchemes = excludedSchemes
    self.overwriteAlreadyGeneratedSchemes = overwriteAlreadyGeneratedSchemes
    self.removeNotGeneratedSchemes = removeNotGeneratedSchemes
  }
}
