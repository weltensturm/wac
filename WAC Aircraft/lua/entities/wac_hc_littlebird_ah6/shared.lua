
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName			= "Little Bird AH-6"

ENT.Model			= "models/Flyboi/LittleBird/littlebirda_fb.mdl"
ENT.RotorPhModel	= "models/props_junk/sawblade001a.mdl"
ENT.RotorModel		= "models/Flyboi/LittleBird/littlebirdrotorm_fb.mdl"
ENT.BackRotorModel= "models/Flyboi/LittleBird/LittleBirdT_fb.mdl"

ENT.BackRotorDir	= -1
ENT.TopRotorPos	= Vector(-10,0,100)
ENT.BackRotorPos	= Vector(-217,9,73)
ENT.EngineForce	= 20
ENT.Weight		= 1300

ENT.SmokePos	= Vector(-80,0,50)
ENT.FirePos		= Vector(-50,0,100)

function ENT:AddSeatTable()
	return{
		[1]={
			Pos=Vector(22, 15, 49),
			ExitPos=Vector(70,60,10),
			wep={
				[1]=WAC.Helicopter.GetWeapon("M134"),
				[2]=WAC.Helicopter.GetWeapon("Hydra 70"),
			},
		},
		[2]={
			Pos=Vector(22, -12, 49),
			ExitPos=Vector(70,-60,10),
			NoHud=true,
			wep={WAC.Helicopter.GetWeapon("No Weapon")},
		},
	}
end

function ENT:AddSounds()
	self.Sound={
		Start=CreateSound(self.Entity,"WAC/Heli/h6_start.wav"),
		Blades=CreateSound(self.Entity,"WAC/Heli/heli_loop_ext.wav"),
		Engine=CreateSound(self.Entity,"WAC/Heli/heli_loop_int.wav"),
		MissileAlert=CreateSound(self.Entity,"HelicopterVehicle/MissileNearby.mp3"),
		MissileShoot=CreateSound(self.Entity,"HelicopterVehicle/MissileShoot.mp3"),
		MinorAlarm=CreateSound(self.Entity,"HelicopterVehicle/MinorAlarm.mp3"),
		LowHealth=CreateSound(self.Entity,"HelicopterVehicle/LowHealth.mp3"),
		CrashAlarm=CreateSound(self.Entity,"HelicopterVehicle/CrashAlarm.mp3"),
	}
end
