
if !wac or !wac.aircraft then
	error("WAC scripts not loaded.")
end

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Base Helicopter"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.SmokePos = Vector(-75,0,20)
ENT.FirePos = Vector(-60,0,60)

function ENT:AddSeatTable()
	return {
		[1]={
			Pos=Vector(68, 0, 48),
			ExitPos=Vector(72,70,0),
			wep={
				[1]=WAC.Helicopter.GetWeapon("No Weapon"),
			},
		},
	}
end

function ENT:AddSounds()
	self.Sound={
		Start=CreateSound(self.Entity,"HelicopterVehicle/HeliStart.mp3"),
		Blades=CreateSound(self.Entity,"vehicles/Airboat/fan_blade_idle_loop1.wav"),
		Engine=CreateSound(self.Entity,"WAC/Heli/heli_loop_int.wav"),
		MissileAlert=CreateSound(self.Entity,"HelicopterVehicle/MissileNearby.mp3"),
		MissileShoot=CreateSound(self.Entity,"HelicopterVehicle/MissileShoot.mp3"),
		MinorAlarm=CreateSound(self.Entity,"HelicopterVehicle/MinorAlarm.mp3"),
		LowHealth=CreateSound(self.Entity,"HelicopterVehicle/LowHealth.mp3"),
		CrashAlarm=CreateSound(self.Entity,"HelicopterVehicle/CrashAlarm.mp3"),
	}
end
