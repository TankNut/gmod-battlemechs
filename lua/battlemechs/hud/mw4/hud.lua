local HUD = {}
battlemechs.HUDList.mw4 = HUD

HUD.Hue = 120

HUD.Colors = {}
HUD.Colors.Border = HSVToColor(HUD.Hue, 1, 0.4)
HUD.Colors.Fill = HSVToColor(HUD.Hue, 1, 0.2)
HUD.Colors.Fill.a = 230

include("panels/base.lua")
include("panels/mech_view.lua")

function HUD:Init(mech)
	self.Mech = mech

	-- Defining screenscale values
	self.Border = ScreenScaleH(10)
	self.Margin = ScreenScaleH(1)
	self.Padding = ScreenScaleH(3)

	-- Initializing the hud itself
	self.Instance = vgui.CreateFromTable(self.BasePanel)
end

function HUD:Destroy()
	if IsValid(self.Instance) then
		self.Instance:Remove()
		self.Instance = nil
	end
end

-- Draw functions

function HUD:PaintPanel(x, y, w, h)
	surface.SetDrawColor(self.Colors.Fill)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(self.Colors.Border)
	surface.DrawOutlinedRect(0, 0, w, h)
end
