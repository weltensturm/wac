INFO_PLAYER_SPAWN = {Vector(-2489, -1292, 580), 90}

NEXT_MAP_PERCENT = 1

NEXT_MAP_TIME = 45

RESET_WEAPONS = true

SUPER_GRAVITY_GUN = true

TRIGGER_CHECKPOINT = {
	{Vector(-2379, 390, 576), Vector(-2237, 531, 697)},
	{Vector(-1890, -58, 1344), Vector(-1849, 63, 1465)},
	{Vector(-820, -115, -256), Vector(-780, 111, -95)}
}

TRIGGER_DELAYMAPLOAD = {Vector(14095, 15311, 14964), Vector(13702, 14514, 15000)}

if PLAY_EPISODE_1 == 1 then
	NEXT_MAP = "ep1_citadel_00"
else
	NEXT_MAP = "d1_trainstation_01"
end