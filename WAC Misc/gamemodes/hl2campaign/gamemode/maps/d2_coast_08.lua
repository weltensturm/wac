INFO_PLAYER_SPAWN = {Vector(3328, 1570, 1539), -90}

NEXT_MAP = "d2_coast_07"

TRIGGER_CHECKPOINT = {
	{Vector(3006, -6962, 1920), Vector(3039, -6928, 1996)}
}

hook.Add("PlayerUse", "hl2cPlayerUse", function(pl, ent)
	if ent:GetClass() == "func_door" then
		file.Write("hl2-campaign/d2_coast_08.txt", "We have been to d2_coast_08 && pressed the button.")
	end
end)