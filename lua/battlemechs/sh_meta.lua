module("battlemechs", package.seeall)

Meta = Meta or {}

local META = {}

function META:IsType(name)
	return self.TypeName == name
end

function META:IsBasedOn(name)
	-- Get class table
	local meta = getmetatable(self).__meta

	while meta do
		if meta.TypeName == name then
			return true
		end

		meta = meta._Base
	end

	return false
end

function CreateMetaTable(name, base)
	local meta = FindMetaTable("Battlemechs_" .. name)

	if not meta then
		meta = {}

		Meta[name] = meta
		RegisterMetaTable("Battlemechs_" .. name, meta)
	end

	meta.TypeName = name
	meta._Base = battlemechs.Meta[base]

	setmetatable(meta, {
		__index = base and battlemechs.Meta[base] or META,
		__meta = meta
	})

	battlemechs[name] = function(mech, ...)
		local instance = setmetatable({Mech = mech}, {__index = meta, __meta = meta})
		instance:Initialize(...)

		return instance
	end

	return meta
end
