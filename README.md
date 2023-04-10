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

## Support

You can support me on [Patreon](https://www.patreon.com/addons_by_sanjo).
