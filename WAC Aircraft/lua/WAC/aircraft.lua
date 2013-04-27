
include "wac/base.lua"
include "wac/keyboard.lua"

wac.menu.aircraft = "Aircraft"


wac.aircraft = wac.aircraft or {
	
	version = "329",
	
	spawnCategory = "WAC Aircraft",

	addControls = function(category, t)
		local c
		for i, t in pairs(wac.aircraft.controls) do
			if t.name == category then
				c = t
			end
		end
		if !c then
			c = { name = category, list = {} }
			table.insert(wac.aircraft.controls, c)
		end

		for name, control in pairs(t) do
			c.list[name] = control
		end
	end,

	controls = {},

	init = false

}
