
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:gcbt_breakactions() end
ENT.hasdamagecase = true

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetMoveType(MOVETYPE_NONE)
    self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetTrigger(true)
	timer.Simple(0.1, function()
		self:SetNotSolid(true)
		self:SetTrigger(true)
		if self.Team == TEAM_BLUE then
			self:SetMaterial("models/props_combine/com_shield001a")
		else
			self:SetMaterial("models/props_combine/tprings_globe")
		end
	end)
end

function ENT:StartTouch(e)
	if e.Team and (e.Team == 1 or e.Team == 2) then
		if e.Team != self.Team then
			NDS.SimpleSplode(e:GetPos(), 20, 999999, 10, true, self.Entity, self.Entity)
		end
	end
end