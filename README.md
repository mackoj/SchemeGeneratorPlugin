# SchemeGeneratorPlugin

This plugin allow to generate schemes automatically. 
This is very usefull when using TCA or any SPM based project.

It works only for mac using apple silicon. 

## Usage

To use it you have to set a configuration file at the root of your project named `scheme_generator.yaml`.
This file contain.
```yaml
# Where the schemes will be saved
schemesDirectory: ""

# Remove schemes that are not in the Package.swift anymore
removeNotGeneratedSchemes: true

# Force the overwrite of already present scheme
overwriteAlreadyGeneratedSchemes: false

# This allow to have more info in the console for debug purpose
verbose: false
```


Have fun
