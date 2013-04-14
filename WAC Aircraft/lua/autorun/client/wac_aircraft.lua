

include "wac/aircraft.lua"

CreateClientConVar("wac_cl_air_realism", 3, true, true)
CreateClientConVar("wac_cl_air_sensitivity", 1, true, true)
CreateClientConVar("wac_cl_air_usejoystick", 0, true, true)
CreateClientConVar("wac_cl_air_smoothview", 1, true, true)
CreateClientConVar("wac_cl_air_mouse", 1, true, true)
CreateClientConVar("wac_cl_air_mouse_swap", 1, true, true)
CreateClientConVar("wac_cl_air_mouse_invert_pitch", 0, true, true)
CreateClientConVar("wac_cl_air_mouse_invert_yawroll", 0, true, true)
CreateClientConVar("wac_cl_air_shakeview", 1, true, true)


surface.CreateFont("wac_heli_big", {
	font = "monospace",
	size = 32
})

surface.CreateFont("wac_heli_small", {
	font = "monospace",
	size = 28
})

usermessage.Hook("wac_toggle_thirdp", function(m)
	RunConsoleCommand("gmod_vehicle_viewmode", GetConVar("gmod_vehicle_viewmode"):GetInt() == 1 and 0 or 1)
end)


wac.hook("CalcView", "wac_air_calcview", function(p, pos, ang, fov)

	p.wac = p.wac or {}
	p.wac.air = p.wac.air or {}

	local aircraft = p.wac.air.vehicle --p:GetVehicle():GetNWEntity("wac_aircraft")
	if !IsValid(aircraft) then
		if IsValid(p:GetVehicle():GetNWEntity("wac_aircraft")) then
			aircraft = p:GetVehicle():GetNWEntity("wac_aircraft")
			aircraft.viewPos = {
				origin = p.wac.air.lastView.origin - pos,
				angles = p.wac.air.lastView.angles - ang,
				fov = fov
			}
			aircraft:onEnter(p)
		else
			p.wac.air.vehicle = nil
			p.wac.air.lastView = {origin=pos, angles=ang, fov=fov}
			return false
		end
	end
	
	local i = p:GetNWInt("wac_passenger_id")
	if p.wac.air.vehicle and GetViewEntity() == p and aircraft.SeatsT then
		return aircraft:viewCalc((i==0 and 1 or i), p, pos, ang, fov)
	end

end)

wac.hook("RenderScreenspaceEffects", "wac_air_weaponcam",function()
	local p = LocalPlayer()
	if !IsValid(p) then return end
	local e = p:GetVehicle():GetNWEntity("wac_aircraft")
	if IsValid(e) then
		e:DrawScreenSpaceEffects(p:GetNWInt("wac_passenger_id"),p)
	end
end)

wac.hook("HUDPaint", "wac_air_weaponhud", function()
	local p = LocalPlayer()
	if !IsValid(p) then return end
	local e = p:GetVehicle():GetNWEntity("wac_aircraft")
	if IsValid(e) then
		e:DrawHUD(p:GetNWInt("wac_passenger_id"),p)
	end
end)

wac.hook("CreateMove", "wac_cl_air_mouseinput", function(md)
	local p=LocalPlayer()
	local e=p:GetVehicle():GetNWEntity("wac_aircraft")
	if IsValid(e) then
		e:MovePlayerView(p:GetNWInt("wac_passenger_id"),p,md)
	end
end)


