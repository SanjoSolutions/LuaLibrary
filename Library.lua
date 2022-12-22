Library = Library or {}
local addOnName, AddOn = ...
local _ = {}

_.libraries = {}

function Library.register(name, version, library)
	if not _.libraries[name] then
    _.libraries[name] = {}
  end
  if not _.libraries[name][version] then
    _.libraries[name][version] = library
  end
end

function Library.retrieve(name, version)
  local versions = _.libraries[name]
  if versions then
    local library = versions[version]
    return library
  end
  return nil
end
