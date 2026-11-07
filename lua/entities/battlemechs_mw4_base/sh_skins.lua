AddCSLuaFile()
DEFINE_BASECLASS("battlemechs_base")

local i = 0
local function addSkin(category, name)
	local tab = {
		Name = name,
		Category = category
	}

	if i > 0 then
		tab.Material = "skin" .. i
	end

	i = i + 1

	return tab
end

ENT.SkinData = {
	addSkin(nil, "None"),

	addSkin("Ops", "Blue"),
	addSkin("Ops", "Red"),
	addSkin("Ops", "Gold"),
	addSkin("Ops", "Green"),
	addSkin("Ops", "Orange"),
	addSkin("Ops", "Cyan"),
	addSkin("Ops", "Purple"),
	addSkin("Ops", "Pink"),

	addSkin("Snow", "WinterWar"),
	addSkin("Snow", "SnowBlind"),
	addSkin("Snow", "SnowBall"),
	addSkin("Snow", "Arctic"),

	addSkin("Alpine", "Temperate Winter"),
	addSkin("Alpine", "Snow Leopard"),
	addSkin("Alpine", "Taiga Winter"),
	addSkin("Alpine", "Ozark Winter"),

	addSkin("Swamp", "Great Dismal"),
	addSkin("Swamp", "Everglades"),
	addSkin("Swamp", "Pripyat"),
	addSkin("Swamp", "Bayou"),

	addSkin("Woodland", "Hunter Woods"),
	addSkin("Woodland", "Schwarzwald"),
	addSkin("Woodland", "Olympic Forest"),
	addSkin("Woodland", "Gecko"),

	addSkin("Grassland", "Summer Tundra"),
	addSkin("Grassland", "Rhodesian Fall"),
	addSkin("Grassland", "Steppe Spring"),
	addSkin("Grassland", "Great Plains"),

	addSkin("Sand", "Empty Quarter"),
	addSkin("Sand", "Negev"),
	addSkin("Sand", "Sahara"),
	addSkin("Sand", "Mojave"),

	addSkin("Rock", "Desert Fox"),
	addSkin("Rock", "Blood Stone"),
	addSkin("Rock", "Quattra Depression"),
	addSkin("Rock", "Savannah Tiger"),

	addSkin("Urban", "Concrete"),
	addSkin("Urban", "Spiral Maze"),
	addSkin("Urban", "Headstone"),
	addSkin("Urban", "Skyline"),

	addSkin("Night Ops", "Charred Steel"),
	addSkin("Night Ops", "Scorched Earth"),
	addSkin("Night Ops", "Nightmare"),
	addSkin("Night Ops", "Urban Assault"),

	addSkin("Parade", "Capellan Confederation"),
	addSkin("Parade", "Draconis Combine"),
	addSkin("Parade", "Federated Suns"),
	addSkin("Parade", "Free Worlds League"),
	addSkin("Parade", "Lyran Alliance"),
	addSkin("Parade", "Blue Solaris"),
	addSkin("Parade", "Red Solaris")
}

function ENT:CanProperty(ply, prop)
	return prop != "skin"
end

if CLIENT then
	function ENT:UpdatePartSkin(part)
		local index = part.SkinIndex or 0
		local target = self:GetSkinIndex()

		if index != target then
			local skinData = self.SkinData[target + 1]

			if target == 0 or not skinData then
				part.Material = ""
			else
				local family = string.match(part.Model, "^models/battlemechs/mw4/(%a+)/")

				if family then
					part.Material = string.format("models/battlemechs/mw4/%s/%s", family, skinData.Material)
				end
			end

			part.SkinIndex = target
		end
	end

	function ENT:UpdateParts()
		for _, part in ipairs(self.Parts) do
			if not part:IsBasedOn("ModelPart") or not part:ShouldDraw() or part.NoSkin then
				continue
			end

			self:UpdatePartSkin(part)
		end

		BaseClass.UpdateParts(self)
	end
end

properties.Add("battlemechs_mw4_skin", {
	MenuLabel = "Skin",
	Order = 601,
	MenuIcon = "icon16/picture_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) then return false end
		if not scripted_ents.IsBasedOn(ent:GetClass(), "battlemechs_mw4_base") then return false end
		if not hook.Run("CanProperty", ply, "battlemechs_mw4_skin", ent) then return false end

		return #ent.SkinData > 0
	end,

	MenuOpen = function(self, option, ent, tr)
		local submenu = option:AddSubMenu()
		local categories = {}
		local activeChoice

		local current = ent:GetSkinIndex()

		for k, v in ipairs(ent.SkinData) do
			local index = k - 1
			local target = submenu

			if v.Category then
				if not categories[v.Category] then
					categories[v.Category] = submenu:AddSubMenu(v.Category)
				end

				target = categories[v.Category]
			end

			local choice = target:AddOption(v.Name)
			choice:SetRadio(true)
			choice:SetIsCheckable(true)

			if current == index then
				choice:SetChecked(true)
				activeChoice = choice
			end

			choice.OnChecked = function(_, checked)
				if checked then
					self:SetSkin(ent, index)

					if IsValid(activeChoice) and activeChoice != choice then
						activeChoice:SetChecked(false)
					end

					activeChoice = choice
				end
			end
		end
	end,

	Action = function(self, ent) end,

	SetSkin = function(self, ent, index)
		self:MsgStart()
			net.WriteEntity(ent)
			net.WriteUInt(index, 8)
		self:MsgEnd()
	end,

	Receive = function(self, length, ply)
		local ent = net.ReadEntity()
		local index = net.ReadUInt(8)

		if not properties.CanBeTargeted(ent, ply) then return end
		if not self:Filter(ent, ply) then return end

		ent:SetSkinIndex(math.Clamp(index, 0, #ent.SkinData - 1))
	end
})
