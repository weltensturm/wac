
include("wac/base.lua")
include("wac/keyboard.lua")

wac.menu.aircraft = "Aircraft"


wac.aircraft = wac.aircraft or {
	
	version = "329",
	
	spawnCategory = "WAC Aircraft",

	controls = {
		Throttle = {-1, 1},
		Pitch = {-1, 1},
		Yaw = {-1, 1},
		Roll = {-1, 1},
		Start = true,
		Exit = true,
		FreeCamera = true,
	},

	keybindings = {
		Throttle_Inc = KEY_SPACE,
		Throttle_Dec = KEY_SHIFT,
		Yaw_Inc = KEY_Q,
		Yaw_Dec = KEY_E,
		Roll_Inc = KEY_A,
		Roll_Dec = KEY_D,
		Pitch_Inc = KEY_W,
		Pitch_Dec = KEY_S,
		Start = KEY_R,
		Exit = KEY_F,
		FreeCamera = KEY_SPACE,
	},

	keys = {
		{k=KEY_E,n="Exit Helicopter"},
		{k=KEY_R,n="Start Engine"},
		{k=KEY_W,n="Lift"},
		{k=KEY_S,n="Fall"},
		{k=KEY_A,n="Roll Left"},
		{k=KEY_D,n="Roll Right"},
		{k=KEY_NONE,n="Nose Down"},
		{k=KEY_NONE,n="Nose Up"},
		{k=KEY_A,n="Nose Left"},
		{k=KEY_D,n="Nose Right"},
		{k=KEY_LALT,n="Switch Camera"},
		{k=MOUSE_LEFT,n="Fire Weapon"},
		{k=MOUSE_RIGHT,n="Next Weapon"},
		{k=MOUSE_4,n="Auto Hover Toggle"},
		{k=KEY_SPACE,n="Free Pilot View"},
	},

}
