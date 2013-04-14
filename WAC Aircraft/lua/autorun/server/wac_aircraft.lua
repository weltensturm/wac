
include "wac/aircraft.lua"

AddCSLuaFile("autorun/client/wac_aircraft.lua");
AddCSLuaFile("autorun/client/wac_aircraft_dev.lua");


wac.aircraft.cvars = {
	startSpeed = CreateConVar("wac_air_startspeed", 1, {FCVAR_ARCHIVE}),
	doubleTick = CreateConVar("wac_air_doubletick", 0, {FCVAR_ARCHIVE}),
}

wac.hook("SetPlayerAnimation", "wac_cl_heliseat_animation", function(pl, anim)
	 if pl:InVehicle() then
	 local v = pl:GetVehicle()
		if string.find(v:GetModel(), "models/nova/airboat_seat") and v:GetNWEntity("wac_aircraft"):IsValid() then 
			local seq = pl:LookupSequence("sit")	
			pl:SetPlaybackRate(1.0)
			pl:ResetSequence(seq)
			pl:SetCycle(0)
			return true
		end
	end
end)


wac.hook("JoystickInitialize", "wac_air_jcon_init", function()

	local tbl={
		[WAC_AIR_LEANP]	= "Lean Forward/Back",
		[WAC_AIR_LEANY]	= "Turn Left/Right",
		[WAC_AIR_LEANR]	= "Roll Left/Right",
		[WAC_AIR_UPDOWN] ="Thrust",
		[WAC_AIR_START] = "Turn On/Off",
		[WAC_AIR_FIRE] ="Shoot",
		[WAC_AIR_CAM] = "Toggle Camera",
		[WAC_AIR_NEXTWEP] = "Next Weapon",
		[WAC_AIR_HOVER] = "Auto Hover Toggle",
		[WAC_AIR_EXIT] = "Exit Helicopter",
		[WAC_AIR_FREEAIM] = "Free Aim",
	}

	for k, v in pairs(tbl) do
		jcon.register({
			uid = "wac_air_"..k,
			type = "analog",
			description = v[2],
			category = "WAC Helicopter"
		})
	end
	jcon.register({
		uid="wac_air_"..WAC_AIR_THIRDP,
		type="analog",
		description="Third Person",
		category="WAC Helicopter"
	})
	
end)

