
include "shared.lua"
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Spawnable = false
ENT.AdminSpawnable = false


function ENT:trigger(b, player)
	self.shouldShoot = b
	self.player = player
end


function ENT:fire()
end


function ENT:stop()
end


function ENT:select(bool)
	if !bool then
		self:stop()
	end
end

function ENT:Think()
	if self.shouldShoot and self:GetNextShot() <= CurTime() and self:GetAmmo() > 0 then
		self:fire()
		self:SetAmmo(self:GetAmmo()-1)
		self:SetLastShot(CurTime())
		self:SetNextShot(self:GetLastShot() + 60/self.FireRate)
		if self:GetAmmo() <= 0 then
			self:stop()
			self:SetAmmo(self.Ammo)
			self:SetNextShot(CurTime() + 60)
		end
	end
	if self:GetNextShot() <= CurTime() then
		self:stop()
	end
	self:NextThink(CurTime())
	return true
end
