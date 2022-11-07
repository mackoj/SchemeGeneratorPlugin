# Scheme Generator

Scheme Generator is a Swift Package Manager Plugin for quickly updating your Schemes files. It is great tool for project that are modularize or that use TCA.

* [Installation](#installation)
* [Basic usage](#basic-usage)
* [Configuration](#configuration)
* [How does it works?](#how-does-it-works)

## Installation

Add to your dependencies `.package(url: "https://github.com/mackoj/SchemeGeneratorPlugin.git", from: "0.5.5"),`.

## Basic usage

The plugin will display message and errors in **Xcode Report navigator**. 

| step | description | img |
| --- | --- | --- |
| 0 | To run it right click on the package you want to run it on. | ![Capture d’écran 2022-10-21 à 13 16 35](https://user-images.githubusercontent.com/661647/197189715-d810a52d-ce88-4371-9c9d-09d6d41fe883.png) |
| 1 | It will propose you to run it you can provide an optional argument(`--confFile newName.json`) that will allow you to change the name of the configuration file. Once change the new configuration file name will be stored | ![Capture d’écran 2022-10-21 à 13 38 29](https://user-images.githubusercontent.com/661647/197189807-327b51b5-5f5b-4162-a433-a4c3215e67ec.png) |
| 2 | At first lunch it will ask for permission to write files into the schemesDirectory in order for it to work you have to say yes. | <img width="361" alt="Capture d’écran 2022-10-21 à 01 35 07" src="https://user-images.githubusercontent.com/661647/200274173-e3e1e1f7-9d93-4a5e-ac4e-062e6cbc5200.png"> |

_If the `schemesDirectory` point to inside a workspace `project.xcworkspace/xcshareddata/xcschemes` you might need to restart xcode to see all you schemes updated._

## Configuration

To use it you have to set a configuration file at the root of your project named `schemeGenerator.json`.
This file contain theses keys:
- `schemesDirectory`: A string that represent where the schemes will be saved(if you use TCA you can put it in workspace)
- `removeNotGeneratedSchemes`: A bool that represent if it should remove schemes that are no longer in Package.swift
- `overwriteAlreadyGeneratedSchemes`: A bool that represent if it should force the overwrite of schemes already present scheme
- `excludedSchemes`: A Array of String that represent the **name** of the schemes files that already exist and should not be processed 
- `verbose`: A bool that represent if it should print more information in the console

```json
{
  "schemesDirectory": "Project/project.xcworkspace/xcshareddata/xcschemes",
  "excludedSchemes": ["Target1Tests", "Target2Tests"],
  "removeNotGeneratedSchemes": true,
  "overwriteAlreadyGeneratedSchemes": false,
  "verbose": true
}
```

If a new configuration filename is used as explain in #basic-usage step 1. It will be save so that you will not be requeried to input the configuration fileName at each launch. 

## How Does it Works?

It load it's configuration to figure out `what` it can do and `where` to apply it. Then it load all the products from the `Package.swift`. Apply a filter in order to do just what is required then wrote the files in the `schemesDirectory`.

The scheme are base from a template.
