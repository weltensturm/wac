
local rr = CreateClientConVar("hud_red_r", 195, true, false)
local rg = CreateClientConVar("hud_red_g", 50, true, false)
local rb = CreateClientConVar("hud_red_b", 50, true, false)
local ra = CreateClientConVar("hud_red_a", 200, true, false)

local br = CreateClientConVar("hud_blue_r", 50, true, false)
local bg = CreateClientConVar("hud_blue_g", 50, true, false)
local bb = CreateClientConVar("hud_blue_b", 195, true, false)
local ba = CreateClientConVar("hud_blue_a", 200, true, false)

local bgr = CreateClientConVar("hud_bg_r", 20, true, false)
local bgg = CreateClientConVar("hud_bg_g", 20, true, false)
local bgb = CreateClientConVar("hud_bg_b", 20, true, false)
local bga = CreateClientConVar("hud_bg_a", 100, true, false)

local txtr = CreateClientConVar("hud_txt_r", 20, true, false)
local txtg = CreateClientConVar("hud_txt_g", 20, true, false)
local txtb = CreateClientConVar("hud_txt_b", 20, true, false)
local txta = CreateClientConVar("hud_txt_a", 100, true, false)

local function HudColorPanel(CPanel)
	CPanel:AddControl("Label",
		{
			Text		= "Team Red Color"
		})
	CPanel:AddControl("Color",
		{
			Label		= "Team Red Color",
			Red			= "hud_red_r",
			Green		= "hud_red_g",
			Blue		= "hud_red_b",
			Alpha		= "hud_red_a",
			ShowAlpha	= 1,
			ShowHSV		= 1,
			ShowRGB 	= 1,
			Multiplier	= 255
		})
	CPanel:AddControl("Label",
		{
			Text		= "Team Blue Color"
		})
	CPanel:AddControl("Color",
		{
			Label		= "Team Blue Color",
			Red			= "hud_blue_r",
			Green		= "hud_blue_g",
			Blue		= "hud_blue_b",
			Alpha		= "hud_blue_a",
			ShowAlpha	= 1,
			ShowHSV		= 1,
			ShowRGB 	= 1,
			Multiplier	= 255
		})
	CPanel:AddControl("Label",
		{
			Text		= "Background Color"
		})
	CPanel:AddControl("Color",
		{
			Label		= "Background Color",
			Red			= "hud_bg_r",
			Green		= "hud_bg_g",
			Blue		= "hud_bg_b",
			Alpha		= "hud_bg_a",
			ShowAlpha	= 1,
			ShowHSV		= 1,
			ShowRGB 	= 1,
			Multiplier	= 255
		})
	CPanel:AddControl("Label",
		{
			Text		= "Text Color"
		})
	CPanel:AddControl("Color",
		{
			Label		= "Text Color",
			Red			= "hud_txt_r",
			Green		= "hud_txt_g",
			Blue		= "hud_txt_b",
			Alpha		= "hud_txt_a",
			ShowAlpha	= 1,
			ShowHSV		= 1,
			ShowRGB 	= 1,
			Multiplier	= 255
		})
	CPanel:AddControl("Button",
		{
			Label		= "Update",
			Command		= "hud_update"
		})
end
function AddHudColorPanel()
	spawnmenu.AddToolMenuOption("Utilities", "Client", "HUD Controls", "HUD Controls", "", "", HudColorPanel, {})
end
hook.Add("PopulateToolMenu", "asdfpanel", AddHudColorPanel)
