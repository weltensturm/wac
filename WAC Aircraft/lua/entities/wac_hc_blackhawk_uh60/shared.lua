
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Black Hawk UH-60"

ENT.Model = "models/BF2/helicopters/UH-60 BlackHawk/uh60_b.mdl"
ENT.RotorPhModel = "models/props_junk/sawblade001a.mdl"
ENT.RotorModel = "models/BF2/helicopters/UH-60 BlackHawk/uh60_r.mdl"
ENT.BackRotorModel = "models/BF2/helicopters/UH-60 BlackHawk/uh60_rr.mdl"

ENT.SmokePos = Vector(-80,40,90)--{Vector(-80,40,90), Vector(-80,-40,90)}
ENT.FirePos = Vector(-25,0,130)

function ENT:AddSeatTable()
	return {
		[1]={
			Pos=Vector(110,-31,30),
			ExitPos=Vector(140,-100,3),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
		[2]={
			Pos=Vector(110,31,30),
			ExitPos=Vector(140,100,3),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
		[3]={
			Pos=Vector(65,-24,33),
			Ang=Angle(0,-90,0),
			ExitPos=Vector(33,-100,3),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
		[4]={
			Pos=Vector(65,24,33),
			Ang=Angle(0,90,0),
			ExitPos=Vector(33,101.04,3),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
		[5]={
			Pos=Vector(34.5,34,33),
			Ang=Angle(0,180,0),
			ExitPos=Vector(33,100,3),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
		[6]={
			Pos=Vector(-48,34,33),
			ExitPos=Vector(-20,100,3),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
		[7]={
			Pos=Vector(-48,-34,33),
			ExitPos=Vector(-20,-100,3),
			NoHud=true,
			wep={
				wac.aircraft.getWeapon("No Weapon"),
			},
		},
	}
end

function ENT:AddSounds()
	self.Sounds={
		Start=CreateSound(self.Entity,"WAC/Heli/h6_start.wav"),
		Blades=CreateSound(self.Entity,"WAC/Heli/uh60_loop.wav"),
		Engine=CreateSound(self.Entity,""),
		MissileAlert=CreateSound(self.Entity,"HelicopterVehicle/MissileNearby.mp3"),
		MissileShoot=CreateSound(self.Entity,"HelicopterVehicle/MissileShoot.mp3"),
		MinorAlarm=CreateSound(self.Entity,"HelicopterVehicle/MinorAlarm.mp3"),
		LowHealth=CreateSound(self.Entity,"HelicopterVehicle/LowHealth.mp3"),
		CrashAlarm=CreateSound(self.Entity,"HelicopterVehicle/CrashAlarm.mp3"),
		Radio=CreateSound(self.Entity, "HelicopterVehicle/MissileNearby.mp3"),
	}
end
