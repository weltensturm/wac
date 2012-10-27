
local c="WAC"
local n="SWEPs"

CreateClientConVar("wac_cl_wep_help",0,false,false)

WAC.AddMenuPanel(c,n,function(CPanel,t)
	CPanel:Clear()
	CPanel:AddHeader()
	CPanel:AddDefaultControls()
	CPanel:AddControl("Label", {Text = "Client Settings"})
	CPanel:CheckBox("Free Aim for all Weapons","wac_cl_wep_allview")
	CPanel:CheckBox("Crosshair", "wac_cl_customcrosshair")
	CPanel:CheckBox("Cheap Muzzle Flash", "wac_cl_wep_defmuzzle")
	CPanel:AddControl("Slider", {
		Label = "View Bounce",
		Type = "float",
		Min = 0.3,
		Max = 1,
		Command = "wac_cl_wep_bounce",
	})
	CPanel:CheckBox("Viewmodel Positioner","wac_cl_wep_help")
	if t["wac_cl_wep_help"]=="1" then
		CPanel:AddControl("Button",{
			Label="Print Settings",
			Command="wac_cl_weaponhelp_print",
		})
		CPanel:AddControl("Button",{
			Label="Give Ironsight-Helper",
			Command="give w_wac_test",
		})
		CPanel:CheckBox("Flip Side","wac_cl_wep_help_flip")
		CPanel:CheckBox("Sprint","wac_cl_wep_help_sprint")
		CPanel:AddControl("TextBox", {
			Label="Model",
			MaxLength=512,
			Text="models/weapons/v_smg_mp5.mdl",
			Command="wac_cl_wep_help_model",
		})
		CPanel:AddControl("Slider", {
			Label = "X",
			Type = "float",
			Min = -10,
			Max = 10,
			Command = "wac_cl_wep_help_x",
		})
		CPanel:AddControl("Slider", {
			Label = "Y",
			Type = "float",
			Min = -10,
			Max = 10,
			Command = "wac_cl_wep_help_y",
		})
		
		CPanel:AddControl("Slider", {
			Label = "Z",
			Type = "float",
			Min = -10,
			Max = 10,
			Command = "wac_cl_wep_help_z",
		})
			
		CPanel:AddControl("Slider", {
			Label = "Pitch",
			Type = "float",
			Min = -10,
			Max = 10,
			Command = "wac_cl_wep_help_pitch",
		})
		CPanel:AddControl("Slider", {
			Label = "Yaw",
			Type = "float",
			Min = -10,
			Max = 10,
			Command = "wac_cl_wep_help_yaw",
		})
		CPanel:AddControl("Slider", {
			Label = "Roll",
			Type = "float",
			Min = -10,
			Max = 10,
			Command = "wac_cl_wep_help_roll",
		})
		CPanel:AddControl("Slider", {
			Label = "RunPos X",
			Type = "float",
			Min = -10,
			Max = 10,
			Command = "wac_cl_wep_help_rx",
		})
		CPanel:AddControl("Slider", {
			Label = "RunPos Y",
			Type = "float",
			Min = -10,
			Max = 10,
			Command = "wac_cl_wep_help_ry",
		})
		CPanel:AddControl("Slider", {
			Label = "RunPos z",
			Type = "float",
			Min = -10,
			Max = 10,
			Command = "wac_cl_wep_help_rz",
		})
		CPanel:AddControl("Slider", {
			Label = "RunAng Pitch",
			Type = "float",
			Min = -50,
			Max = 50,
			Command = "wac_cl_wep_help_rap",
		})
		CPanel:AddControl("Slider", {
			Label = "RunAng Yaw",
			Type = "float",
			Min = -50,
			Max = 50,
			Command = "wac_cl_wep_help_ray",
		})
		CPanel:AddControl("Slider", {
			Label = "RunAng Roll",
			Type = "float",
			Min = -50,
			Max = 50,
			Command = "wac_cl_wep_help_rar",
		})
	end
	CPanel:AddControl("Label", {Text = ""})
	CPanel:AddControl("Label", {Text = "Admin Settings"})
	CPanel:CheckBox("Allow Crosshair","wac_allow_crosshair")
	CPanel:CheckBox("Simulated Bullets","wac_physbullets")
	CPanel:CheckBox("Bullet Penetration", "wac_physbullets_penetrate")
end,{"wac_cl_wep_help"})
