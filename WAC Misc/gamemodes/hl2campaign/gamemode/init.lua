DeriveGamemode("sandbox")

-- Send the required resources to the client
resource.AddFile("materials/hl2c_nav_marker.vmt")
resource.AddFile("materials/hl2c_nav_marker.vtf")
resource.AddFile("materials/hl2c_nav_pointer.vmt")
resource.AddFile("materials/hl2c_nav_pointer.vtf")


-- Send the required lua files to the client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_scoreboard_playerlist.lua")
AddCSLuaFile("cl_scoreboard_playerrow.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_player.lua")


-- Include the required lua files
include("sh_init.lua")


-- Server only constants
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

-- Include the configuration for this map
if file.Exists("../gamemodes/hl2campaign/gamemode/maps/"..game.GetMap()..".lua") then
	include("maps/"..game.GetMap()..".lua")
end

if !ConVarExists("hl2c_admin_physgun") then
	CreateConVar("hl2c_admin_physgun", ADMIN_NOCLIP, FCVAR_NOTIFY)
	CreateConVar("hl2c_admin_noclip", ADMIN_PHYSGUN, FCVAR_NOTIFY)
end

local game_dd = {
	maxdeaths 	= CreateConVar("game_maxdeaths", 	"3", {FCVAR_REPLICATED, FCVAR_ARCHIVE}),
	dif_divide	= CreateConVar("game_diffdivider", 	"1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}),
}

for _, playerModel in pairs(PLAYER_MODELS) do
	util.PrecacheModel(playerModel)
end

function GM:CanPlayerSuicide(pl)
	if pl:Team() == TEAM_COMPLETED_MAP then
		pl:ChatPrint("You cannot suicide once you've completed the map.")
		return false
	elseif pl:Team() == TEAM_DEAD then
		pl:ChatPrint("This may come as a suprise, but you are already dead.")
		return false
	end	
	return true
end 

function GM:CreateSpawnPoint(pos, yaw)
	local ips = ents.Create("info_player_start")
	ips:SetPos(pos)
	ips:SetAngles(Vector(0, yaw, 0))
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

function GM:DoPlayerDeath(pl, attacker, dmgInfo)
	pl.deathPos = pl:EyePos()
	pl:RemoveVehicle()
	pl:Flashlight(false)
	pl:CreateRagdoll()
	pl:AddDeaths(1)
	if !table.HasValue(deadPlayers, pl:UniqueID()) and pl:Deaths() >= game_dd.maxdeaths:GetFloat() then
		table.insert(deadPlayers, pl:UniqueID())
		pl:SetTeam(TEAM_DEAD)
	end	
end

function GM:EntityKeyValue(ent, key, value)
	if ent:GetClass() == "trigger_changelevel" && key == "map" then
		ent.map = value
	end
end

function GM:GrabAndSwitch()
	for _, pl in pairs(player.GetAll()) do
		local plInfo = {}
		local plWeapons = pl:GetWeapons()		
		plInfo.predictedMap = NEXT_MAP
		plInfo.health = pl:Health()
		plInfo.armor = pl:Armor()
		plInfo.score = pl:Frags()
		plInfo.deaths = pl:Deaths()
		plInfo.model = pl.modelName
		if plWeapons && #plWeapons > 0 then
			plInfo.loadout = {}			
			for _, wep in pairs(plWeapons) do
				plInfo.loadout[wep:GetClass()] = {pl:GetAmmoCount(wep:GetPrimaryAmmoType()), pl:GetAmmoCount(wep:GetSecondaryAmmoType())}
			end
		end		
		file.Write("hl2campaign/"..pl:UniqueID()..".txt", util.TableToKeyValues(plInfo))
	end
	game.ConsoleCommand("changegamemode "..NEXT_MAP.." hl2campaign\n")
end

function GM:Initialize()
	deadPlayers = {}
	difficulty = 1
	changingLevel = false
	checkpointPositions={}
	nextAreaOpenTime=0
	startingWeapons={}
	SetGlobalFloat("NDS_WEAPONVIEW_FORCEALL", true)
	game.ConsoleCommand("ai_disabled 0\n")
	game.ConsoleCommand("ai_ignoreplayers 0\n")
	game.ConsoleCommand("hl2_episodic 0\n")
	game.ConsoleCommand("mp_falldamage 1\n")
	game.ConsoleCommand("physgun_limited 1\n")
	if string.find(game.GetMap(), "ep1_") || string.find(game.GetMap(), "ep2_") then
		game.ConsoleCommand("hl2_episodic 1\n")
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

function GM:InitPostEntity()
	if !NEXT_MAP then
		game.ConsoleCommand("changelevel d1_trainstation_01\n")
		return
	end
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
			
			table.insert(checkpointPositions, tcp.pos)
		end
	end
	if TRIGGER_DELAYMAPLOAD then
		GAMEMODE:CreateTDML(TRIGGER_DELAYMAPLOAD[1], TRIGGER_DELAYMAPLOAD[2])		
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
	table.insert(checkpointPositions, tdmlPos)	
	umsg.Start("SetCheckpointPosition", RecipientFilter():AddAllPlayers())
	umsg.Vector(checkpointPositions[#checkpointPositions])
	umsg.End()
	local triggerMultiples = ents.FindByClass("trigger_multiple")
	for _, tm in pairs(triggerMultiples) do
		if tm:GetName() == "fall_trigger" then
			tm:Remove()
		end
	end
end 

function GM:NextMap()
	if changingLevel then
		return
	end	
	changingLevel = true	
	umsg.Start("NextMap")
	umsg.Long(CurTime())
	umsg.End()	
	timer.Simple(NEXT_MAP_TIME, GAMEMODE.GrabAndSwitch)
end
concommand.Add("hl2c_next_map", function(pl) if pl:IsAdmin() then GAMEMODE:NextMap() end end)

function GM:OnNPCKilled(npc, killer, weapon)
	if killer && killer:IsValid() && killer:IsVehicle() && killer:GetDriver():IsPlayer() then
		killer = killer:GetDriver()
	end
	if killer && killer:IsValid() && killer:IsPlayer() && npc && npc:IsValid() then
		if table.HasValue(GODLIKE_NPCS, npc:GetClass()) then
			game.ConsoleCommand("kickid "..killer:UserID().." \"Killed an important NPC actor!\"\n")
			GAMEMODE:RestartMap()
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

function GM:PlayerCanPickupWeapon(pl, weapon) 
	if pl:Team() != TEAM_ALIVE || weapon:GetClass() == "weapon_stunstick" || (weapon:GetClass() == "weapon_physgun" && !pl:IsAdmin()) then
		weapon:Remove()
		return false
	end
	--if pl:KeyDown(IN_USE) then return true end
	--return false
	return true
end

function GM:PlayerDisconnected(pl)
	if file.Exists("hl2campaign/"..pl:UniqueID()..".txt") then
		file.Delete("hl2campaign/"..pl:UniqueID()..".txt")
	end	
	pl:RemoveVehicle()	
	if isDedicatedServer() && #player.GetAll() == 1 then
		game.ConsoleCommand("changelevel "..game.GetMap().."\n")
	end
end

function GM:PlayerInitialSpawn(pl)
	pl.startTime = CurTime()
	pl:SetTeam(TEAM_ALIVE)
	local plUniqueId = pl:UniqueID()
	if file.Exists("hl2campaign/"..plUniqueId..".txt") then
		pl.info=util.KeyValuesToTable(file.Read("hl2campaign/"..plUniqueId..".txt"))		
		if pl.info.predictedMap != game.GetMap() or RESET_PL_INFO then
			file.Delete("hl2campaign/"..plUniqueId..".txt")
			pl.info=nil
		elseif RESET_WEAPONS then
			pl.info.loadout=nil
		else
			--[[for k,a in pairs(pl.info.ammo) do
				pl:GiveAmmo(k,tonumber(a))
			end]]
		end
	end
	umsg.Start("PlayerInitialSpawn", pl)
	umsg.Vector(checkpointPositions[1])
	umsg.End()
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

function GM:PlayerLoadout(pl)
	pl:Give("w_wac_hands")
	if pl.info && pl.info.loadout then
		for wep, ammo in pairs(pl.info.loadout) do
			pl:Give(wep)
		end
	elseif startingWeapons && #startingWeapons > 0 then
		for _, wep in pairs(startingWeapons) do
			pl:Give(wep)
		end
	end
	timer.Simple(1, function()
		for _,e in pairs(pl:GetWeapons()) do
			local c=e:GetClass()
			if Weapons_Add[c] then
				for _,cn in pairs(Weapons_Add[c]) do
					pl:Give(cn)
				end
			end
		end
	end)
	pl:RemoveAllAmmo()
	if GetConVarNumber("hl2c_admin_physgun") == 1 && pl:IsAdmin() then
		pl:Give("weapon_physgun")
	end
end

function GM:PlayerNoClip(pl)
	if pl:IsAdmin() && GetConVarNumber("hl2c_admin_noclip") == 1 then
		return true
	end
	
	return false
end 

function GM:PlayerSelectSpawn(pl)
	local spawnPoints = ents.FindByClass("info_player_start")
	return spawnPoints[#spawnPoints]
end 

function GM:PlayerSetModel(pl)
	if pl.info && pl.info.model then
		pl.modelName = pl.info.model
	else
		local modelName = player_manager.TranslatePlayerModel(pl:GetInfo("cl_playermodel"))		
		if modelName && table.HasValue(PLAYER_MODELS, string.lower(modelName)) then
			pl.modelName = modelName
		else
			pl.modelName = PLAYER_MODELS[math.random(1, #PLAYER_MODELS)]
		end
	end	
	util.PrecacheModel(pl.modelName)
	pl:SetModel(pl.modelName)
end

function GM:PlayerSpawn(pl)
	if pl:Team() == TEAM_DEAD then
		pl:Spectate(OBS_MODE_ROAMING)
		pl:SetPos(pl.deathPos)
		pl:SetNoTarget(true)		
		return
	end
	pl:CrosshairDisable(true)
	local dist=10000
	local pteleto=nil
	for _,p in pairs(player.GetAll()) do
		local dista=p:GetPos():Distance(pl:GetPos())
		if p!=pl and dista<dist then
			dist=dista
			pteleto=p
		end
	end
	if ValidEntity(pteleto) then
		for i=0,350,10 do
			local pos=pteleto:GetPos()
			local tr=util.QuickTrace(pos+Vector(math.sin(i)*50,math.cos(i)*50,50),Vector(0,0,-49))
			if !tr.Hit then
				pl:SetPos(tr.HitPos)
			end
		end
	end
	pl.LastDamageTime = 0
	pl.energy = 100
	pl.givenWeapons = {}
	pl.healthRemoved = 0
	pl.nextEnergyCycle = 0
	pl.nextSetHealth = 0
	pl.sprintDisabled = false
	pl.vulnerable = false
	timer.Simple(VULNERABLE_TIME, function(pl) if pl && pl:IsValid() then pl.vulnerable = true end end, pl)
	GAMEMODE:SetPlayerSpeed(pl, 190, 320)
	GAMEMODE:PlayerSetModel(pl)
	GAMEMODE:PlayerLoadout(pl)
	if pl.info then
		if pl.info.health > 0 then
			pl:SetHealth(pl.info.health)
		end		
		if pl.info.armor > 0 then
			pl:SetArmor(pl.info.armor)
		end		
		pl:SetFrags(pl.info.score)
		pl:SetDeaths(pl.info.deaths)
	end
	--pl:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	if table.HasValue(deadPlayers, pl:UniqueID()) then
		pl:PrintMessage(HUD_PRINTTALK, "You may not respawn until the next map. Nice try though.")		
		pl.deathPos = pl:EyePos()		
		pl:RemoveVehicle()
		pl:Flashlight(false)
		pl:SetTeam(TEAM_DEAD)
		pl:AddDeaths(1)		
		pl:KillSilent()
	end
end

function GM:PlayerSwitchFlashlight(pl, on)
	if pl:Team() != TEAM_ALIVE then
		return false
	end	
	return true
end

function GM:PlayerUse(pl, ent)
	if ent:GetName() == "telescope_button" || pl:Team() != TEAM_ALIVE then
		return false
	end	
	return true
end

function GM:RestartMap()
	if changingLevel then
		return
	end	
	changingLevel = true	
	umsg.Start("RestartMap", RecipientFilter():AddAllPlayers())
	umsg.Long(CurTime())
	umsg.End()	
	for _, pl in pairs(player.GetAll()) do
		pl:SendLua("GAMEMODE.ShowScoreboard = true")
	end	
	timer.Simple(RESTART_MAP_TIME, game.ConsoleCommand, "changelevel "..game.GetMap().."\n")
end
concommand.Add("hl2c_restart_map", function(pl, command, arguments) if pl:IsAdmin() then GAMEMODE:RestartMap() end end)

function GM:ShouldCollide(e1,e2)
	if e1:IsPlayer() and e2:IsPlayer() then
		return false
	end
	return true
end

function GM:PlayerShouldTakeDamage(v,p)
	if v:IsPlayer() and p:IsPlayer() then
		if(p:Team() == v:Team() and GetConVarNumber("mp_friendlyfire") == 0) then
			return false
		end
	end
	return true
end

function GM:EntityTakeDamage(ent,i,at,amt,dmginfo)
	local entp = ent:IsPlayer()
	local atp = at:IsPlayer()
	local entn = ent:IsNPC()
	local atn = at:IsNPC()
	if entn then	
		local clss = ent:GetClass()
		local hit = true
		for _,n in pairs(GODLIKE_NPCS) do
			if clss == n then
				hit = false
			end
		end
		if atp then
			for _,cn in pairs(FRIENDLY_NPCS) do
				if clss == cn then
					hit = false
				end
			end
		end
		if !hit then
			dmginfo:ScaleDamage(0)
		end
	elseif entp then
		ent.LastDamageTime = CurTime()+1
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
	if #player.GetAll() > 0 && #team.GetPlayers(TEAM_ALIVE) + #team.GetPlayers(TEAM_COMPLETED_MAP) <= 0 then
		GAMEMODE:RestartMap()
	end
	for _, pl in pairs(player.GetAll()) do
		if !pl:Alive() or pl:Team() != TEAM_ALIVE then return end
		local wep1=pl:GetActiveWeapon()
		if ValidEntity(wep1) then
		local wep1c=wep1:GetClass()
			if Weapons_Add[wep1c] then
				for _,c in pairs(Weapons_Add[wep1c]) do
					if !pl:HasWeapon(c) then
						pl:Give(c)
					end
				end
			end
		end
		for _,pl2 in pairs(player.GetAll()) do
			if !pl2:Alive() or pl2:Team() != TEAM_ALIVE then return end
			local wep2=pl2:GetActiveWeapon()
			if ValidEntity(wep2) then
				local wep2c=wep2:GetClass()
				if pl != pl2 and pl2:Alive() and !pl:InVehicle() and !pl2:InVehicle() and wep2:IsValid() and !pl:HasWeapon(wep2c) and !table.HasValue(pl.givenWeapons, wep2c) and wep2c != "weapon_physgun" then
					pl:Give(pl2:GetActiveWeapon():GetClass())
					table.insert(pl.givenWeapons, pl2:GetActiveWeapon():GetClass())
				end
			end
		end
		if pl.nextEnergyCycle < CurTime() then
			if !pl:InVehicle() and ((pl:GetVelocity():Length() > 100 and pl:KeyDown(IN_SPEED) and pl:OnGround()) or pl:WaterLevel() == 3) and pl.energy > 0 then
				pl.energy = pl.energy - 1
			elseif pl.energy < 100 then
				pl.energy = pl.energy + .5
			end			
			umsg.Start("UpdateEnergy", pl)
			umsg.Float(pl.energy)
			umsg.End()
			pl.nextEnergyCycle = CurTime() + 0.1
		end
		if pl.energy < 2 then
			if !pl.sprintDisabled then
				pl.sprintDisabled = true
				GAMEMODE:SetPlayerSpeed(pl, 190, 190)
			end
			if pl:WaterLevel() == 3 && pl.nextSetHealth < CurTime() then
				pl.nextSetHealth = CurTime() + 1
				pl:SetHealth(pl:Health() - 10)				
				umsg.Start("DrowningEffect", pl)
				umsg.End()				
				if pl:Alive() && pl:Health() < 1 then
					pl:Kill()
				else
					pl.healthRemoved = pl.healthRemoved + 10
				end
			end				
		elseif pl.energy >= 15 && pl.sprintDisabled then
			pl.sprintDisabled = false
			GAMEMODE:SetPlayerSpeed(pl, 190, 320)
		end
		if pl:WaterLevel() <= 2 && pl.nextSetHealth < CurTime() && pl.healthRemoved > 0 then
			pl.nextSetHealth = CurTime() + 1
			pl:SetHealth(pl:Health() + 10)
			pl.healthRemoved = pl.healthRemoved - 10
		end
	end
	difficulty = math.Clamp((#player.GetAll() + 1) / 3, DIFFICULTY_RANGE[1], DIFFICULTY_RANGE[2])
	if nextAreaOpenTime <= CurTime() then
		for _, fap in pairs(ents.FindByClass("func_areaportal")) do
			fap:Fire("Open")
		end		
		nextAreaOpenTime = CurTime() + 3
	end
end

function GM:WeaponEquip(weapon)
	if weapon && weapon:IsValid() && weapon:GetClass() && !table.HasValue(startingWeapons, weapon:GetClass()) then
		table.insert(startingWeapons, weapon:GetClass())
	end
end