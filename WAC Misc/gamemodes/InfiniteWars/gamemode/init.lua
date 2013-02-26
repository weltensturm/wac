DeriveGamemode("sandbox")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_deathview.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_notice.lua")
AddCSLuaFile("skins/shadow.lua")
AddCSLuaFile("language.lua")
AddCSLuaFile("cl_panel.lua")

resource.AddFile("sound/if_team_win.mp3")
resource.AddFile("sound/if_team_loose.mp3")

include('shared.lua')
include('autospawn.lua')

STANDARD_WEAPONS = {
	"w_wac_tw_coltm1911",
	"weapon_physgun",
	"weapon_physcannon",
	"gmod_tool"
}

function GM:PlayerInitialSpawn(ply)
	if !loadedmapspawner then
		self:SpawnFromFile()
		loadedmapspawner = true
	end
	timer.Simple(0.005, function()
		self:SpawnAsSpectrator(ply)
	end)
	timer.Simple(0.1, function()
		if map_camera then
			ply:SetPos(map_camera:GetPos())
			ply:SetAngles(map_camera:GetAngles())
			ply:SetViewEntity(map_camera)
			ply:ConCommand("team_menu")
		end
	end)
end

function GM:PlayerSpawnSWEP(p,c)
	return false
end

function GM:PlayerSpawn(p)
	if !p.Class and !p.SetClass and (p:Team() == 1 or p:Team() == 2) then
		p:ConCommand("class_menu")
	end
	if p.SetClass then
		p.Class = p.SetClass
		p:SetNWString("class", p.SetClass)
		p.SetClass = nil
	end
	self:SetPlayerSpeed(p, WAC.WalkMod.ws:GetInt(), WAC.WalkMod.rs:GetInt())
	p:SetViewEntity(nil)
	p:SetNWBool("nored", false)
	p.sprintvar = 100
	p.cansprint = true
	self:PlayerLoadout(p, false)
end

--####################################[ Name: Team Management ]
--####################################[ Descr: Set players team/class ]

function GM:ShowTeam(ply)
	ply:ConCommand("team_menu")	
end

function GM:PlayerLoadout(ply, noloadout)
	if !ply or !ply:IsValid() then return end
	ply:StripAmmo()
	ply:StripWeapons()
	if ply:Team() == TEAM_BLUE then
		ply:SetModel("models/player/combine_soldier_prisonguard.mdl")
	else
		ply:SetModel("models/player/combine_super_soldier.mdl")
	end
	if !ply.Class and ply:Team() != 3 then ply:ConCommand("class_menu") return end
	if ply:Team() == 3 then return end
	ply:SetMoveType(MOVETYPE_WALK)
	for _,w in pairs(STANDARD_WEAPONS) do
		ply:Give(w)
	end
	for k,c in pairs(CLASSES) do
		if ply.Class == k then
			for id,w in pairs(c.weapons) do
				ply:Give(id)
			end
			ply:RemoveAllAmmo()
			for id,am in pairs(c.defammo) do
				ply:GiveAmmo(am, id)
			end
		end
	end
end 

function setteam(p,c,a)
	if a then
		local tms = tonumber(a[1])
		local tm = p:Team()
		p:ConCommand("team_menu_close")
		if tm != tms then
			p:SetTeam(tms)
			p.NextSpawnTime = CurTime()+((GAMEMODE.Started)and(15)or(25))
			if tms != 3 then
				p:Spectate(OBS_MODE_NONE)
				if p:Alive() and tms != tm and tm != 3 and GAMEMODE.Started then
					p:Kill()
				else
					p:KillSilent()
				end
			end
			for _, ply in pairs(player.GetAll()) do
				ply:ChatPrint("Player "..p:Nick().." joined team "..team.GetName(tms)..".")
			end
		end
		if tms == 3 then
			GAMEMODE:SpawnAsSpectrator(p)
		else
			p:ConCommand("class_menu")
		end
	end
end
concommand.Add("setteam", setteam)

local function setclass(p,c,a)
	if a then
		p.SetClass = a[1]
		p:ConCommand("class_menu_close")
		if p:Health() <= 0 then
			p:SetNWString("class", a[1])
			p.Class = a[1]
		else
			p.SetClass = a[1]
			p:ChatPrint("Your new class will be set during next respawn.")
		end
	end
end
concommand.Add("setclass", setclass)

