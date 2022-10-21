import Foundation

extension KeyedDecodingContainer {
  public func decode(_ type: URL.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> URL {
    let decodedValue = try self.decode(String.self, forKey: key)
    return URL(fileURLWithPath: decodedValue)
  }
  
  public func decodeIfPresent(_ type: URL.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> URL? {
    if let decodedValue = try self.decodeIfPresent(String.self, forKey: key)  {
      return URL(fileURLWithPath: decodedValue)
    }
    return nil
  }
}

extension KeyedEncodingContainer {
  public mutating func encode(_ value: URL, forKey key: KeyedEncodingContainer<K>.Key) throws {
    try self.encode(value.path, forKey: key)
  }
  
  public mutating func encodeIfPresent(_ value: URL?, forKey key: KeyedEncodingContainer<K>.Key) throws {
    try self.encodeIfPresent(value?.path, forKey: key)
  }
}
