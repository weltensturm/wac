
include "shared.lua"

AddCSLuaFile "shared.lua"
AddCSLuaFile "cl_init.lua"

ENT.rpmMax = 240
ENT.throttle = 0
ENT.dir = 1

function ENT:Initialize()
	self.Entity:SetModel(self.model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
end


function ENT:PhysicsUpdate(ph)
	ph:AddVelocity(self:GetUp()*ph:GetAngleVelocity().z*self.dir*self.throttle/100)
end

