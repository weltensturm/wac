
local c="WAC"
local n="Miscellaneous"

WAC.AddMenuPanel(c,n,function(CPanel,t)
	CPanel:AddControl("Label", {Text = "Admin Settings"})
	CPanel:CheckBox("Enable Spawnpoints","wac_spawnmod_enable")
	CPanel:CheckBox("NPC Headshot Damage Fix","wac_headshotfix_enable")
	CPanel:AddControl("Slider", {
		Label = "Deathnotices",
		Type = "number",
		Min = 0,
		Max = 6,
		Command = "hud_deathnotice_time",
	})
	if SinglePlayer() then
		CPanel:AddControl("Slider", {
			Label = "Autosave Time (Seconds)",
			Type = "number",
			Min = 0,
			Max = 1000,
			Command = "wac_autosave_time",
		})
	end
end)