local function setsuperallowed(p,c,a)
	if !p:IsSuperAdmin() or !a[1] or !a[2] then return end
	local msg = "Player "..a[1].." not found!"
	for _,p in pairs(player.GetAll()) do
		local n = p:Nick()
		if string.find(n, a[1]) then
			local all = util.tobool(a[2])
			p.IsSuperAllowed = all
			if all then
				msg = "Player "..n.." is now super allowed."
			else
				msg = "Player "..n.." is not super allowed."
			end
		end
	end
	p:PrintMessage(HUD_PRINTCONSOLE, msg)
end
concommand.Add("player_setsuperallowed", setsuperallowed)

--####################################[ Name: Damage/Points ]
--####################################[ Descr: Damage/Death/Score shit ]

function GM:PlayerShouldTakeDamage(v,p)
	if v:Team() == 3 then return false end
	if v:IsPlayer() and p:IsPlayer() then
		if(p:Team() == v:Team() and GetConVarNumber("mp_friendlyfire") == 0) then
			return false
		elseif p:Team() == v:Team() and p != v then
			for _,pl in pairs(player.GetAll()) do
				local msg = ""
				if pl:Team() == p:Team() then
					pl:ChatPrint(p:Nick().." attacked a teammate!")
				end
			end
		end
	end
	return true
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	ply:CreateRagdoll()
	ply:AddDeaths(1)
	if (attacker:IsValid() && attacker:IsPlayer()) then
		if (attacker == ply) then
			attacker:AddFrags(-1)
		elseif (attacker:Team() == ply:Team()) then
			attacker:AddFrags(-5)
			local scr = attacker:GetNWInt("score")
			attacker:SetNWInt("score", scr-200)
			for _,p in pairs(player.GetAll()) do
				p:ChatPrint(attacker:Nick().." killed a teammate!")
			end
		else
			attacker:AddFrags(1)
		end 
	end 
end

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerDeath(v,w,k)
	if v:Team() != 3 then
		if (k && w == k && (w:IsPlayer() || w:IsNPC())) then
			w = w:GetActiveWeapon()
			if (!w || w == NULL) then w = k end	
		end
		if k and k:IsPlayer() then
			local team = k:Team()
			if team then
				if team != v:Team() then
					self:AddPointsToTeam(team, 1000)
					local scr = k:GetNWInt("score")
					k:SetNWInt("score", scr+100)
				end
			end
		end
		v:EmitSound("npc/combine_soldier/die"..math.random(1,3)..".wav")
		v.NextSpawnTime = CurTime()+10
		umsg.Start("PlayerKilledByPlayer")
		umsg.Entity(v)
		umsg.String(w:GetClass())
		umsg.Entity(k)
		umsg.End()
	else
		timer.Simple(0.01, function()
			self:SpawnAsSpectrator(v)
		end)
	end
end

function GM:SpawnAsSpectrator(p)
	p:SetModel("")
	if p:Alive() then
		local Pos = p:EyePos()
	end
	p.Class = nil
	p:SetViewEntity(nil)
	p:SetTeam(3)
	p:KillSilent()
	p:Spectate(OBS_MODE_ROAMING)
	if Pos then
		p:SetPos(Pos)
	end
	p:SetNWBool("nored", true)
	p.NextSpawnTime = 99999999999999999999
	p:SetNWInt("spawntime", p.NextSpawnTime)
	p:ConCommand("class_menu_close")
end

function GM:EntityDeath(v,w,k)
	if k and k:IsPlayer() and v.Owner and v.Owner:IsPlayer() then
		local t1 = k:Team()
		local t2 = v.Team
			if t1 != t2 then
			local ph = v:GetPhysicsObject()
			if ph and ph:IsValid() then
				local add = v:GetPhysicsObject():GetMass()
				self:AddPointsToTeam(t1, add)
				local scr = k:GetNWInt("score")
				k:SetNWInt("score", scr+add)
			end
		end
	end
end

function GM:AddPointsToTeam(t, p)
	local scr = team.GetScore(t)
	team.SetScore(t, scr + p/10)
end

function GM:EntTakesCombatDamage(ent, dmg, prc, wep, att)
	local valid = true
	if NDS.Validate(ent) and att then
		if ent.Owner and ent.Owner:IsPlayer() and att and att:IsPlayer() and ent.Owner:Team() == att:Team() and GetConVarNumber("mp_friendlyfire")==0 then
			valid = false
		end
	end
	return valid
end

--####################################[ Name: construction management ]
--####################################[ Descr: deny toolgun/physgun outside base and remove ressources with spawning ents ]

function GM:PlayerSpawnedProp(ply, model, ent)
	self:CanEntitySpawn(ply, ent)
end

function GM:PlayerSpawnedSENT(ply, ent)
	self:CanEntitySpawn(ply, ent)
end

function GM:PlayerSpawnedVehicle(ply, ent)
	self:CanEntitySpawn(ply, ent)
