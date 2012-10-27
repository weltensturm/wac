
ENT.Base = "wac_pl_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Cessna C172"

ENT.Model						= "models/Cessna/cessna172.mdl"
ENT.RotorPhModel		= "models/props_junk/sawblade001a.mdl"
ENT.RotorModel			= "models/Cessna/cessna172_prop.mdl"

ENT.FirePos			= Vector(70,0,0)
ENT.SmokePos		= ENT.FirePos

ENT.Weight			= 800

ENT.EngineWeight = {
	Weight = 300,
	Position = ENT.TopRotorPos
}

ENT.WheelInfo={
	{
		mdl="models/Cessna/cessna172_mlwheel.mdl",
		pos=Vector(-13.73,45.36,-39),
		friction=0,
		mass=50,
	},
	{
		mdl="models/Cessna/cessna172_mwheel.mdl",
		pos=Vector(-13.73,-45.36,-39),
		friction=0,
		mass=50,
	},
	{
		mdl="models/Cessna/cessna172_nwheel.mdl",
		pos=Vector(53.31,0,-41.89),
		friction=0,
		mass=50,
	},
}

function ENT:AddSeatTable()
	return {
		[1]={
			Pos=Vector(1.4, 9.5, -10),
			ExitPos=Vector(60, 50, -45),
			NoHud=true,
			wep={
				WAC.Helicopter.GetWeapon("No Weapon"),
			},
		},
		[2]={
			Pos=Vector(1.4, -9.5, -10),
			ExitPos=Vector(60, -50, -45),
			NoHud=true,
			wep={
				WAC.Helicopter.GetWeapon("No Weapon"),
			},
		},
		[3]={
			Pos=Vector(-40,-10,-13),
			ExitPos=Vector(-50, -70, -45),
			NoHud=true,
			wep={
				WAC.Helicopter.GetWeapon("No Weapon"),
			},
		},
		[4]={
			Pos=Vector(-40,10,-13),
			ExitPos=Vector(-50, 70, -45),
			NoHud=true,
			wep={
				WAC.Helicopter.GetWeapon("No Weapon"),
			},
		},
	}
end

function ENT:AddSounds()
	self.Sound={
		Start=CreateSound(self.Entity,"FSX/C172/xc172_startup.wav"),
		Blades=CreateSound(self.Entity,"FSX/C172/xc172_Rrpm2.wav"),
		Engine=CreateSound(self.Entity,"FSX/C172/c172_rpm2.wav"),
		MissileAlert=CreateSound(self.Entity,"HelicopterVehicle/MissileNearby.mp3"),
		MissileShoot=CreateSound(self.Entity,"HelicopterVehicle/MissileShoot.mp3"),
		MinorAlarm=CreateSound(self.Entity,"HelicopterVehicle/MinorAlarm.mp3"),
		LowHealth=CreateSound(self.Entity,"HelicopterVehicle/LowHealth.mp3"),
		CrashAlarm=CreateSound(self.Entity,"HelicopterVehicle/CrashAlarm.mp3"),
	}
end

function ENT:DrawPilotHud() end
function ENT:DrawWeaponSelection() end

