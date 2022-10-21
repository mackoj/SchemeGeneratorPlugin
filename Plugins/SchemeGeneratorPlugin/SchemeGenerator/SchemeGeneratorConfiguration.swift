import Foundation

public struct SchemeGeneratorConfiguration: Codable, CustomStringConvertible {
  var schemesDirectory: URL
  var verbose: Bool = false
  var overwriteAlreadyGeneratedSchemes: Bool = false
  var removeNotGeneratedSchemes: Bool = false
  
  public var description: String {
    "SchemeGeneratorConfiguration:\nschemesDirectory: \(schemesDirectory.path)\nverbose: \(verbose)\noverwriteAlreadyGeneratedSchemes: \(overwriteAlreadyGeneratedSchemes)\nremoveNotGeneratedSchemes: \(removeNotGeneratedSchemes)"
  }
}
