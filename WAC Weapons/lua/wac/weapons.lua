
include "wac/base.lua"

wac.weapons = wac.weapons or {
	
	version = "316",

	prepareWeapon = function(weapon)

	end,

	muzzle = {
		star = {	
			Speed = 20,
			Vector(1, 1, 1),
			Vector(1, 1, -1),
			Vector(-1, 1, 1),
			Vector(-1, 1, -1)
		},
		normal = {
			Speed = 15,
			Vector(0, 1, 0)
		}
	},

	weaponClasses = {},

	register = function(name, data)
		wac.weapons.weaponClasses[name] = data
	end

}
