Library = Library or {}

local _ = {}

if not Library.libraries then
  Library.libraries = {}
end

function Library.register(name, version, library)
	if not _.libraries[name] then
    _.libraries[name] = {}
  end
  local major, minor, patch = _.parseSemanticVersion(version)
  if not _.libraries[name][major] then
    _.libraries[name][major] = {}
  end
  if not _.libraries[name][major][minor] then
    _.libraries[name][major][minor] = {}
  end
  if not _.libraries[name][major][minor][patch] then
    _.libraries[name][major][minor][patch] = library
  end
  if (
    not _.libraries[name][major].highest or
      minor > _.libraries[name][major].highest.version.minor or
      (minor == _.libraries[name][major].highest.version.minor and patch > _.libraries[name][major].highest.version.patch)
  ) then
    _.libraries[name][major].highest = {
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
  local versions = _.libraries[name]
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

function _.parseSemanticVersion(semanticVersion)
	local major, minor, patch = string.match(semanticVersion, '(%d+)%.(%d+)%.(%d+)')
  return major, minor, patch
end

function _.retrieveHighestVersionWithMajor(versions, major)
	return versions[major].highest.library
end
