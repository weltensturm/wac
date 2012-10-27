
local SKIN = {}

SKIN.PrintName 		= "Shadow"
SKIN.Author 			= "WeltEnSTurm"
SKIN.DermaVersion		= 1

SKIN.colOutline					= Color( 30,  30,  30,  80)

SKIN.bg_color 					= Color( 20,  20,  20,  90) --derma windows, main tool area, slider background
SKIN.bg_color_sleep 			= Color( 60,  60,  60, 130)
SKIN.bg_color_dark				= Color( 20,  20,  20, 140) --Most areas
SKIN.bg_color_bright			= Color( 70,  70,  70, 230) --propsearch bg

SKIN.fontFrame					= "TargetID"

SKIN.control_color 				= Color(100, 100, 100, 155) --buttons, sliders etc
SKIN.control_color_highlight	= Color( 44,  44,  44, 100)
SKIN.control_color_active 		= Color( 66,  66,  66, 145)
SKIN.control_color_bright 		= Color( 44,  44,  44, 135)
SKIN.control_color_dark 		= Color( 11,  11,  11, 155)

SKIN.panel_transback			= Color(  5,   5,   5, 100)

SKIN.bg_alt1					= Color( 31,  31,  31,  50) --Colors of the spawnlist pattern
SKIN.bg_alt2					= Color( 41,  41,  41, 120)

SKIN.listview_hover				= Color(100, 100, 100, 140) --Spawnlist thing
SKIN.listview_selected			= Color(105, 105, 105, 140)

SKIN.text_bright				= Color(166, 166, 166, 255)
SKIN.text_normal				= Color(133, 133, 133, 255)
SKIN.text_dark					= Color( 60,  60,  60, 155)
SKIN.text_highlight				= Color(100, 100, 100, 155)

SKIN.texGradientUp				= Material( "gui/gradient_up" )
SKIN.texGradientDown			= Material("gui/gradient_down")

SKIN.combobox_selected			= SKIN.listview_selected

SKIN.tooltip					= Color(200, 200, 200, 255) --Bubble, on hover over ent/prop icon

SKIN.colPropertySheet 			= Color( 10,  10,  15, 110)
SKIN.colTab			 			= SKIN.colPropertySheet
SKIN.colTabInactive				= Color( 50,  50,  50, 150)
SKIN.colTabText		 			= Color(255, 255, 255, 255)
SKIN.colTabTextInactive			= Color(110, 110, 110, 255)
SKIN.colTabShadow				= Color( 13,  13,  13, 150)
SKIN.fontTab					= "DefaultSmall"

SKIN.colCollapsibleCategory		= Color( 15,  15,  20,  70)

SKIN.colCategoryText			= Color(250, 250, 250, 255)
SKIN.colCategoryTextInactive	= Color(170, 170, 170, 255)
SKIN.fontCategoryHeader			= "DefaultSmall"

--
SKIN.colNumberWangBG			= Color(255, 240, 150, 255)
SKIN.colTextEntryBG				= Color(240, 240, 240, 255)
SKIN.colTextEntryBorder			= Color( 20,  20,  20, 255)
SKIN.colTextEntryText			= Color( 79,  79,  79, 255)
SKIN.colTextEntryTextHighlight	= Color(130, 130, 130, 255)

SKIN.colMenuBG					= Color(150, 150, 150, 250) --presetlist background
SKIN.colMenuBorder				= Color(  0,   0,   0, 200)

SKIN.colButtonText				= Color(165, 165, 165, 255)
SKIN.colButtonTextDisabled		= Color( 90,  90,  90, 255)
SKIN.colButtonBorder			= Color( 20,  20,  20, 255)
SKIN.colButtonBorderHighlight	= Color( 55,  55,  55, 100)
SKIN.colButtonBorderShadow		= Color(  0,   0,   0, 100)
SKIN.fontButton					= "DefaultSmall"

function SKIN:DrawSquaredBox(x, y, w, h, color)
	surface.SetDrawColor(color)
	surface.DrawRect(x, y, w, h)	
	surface.SetDrawColor(self.colOutline)
	surface.DrawOutlinedRect(x, y, w, h)
end

function SKIN:PaintFrame(panel)
	local color = self.bg_color
	self:DrawSquaredBox(0, 0, panel:GetWide(), panel:GetTall(), color)
	surface.SetDrawColor(0, 0, 0, 75)
	surface.DrawRect(0, 0, panel:GetWide(), 21)	
	surface.SetDrawColor(self.colOutline)
	surface.DrawRect(0, 21, panel:GetWide(), 1)
end

derma.DefineSkin( "Shadow", "Dark shiny skin", SKIN )