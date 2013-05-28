

include "wac/aircraft.lua"

CreateClientConVar("wac_cl_air_realism", 3, true, true)
CreateClientConVar("wac_cl_air_sensitivity", 1, true, true)
CreateClientConVar("wac_cl_air_mouse", 1, true, true)
CreateClientConVar("wac_cl_air_mouse_swap", 1, true, true)
CreateClientConVar("wac_cl_air_mouse_invert_pitch", 0, true, true)
CreateClientConVar("wac_cl_air_mouse_invert_yawroll", 0, true, true)
CreateClientConVar("wac_cl_air_smoothview", 1, true, true)
CreateClientConVar("wac_cl_air_shakeview", 1, true, true)
CreateClientConVar("wac_cl_air_smoothkeyboard", 1, true, true)


surface.CreateFont("wac_heli_big", {
	font = "monospace",
	size = 32
})

surface.CreateFont("wac_heli_small", {
	font = "monospace",
	size = 22
})


wac.hook("ShouldDrawLocalPlayer", "wac_air_showplayerthirdperson", function()
	local v = LocalPlayer():GetVehicle()
	if IsValid(v:GetNWEntity("wac_aircraft")) then
		return v:GetThirdPersonMode()
	end
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
	if p.wac.air.vehicle and GetViewEntity() == p and aircraft.Seats then
		return aircraft:viewCalc((i==0 and 1 or i), p, pos, ang, 75)
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
				wac_cl_air_mouse = "1",
				wac_cl_air_mouse_swap ="1",
				wac_cl_air_mouse_invert_pitch = "0",
				wac_cl_air_mouse_invert_yawroll = "0",
				wac_cl_air_key_Exit = KEY_E,
				wac_cl_air_key_Start = KEY_R,
				wac_cl_air_key_Throttle_Inc = KEY_W,
				wac_cl_air_key_Throttle_Dec = KEY_S,
				wac_cl_air_key_Yaw_Inc = KEY_A,
				wac_cl_air_key_Yaw_Dec = KEY_D,
				wac_cl_air_key_Pitch_Inc = KEY_NONE,
				wac_cl_air_key_Pitch_Dec = KEY_NONE,
				wac_cl_air_key_Roll_Inc = KEY_NONE,
				wac_cl_air_key_Roll_Dec = KEY_NONE,
				wac_cl_air_key_FreeView = KEY_SPACE,
				wac_cl_air_key_Fire = MOUSE_LEFT,
				wac_cl_air_key_NextWeapon = MOUSE_RIGHT,
				wac_cl_air_key_Hover = MOUSE_4,
			},
			keyboard = {
				wac_cl_air_mouse = "0",
				wac_cl_air_mouse_swap = "0",
				wac_cl_air_mouse_invert_pitch = "0",
				wac_cl_air_mouse_invert_yawroll = "0",
				wac_cl_air_key_Exit = KEY_E,
				wac_cl_air_key_Start = KEY_R,
				wac_cl_air_key_Throttle_Inc = KEY_SPACE,
				wac_cl_air_key_Throttle_Dec = KEY_LSHIFT,
				wac_cl_air_key_Yaw_Inc = MOUSE_LEFT,
				wac_cl_air_key_Yaw_Dec = MOUSE_RIGHT,
				wac_cl_air_key_Pitch_Inc = KEY_W,
				wac_cl_air_key_Pitch_Dec = KEY_S,
				wac_cl_air_key_Roll_Inc = KEY_D,
				wac_cl_air_key_Roll_Dec = KEY_A,
				wac_cl_air_key_FreeView = KEY_X,
				wac_cl_air_key_Fire = KEY_F,
				wac_cl_air_key_NextWeapon = KEY_G,
				wac_cl_air_key_Hover = MOUSE_4,
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
	for category, controls in pairs(wac.aircraft.controls) do
		for i, t in pairs(controls) do
			if !t[3] then
				table.insert(presetParams.CVars, "wac_cl_air_key_" .. i)
			else
				table.insert(presetParams.CVars, "wac_cl_air_key_" .. i .. "_Inc")
				table.insert(presetParams.CVars, "wac_cl_air_key_" .. i .. "_Dec")
			end
		end
	end
	panel:AddControl("ComboBox", presetParams)

	for i, controls in pairs(wac.aircraft.controls) do
		panel:AddControl("Label", {Text = controls.name})
		for name, t in pairs(controls.list) do
			if !t[3] then
				local k = vgui.Create("wackeyboard::key", panel)
				k:setLabel(name)
				k:setKey(t[2])
				k.runCommand="wac_cl_air_key_"..name
				panel:AddPanel(k)
			else
				local f = vgui.Create("wackeyboard::key", panel)
				f:setLabel(name .. " +")
				f:setKey(t[2])
				f.runCommand = "wac_cl_air_key_"..name.."_Inc"
				panel:AddPanel(f)
				local k = vgui.Create("wackeyboard::key", panel)
				k:setLabel(name .. " -")
				k:setKey(t[3])
				k.runCommand = "wac_cl_air_key_"..name.."_Dec"
				panel:AddPanel(k)
			end
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

	panel:CheckBox("Use Mouse","wac_cl_air_mouse")
	if info["wac_cl_air_mouse"]=="1" then
		panel:CheckBox(" - Invert Pitch","wac_cl_air_mouse_invert_pitch")
		panel:CheckBox(" - Invert Yaw/Roll","wac_cl_air_mouse_invert_yawroll")
		panel:CheckBox(" - Swap Yaw/Roll","wac_cl_air_mouse_swap")
		panel:AddControl("Label", {Text = ""})
	end
	
	panel:AddControl("Button", {
		Label = "Joystick Configuration",
		Command = "joyconfig"
	})
	
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
	"wac_cl_air_showdevhelp"
)

