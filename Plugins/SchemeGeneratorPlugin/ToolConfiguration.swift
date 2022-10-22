import Foundation

struct ToolConfiguration: Codable, CustomStringConvertible {
  var defaultConfigFileName: String
  var lastProductNamesHash: String?

  var description: String {
    """
ToolConfiguration:
lastProductNamesHash: \(lastProductNamesHash ?? "nil")
defaultConfigFileName: \(defaultConfigFileName)
"""
  }
  
  init(defaultConfigFileName: String = "schemeGenerator.json", lastProductNamesHash: String? = nil) {
    self.defaultConfigFileName = defaultConfigFileName
    self.lastProductNamesHash = lastProductNamesHash
  }
}
