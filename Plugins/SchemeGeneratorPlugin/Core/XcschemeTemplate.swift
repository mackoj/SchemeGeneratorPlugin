import Foundation

let xcschemeExtension = "xcscheme"
let xcscheme = """
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1400"
   version = "1.3">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "__LIBRARY__"
               BuildableName = "__LIBRARY__"
               BlueprintName = "__LIBRARY__"
               ReferencedContainer = "container:">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Debug"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <MacroExpansion>
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "__LIBRARY__"
            BuildableName = "__LIBRARY__"
            BlueprintName = "__LIBRARY__"
            ReferencedContainer = "container:">
         </BuildableReference>
      </MacroExpansion>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""

enum XcschemeTemplate {
  static let placeholder = "__LIBRARY__"

  /// The template cut at each placeholder, once: rendering appends these around the product name rather than
  /// searching the template again for every product.
  static let pieces: [Substring] = {
    var pieces: [Substring] = []
    var rest = xcscheme[...]
    while let range = rest.range(of: placeholder) {
      pieces.append(rest[..<range.lowerBound])
      rest = rest[range.upperBound...]
    }
    pieces.append(rest)
    return pieces
  }()

  static let piecesUTF8Count = pieces.reduce(0) { $0 + $1.utf8.count }

  /// The scheme file for `productName`: the template with every `__LIBRARY__` replaced.
  static func render(productName: String) -> String {
    var scheme = ""
    scheme.reserveCapacity(piecesUTF8Count + (pieces.count - 1) * productName.utf8.count)
    for (index, piece) in pieces.enumerated() {
      if index > 0 { scheme += productName }
      scheme += piece
    }
    return scheme
  }

  /// `render(productName:)` as UTF-8, ready to write.
  static func renderData(productName: String) -> Data {
    Data(render(productName: productName).utf8)
  }
}
