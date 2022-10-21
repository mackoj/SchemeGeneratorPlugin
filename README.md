# SchemeGeneratorPlugin

This plugin allow to generate schemes automatically. 
This is very usefull when using TCA or any SPM based project.

## Usage

Add to your dependencies `.package(url: "https://github.com/mackoj/SchemeGeneratorPlugin.git", from: "0.4.2"),`.

To use it you have to set a configuration file at the root of your project named `conf_scheme_generator.json`.
This file contain.
```json
{
  # Where the schemes will be saved
  "schemesDirectory": "",
  # Remove schemes that are not in the Package.swift anymore
  "removeNotGeneratedSchemes": true,
  # Force the overwrite of already present scheme
  "overwriteAlreadyGeneratedSchemes": false,
  # This allow to have more info in the console for debug purpose
  "verbose": true
}
```

Then in xcode go on the target in the side panel you want to re-generate the schemes right click on SchemeGeneratorPlugin and after it running you can restart xcode to see all you schemes updated.

Have fun
