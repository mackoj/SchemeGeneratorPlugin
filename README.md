# SchemeGeneratorPlugin

This plugin allow to generate schemes automatically. 
This is very usefull when using TCA or any SPM based project.

## Usage

Add to your dependencies `.package(url: "https://github.com/mackoj/SchemeGeneratorPlugin.git", from: "0.5.4"),`.

To use it you have to set a configuration file at the root of your project named `schemeGenerator.json`.
This file contain theses keys:
- schemesDirectory: A string that represent where the schemes will be saved(if you use TCA you can put it in workspace)
- removeNotGeneratedSchemes: A bool that represent if it should remove schemes that are no longer in Package.swift
- overwriteAlreadyGeneratedSchemes: A bool that represent if it should force the overwrite of schemes already present scheme
- excludedSchemes: A Array of String that represent the **name** of the schemes files that already exist and should not be processed 
- verbose: A bool that represent if it should print more information in the console
```json
{
  "schemesDirectory": "Project/project.xcworkspace/xcshareddata/xcschemes",
  "excludedSchemes": ["Target1Tests", "Target2Tests"],
  "removeNotGeneratedSchemes": true,
  "overwriteAlreadyGeneratedSchemes": false,
  "verbose": true
}
```

To run it right click on the package you want to run it on.
![Capture d’écran 2022-10-21 à 13 16 35](https://user-images.githubusercontent.com/661647/197189715-d810a52d-ce88-4371-9c9d-09d6d41fe883.png)

It will propose you to run it you can provide an optional argument(`--confFile newName.json`) that will allow you to change the name of the configuration file.
![Capture d’écran 2022-10-21 à 13 38 29](https://user-images.githubusercontent.com/661647/197189807-327b51b5-5f5b-4162-a433-a4c3215e67ec.png)

At first lunch it will ask for permission to write files into the schemesDirectory in order for it to work you have to say yes.

If the `schemesDirectory` point to inside a workspace `project.xcworkspace/xcshareddata/xcschemes` you will need to restart xcode to see all you schemes updated.

Have fun
