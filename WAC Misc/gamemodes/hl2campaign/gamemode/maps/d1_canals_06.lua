ALLOWED_VEHICLE = "Airboat"

NEXT_MAP = "d1_canals_07"

hook.Add("PlayerSpawn", "hl2cPlayerSpawn", function(pl)
	pl:Give("weapon_physcannon")
end)