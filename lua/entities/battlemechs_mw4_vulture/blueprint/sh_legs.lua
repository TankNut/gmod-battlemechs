AddCSLuaFile()

local spread = 44

function ENT:BuildLegs()
	self:AddLeg({
		Timing = 0,

		RootBone = self:GetBone("Root"),
		Rotation = Angle(0, 0, 0),

		Origin = Vector(0, spread, 0),
		Offset = Vector(0, spread, 0),
		MaxLength = self.UpperLength + self.LowerLength + self.FootOffset,

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self:GetBone("LeftHip"),
		Knee = self:GetBone("LeftKnee"),
		Foot = self:GetBone("LeftFoot"),

		LengthA = self.UpperLength,
		LengthB = self.LowerLength,
		FootOffset = self.FootOffset,
	})

	self:AddLeg({
		Timing = 0.5,

		RootBone = self:GetBone("Root"),
		Rotation = Angle(0, 0, 0),

		Origin = Vector(0, -spread, 0),
		Offset = Vector(0, -spread, 0),
		MaxLength = self.UpperLength + self.LowerLength + self.FootOffset,

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self:GetBone("RightHip"),
		Knee = self:GetBone("RightKnee"),
		Foot = self:GetBone("RightFoot"),

		LengthA = self.UpperLength,
		LengthB = self.LowerLength,
		FootOffset = self.FootOffset
	})
end
