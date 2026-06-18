AddCSLuaFile()

function ENT:BuildLegs()
	self:AddLeg({
		Timing = 0,

		RootBone = self:GetBone("Root"),
		Rotation = Angle(0, 0, 0),

		Origin = battlemechs:MW4Scale(0, 1.45, 0),
		Offset = battlemechs:MW4Scale(0, 1, 0),
		MaxLength = self.UpperLength + self.LowerLength,

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self:GetBone("LHip"),
		Knee = self:GetBone("LKnee"),
		Foot = self:GetBone("LFoot"),

		LengthA = self.UpperLength,
		LengthB = self.LowerLength,
		FootOffset = self.FootOffset
	})

	self:AddLeg({
		Timing = 0.5,

		RootBone = self:GetBone("Root"),
		Rotation = Angle(0, 0, 0),

		Origin = battlemechs:MW4Scale(0, -1.45, 0),
		Offset = battlemechs:MW4Scale(0, -1, 0),
		MaxLength = self.UpperLength + self.LowerLength,

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self:GetBone("RHip"),
		Knee = self:GetBone("RKnee"),
		Foot = self:GetBone("RFoot"),

		LengthA = self.UpperLength,
		LengthB = self.LowerLength,
		FootOffset = self.FootOffset
	})
end
