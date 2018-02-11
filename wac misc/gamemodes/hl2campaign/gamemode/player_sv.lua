

MAX_AMMO = {
	["pistol"] = 150,
	["357"] = 12,
	["smg1"] = 225,
	["smg1_grenade"] = 3,
	["ar2"] = 60,
	["ar2altfire"] = 3,
	["buckshot"] = 30,
	["xbowbolt"] = 10,
	["rpg_round"] = 3,
	["slam"] = 5,
}

function GM:PlayerInfoSave(pl)
    print("saving playerinfo for "..tostring(pl).." (" .. pl:UniqueID() .. ")")
    file.CreateDir("hl2campaign")
    local info = {}
    info.predictedmap = NEXT_MAP
    info.health = pl:Health()
    info.armor = pl:Armor()
    info.score = pl:Frags()
    info.deaths = pl:Deaths()
    info.model = pl.modelName
    info.suit = pl:IsSuitEquipped()
    info.active = pl:GetActiveWeapon():GetClass()
    local weapons = pl:GetWeapons()
    if weapons && #weapons > 0 then
        info.loadout = {}
        info.ammo = {}		
        for _, wep in pairs(weapons) do
            local ammoTypes = {wep:GetPrimaryAmmoType(), wep:GetSecondaryAmmoType()}
            for _, ammo in pairs(ammoTypes) do
                if not info.ammo[ammo] then
                    info.ammo[ammo] = pl:GetAmmoCount(ammo)
                end
            end
            info.loadout[wep:GetClass()] = {wep:Clip1(), wep:Clip2()}
        end
    end
    file.Write("hl2campaign/"..pl:UniqueID()..".txt", util.TableToKeyValues(info))
end

function GM:PlayerInfoLoad(pl)
	local uid = pl:UniqueID()
    if file.Exists("hl2campaign/"..uid..".txt", "DATA") then
        pl.info = util.KeyValuesToTable(file.Read("hl2campaign/"..uid..".txt", "DATA"))
        if pl.info.predictedmap != game.GetMap() or RESET_PL_INFO then
			file.Delete("hl2campaign/"..uid..".txt", "DATA")
			pl.info=nil
		elseif RESET_WEAPONS then
			pl.info.loadout=nil
		else
			--[[for k,a in pairs(pl.info.ammo) do
				pl:GiveAmmo(k,tonumber(a))
			end]]
        end
        if pl.info then
            pl:SetFrags(pl.info.score)
            pl:SetDeaths(pl.info.deaths)
        end
	end
end


function GM:PlayerThink()
	for _, pl in pairs(player.GetAll()) do
        if !pl:Alive() or pl:Team() != TEAM_ALIVE then return end
        local suit = pl:IsSuitEquipped()
		if not suit then
			self:SetPlayerSpeed(pl, PLAYER_SPEED[1], PLAYER_SPEED[1])
        end
        
        for type, max in pairs(MAX_AMMO) do
            if pl:GetAmmoCount(type) > max then
                pl:SetAmmo(max, type)
            end
        end

		if suit and pl.nextEnergyCycle < CurTime() then
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

        if pl.energy < 2 or not suit then
			if !pl.sprintDisabled then
				pl.sprintDisabled = true
				self:SetPlayerSpeed(pl, PLAYER_SPEED[1], PLAYER_SPEED[1])
			end
			if pl:WaterLevel() == 3 && pl.nextSetHealth < CurTime() then
				pl.nextSetHealth = CurTime() + 1
				pl:SetHealth(pl:Health()-10)
				umsg.Start("DrowningEffect", pl)
				umsg.End()
				pl.healthRemoved = pl.healthRemoved + 10
			end
		elseif pl.energy >= 15 && pl.sprintDisabled then
			pl.sprintDisabled = false
			self:SetPlayerSpeed(pl, PLAYER_SPEED[1], PLAYER_SPEED[2])
		end

        if pl:WaterLevel() <= 2 && pl.nextSetHealth < CurTime() && pl.healthRemoved > 0 then
			pl.nextSetHealth = CurTime() + 1
			pl:SetHealth(pl:Health() + 10)
			pl.healthRemoved = pl.healthRemoved - 10
		end

    end
end


function GM:CanPlayerSuicide(pl)
    return false
end 

