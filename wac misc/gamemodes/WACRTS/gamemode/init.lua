
include("shared.lua")
include("savespawner.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_body.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_body.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_body.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_body.phy")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_body.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_body.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_gun.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_gun.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_gun.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_gun.phy")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_gun.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_gun.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_turret.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_turret.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_turret.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_turret.phy")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_turret.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank01_turret.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_body.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_body.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_body.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_body.phy")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_body.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_body.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_gun.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_gun.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_gun.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_gun.phy")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_gun.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_gun.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_turret.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_turret.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_turret.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_turret.phy")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_turret.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank02_turret.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_body.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_body.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_body.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_body.phy")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_body.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_body.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_gun.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_gun.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_gun.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_gun.phy")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_gun.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_gun.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_turret.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_turret.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_turret.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_turret.phy")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_turret.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/tanks/tank03_turret.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory01.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory01.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory01.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory01.phy")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory01.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory01.vvd")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory02.dx80.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory02.dx90.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory02.mdl")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory02.phy")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory02.sw.vtx")
resource.AddFile("models/WeltEnSTurm/RTS/factories/factory02.vvd")

GM.Resources={
	BaseIncome=CreateConVar("wacrts_resources_baseincome",1,{FCVAR_REPLICATED,FCVAR_ARCHIVE}),
	BuildRate=CreateConVar("wacrts_resources_buildrate",1,{FCVAR_REPLICATED,FCVAR_ARCHIVE}),
}

function GM:SetResources(amt,p)
	p:SetNWFloat("wacrts_resources", amt)
end

function GM:PlayerSpawn(p)
	p:Give("w_idle")
	p:Spectate(OBS_MODE_ROAMING)
	p.SelectedUnits={}
	umsg.Start("wacrts_spawnplayer",p)
	umsg.Vector(p:GetPos())
	umsg.End()
	p:SetMoveType(MOVETYPE_NONE)
	self:SetResources(200,p)
	p:SetNWFloat("wacrts_resources_max",1000)
end

function GM:CanPlayerSuicide(p)
	return false
end

local function DeselectAll(p,c,a)
	for k,e in pairs(p.SelectedUnits) do
		e:SetNWBool("selected", false)
		p.SelectedUnits[k]=nil
	end
end
concommand.Add("wacrts_deselectall", DeselectAll)

local function SelectUnit(p,c,a)
	local e=ents.GetByIndex(a[1])
	if !table.HasValue(p.SelectedUnits, e) and ValidEntity(e) then
		table.insert(p.SelectedUnits, e)
		e:SetNWBool("selected", true)
	end
end
concommand.Add("wacrts_selectunit", SelectUnit)

concommand.Add("wacrts_resettargetpos", function(p,c,a)
	local e=ents.GetByIndex(a[1])
	if ValidEntity(e) then
		e:ResetTargetPos()
	end
end)

local function CheckUnits(t)
	for k,e in pairs(t) do
		if !e or !e:IsValid() then
			table.remove(t,k)
		end
	end
	return t
end

local function SetTargetPos(p,c,a)
	local e=ents.GetByIndex(a[1])
	e:SetDesiredPos(Vector(a[2],a[3],a[4]),a[5])
end
concommand.Add("wacrts_orders_Move", SetTargetPos)

concommand.Add("wacrts_orders_Attack", function(p,c,a)
	local e=ents.GetByIndex(a[1])
	e:SetAttackPosition(Vector(a[2],a[3],a[4]))
end)

concommand.Add("wacrts_settargetyaw", function(p,c,a)
	local ent=ents.GetByIndex(a[1])
	if ent and ent:IsValid() then
		ent:SetTargetYaw(a[2])
	end
end)

concommand.Add("wacrts_factorybuild", function(p,c,a)
	local e=ents.GetByIndex(a[1])
	if ValidEntity(e) then
		e:BuildUnit(a[2])
	end
end)

local function SpawnUnit(p,c,a)
	p.Units=p.Units or {}
	if GAMEMODE:PlayerCanCreateUnit(p) then
		local e=ents.Create(a[1])
		e:SetPos(Vector(a[2],a[3],a[4]))
		e:SetColor(a[5],a[6],a[7],255)
		e:Spawn()
		e:SetOwner(p)
		table.insert(p.Units,e)
	end
end
concommand.Add("wacrts_spawnunit", SpawnUnit)

function GM:PlayerCanCreateUnit(p)
	if #p.Units>33 then return false end
	return true
end

concommand.Add("wacrts_setplayerpos", function(p,c,a)
	p:SetPos(Vector(a[1],a[2],a[3]))
end)

function GM:TakeResources(amt,p)
	local res=p:GetNWFloat("wacrts_resources")
	local be=math.Clamp(res-amt,0,999999)
	self:SetResources(be,p)
	return (res-be)
end

local lastthink=0
function GM:Think()
	local crt=CurTime()
	for _,p in pairs(player.GetAll()) do
		local res=p:GetNWFloat("wacrts_resources")
		p:SetNWFloat("wacrts_resources", math.Clamp(res+(crt-lastthink)*self.Resources.BaseIncome:GetFloat(),0,p:GetNWFloat("wacrts_resources_max")))
	end
	lastthink=crt
end