end

function GM:PlyIsInBaseRange(ply,e,tr)
	if !ply.teambase or (ply.teambase and !ply.teambase:IsValid()) or ply.IsSuperAllowed then return true end
	if tr and tr.Entity then
		e = tr.Entity
		if e.AutoSpawned or !e.Team or (e.Team and e.Team != ply:Team())then return false end
		compareentpos = tr.HitPos
	elseif e and e:IsValid() then
		if e.AutoSpawned or !e.Team or (e.Team and e.Team != ply:Team())then return false end
		compareentpos = e:GetPos()
	else
		compareentpos = ply:GetPos()
	end
	if (ply.teambase and ply.teambase:IsValid() and compareentpos:Distance(ply.teambase:GetPos()) < 1000) or ply.Class == "Engineer" then
		return true
	else
		return false
	end
end

function GM:PhysgunPickup(p,e)
	if !e.Team or (e.Team != p:Team()) or ValidEntity(e.iw_ghost) or e.iw_team or e.AutoSpawned or e:GetClass()=="gen_mass" then return false end
	return true
end

function GM:SpawnBuildingGhost(p,e)
	local ghost=ents.Create("iw_ghost")
	if e:GetModel() then
		ghost:SetModel(e:GetModel())
	else
		ghost:Remove()
		return
	end
	ghost:SetPos(e:GetPos())
	ghost:SetAngles(e:GetAngles())
	ghost:Spawn()
	local ph=e:GetPhysicsObject()
	if ph:IsValid() then
		ghost.iw_mass=ph:GetMass()
	else
		ghost:Remove()
		return
	end
	ghost.iw_team=p:Team()
	ghost.iw_owner=p
	ghost.iw_progress=0
	ghost.iw_parent=e
	ghost:SetParent(e)
	ghost:SetNWEntity("ent", e)
	e.iw_ghost=ghost
	e.iw_spawning=true
	e.iw_weld=constraint.Weld(e,ents.FindByClass("worldspawn")[1],0,0,0,true)
end

local maxradius=CreateConVar("iw_max_entradius", 200, {FCVAR_REPLICATED,FCVAR_ARCHIVE})
function GM:CanEntitySpawn(ply, ent)
	local tm = ply:Team()
	if tm == 3 then
		ent:Remove()
		return
	end
	if ent:BoundingRadius() > maxradius:GetFloat() then
		ent:Remove()
		ply:ChatPrint("This entity is too large!")
		return
	end
	ent.Owner=ply
end

function GM:CanTool(p, tr, toolm)
	if ValidEntity(tr.Entity.iw_ghost) or (tr.Entity.Team and tr.Entity.Team != p:Team()) or tr.Entity.AutoSpawned or tr.Entity:GetClass()=="gen_mass" then return false end
	return true
end

function GM:OnPhysgunReload(w, p)
	local tre = p:GetEyeTrace().Entity
	if !tre.Team then
		tre.Owner=tre.Owner or tre:GetOwner()
		if tre.Owner:IsValid() then
			tre.Team=tre.Owner:Team()
		end
	end
	if tre and tre.Team and tre.Team == p:Team() then
		p:PhysgunUnfreeze(w)
	end
end

--####################################[ Name: Round system ]
--####################################[ Descr: Round start/end and that ]

function GM:StartRound()
	self.Started = true
	for _,p in pairs(player.GetAll()) do
		if p:Team() != 3 then
			p.NextSpawnTime = CurTime() + 5
		end
	end
	for _,e in pairs(ents.FindByClass("nds_wreck")) do
		timer.Simple(math.Rand(0.1, 2), function()
			if e and e:IsValid() then
				e:ExplodeFinal()
			end
		end)
	end
	self:SpawnFromFile()
	RunConsoleCommand("r_cleardecals")
	SetGlobalFloat("time_build", CurTime()+60)
	for i=1,2 do
		team.SetScore(i, 0)
		SetGlobalInt("resources_team"..i, 99999999)
	end
end

function GM:EndRound(t)
	self.Started = false
	for _,lol in pairs(ents.GetAll()) do
		if lol and lol.Team or lol:IsVehicle() then
			timer.Simple(math.Rand(0.1, 2), function()
				WAC.Damage.WreckIt(lol, lol, lol)
			end)
		end
	end
	SetGlobalInt("restarttime", CurTime()+20)
	timer.Simple(20, function() self:StartRound() end)
	for _,p in pairs(player.GetAll()) do
		local tm = p:Team()
		if tm != 3 then
			if p:InVehicle() then p:ExitVehicle() end
			if p:Alive() then
				p:Kill()
			end
			timer.Simple(0, function()
				if map_camera then
					p:SetViewEntity(map_camera)
					umsg.Start("WinLoose", p)
					umsg.Long(t)
					umsg.Long(tm)
					umsg.End()
				end
			end)
		end
		p.NextSpawnTime = CurTime()+999999999999999
	end
	for _,e in pairs(ents.FindByClass("control_point")) do
		e.state = 0
		e.team = 0
	end
