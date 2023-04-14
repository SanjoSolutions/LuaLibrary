# Library

A library for registering libraries that can be used by add-ons. With this library multiple different versions of a library can be loaded and the same version of a library can be loaded only once and shared across add-ons.

**Functions included:**

* **Library.create**: a function to create a new library.
* **Library.register**: a function to register a library.
* **Library.retrieve**: a function to retrieve a library.
* **Library.isRegistered**: a function for checking if a library is registered.

It is intended to use [semantic versioning](https://semver.org/) for versions and version constraints.

**Supported version constraints:**

* The newest version with a specific major version. E.g. "^1.0.0"
* A specific version. E.g. "1.0.0"

It is recommended to use a version constraint for the newest version with a specific version (i.e. "^1.0.0"),
so that the add-on uses the version of the library that is available with the latest bug fixes.

## How to use

In this section it is explained for how to ship the dependencies via embedding.
With this approach, the library is included as part of the add-on. A benefit to the add-on user is, that only
the add-on appears in the add-on list. So it can be easier to enable or disable an add-on and its library dependencies
compared to an approach where the libraries are included as add-ons (in this case each library shows as an add-on in the add-ons list and the user potentially is required to tick multiple checkboxes to enable or disable an add-on and its library dependencies).
Also with this approach it can be made sure that the exact versions of the libraries are used that has been tested with.

### Providing a library

```lua
--- @class ALibrary
local ALibrary = {}

-- Here you can add things to ALibrary

Library.register('ALibrary', '1.0.0', ALibrary)
```

### Using a library

```lua
local ALibrary = Library.retrieve('ALibrary', '^1.0.0')
```

### Make it easy to embed a library

It is recommended to create an XML file which includes all files of the library.
With this approach, libraries with multiple Lua files can also be included by library users by just referencing one file.
Example:

ALibrary.xml
```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.blizzard.com/wow/ui/
..\..\FrameXML\UI.xsd">
  <Include file="ALibrary.lua" />
</Ui>
```

Then the library can be loaded by referencing it in the TOC file of the add-on that uses the library. Example:

```
libs/ALibrary/ALibrary.xml
```

It's recommended to load the library files first, so that the libraries are available in the other Lua files.

If the library itself has dependencies, it is recommended that those dependencies are also loaded by the add-on who uses the library.

## Support

You can support me on [Patreon](https://www.patreon.com/addons_by_sanjo).
