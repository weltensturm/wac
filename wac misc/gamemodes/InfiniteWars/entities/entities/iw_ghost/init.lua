
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_NONE)
	self.Entity:SetMaterial("models/wireframe")
end

function ENT:OnRemove()
end

function ENT:OnTakeDamage(dmginfo)
end

function ENT:SpawnOriginal()
	if !self.Spawned then
		self.iw_parent.iw_weld:Remove()
		self.iw_parent.Team=self.iw_team
		self.iw_parent:SetNWInt("Team", self.iw_team)
		umsg.Start("iw_ghost_remove")
		umsg.Entity(self.iw_parent)
		umsg.End()
		timer.Simple(1, function()
			if self and self:IsValid() then
				self:Remove()
			end
		end)
		self.Spawned=true
	end
end

function ENT:Think()
	if !ValidEntity(self.iw_parent) then self:Remove() end
	if self.iw_progress>self.iw_mass then
		self:SpawnOriginal()
	end
	if self:GetNWFloat("progress")!=self.iw_progress/self.iw_mass then
		self:SetNWFloat("progress", self.iw_progress/self.iw_mass)
	end
end

function ENT:Use(p)
end
