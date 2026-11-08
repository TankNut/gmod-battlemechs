module("battlemechs", package.seeall)

local PART = CreateMetaTable("ModelPart", "BasePart")
local BaseClass = Meta.BasePart

function PART:Initialize(data)
	-- Bypassing callbacks since there isn't an entity yet
	local tab = self:GetTable()
	tab.Entity = NULL

	tab.Model = "models/error.mdl"
	tab.Skin = 0

	tab.Material = ""

	BaseClass.Initialize(self, data)

	self:CreateEntity()
end

-- Returns false if we don't have a valid entity
function PART:CreateEntity()
	-- Remove the old entity if any exists
	if self.Entity:IsValid() then self.Entity:Remove() end

	self.Entity = ClientsideModel(self.Model) or NULL
	self._Broken = not self.Entity:IsValid() or self.Entity:GetModel() == "models/error.mdl"

	if self._Broken then
		SafeRemoveEntity(self.Entity)
	else
		self.Entity:SetNoDraw(true)
		self:ApplyModifiers()
	end

	return not self._Broken
end

-- Returns false if we don't have a valid entity
function PART:CheckEntity()
	if self._Broken then
		return false
	end

	-- Fullupdate might have deleted the entity, we're not broken so try to recreate it
	if not self.Entity:IsValid() then
		return self:CreateEntity()
	end

	return true
end

function PART:Destroy()
	if self.Entity:IsValid() then
		self.Entity:Remove()
	end
end

function PART:ApplyModifiers()
	local ent = self.Entity

	if self.Skin != 0 then ent:SetSkin(self.Skin) end
	if self.Material != "" then ent:SetMaterial(self.Material) end
end

function PART:OnModelChanged(mdl)
	self:CreateEntity()
end

function PART:OnSkinChanged(index)
	if self._Broken then return end

	self.Entity:SetSkin(index)
end

function PART:OnMaterialChanged(mat)
	if self._Broken then return end

	self.Entity:SetMaterial(mat)
end

function PART:Update()
	if not self:CheckEntity() then return end

	local ent = self.Entity
	local pos, ang = self:GetTransform()

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetupBones()
end

function PART:GetRenderBounds()
	local ent = self.Entity

	if not IsValid(ent) then
		return
	end

	local mins, maxs = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs())
	mins:Add(ent:GetPos())
	maxs:Add(ent:GetPos())

	return mins, maxs
end

function PART:ShouldDraw()
	if self._Broken then return false end

	return BaseClass.ShouldDraw(self)
end

function PART:Draw(flags, rendergroup)
	local group = self.Entity:GetRenderGroup()

	if group != RENDERGROUP_BOTH and group != rendergroup then
		return
	end

	self.Entity:DrawModel(flags)
end

function PART:__tostring()
	return string.format("%s [%s][\"%s\"]", self.MetaName, self.Mech:EntIndex(), self.Model)
end
