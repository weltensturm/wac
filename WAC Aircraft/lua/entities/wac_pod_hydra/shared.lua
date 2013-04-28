
AddCSLuaFile("shared.lua")

ENT.Base = "wac_pod_base"
ENT.Type = "anim"

ENT.PrintName = "Hydra 70 Pod"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false


ENT.Name = "Hydra 70"
ENT.Ammo = 7
ENT.FireRate = 120



function ENT:Initialize()
	self.sounds = {
		fire = CreateSound(self, "HelicopterVehicle/MissileShoot.mp3")
	}

	self.rockets = {}
	self:SetAmmo(self.Ammo)
	self:SetNextShot(0)
	self:SetLastShot(0)
end


function ENT:fire()
	local rocket = ents.Create("wac_hc_rocket")
	rocket:SetPos(self:GetPos())
	rocket:SetAngles(self:GetAngles())
	rocket.Owner = self.player
	rocket.Damage = 150
	rocket.Radius = 200
	rocket.Speed = 500
	rocket.Drag = Vector(0,1,1)
	rocket.TrailLength = 200
	rocket.Scale = 15
	rocket.SmokeDens = 1
	rocket.Launcher = self.aircraft
	rocket:Spawn()
	rocket:Activate()
	rocket:StartRocket()
	local ph = rocket:GetPhysicsObject()
	if ph:IsValid() then
		ph:SetVelocity(self:GetVelocity())
		ph:AddAngleVelocity(Vector(30,0,0))
	end
	self.sounds.fire:Stop()
	self.sounds.fire:Play()
	constraint.NoCollide(self.aircraft, rocket, 0, 0)
end



