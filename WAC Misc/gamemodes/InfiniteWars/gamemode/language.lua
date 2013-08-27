
local ph = {
	["weapon_ar2"]			="AR2",
	["weapon_smg1"]		="SMG",
	["rpg_missile"]			="RPG",
	["worldspawn"]			="World",
	["player"]				="Suicide",
	["teamkill"]				="Teamkill",
	["npc_hunter"]			="Hunter",
	["hunter_flechette"]		="Flechettes",
	["control_point"]			="CP",
	["staff_pulse"]			="Staff Weapon",
	["wac_w_rocket"]		="Rocket",
	["wac_w_base_bullet"]	="Grenade",
	["prop_combine_ball"]	="Combine Ball",
	["prop_physics"]			="Prop",
	["w_wac_base"]			="MP5",
	["w_wac_c4"]			="C4",
	["w_wac_as50"]			="AS50",
	["w_wac_tw_g36"]		="G36",
	["weapon_nds_p90"]		="P90",
	["w_nds_base_shot"]		="M1014"
}

function GM:CheckLanguage(s)
	if ph[s] then
		return ph[s]
	else
		return s
	end
end
