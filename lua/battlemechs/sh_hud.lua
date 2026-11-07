module("battlemechs", package.seeall)

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

function GetHUD()
	return ActiveHUD, ActiveMech
end

function CreateHUD(mech, name)
	if ActiveHUD then
		DestroyHUD()
	end

	ActiveHUD = HUDList[name]
	ActiveMech = mech

	if ActiveHUD then
		ActiveHUD:Init(mech)
	end
end

function DestroyHUD(mech)
	if not ActiveHUD or (mech and ActiveMech != mech) then
		return
	end

	ActiveHUD:Destroy()

	ActiveHUD = nil
	ActiveMech = nil
end

HUDList = HUDList or {}

include("hud/mw4/hud.lua")
