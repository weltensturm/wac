if file.Exists("hl2-campaign/d1_town_03.txt") then
	INFO_PLAYER_SPAWN = {Vector(-3755, -28, -3366), 0}
	NEXT_MAP = "d1_town_02a"
	TRIGGER_CHECKPOINT = {
		{Vector(-5544, 1512, -3254), Vector(-5138, 1723, -2980)}
	}
else
	NEXT_MAP = "d1_town_03"
	TRIGGER_CHECKPOINT = {
		{Vector(-3494, -216, -3584), Vector(-3457, -64, -3477)}
	}
end