-- Please make new versions backwards-compatible,
-- so that the loading strategy of the library "Library" itself (a newer version replaces an older version)
-- works correctly.

local version = '0.5.0'

local _ = {}

function _.isNewerVersion(a, b)
  local majorA, minorA, patchA = _.parseSemanticVersion(a)
  local majorB, minorB, patchB = _.parseSemanticVersion(b)
  return (
    majorA > majorB or
      (majorA == majorB and minorA > minorB) or
      (majorA == majorB and minorA == minorB and patchA > patchB)
  )
end

function _.parseSemanticVersion(semanticVersion)
  local major, minor, patch = string.match(semanticVersion, '(%d+)%.(%d+)%.(%d+)')
  return tonumber(major, 10), tonumber(minor, 10), tonumber(patch, 10)
end

if not _G.Library or _.isNewerVersion(version, _G.Library.version) then
  Library = {
    version = version,
    libraries = (_G.Library and Library.libraries) or {}
  }

  function Library.create(name, version)
    local library = {}
    Library.register(name, version, library)
    return library
  end

  function Library.register(name, version, library)
    if not Library.libraries[name] then
      Library.libraries[name] = {}
    end
    local major, minor, patch = _.parseSemanticVersion(version)
    if not Library.libraries[name][major] then
      Library.libraries[name][major] = {}
    end
    if not Library.libraries[name][major][minor] then
      Library.libraries[name][major][minor] = {}
    end
    if not Library.libraries[name][major][minor][patch] then
      Library.libraries[name][major][minor][patch] = library
    end
    if (
      not Library.libraries[name][major].highest or
        minor > Library.libraries[name][major].highest.version.minor or
        (minor == Library.libraries[name][major].highest.version.minor and patch > Library.libraries[name][major].highest.version.patch)
    ) then
      Library.libraries[name][major].highest = {
        version = {
          major = major,
          minor = minor,
          patch = patch
        },
        library = library
      }
    end
  end

  function Library.retrieve(name, versionConstraint)
    local resolvedLibrary = _.resolveLibrary(name, versionConstraint)

    if resolvedLibrary then
      return resolvedLibrary
    else
      local libraryFacade = {}

      setmetatable(libraryFacade, {
        __index = function(table, key)
          if not resolvedLibrary then
            resolvedLibrary = _.resolveLibrary(name, versionConstraint)
          end

          if resolvedLibrary then
            return resolvedLibrary[key]
          else
            return nil
          end
        end
      })

      return libraryFacade
    end
  end

  function _.resolveLibrary(name, versionConstraint)
    local library
    if string.sub(versionConstraint, 1, 1) == '^' then
      local version = string.sub(versionConstraint, 2)
      local major = _.parseSemanticVersion(version)
      library = _.retrieveHighestVersionWithMajor(name, major)
    else
      local version = versionConstraint
      library = _.retrieveLibraryWithVersion(name, version)
    end
    return library
  end

  function _.retrieveLibraryWithVersion(name, version)
    local major, minor, patch = _.parseSemanticVersion(version)
    local a = Library.libraries[name]
    if a then
      local b = a[major]
      if b then
        local c = b[minor]
        if c then
          return c[patch]
        end
      end
    end
    return nil
  end

  function Library.isRegistered(name, version)
    return not not _.retrieveLibraryWithVersion(name, version)
  end

  function _.retrieveHighestVersionWithMajor(name, major)
    local versions = Library.libraries[name]
    if versions and versions[major]then
      return versions[major].highest.library
    else
      return nil
    end
  end
end
