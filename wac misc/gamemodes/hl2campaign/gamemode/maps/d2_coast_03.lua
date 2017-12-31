ALLOWED_VEHICLE = "Jeep"

NEXT_MAP = "d2_coast_04"

hook.Add("InitPostEntity", "hl2cInitPostEntity", function()
	local wep = ents.Create("weapon_rpg")
	wep:SetPos(Vector(8513, 4299, 270))
	wep:Spawn()
	wep:Activate()
end)