-- menu
wac.addMenuPanel(wac.menu.tab, wac.menu.category, wac.menu.aircraft, function(panel, info)

	panel:AddControl("Label", {Text = "Client Settings"})
	
	local presetParams = {
		Label = "Presets",
		MenuButton = 1,
		Folder = "wac_aircraft",
		Options = {
			mouse = {
				wac_cl_air_easy = "1",
				wac_cl_air_sensitivity = "1",
				wac_cl_air_usejoystick = "0",
				wac_cl_air_mouse = "1",
				wac_cl_air_mouse_swap ="1",
				wac_cl_air_mouse_invert_pitch = "0",
				wac_cl_air_mouse_invert_yawroll = "0",
				wac_cl_air_key_1 = KEY_E,
				wac_cl_air_key_2 = KEY_R,
				wac_cl_air_key_3 = KEY_W,
				wac_cl_air_key_4 = KEY_S,
				wac_cl_air_key_5 = KEY_A,
				wac_cl_air_key_6 = KEY_D,
				wac_cl_air_key_7 = KEY_NONE,
				wac_cl_air_key_8 = KEY_NONE,
				wac_cl_air_key_9 = KEY_A,
				wac_cl_air_key_10 = KEY_D,
				wac_cl_air_key_11 = KEY_LALT,
				wac_cl_air_key_12 = MOUSE_LEFT,
				wac_cl_air_key_13 = MOUSE_RIGHT,
				wac_cl_air_key_14 = MOUSE_4,
				wac_cl_air_key_15 = KEY_SPACE,
			},
			keyboard = {
				wac_cl_air_easy = "1",
				wac_cl_air_sensitivity = "1",
				wac_cl_air_usejoystick = "0",
				wac_cl_air_mouse = "0",
				wac_cl_air_mouse_swap = "0",
				wac_cl_air_mouse_invert_pitch = "0",
				wac_cl_air_mouse_invert_yawroll = "0",
				wac_cl_air_key_1 = KEY_E,
				wac_cl_air_key_2 = KEY_R,
				wac_cl_air_key_3 = KEY_SPACE,
				wac_cl_air_key_4 = KEY_LSHIFT,
				wac_cl_air_key_5 = KEY_A,
				wac_cl_air_key_6 = KEY_D,
				wac_cl_air_key_7 = KEY_W,
				wac_cl_air_key_8 = KEY_S,
				wac_cl_air_key_9 = MOUSE_LEFT,
				wac_cl_air_key_10 = MOUSE_RIGHT,
				wac_cl_air_key_11 = KEY_LALT,
				wac_cl_air_key_12 = KEY_F,
				wac_cl_air_key_13 = KEY_G,
				wac_cl_air_key_14 = MOUSE_4,
				wac_cl_air_key_15 = KEY_X,
			},
		},
		CVars = {
			"wac_cl_air_easy",
			"wac_cl_air_sensitivity",
			"wac_cl_air_usejoystick",
			"wac_cl_air_mouse",
			"wac_cl_air_mouse_swap",
			"wac_cl_air_mouse_invert_pitch",
			"wac_cl_air_mouse_invert_yawroll",
		}
	}	
	for i,t in pairs(wac.aircraft.keys) do
		table.insert(presetParams.CVars, "wac_cl_air_key_" .. i)
	end
	panel:AddControl("ComboBox", presetParams)

	for name, t in pairs(wac.aircraft.controls) do
		if type(t) == "boolean" then
			local k = vgui.Create("wackeyboard::key", panel)
			k:setLabel(name)
			k:setKey(t)
			k.runCommand="wac_cl_air_key_"..name
			panel:AddPanel(k)
		else
			local f = vgui.Create("wackeyboard::key", panel)
			f:setLabel(name .. " +")
			f:setKey(wac.aircraft.keybindings["wac_cl_air_key_" .. name .. "_Inc"])
			f.runCommand = "wac_cl_air_key_"..name.."_Inc"
			panel:AddPanel(f)
			local k = vgui.Create("wackeyboard::key", panel)
			k:setLabel(name .. " -")
			k:setKey(wac.aircraft.keybindings["wac_cl_air_key_" .. name .. "_Dec"])
			k.runCommand = "wac_cl_air_key_"..name.."_Dec"
			panel:AddPanel(k)
		end
	end
	
	panel:AddControl("Slider", {
		Label = "Sensitivity",
		Type = "float",
		Min = 0.5,
		Max = 1.9,
		Command = "wac_cl_air_sensitivity",
	})
	
	panel:AddControl("Slider", {
		Label = "Realism",
		Type = "float",
		Min = 1,
		Max = 3,
		Command = "wac_cl_air_realism",
	})
	
	panel:CheckBox("Dynamic View Angle","wac_cl_air_smoothview")
	
	panel:CheckBox("Dynamic View Position","wac_cl_air_shakeview")

	if info["wac_cl_air_usejoystick"]=="0" then
		panel:CheckBox("Use Mouse","wac_cl_air_mouse")
		if info["wac_cl_air_mouse"]=="1" then
			panel:CheckBox(" - Invert Pitch","wac_cl_air_mouse_invert_pitch")
			panel:CheckBox(" - Invert Yaw/Roll","wac_cl_air_mouse_invert_yawroll")
			panel:CheckBox(" - Swap Yaw/Roll","wac_cl_air_mouse_swap")
			panel:AddControl("Label", {Text = ""})
		end
	end
	
	panel:CheckBox("Use Joystick","wac_cl_air_usejoystick")
	
	if info["wac_cl_air_usejoystick"]=="1" then
		panel:AddControl("Button", {
			Label = "Joystick Configuration",
			Command = "joyconfig"
		})
	end
	
	panel:AddControl("Label", {Text = ""})
	panel:AddControl("Label", {Text = "Admin Settings"})

	--panel:CheckBox("Double Force","wac_air_doubletick")

	panel:AddControl("Slider", {
		Label="Start Speed",
		Type="float",
		Min=0.1,
		Max=2,
		Command="wac_air_startspeed",
	})
	
	if game.SinglePlayer() then
		panel:CheckBox("Dev Helper","wac_cl_air_showdevhelp")
		if info["wac_cl_air_showdevhelp"]=="1" then
			panel:AddControl("Button", {
				Label = "Spawn",
				Command = "wac_cl_air_clientsidemodel_create",
			})
			panel:AddControl("Button", {
				Label = "Remove",
				Command = "wac_cl_air_clientsidemodel_remove",
			})
			panel:AddControl("TextBox", {
				Label="Model",
				MaxLength=512,
				Text="",
				Command="wac_cl_air_clmodel_model",
			})
			panel:AddControl("Slider", {
				Label="X",
				Type="float",
				Min=-600,
				Max=600,
				Command="wac_cl_air_clmodel_line_x",
			})
			panel:AddControl("Slider", {
				Label="Y",
				Type="float",
				Min=-200,
				Max=200,
				Command="wac_cl_air_clmodel_line_y",
			})
			panel:AddControl("Slider", {
				Label="Z",
				Type="float",
				Min=-200,
				Max=200,
				Command="wac_cl_air_clmodel_line_z",
			})
			panel:AddControl("Button", {
				Label = "Print",
				Command = "wac_cl_air_clmodel_printvars",
			})
			panel:AddControl("Button", {
				Label = "Reset",
				Command = "wac_cl_air_clmodel_line_x 0;wac_cl_air_clmodel_line_y 0;wac_cl_air_clmodel_line_z 0;",
			})
		end
	end
end,
	"wac_cl_air_mouse",
	"wac_cl_air_usejoystick",
	"wac_cl_air_showdevhelp"
)

