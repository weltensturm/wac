ALLOWED_VEHICLE = "Jeep"

if file.Exists("hl2-campaign/d2_coast_08.txt") then
	INFO_PLAYER_SPAWN = {Vector(3014, 3676, 1536), -194}
	NEXT_MAP = "d2_coast_09"
else
	INFO_PLAYER_SPAWN = {Vector(-6395, 4566, 1664), 0}
	NEXT_MAP = "d2_coast_08"
end

hook.Add("InitPostEntity", "hl2cInitPostEntity", function()
	if file.Exists("hl2-campaign/d2_coast_08.txt") then
		local func_brushes = ents.FindByClass("func_brush")
		func_brushes[1]:Remove()
	end
end)