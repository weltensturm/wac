
include "shared.lua"
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Spawnable = false
ENT.AdminSpawnable = false


function ENT:Initialize()
	self:SetNextShot(0)
	self:SetLastShot(0)
	self:SetAmmo(self.Ammo)
	self.sounds = {}
	for n, p in pairs(self.Sounds) do
		if n != "BaseClass" then
			self.sounds[n] = CreateSound(self, p)
		end
	end
end


function ENT:OnRemove()
	for _, s in pairs(self.sounds) do
		s:Stop()
	end
end


function ENT:trigger(b, player)
	self.shouldShoot = b
	self.seat = player
end


function ENT:canFire()
	return true
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


function ENT:takeAmmo(amount)
	if self:GetAmmo() < amount then return false end
	self:SetAmmo(self:GetAmmo() - amount)
	return true
end


function ENT:Think()
	if self:canFire() and self.shouldShoot and self:GetNextShot() <= CurTime() and self:GetAmmo() > 0 then
		self:fire()
		self:SetLastShot(CurTime())
		self:SetNextShot(self:GetLastShot() + 60/self.FireRate)
	end
	if self:GetNextShot() <= CurTime() then
		self:stop()
	end
	self:NextThink(CurTime())
	return true
end
