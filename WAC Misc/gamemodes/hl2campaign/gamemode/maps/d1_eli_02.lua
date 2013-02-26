NEXT_MAP = "d1_town_01"

TRIGGER_CHECKPOINT = {
	{Vector(-684, 845, -2688), Vector(-501, 886, -2567)},
	{Vector(-706, 1212, -2688), Vector(-524, 1253, -2567)},
	{Vector(-1939, 1833, -2736), Vector(-1897, 2001, -2629)}
}

hook.Add("InitPostEntity", "hl2cInitPostEntity", function()
	local wep = ents.Create("weapon_physcannon")
	wep:SetPos(Vector(-473, 814, -2590))
	wep:Spawn()
	wep:Activate()
end)