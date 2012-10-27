
local c="WAC"
local n="Player Health"

WAC.AddMenuPanel(c,n,function(CPanel,t)
	CPanel:CheckBox("Enable","wac_healthmod")
	CPanel:AddControl("Slider", {
		Label = "Regen Start Delay",
		Type = "float",
		Min = 0,
		Max = 3,
		Command = "wac_healthstart",
	})
	CPanel:AddControl("Slider", {
		Label = "Max Health",
		Type = "int",
		Min = 1,
		Max = 1000,
		Command = "wac_maxhealth",
	})
	CPanel:AddControl("Slider", {
		Label = "Health Regen Rate",
		Type = "float",
		Min = 0,
		Max = 3,
		Command = "wac_healthtime",
	})
	CPanel:AddControl("Slider", {
		Label = "Max Armor",
		Type = "int",
		Min = 1,
		Max = 1000,
		Command = "wac_maxarmor",
	})
	CPanel:AddControl("Slider", {
		Label = "Armor Regen Rate",
		Type = "float",
		Min = 0,
		Max = 3,
		Command = "wac_armortime",
	})
	CPanel:AddControl("Slider", {
		Label = "Damage Multiplicator, to NPC",
		Type = "float",
		Min = 0,
		Max = 3,
		Command = "wac_damage_npc",
	})
	CPanel:AddControl("Slider", {
		Label = "Damage Multiplicator, to Player",
		Type = "float",
		Min = 0,
		Max = 3,
		Command = "wac_damage_player",
	})
	CPanel:AddControl("Slider", {
		Label = "Falldamage Multiplicator",
		Type = "float",
		Min = 0,
		Max = 5,
		Command = "wac_falldamage",
	})
	CPanel:CheckBox("Custom Death Sounds","wac_damage_customsnd")
end)
