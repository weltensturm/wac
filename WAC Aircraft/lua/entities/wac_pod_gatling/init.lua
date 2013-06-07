
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")


ENT.Sounds = {
	shoot = "Warkanum/minigun_shoot.wav",
	stop = "Warkanum/minigun_wind_stop.wav",
}

function ENT:Initialize()
	self:base("wac_pod_base").Initialize(self)
	self.sounds = {}
	for n, p in pairs(self.Sounds) do
		self.sounds[n] = CreateSound(self, p)
	end
end


function ENT:fireBullet(pos)
	if !self:takeAmmo(1) then return end
	local bullet = {}
	bullet.Num = 1
	bullet.Src = pos
	bullet.Dir = self:GetForward()
	bullet.Spread = Vector(0.015,0.015,0)
	bullet.Tracer = 0
	bullet.Force = 10
	bullet.Damage = 20
	bullet.Attacker = self.seat:GetDriver() or self.aircraft
	local effectdata = EffectData()
	effectdata:SetOrigin(bullet.Src)
	effectdata:SetAngles(self:GetAngles())
	effectdata:SetScale(1.5)
	util.Effect("MuzzleEffect", effectdata)
	self:FireBullets(bullet)
end


function ENT:fire()
	if !self.shooting then
		self.shooting = true
		self.sounds.stop:Stop()
		self.sounds.shoot:Play()
	end
	for _, v in pairs(self.Pods) do
		self:fireBullet(self:LocalToWorld(v))
	end
	self:SetNextShot(self:GetLastShot() + 60/self.FireRate)
end


function ENT:stop()
	if self.shooting then
		self.sounds.shoot:Stop()
		self.sounds.stop:Play()
		self.shooting = false
	end				
end
