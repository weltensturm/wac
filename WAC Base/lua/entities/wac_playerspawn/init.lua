
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/sawblade001a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	--self.Entity:SetCollisionGroup(0)
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent=ents.Create("wac_playerspawn")
	ent:SetPos(tr.HitPos+tr.HitNormal*5)
	ent:Spawn()
	ent.Owner=ply
	ent:SetNWEntity("owner", ply)
	return ent
end
