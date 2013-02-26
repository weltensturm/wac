include("ini_parser.lua")

if !file.IsDir("WACRTS") then
    file.CreateDir("WACRTS")
end

local classlist={
	"res_mass_point",
	"player_start",
}

local function SpawnerSaveValidate(e)
	if e and e:IsValid() and table.HasValue(classlist,e:GetClass()) then
		return true
	end
	return false	
end

local function WriteSpawnerFile()
	local s = ""
	for _,e in pairs(ents.GetAll()) do
		if SpawnerSaveValidate(e) then
			local pos = e:GetPos()
			local ang = e:GetAngles()
			local cl = e:GetClass()
			s = s.."[ents]\ncname="..cl.."\npos="..pos.x.." "..pos.y.." "..pos.z.."\nang="..ang.p.." "..ang.y.." "..ang.r.."\nmodel="..e:GetModel().."\n"
			s = s.."\n"
			Msg("Saved "..cl.."\n")
		end
	end
	file.Write("WACRTS/"..game.GetMap()..".txt", s)
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
end
concommand.Add("basespawner_spawn", SpawnFromFile)

function GM:ClearSpawnedEntities()
	for _,e in pairs(ents.GetAll()) do
		if e.wac_autospawned then
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
	if tEnt.model and tEnt.model != "" then
		se:SetModel(tEnt.model)
		se:PhysicsInit(SOLID_VPHYSICS)
		se:SetMoveType(MOVETYPE_NONE)
		se:SetSolid(SOLID_VPHYSICS)
		se.phys = se:GetPhysicsObject()
	end
	local ph=se:GetPhysicsObject()
	if ph and ph:IsValid() then
		ph:EnableMotion(false)
	else
		MsgN("Warning: Entity has no physics object!")
	end
	se.wac_autospawned=true
	se.wac_ignore=tEnt.wac_ignore
end
