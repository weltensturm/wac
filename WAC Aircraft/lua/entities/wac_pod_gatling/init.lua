
include("shared.lua")
include("entities/base_wire_entity/init.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")


function ENT:Initialize()
	self.sounds = {
		shoot = CreateSound(self,"Warkanum/minigun_shoot.wav"),
		stop = CreateSound(self,"Warkanum/minigun_wind_stop.wav"),
	}
end


function ENT:trigger(b)
	self.shouldShoot = b
end


function ENT:fire()
	if self:GetNextShot() <= CurTime() then
		if self:GetAmmo() > 0 then
			if !self.shooting then
				self.shooting = true
				self.sounds.stop:Stop()
				self.sounds.shoot:Play()
			end
			local bullet = {}
			bullet.Num = 1
			bullet.Src = self:LocalToWorld(t.Gun==1 and t.ShootPos1 or t.ShootPos2)
			bullet.Dir = self:GetForward()
			bullet.Spread = Vector(0.015,0.015,0)
			bullet.Tracer = 4
			bullet.Force = 10
			bullet.Damage = 20
			bullet.Attacker = p
			local effectdata=EffectData()
			effectdata:SetOrigin(bullet.Src)
			effectdata:SetAngles(self:GetAngles())
			effectdata:SetScale(1.5)
			util.Effect("MuzzleEffect", effectdata)
			self.Entity:FireBullets(bullet)
			self:SetAmmo(self:GetAmmo()-1)
			self:SetLastShot(CurTime())
			self:SetNextShot(self:GetLastShot() + 60/self.FireRate)
		end
		if self:GetAmmo() <= 0 then
			self:stop()
			self:SetAmmo(self.Ammo)
			self:SetNextShot(CurTime() + 60)
		end
	end
end


function ENT:stop()
	if self.shooting then
		self.sounds.shoot:Stop()
		self.sounds.stop:Play()
		self.shooting = false
	end				
end

function ENT:Think()
	if self.shouldShoot then
		self:fire()
	end
	if self:GetNextShot() <= CurTime() then
		self:StopSounds()
	end
end

function ENT:deSelect()
	self:stop()
end
