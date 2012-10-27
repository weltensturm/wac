
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:SetModel("models/WeltEnSTurm/BF2/bf2_physbullet.mdl")		
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if self.phys:IsValid() then
		self.phys:SetMass(5)
	end
	self.DieTime=CurTime()+4
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true
	self.Owner = self.Owner or self.Entity
	local tr=util.QuickTrace(self:GetPos(), Vector(0,0,-100), self.Entity)
	util.Decal("Scorch",tr.HitPos+tr.HitNormal, tr.HitPos-tr.HitNormal)
	if WAC then
		WAC.SimpleSplode(tr.HitPos, 200, 200, 7, false, self.Entity, self.Owner)
		WAC.Hit(tr.Entity, 50, 7, self.Entity, self.Owner)
	end
	self.HitPlayers = {}	
	local HitEnts = ents.FindInSphere(tr.HitPos, 100)
	--self.Entity:EmitSound(self.ConTable["soundExplode"][2], 80)
	local ed = EffectData()
	ed:SetEntity(self.Entity)
	ed:SetOrigin(tr.HitPos)
	ed:SetStart(tr.HitPos)
	ed:SetScale(1)
	ed:SetRadius(tr.MatType)
	ed:SetAngle(tr.HitNormal:Angle())
	util.Effect("wac_tankshell_impact", ed)
	self.Entity:Remove()
end

function ENT:Think()
	if !self.Exploded and self.DieTime<CurTime() then
		self:Explode()
	end
end
