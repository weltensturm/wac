
include "wac/weapons.lua"


for _, file in pairs(file.Find("wac/weapons/*", "LUA")) do
	if SERVER then
		AddCSLuaFile("wac/weapons/" .. file)
	else
		include("wac/weapons/" .. file)
	end
end

local cvars = {
	allow = CreateClientConVar("wac_weapon_freeview", 1, true, true),
	offset = CreateClientConVar("wac_weapon_offset", 0, true, false),
	fov = CreateClientConVar("wac_weapon_fovmod", 0, true, false),
	bounce = CreateClientConVar("wac_weapon_bounce", 0.6, true, false),
}

local authors = {
	[wac.author] = {
		zoomed = function(w)
			local p = LocalPlayer()
			if IsValid(p) and IsValid(w) and !w.wacNoZoom and !wac.sprinting(p) and w:GetSequence()!=w:LookupSequence("reload") then
				if p:KeyDown(IN_ATTACK2) then
					if !w.wacZoomKeyDown and w.wacLastZoomed < CurTime()+0.2 then
						w.wacZoomKeyDown = true
						w.wacLastZoomed = CurTime()
					end
				else
					w.wacZoomKeyDown = false
				end
			end
		end
	},
	
	Worshipper = {
		zoomed = function(w)
			return w:GetDTBool(1)
		end
	},
	
}
