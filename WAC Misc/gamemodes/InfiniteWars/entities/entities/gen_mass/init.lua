
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_wasteland/coolingtank01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	local ph=self.Entity:GetPhysicsObject()
	self.cbt={
		health=1500,
		maxhealth=1500,
	}
	self:SetNWInt("nds_maxhealth", 1500)
	self:SetNWInt("nds_health", 1500)
	if ph:IsValid() then
		ph:SetMass(500)
	end
	self.NDSctr={
		cbt={
			health=0,
			maxhealth=0,
		}
	}
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local tEnts=ents.FindInSphere(tr.HitPos, 100)
	for _,e in pairs(tEnts) do
		if e:GetClass()=="iw_masspoint" and !ValidEntity(e.Extractor) then
			local e2=ents.Create("gen_mass")
			e2:SetPos(e:GetPos()+Vector(0,0,80))
			e2:Spawn()
			e2:Activate()
			e2:SetParent(e)
			constraint.Weld(e, e2, 0,0,0,0)
			e.Extractor=e2
			e:SetNWEntity("extractor", e2)
			return e2
		end
	end
end

function ENT:OnRemove()
end

function ENT:OnTakeDamage(dmginfo)
end

function ENT:Think()
end

function ENT:Use(p)
end
