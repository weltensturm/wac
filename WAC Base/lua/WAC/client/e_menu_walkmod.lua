
local c="WAC"
local n="Player Speed"

WAC.AddMenuPanel(c,n,function(CPanel,vt)
	CPanel:AddControl("Label", {Text = "Client Settings"})
	CPanel:CheckBox("Enable Speed Blur", "wac_cl_speed_blur")
	CPanel:CheckBox("Enable Blur in Noclip", "wac_cl_speed_blur_noclip")
	CPanel:AddControl("Label", {Text = ""})
	CPanel:AddControl("Label", {Text = "Admin Settings"})
	CPanel:CheckBox("Enable","wac_walkm_enable")
	local cb={}
	cb.Label="Presets"
	cb.MenuButton=0
	cb.Options = {}
	cb.Options["Default"]={
		wac_walkm_runspeed=500,
		wac_walkm_walkspeed=250,
		wac_walkm_jumpp=200,
		wac_walkm_update=1,
	}
	cb.Options["Realistic"]={
		wac_walkm_runspeed=215,
		wac_walkm_walkspeed=90,
		wac_walkm_update=1,
	}
	cb.Options["Balanced"]={
		wac_walkm_runspeed=310,
		wac_walkm_walkspeed=195,
		wac_walkm_update=1,
	}
	CPanel:AddControl("ComboBox", cb)
	CPanel:AddControl("Slider", {
		Label = "Walkspeed",
		Type = "number",
		Min = 1,
		Max = 1000,
		Command = "wac_walkm_walkspeed",
	})
	CPanel:AddControl("Slider", {
		Label = "Runspeed",
		Type = "number",
		Min = 1,
		Max = 1000,
		Command = "wac_walkm_runspeed",
	})
	CPanel:AddControl("Slider", {
		Label = "Jumppower",
		Type = "number",
		Min = 1,
		Max = 1000,
		Command = "wac_walkm_jumpp",
	})
	CPanel:AddControl("Button", {
		Label = "Update",
		Description = "Update Walkspeed",
		Text = "Update Walkspeed",
		Command = "wac_walkm_update",
	})
end)
