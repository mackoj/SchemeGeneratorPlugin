# SchemeGeneratorPlugin

This plugin allow to generate schemes automatically. 
This is very usefull when using TCA or any SPM based project.

## Usage

Add to your dependencies `.package(url: "https://github.com/mackoj/SchemeGeneratorPlugin.git", from: "0.4.2"),`.

To use it you have to set a configuration file at the root of your project named `conf_scheme_generator.json`.
This file contain theses keys:
- schemesDirectory: A string that represent where the schemes will be saved
- removeNotGeneratedSchemes: A bool that represent if it should remove schemes that are no longer in Package.swift
- overwriteAlreadyGeneratedSchemes: A bool that represent if it should force the overwrite of schemes already present scheme
- verbose: A bool that represent if it should print more information in the console
```json
{
  "schemesDirectory": "",
  "removeNotGeneratedSchemes": true,
  "overwriteAlreadyGeneratedSchemes": false,
  "verbose": true
}
```

To run it right click on the package you want to run it on.
It will propose you to  
At first lunch it will ask for permission to write files into the schemesDirectory. Say yes
Then in xcode go on the target in the side panel you want to re-generate the schemes right click on SchemeGeneratorPlugin and after it running you can restart xcode to see all you schemes updated.

Have fun
