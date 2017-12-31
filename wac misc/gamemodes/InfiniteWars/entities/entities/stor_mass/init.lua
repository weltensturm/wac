
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_wasteland/laundry_washer001a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	local ph=self.Entity:GetPhysicsObject()
	if ph:IsValid() then
		ph:SetMass(500)
	end
	self:SetNWInt("nds_maxhealth", 1500)
	self:SetNWInt("nds_health", 1500)
	self.cbt={
		health=1500,
		maxhealth=1500,
	}
	self.NDSctr={
		cbt={
			health=0,
			maxhealth=0,
		}
	}
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent=ents.Create("stor_mass")
	ent:SetPos(tr.HitPos+tr.HitNormal*60)
	ent:Spawn()
	ent:Activate()
	ent.Owner=ply	
	return ent
end

function ENT:OnRemove()
end

function ENT:OnTakeDamage(dmginfo)
end

function ENT:Think()
end

function ENT:Use(p)
end
