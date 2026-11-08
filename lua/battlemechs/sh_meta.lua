module("battlemechs", package.seeall)

Meta = Meta or {Base = {}}
Data = Data or setmetatable({}, {__mode = "k"})

-- True base class, only exists as a table
local META = Meta.Base

function META:IsTypeOf(typeid)
	local meta = getmetatable(self)

	while meta do
		if rawget(meta, "MetaID") == typeid then
			return true
		end

		meta = rawget(meta, "MetaBaseClass")
	end

	return false
end

local function find(meta, key)
	while meta do
		local val = rawget(meta, key)

		if val != nil then
			return val
		end

		meta = rawget(meta, "MetaBaseClass")
	end
end

function CreateMetaTable(name, base)
	local metaName = "Battlemechs." .. name
	local meta = FindMetaTable(metaName)

	if meta then
		return meta
	end

	local proxy = newproxy(true)
	meta = getmetatable(proxy)

	RegisterMetaTable(metaName, meta)
	Meta[name] = meta

	meta.MetaBaseClass = base and Meta[base] or Meta.Base

	function meta:GetTable()
		return Data[self]
	end

	function meta:__index(key)
		-- Check GetTable first
		local val = Data[self][key]

		if val != nil then
			return val
		end

		-- Try to find what we're looking for in our various metatables
		return find(meta, key)
	end

	function meta:__newindex(key, val)
		Data[self][key] = val

		local callback = find(meta, "On" .. key .. "Changed")

		if callback then
			callback(self, val)
		end
	end

	function meta:__tostring()
		return meta.MetaName
	end

	battlemechs[name] = function(mech, ...)
		local instance = newproxy(proxy)
		Data[instance] = {
			Mech = mech
		}

		instance:Initialize(...)

		return instance
	end

	battlemechs["TYPE_" .. string.upper(name)] = meta.MetaID

	return meta
end
