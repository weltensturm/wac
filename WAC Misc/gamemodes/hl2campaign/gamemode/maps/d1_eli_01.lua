NEXT_MAP = "d1_eli_02"

TRIGGER_CHECKPOINT = {
	{Vector(-174, 2777, -1280), Vector(29, 2818, -1119)},
	{Vector(214, 2040, -1277), Vector(254, 2124, -1171)},
	{Vector(371, 1760, -2736), Vector(533, 1801, -2615)},
	{Vector(154, 2042, -2735), Vector(191, 2211, -2629)},
	{Vector(-574, 2049, -2736), Vector(-536, 2217, -2629)},
	{Vector(-692, 1053, -2688), Vector(-490, 1093, -2527)}	
}

TRIGGER_DELAYMAPLOAD = {Vector(-703, 989, -2688), Vector(-501, 1029, -2527)}

hook.Add("PlayerInitialSpawn", "hl2cPlayerInitialSpawn", function(pl)
	for _, ent in pairs(ents.FindByClass("prop_vehicle_airboat")) do
		ent:Remove()
	end
end)