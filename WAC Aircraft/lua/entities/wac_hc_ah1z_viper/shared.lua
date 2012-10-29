
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName		= "Viper AH-1Z"

ENT.Model			= "Models/BF2/helicopters/AH-1 Cobra/ah1z_b.mdl"
ENT.RotorPhModel	= "models/props_junk/sawblade001a.mdl"
ENT.RotorModel		= "Models/BF2/helicopters/AH-1 Cobra/ah1z_r.mdl"
ENT.BackRotorModel	= "Models/BF2/helicopters/AH-1 Cobra/ah1z_tr.mdl"

ENT.TopRotorPos		= Vector(0,0,120)
ENT.TopRotorDir		= -1
ENT.BackRotorPos	= Vector(-362.61,22.06,107.22)
ENT.BackRotorDir	= -1
ENT.SmokePos		= Vector(-116.21,0,79.51)
ENT.FirePos			= Vector(-89.17,0,92.37)
ENT.ThirdPDist		= 500

function ENT:AddSeatTable()
	return{
		[1]={
			Pos=Vector(70, 0, 48),
			ExitPos=Vector(72,70,0),
			wep={
				[1] = wac.aircraft.getWeapon("Hydra 70",{
					ShootPos = {
						[1]=Vector(40.25,36.33,32.93),
						[2]=Vector(40.25,-36.33,32.93),
					}
				}),
			},
		},
		[2]={
			Pos=Vector(120, 0, 42),
			ExitPos=Vector(120,70,0),
			wep={
				[1] = wac.aircraft.getWeapon("No Weapon"),
				[2] = wac.aircraft.getWeapon("M197"),
				[3] = wac.aircraft.getWeapon("Hellfire"),
			},
		},
	}
end

function ENT:AddSounds()
	self.Sound={
		Start=CreateSound(self.Entity,"wac/Heli/ah1_start.wav"),
		Blades=CreateSound(self.Entity,"npc/attack_helicopter/aheli_rotor_loop1.wav"),--"npc/attack_helicopter/aheli_rotor_loop1.wav"),
		Engine=CreateSound(self.Entity,"wac/heli/bellinternal.wav"),
		MissileAlert=CreateSound(self.Entity,"HelicopterVehicle/MissileNearby.mp3"),
		MissileShoot=CreateSound(self.Entity,"HelicopterVehicle/MissileShoot.mp3"),
		MinorAlarm=CreateSound(self.Entity,"HelicopterVehicle/MinorAlarm.mp3"),
		LowHealth=CreateSound(self.Entity,"HelicopterVehicle/LowHealth.mp3"),
		CrashAlarm=CreateSound(self.Entity,"HelicopterVehicle/CrashAlarm.mp3"),
	}
end
