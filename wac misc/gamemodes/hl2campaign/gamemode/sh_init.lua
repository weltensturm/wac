
include("sh_config.lua")
include("player_sh.lua")


GM.Author = "WeltEnSTurm"

function GM:CreateTeams()
	TEAM_ALIVE = 1
	team.SetUp(TEAM_ALIVE, "", Color(81, 124, 199, 255))
	
	TEAM_COMPLETED_MAP = 2
	team.SetUp(TEAM_COMPLETED_MAP, "Completed Map", Color(81, 124, 199, 255))
	
	TEAM_DEAD = 3
	team.SetUp(TEAM_DEAD, "Dead", Color(81, 124, 199, 255))
end


// Called when map entities spawn
function GM:EntityKeyValue(ent, key, value)
	if ent:GetClass() == "trigger_changelevel" && key == "map" && SERVER then
		ent.map = key
	end
end


// Called when a gravity gun is attempting to punt something
function GM:GravGunPunt(pl, ent) 
 	if ent && ent:IsVehicle() && ent != pl.vehicle && ent.creator then
		return false
	end
	
	return true
end 


// Called when a physgun tries to pick something up
function GM:PhysgunPickup(pl, ent)
	if string.find(ent:GetClass(), "trigger_") || ent:GetClass() == "player" then
		return false
	end
	
	return true
end


// Called when a player entered a vehicle
function GM:PlayerEnteredVehicle(pl, vehicle, role)
	if pl.vehicle != vehicle and vehicle:GetName()!="jeep" then
		pl.vehicle = vehicle
		if vehicle.creator then
			vehicle.creator.vehicle = nil
		end
		vehicle.creator = pl
	end
end

