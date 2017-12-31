ALLOWED_VEHICLE = "Airboat"

NEXT_MAP = "d1_canals_08"

hook.Add("PlayerCanPickupWeapon", "hl2cPlayerCanPickupWeapon", function(pl, weapon)
	if weapon:GetClass() == "weapon_physcannon" then
		weapon:Remove()
		return false
	end
end)