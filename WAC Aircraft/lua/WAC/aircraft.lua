
include("wac/base.lua")
include("wac/keyboard.lua")

wac.menu.aircraft = "Aircraft"

WAC_AIR_LEANP = 1
WAC_AIR_LEANY = 2
WAC_AIR_LEANR = 3
WAC_AIR_UPDOWN = 4
WAC_AIR_START = 5
WAC_AIR_FIRE = 6
WAC_AIR_CAM = 7
WAC_AIR_NEXTWEP = 8
WAC_AIR_HOVER = 9
WAC_AIR_EXIT = 10
WAC_AIR_FREEAIM = 11
WAC_AIR_THIRDP = 12

local currentKey = 1
local function key(name)
	local t = {}
	t.index = currentKey
	
	t.name = name

	t.down = false
	t.isDown = function(self)
		return self.down
	end

	currentKey = currentKey + 1
	return t
end

wac.aircraft = wac.aircraft or {
	
	version = "327",
	
	spawnCategory = "WAC Air",

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
	}

	--[[
	keys = {
		exit = key('Exit Helicopter'),
		start = key('Start Aircraft'),
		thrust = key('Thrust'),
		brake = key('Brake'),
		rollLeft = key('Roll Left'),
		rollRight = key('Roll Right'),
		pitchUp = key('Pitch Up'),
		pitchDown = key('Pitch Down'),
		noseLeft = key('Nose Left'),
		noseRight = key('Nose Right'),
		fire = key('Fire Weapon'),
		nextWeapon = key('Next Weapon'),
		hover = key('Hover Toggle'),
		freeview = key('Free View'),
	},
	]]
	
}
