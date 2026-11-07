module("battlemechs", package.seeall)

local PART = CreateMetaTable("ModelPart", "BasePart")
local BaseClass = Meta.BasePart

function PART:Initialize(data)
	self.Entity = NULL
	self.Model = "models/error.mdl"
	self.Skin = 0

	self.Material = ""

	BaseClass.Initialize(self, data)

	self:CreateEntity()
end

function PART:SetModel(mdl)
	self.Model = mdl
	self.Bad = nil -- Reset bad model flag
	self:CreateEntity()
end

function PART:CreateEntity()
	-- Remove the old entity if any exists
	if self.Entity:IsValid() then self.Entity:Remove() end

	self.Entity = ClientsideModel(self.Model) or NULL

	if not self.Entity:IsValid() then
		self.Bad = true
	elseif self.Entity:GetModel() == "models/error.mdl" then
		self.Bad = true
		self.Entity:Remove()
	end

	return self.Bad
end

function PART:CheckEntity()
	if self.Bad then
		return false
	end

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

function PART:UpdateMaterials()
	if self.Entity:GetMaterial() != self.Material then
		self.Entity:SetMaterial(self.Material)
	end
end

function PART:Update()
	if not self:CheckEntity() then return end

	local ent = self.Entity
	local pos, ang = self:GetTransform()

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetupBones()

	self:UpdateMaterials()
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
	if self.Bad then return false end

	return BaseClass.ShouldDraw(self)
end

function PART:Draw(flags, rendergroup)
	local group = self.Entity:GetRenderGroup()

	if group != RENDERGROUP_BOTH and group != rendergroup then
		return
	end

	self.Entity:DrawModel(flags)
end
