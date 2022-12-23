local version = '0.1.1'

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
    libraries = {}
  }

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
    local libraryFacade = {}
    local resolvedLibrary = nil

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

  function  _.resolveLibrary(name, versionConstraint)
    local versions = Library.libraries[name]
    if versions then
      local library
      if string.sub(versionConstraint, 1, 1) == '^' then
        local version = string.sub(versionConstraint, 2)
        local major = _.parseSemanticVersion(version)
        library = _.retrieveHighestVersionWithMajor(versions, major)
      else
        library = versions[versionConstraint]
      end
      return library
    end
    return nil
  end

  function Library.isRegistered(name, version)
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

  function _.retrieveHighestVersionWithMajor(versions, major)
    return versions[major].highest.library
  end
end
