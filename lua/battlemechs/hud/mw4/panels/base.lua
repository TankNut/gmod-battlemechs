local HUD = battlemechs.HUDList.mw4
local PANEL = {}

local function addLine(text, y, color)
	local _, h = draw.SimpleText(text, "CenterPrintText", 10, y, color, TEXT_ALIGN_LEFT)

	return y + h
end

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self:ParentToHUD()

	self.View = vgui.CreateFromTable(HUD.MechView, self)
	self.View:SetMech(HUD.Mech)

	self.Status = self:Add("Panel")
	self.Status.Paint = function(_, w, h)
		HUD:PaintPanel(0, 0, w, h)

		local mech = HUD.Mech
		local y = 10

		y = addLine("Hull: 100%", y, Color(0, 255, 0))
		y = addLine("", y, color_white)
		y = addLine("Mobility: Crippled", y, Color(255, 0, 0))
		y = addLine("Weapons: Damaged", y, Color(255, 255, 0))
		y = addLine("", y, color_white)

		for k, v in ipairs(mech.DamageGroups) do
			y = addLine(string.format("%s: 100%%", v.Name), y, Color(0, 255, 0))
		end
	end

	self.Topbar = self:Add("Panel")
	self.Topbar.Paint = function(_, w, h)
		HUD:PaintPanel(0, 0, w, h)

		draw.DrawText(HUD.Mech.PrintName, "DermaLarge", 10, 5, HSVToColor(HUD.Hue, 1, 1), TEXT_ALIGN_LEFT)
	end

	self.Bottom = self:Add("Panel")
	self.Bottom.Paint = function(_, w, h)
		HUD:PaintPanel(0, 0, w, h)

		local mech = HUD.Mech

		draw.DrawText(string.format("%i/%i", mech:GetMechHealth()), "DermaLarge", 10, 5, HSVToColor(HUD.Hue, 1, 1), TEXT_ALIGN_LEFT)
	end
end

function PANEL:PerformLayout(w, h)
	local viewSize = ScreenScale(60)

	self.Bottom:SetSize(viewSize, ScreenScale(10))
	self.Bottom:AlignLeft(HUD.Border)
	self.Bottom:AlignBottom(HUD.Border)

	self.View:SetSize(ScreenScale(60), ScreenScale(60))
	self.View:AlignLeft(HUD.Border)
	self.View:MoveAbove(self.Bottom, HUD.Margin)

	self.Status:SetWide(ScreenScale(40))
	self.Status:SetY(self.View:GetY())
	self.Status:MoveRightOf(self.View, HUD.Margin)
	self.Status:StretchToParent(nil, nil, nil, HUD.Border)

	self.Topbar:SetSize(viewSize + HUD.Margin + self.Status:GetWide(), ScreenScale(10))
	self.Topbar:MoveAbove(self.View, HUD.Margin)
	self.Topbar:AlignLeft(HUD.Border)
end

HUD.BasePanel = vgui.RegisterTable(PANEL, "Panel")