function GM:DoPlayerDeath(pl, attacker, dmgInfo)
	pl.deathPos = pl:EyePos()
	pl:RemoveVehicle()
	pl:Flashlight(false)
	pl:CreateRagdoll()
    pl:AddDeaths(1)
    pl.deaths = pl.deaths+1
	if !table.HasValue(self.deadPlayers, pl:UniqueID()) and pl.deaths >= CONVARS.maxdeaths:GetFloat() then
		table.insert(self.deadPlayers, pl:UniqueID())
		pl:SetTeam(TEAM_DEAD)
	end	
end


function GM:PlayerDisconnected(pl)
	pl:RemoveVehicle()	
	if game.IsDedicated() && #player.GetAll() == 1 then
		game.ConsoleCommand("changelevel "..game.GetMap().."\n")
	end
end

function GM:PlayerInitialSpawn(pl)
    pl.startTime = CurTime()
    pl.deaths = 0
    pl.energy = 0
    pl:SetTeam(TEAM_ALIVE)
    self:PlayerInfoLoad(pl)
	umsg.Start("PlayerInitialSpawn", pl)
	umsg.Vector(self.checkpointPositions[1] or Vector(0,0,0))
	umsg.End()
end 

function GM:PlayerSelectSpawn(pl)
	local spawnPoints = ents.FindByClass("info_player_start")
	return spawnPoints[#spawnPoints]
end 

function GM:PlayerSetModel(pl)
    local modelName = player_manager.TranslatePlayerModel(pl:GetInfo("cl_playermodel"))		
    if modelName && table.HasValue(PLAYER_MODELS, string.lower(modelName)) then
        pl.modelName = modelName
    elseif pl.info && pl.info.model then
		pl.modelName = pl.info.model
    else
        pl.modelName = PLAYER_MODELS[math.random(1, #PLAYER_MODELS)]
	end	
	util.PrecacheModel(pl.modelName)
	pl:SetModel(pl.modelName)
	pl:SetupHands()
end

function GM:PlayerSpawn(pl)
	if pl:Team() == TEAM_DEAD then
		pl:Spectate(OBS_MODE_ROAMING)
		pl:SetPos(pl.deathPos)
		pl:SetNoTarget(true)		
		return
	end
	pl:SetNoTarget(false)
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
	if IsValid(pteleto) then
        pl:SetPos(pteleto:GetPos())
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
	self:SetPlayerSpeed(pl, 190, 320)
	self:PlayerSetModel(pl)
	if pl.info then
		if pl.info.health > 0 then
			pl:SetHealth(pl.info.health)
		end		
		if pl.info.armor > 0 then
			pl:SetArmor(pl.info.armor)
        end
        if pl.info.suit then
            pl:EquipSuit()
        end
	end
	pl:SetNoCollideWithTeammates(true)
	if table.HasValue(self.deadPlayers, pl:UniqueID()) then
		pl.deathPos = pl:EyePos()		
		pl:RemoveVehicle()
		pl:Flashlight(false)
		pl:SetTeam(TEAM_DEAD)
		pl:AddDeaths(1)		
		pl:KillSilent()
	end
	pl:SetupHands()
end

function GM:PlayerNoClip(pl)
	if pl:IsAdmin() && CONVARS.noclip:GetBool() then
		return true
	end
	return false
end 

function GM:PlayerSwitchFlashlight(pl, on)
	if (not pl:IsSuitEquipped() or pl:Team() != TEAM_ALIVE) and on then
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

function GM:PlayerFinishedMap(ply)
    self:PlayerInfoSave(ply)
	ply:SetTeam(TEAM_COMPLETED_MAP)
	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	if ply:GetVehicle() && ply:GetVehicle():IsValid() then
		ply:GetVehicle():Remove()
		ply:ExitVehicle()
	end
	local p = ply:EyePos()
	ply:SetNoTarget(true)
	ply:StripWeapons()
	ply:Flashlight(false)
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SetPos(p)
	ply:SetNotSolid(false)
	PrintMessage(HUD_PRINTTALK, Format("%s completed the map (%s) [%i of %i].", ply:Nick(), string.ToMinutesSeconds(CurTime() - ply.startTime), team.NumPlayers(TEAM_COMPLETED_MAP), #player.GetAll()))
end

function GM:PlayerShouldTakeDamage(v,p)
	if v:IsPlayer() and p:IsPlayer() then
		if(p:Team() == v:Team() and GetConVarNumber("mp_friendlyfire") == 0) then
			return false
		end
	end
	return true
end