end

--####################################[ Name: Misc ]
--####################################[ Descr: N/A ]

function GM:PlayerUse(p, e)
	local ec = e:GetClass()
	if ec == "nds_wreck" then
		local tm = p:Team()
		local stm = nil
		if tm == 1 then
			stm = "Blue"
		elseif tm == 2 then
			stm = "Red"
		end
		if stm then
			local weight = e.phys:GetMass()/2
			local res = GetGlobalFloat("Team"..stm.."Ressources")
			if res >= 10000 then return end
			SetGlobalFloat("Team"..stm.."Ressources", math.Clamp(res + weight,0, 10000))
			e:Remove()
			p:EmitSound("items/ammo_pickup.wav")
		end
	end
	return true
end

function GM:PlayerNoClip(p)
	if p:Team() == 3 then
		return false
	end
	if !p.IsSuperAllowed and GetConVarNumber("sbox_noclip") != 1 then
		return false
	end
	return true
end

local disableendround=CreateConVar("iw_disable_endround", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
local disableresourceneed=CreateConVar("iw_disable_resourceneed", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
local defincome=CreateConVar("iw_income_default", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
function GM:Think()
	for _,p in pairs(player.GetAll()) do
		local spawntime=p:GetNWInt("spawntime")
		if spawntime != p.NextSpawnTime then
			p:SetNWInt("spawntime", p.NextSpawnTime)
		end
		local trd = {}
		trd.start = p:EyePos()
		trd.endpos = p:GetAimVector()*99999999
		trd.filter = p
		local tr = util.TraceLine(trd)
		if tr.Hit and p:Alive() then
			if tr.Entity and (tr.Entity:IsPlayer() and tr.Entity:Team() != p:Team()) then
				umsg.Start("SpottedEnemy")
				umsg.Entity(tr.Entity)
				umsg.End()
			end
		end
		if !p:Alive() and p.Class then
			if p.NextSpawnTime <= CurTime()+0.5 then
				p:Spawn()
			end
		end
	end
	if !self.NextSecond or CurTime()>=self.NextSecond and self.Started then
		for _,e in pairs(ents.GetAll()) do
			e.Owner=e.Owner or e:GetOwner()
			if ValidEntity(e) and !e.IsBullet and e:GetClass()!="iw_ghost" and !e:IsPlayer() and !e:IsWeapon() and e.Owner and e.Owner:IsValid() and e.Owner:IsPlayer() and e.Owner:Team()>0 and !e.iw_spawning then
				self:SpawnBuildingGhost(e.Owner, e)
			end
		end
		local stor={0,0}
		for _,e in pairs(ents.FindByClass("stor_mass")) do
			if e.Team and e.Team>0 and e.Team<=2 then
				stor[e.Team]=stor[e.Team]+e:GetPhysicsObject():GetMass()
			end
		end
		for i=1,#stor do
			SetGlobalInt("resources_max_team"..i, stor[i])
		end
		local iIn={defincome:GetInt(),defincome:GetInt()}
		local iOut={0,0}
		for _,e in pairs(ents.FindByClass("gen_mass")) do
			if e.Team and e.Team>0 and e.Team<=2 then
				iIn[e.Team]=iIn[e.Team]+1
			end
		end
		for _,e in pairs(ents.FindByClass("iw_ghost")) do
			local add=((e.iw_wrenchadd)and(e.iw_wrenchadd+2)or(2))
			if e.iw_team and GetGlobalInt("resources_team"..e.iw_team)+iIn[e.iw_team]-iOut[e.iw_team]>add then
				e.iw_progress=e.iw_progress+2
				iOut[e.iw_team]=iOut[e.iw_team]+2
			end
		end
		for k,v in pairs(stor) do
			if v<1 and disableendround:GetInt()!=1 then self:EndRound(3-k) end
			SetGlobalInt("resources_team"..k, math.Clamp(GetGlobalInt("resources_team"..k)+iIn[k]-iOut[k],0,v))
			SetGlobalInt("resources_in_team"..k, iIn[k])
			SetGlobalInt("resources_out_team"..k, iOut[k])
		end
		self.NextSecond=CurTime()+0.1
	end
end
