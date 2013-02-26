
include("shared.lua")

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:SetModel("models/WeltEnSTurm/BF2/bf2_physbullet.mdl")		
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_NONE)
	self:NextThink(CurTime())
end
