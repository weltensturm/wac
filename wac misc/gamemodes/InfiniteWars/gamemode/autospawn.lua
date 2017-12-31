include("ini_parser.lua")

if (not file.IsDir("InfiniteWars")) then
    file.CreateDir("InfiniteWars")
end

local classlist={
	"prop_iw_static",
	"prop_iw_shield",
	"team_ammostation",
	"team_repairstation",
	"map_camera",
	"wac_playerspawn",
	"iw_masspoint",
	"stor_mass",
}

function SpawnerSaveValidate(e)
	local valid = false
	if e and e:IsValid() then
		local cl = e:GetClass()
		for _,list in pairs(classlist) do
			if cl == list then
				valid = true
			end
		end
	end
	return valid
end

local function WriteSpawnerFile()
	local s = ""
	for _,e in pairs(ents.GetAll()) do
		if SpawnerSaveValidate(e) then
			local pos = e:GetPos()
			local ang = e:GetAngles()
			local cl = e:GetClass()
			if cl == "map_camera" then
				s = s.."[map_camera]\ncname=map_camera\npos="..pos.x.." "..pos.y.." "..pos.z.."\nang="..ang.p.." "..ang.y.." "..ang.r.."\n"
			else
				local range = e:GetNWFloat("range")
				local model = e:GetModel()
				local team = e.Team
				s = s.."[ents]\ncname="..cl.."\npos="..pos.x.." "..pos.y.." "..pos.z.."\nang="..ang.p.." "..ang.y.." "..ang.r.."\nmodel="..model.."\n"
				if team then
					s = s.."team="..team.."\n"
				end
				if range!=0 then
					s=s.."range="..range"\n"
				end
			end
			s = s.."\n"
			Msg("Saved "..cl.."\n")
		end
	end
	file.Write("InfiniteWars/"..game.GetMap()..".txt", s)
end
concommand.Add("basespawner_save", WriteSpawnerFile)

function GM:SpawnFromFile()
	local map = game.GetMap()
	local ini = INIParser:new("InfiniteWars/"..map..".txt")
	if !ini then return end
	self:ClearSpawnedEntities()
	if ini.ents then
		for i=1, table.getn(ini.ents) do
			GAMEMODE:SpawnEntFromString(ini.ents[i])
		end
	end
	if ini.runstring and ini.runstring[1] then
		RunString(ini.runstring[1].s)
	end
	if ini.map_settings and ini.map_settings[1] then
		if ini.map_settings[1].startres then 
			SetGlobalFloat("TeamBlueRessources", tonumber(ini.map_settings[1].startres))
			SetGlobalFloat("TeamRedRessources", tonumber(ini.map_settings[1].startres))
		end
		if ini.map_settings[1].endres then
			SetGlobalFloat("MaxTeamRessources", tonumber(ini.map_settings[1].endres))
		end
		if ini.map_settings[1].maxpoints then
			SetGlobalFloat("MaxPoints", tonumber(ini.map_settings[1].maxpoints))
		end
	end
	if ini.map_camera and ini.map_camera[1] then
		local pos=Vector(unpack(ini.map_camera[1].pos:TrimExplode(" ")))
		if map_camera and ValidEntity(map_camera) and map_camera:GetPos()==pos then return end
		local se = ents.Create("map_camera")
		Msg("Spawning map_camera\n")
		se:SetPos(pos)
		se:SetAngles(Vector(unpack(ini.map_camera[1].ang:TrimExplode(" "))))
		se:SetColor(0,0,0,0)
		map_camera = se
	end
end
concommand.Add("basespawner_spawn", SpawnFromFile)

function GM:ClearSpawnedEntities()
	for _,e in pairs(ents.GetAll()) do
		if e.AutoSpawned then
			e:Remove()
		end
	end
end
concommand.Add("basespawner_clear", ClearSpawnedEntities)

function GM:SpawnEntFromString(tEnt)
	if !tEnt then return end
	local se = ents.Create(tEnt.cname)
	if !se or !ValidEntity(se) then
		Msg("Failed to spawn "..tEnt.cname.."!\n")
		return
	end
	Msg("Spawning "..tEnt.cname.."\n")
	se:SetPos(Vector(unpack(tEnt.pos:TrimExplode(" "))))
	se:SetAngles(Angle(unpack(tEnt.ang:TrimExplode(" "))))
	se:Spawn()
	se:Activate()
	timer.Simple(0.1, function()
		se:SetNWFloat("range", tonumber(tEnt.range))
	end)
	if tEnt.model and tEnt.model != "" then
		se:SetModel(tEnt.model)
		se:PhysicsInit(SOLID_VPHYSICS)
		se:SetMoveType(MOVETYPE_NONE)
		se:SetSolid(SOLID_VPHYSICS)
		se.phys = se:GetPhysicsObject()
	end
	if tEnt.team then
		se:SetNWInt("Team", tonumber(tEnt.team))
		se.Team = tonumber(tEnt.team)
	end
	local ph=se:GetPhysicsObject()
	if ph and ph:IsValid() then
		ph:EnableMotion(false)
	else
		MsgN("Warning: Entity has no physics object!")
	end
	se.wac_vulnerable=tEnt.vulnerable
	se.AutoSpawned = true
end
