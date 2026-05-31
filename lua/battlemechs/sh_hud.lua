AddCSLuaFile()

local function recursiveAddFile(path)
	local files, folders = file.Find(path .. "*", "LUA")

	for _, filename in ipairs(files) do
		if string.GetExtensionFromFilename(filename) != "lua" then
			continue
		end

		AddCSLuaFile(path .. filename)
	end

	for _, folder in ipairs(folders) do
		recursiveAddFile(path .. folder .. "/")
	end
end

local _, huds = file.Find("battlemechs/hud/*", "LUA")

for _, path in ipairs(huds) do
	recursiveAddFile("battlemechs/hud/" .. path .. "/")
end

if SERVER then
	return
end

function battlemechs:GetHUD()
	return self.ActiveHUD, self.ActiveMech
end

function battlemechs:CreateHUD(mech, name)
	if self.ActiveHUD then
		self:DestroyHUD()
	end

	self.ActiveHUD = self.HUDList[name]
	self.ActiveMech = mech

	if self.ActiveHUD then
		self.ActiveHUD:Init(mech)
	end
end

function battlemechs:DestroyHUD(mech)
	if not self.ActiveHUD or (mech and self.ActiveMech != mech) then
		return
	end

	self.ActiveHUD:Destroy()

	self.ActiveHUD = nil
	self.ActiveMech = nil
end

battlemechs.HUDList = battlemechs.HUDList or {}

include("hud/mw4/hud.lua")
