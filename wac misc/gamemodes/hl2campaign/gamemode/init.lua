DeriveGamemode("sandbox")

resource.AddFile("materials/hl2c_nav_marker.vmt")
resource.AddFile("materials/hl2c_nav_marker.vtf")
resource.AddFile("materials/hl2c_nav_pointer.vmt")
resource.AddFile("materials/hl2c_nav_pointer.vtf")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_debug.lua")
AddCSLuaFile("gui/scoreboard.lua")
AddCSLuaFile("gui/playerlist.lua")
AddCSLuaFile("gui/playerrow.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("player_sh.lua")
AddCSLuaFile("loadout.lua")
AddCSLuaFile("countdowns.lua")

include("sh_init.lua")
include("player_sv.lua")
include("loadout.lua")

GM.loadout = {}
GM.deadPlayers = {}
GM.difficulty = 1
GM.changingLevel = false
GM.checkpointPositions={}
GM.nextAreaOpenTime=0
GM.failTimer = 0


util.AddNetworkString("NextMap")
util.AddNetworkString("RestartMap")
util.AddNetworkString("StartCampaign")


FRIENDLY_NPCS = {
	"npc_citizen"
}

GODLIKE_NPCS = {
	"npc_alyx",
	"npc_barney",
	"npc_breen",
	"npc_dog",
	"npc_eli",
	"npc_fisherman",
	"npc_gman",
	"npc_kleiner",
	"npc_magnusson",
	"npc_monk",
	"npc_mossman",
	"npc_vortigaunt"
}

if file.Exists("gamemodes/hl2campaign/gamemode/maps/"..game.GetMap()..".lua", "GAME") then
	AddCSLuaFile("maps/"..game.GetMap()..".lua")
	include("maps/"..game.GetMap()..".lua")
	FOUND_MAP = true
end


for _, playerModel in pairs(PLAYER_MODELS) do
	util.PrecacheModel(playerModel)
end

function GM:Initialize()
	SetGlobalFloat("NDS_WEAPONVIEW_FORCEALL", true)
	game.ConsoleCommand("ai_disabled 0\n")
	game.ConsoleCommand("ai_ignoreplayers 0\n")
	game.ConsoleCommand("hl2_episodic 0\n")
	game.ConsoleCommand("mp_falldamage 1\n")
	game.ConsoleCommand("physgun_limited 1\n")
	game.ConsoleCommand("sv_playerpickupallowed 1\n")
	if string.find(game.GetMap(), "ep1_") || string.find(game.GetMap(), "ep2_") then
		game.ConsoleCommand("hl2_episodic 1\n")
	end
	if SUPER_GRAVITY_GUN then
		RunConsoleCommand("physcannon_pullforce", "8000")
		RunConsoleCommand("physcannon_tracelength", "850")
		RunConsoleCommand("physcannon_maxmass", "850")
		game.SetGlobalState("super_phys_gun", GLOBAL_ON)
	else
		game.SetGlobalState("super_phys_gun", GLOBAL_OFF)
	end
	local jeep = {
		Name = "Jeep",
		Class = "prop_vehicle_jeep_old",
		Model = "models/buggy.mdl",
		KeyValues = {	
			vehiclescript =	"scripts/vehicles/jeep_test.txt",
		}
	}
	list.Set("Vehicles", "Jeep", jeep)
	local airboat = {
		Name = "Airboat Gun",
		Class = "prop_vehicle_airboat",
		Category = Category,
		Model = "models/airboat.mdl",
		KeyValues = {
			vehiclescript = "scripts/vehicles/airboat.txt",
			EnableGun = 0
		}
	}
	list.Set("Vehicles", "Airboat", airboat)
	local airboatGun = {
		Name = "Airboat Gun",
		Class = "prop_vehicle_airboat",
		Category = Category,
		Model = "models/airboat.mdl",
		KeyValues = {
			vehiclescript = "scripts/vehicles/airboat.txt",
			EnableGun = 1
		}
	}
	list.Set("Vehicles", "Airboat Gun", airboatGun)
	local jalopy = {
		Name = "Jalopy",
		Class = "prop_vehicle_jeep",
		Model = "models/vehicle.mdl",
		KeyValues = {	
			vehiclescript =	"scripts/vehicles/jalopy.txt",
		}
	}
	list.Set("Vehicles", "Jalopy", jalopy)
end

function GM:CreateSpawnPoint(pos, yaw)
	local ips = ents.Create("info_player_start")
	ips:SetPos(pos)
	ips:SetAngles(Angle(0, yaw, 0))
	ips:Spawn()
end

function GM:CreateTDML(min, max)
	tdmlPos = max - ((max - min) / 2)	
	local tdml = ents.Create("trigger_delaymapload")
	tdml:SetPos(tdmlPos)
	tdml.min = min
	tdml.max = max
	tdml:Spawn()
end

function GM:EntityKeyValue(ent, key, value)
	if ent:GetClass() == "trigger_changelevel" && key == "map" then
		ent.map = value
	end
end

function GM:InitPostEntity()
	if !NEXT_MAP then
		self:FirstMap()
		return
	end
	if PLAYER_INVULNERABLE then
		game.SetGlobalState("gordon_invulnerable", GLOBAL_ON)
		game.SetGlobalState("gordon_precriminal", GLOBAL_ON)
	else
		game.SetGlobalState("gordon_invulnerable", GLOBAL_OFF)
		game.SetGlobalState("gordon_precriminal", GLOBAL_OFF)
	end
	game.SetGlobalState("friendly_encounter", GLOBAL_OFF)
	for _, ips in pairs(ents.FindByClass("info_player_start")) do
		if !ips:HasSpawnFlags(1) || INFO_PLAYER_SPAWN then
			ips:Remove()
		end
	end
	if INFO_PLAYER_SPAWN then
		GAMEMODE:CreateSpawnPoint(INFO_PLAYER_SPAWN[1], INFO_PLAYER_SPAWN[2])
	end
	if TRIGGER_CHECKPOINT then
		for _, tcpInfo in pairs(TRIGGER_CHECKPOINT) do
			local tcp = ents.Create("trigger_checkpoint")
			
			tcp.min = tcpInfo[1]
			tcp.max = tcpInfo[2]
			tcp.pos = tcp.max - ((tcp.max - tcp.min) / 2)
			tcp.skipSpawnpoint = tcpInfo[3]
			tcp.onTouchRun = tcpInfo[4]
			
			tcp:SetPos(tcp.pos)
			tcp:Spawn()
			
			table.insert(self.checkpointPositions, tcp.pos)
		end
	end
	if TRIGGER_DELAYMAPLOAD then
		self:CreateTDML(TRIGGER_DELAYMAPLOAD[1], TRIGGER_DELAYMAPLOAD[2])		
		for _, tcl in pairs(ents.FindByClass("trigger_changelevel")) do
			tcl:Remove()
		end
	else
		for _, tcl in pairs(ents.FindByClass("trigger_changelevel")) do
			if tcl.map == NEXT_MAP then			
				local tclMin, tclMax = tcl:WorldSpaceAABB()
				GAMEMODE:CreateTDML(tclMin, tclMax)
			end
			tcl:Remove()
		end
	end
	table.insert(self.checkpointPositions, tdmlPos)	
	umsg.Start("SetCheckpointPosition", RecipientFilter():AddAllPlayers())
	umsg.Vector(self.checkpointPositions[#self.checkpointPositions])
	umsg.End()
	local triggerMultiples = ents.FindByClass("trigger_multiple")
	for _, tm in pairs(triggerMultiples) do
		if tm:GetName() == "fall_trigger" then
			tm:Remove()
		end
	end
end 

function GM:ScaleNPCDamage(npc, hitGroup, dmgInfo)
	local attacker = dmgInfo:GetAttacker()
	if IsValid(attacker) && attacker:IsPlayer() then
		if SUPER_GRAVITY_GUN && attacker:GetActiveWeapon() && attacker:GetActiveWeapon():GetClass() == "weapon_physcannon" then
			dmgInfo:SetDamage(100)
		end
	end
end
	
function GM:OnNPCKilled(npc, killer, weapon)
	if killer && killer:IsValid() && killer:IsVehicle() && killer:GetDriver():IsPlayer() then
		killer = killer:GetDriver()
	end
	if killer && killer:IsValid() && killer:IsPlayer() && npc && npc:IsValid() then
		if table.HasValue(GODLIKE_NPCS, npc:GetClass()) then
			game.ConsoleCommand("kickid "..killer:UserID().." \"Killed an important NPC actor!\"\n")
			self:RestartMap()
		elseif NPC_POINT_VALUES[npc:GetClass()] then
			killer:AddFrags(NPC_POINT_VALUES[npc:GetClass()])
		else
			killer:AddFrags(1)
		end
	end
 	if weapon && weapon != NULL && killer == weapon && (weapon:IsPlayer() || weapon:IsNPC()) then 
 		weapon = weapon:GetActiveWeapon() 
 		if killer == NULL then weapon = killer end 
 	end 
 	local weaponClass = "World" 
 	local killerClass = "World" 
 	if weapon && weapon != NULL then weaponClass = weapon:GetClass() end 
 	if killer && killer != NULL then killerClass = killer:GetClass() end
 	if killer && killer != NULL && killer:IsPlayer() then 
 		umsg.Start("PlayerKilledNPC") 
 		umsg.String(npc:GetClass()) 
 		umsg.String(weaponClass) 
 		umsg.Entity(killer) 
 		umsg.End() 
 	end
end

local Weapons_Add={
	--[[["weapon_xbow"]={
		"w_wac_tw_as50",
		"w_wac_tw_m24",
	},
	["weapon_ar2"]={
		"w_wac_mw_m4",
		"w_wac_tw_fn2000",
		"w_wac_mw_fal",
	},
	["weapon_smg1"]={
		"w_wac_mw_ak47",
		"w_wac_tw_g36",
	},
	["weapon_pistol"]={
		"w_wac_tw_coltm1911",
	},
	["weapon_shotgun"]={
		"w_wac_css_m3",
	}]]
}

function GM:NextMap()
	if changingLevel then
		return
	end	
	changingLevel = true
	print("NEXT_MAP", NEXT_MAP)
	net.Start("NextMap")
	net.WriteString(NEXT_MAP)
	net.Broadcast()
	timer.Simple(NEXT_MAP_TIME, function() self:GrabAndSwitch() end)
	hook.Call("NextMap", nil, NEXT_MAP)
end

function GM:RestartMap()
	if changingLevel then
		return
	end
	self.failTimer = CurTime()+1
	changingLevel = true
	print("RESTART_MAP")
	net.Start("RestartMap")
	net.WriteString(game.GetMap())
	net.Broadcast()
	for _, pl in pairs(player.GetAll()) do
		pl:SendLua("GAMEMODE.ShowScoreboard = true")
	end	
	timer.Simple(RESTART_MAP_TIME, function() game.ConsoleCommand("changelevel "..game.GetMap().."\n") end)
	hook.Call("RestartMap", nil, game.GetMap())
end

function GM:FirstMap()
	if changingLevel then
		return
	end	
	changingLevel = true	
	print("FIRST_MAP")
	net.Start("StartCampaign")
	net.WriteString("HL2")
	net.Broadcast()
	timer.Simple(RESTART_MAP_TIME, function() game.ConsoleCommand("changelevel d1_trainstation_01\n") end)
	hook.Call("StartCampaign", nil, "HL2")
end

function GM:GrabAndSwitch()
	for _, pl in pairs(player.GetAll()) do
		if pl:Team() == TEAM_ALIVE then
			self:PlayerInfoSave(pl)
		end
	end
	game.ConsoleCommand("gamemode hl2campaign\n")
	game.ConsoleCommand("changelevel "..NEXT_MAP.."\n")
end


function GM:ShouldCollide(e1,e2)
	if e1:IsPlayer() and e2:IsPlayer() then
		return false
	end
	return true
end

function GM:EntityTakeDamage(target, dmg)
	local attacker = dmg:GetAttacker()
	if target:IsNPC() then
		local class = target:GetClass()
		if table.HasValue(GODLIKE_NPCS, class) and attacker:IsPlayer() then
			dmg:ScaleDamage(0)
		else
			dmg:ScaleDamage(1/self.difficulty)
		end
	elseif target:IsPlayer() then
		target.LastDamageTime = CurTime()+1
	end
end

function GM:ShowHelp(pl)
	umsg.Start("ShowHelp", pl)
	umsg.End()
end

function GM:ShowTeam(pl)
	umsg.Start("ShowTeam", pl)
	umsg.End()
end

function GM:ShowSpare1(pl)
	if pl:Team() != TEAM_ALIVE || pl:InVehicle() then
		return
	end	
	pl:RemoveVehicle()
	if ALLOWED_VEHICLE then
		local vehicleList = list.Get("Vehicles")
		local vehicle = vehicleList[ALLOWED_VEHICLE]		
		if !vehicle then return end
		pl.vehicle = ents.Create(vehicle.Class)
		pl.vehicle:SetModel(vehicle.Model)
		for a, b in pairs(vehicle.KeyValues) do
			pl.vehicle:SetKeyValue(a, b)
		end
		if ALLOWED_VEHICLE == "Jeep" then
			pl.vehicle:Fire("enablegun", 1)
		end
		local plAngle = pl:GetAngles()
		pl.vehicle:SetPos(pl:GetPos() + Vector(0, 0, 48) + plAngle:Forward() * 180)
		pl.vehicle:SetAngles(Angle(0, plAngle.y, 0))
		pl.vehicle:Spawn()
		pl.vehicle:Activate()
		pl.vehicle.creator = pl
	else
		pl:PrintMessage(HUD_PRINTTALK, "You may not spawn a vehicle at this time.")
	end
end

function GM:ShowSpare2(pl)
	pl:RemoveVehicle()
end

function GM:Think()
	local alive = #team.GetPlayers(TEAM_ALIVE)
	local dead = #team.GetPlayers(TEAM_DEAD)
	local completed = #team.GetPlayers(TEAM_COMPLETED_MAP)
	local count = #player.GetAll()
	if count > 0 and dead > count*(1-NEXT_MAP_PERCENT/100) then
		self:RestartMap()
	end
	if count > 0 and completed > count*(NEXT_MAP_PERCENT/100) then
		self:NextMap()
	end
	self:PlayerThink()
	self.difficulty = #player.GetAll()
	if self.nextAreaOpenTime <= CurTime() then
		for _, fap in pairs(ents.FindByClass("func_areaportal")) do
			fap:Fire("Open")
		end		
		self.nextAreaOpenTime = CurTime() + 3
	end
	if changingLevel and self.failTimer > 0 then
		game.SetTimeScale(math.Clamp((self.failTimer-CurTime()), 0.15, 1))
	end
end
