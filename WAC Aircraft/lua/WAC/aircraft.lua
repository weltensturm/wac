
include "wac/base.lua"
include "wac/keyboard.lua"

wac.menu.aircraft = "Aircraft"


wac.aircraft = wac.aircraft or {
	
	version = "329",
	
	spawnCategory = "WAC Aircraft",

	addControl = function(category, name, range, key1, key2)
		wac.aircraft.controls[category] = wac.aircraft.controls[category] or {}
		wac.aircraft.controls[category][name] = {range, key1, key2}
	end,

	addControls = function(category, table)
		for name, control in pairs(table) do
			wac.aircraft.addControl(category, name, control[1], control[2], control[3])
		end
	end,

	controls = {},

	init = false

}
