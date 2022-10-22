import Foundation

struct ToolConfiguration: Codable {
  let defaultConfigFileName: String
  var lastProductNamesHash: String?

  init(defaultConfigFileName: String = "schemeGenerator.json", lastProductNamesHash: String? = nil) {
    self.defaultConfigFileName = defaultConfigFileName
    self.lastProductNamesHash = lastProductNamesHash
  }
}
