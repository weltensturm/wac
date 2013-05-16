
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Havoc Mi-28"

ENT.Model = "models/BF2/helicopters/Mil Mi-28/mi28_b.mdl"
ENT.RotorPhModel = "models/props_junk/sawblade001a.mdl"
ENT.RotorModel = "models/BF2/helicopters/Mil Mi-28/mi28_r.mdl"
ENT.BackRotorModel = "models/BF2/helicopters/Mil Mi-28/mi28_tr.mdl"

ENT.TopRotorPos = Vector(0,0,119)
ENT.TopRotorDir = 1
ENT.BackRotorPos = Vector(-435.09,18.46,164.91)
ENT.BackRotorDir = 1
ENT.SmokePos = Vector(-80,0,50)
ENT.FirePos = Vector(-50,0,100)
ENT.MaxEnterDistance = 100
ENT.EngineForce	= 30
ENT.Weight = 9000

ENT.Seats = {
	{
		pos = Vector(54.74,0,85.22),
		exit = Vector(54.74,80,5),
		weapons = {"Hydra 70"}
	},
	{
		pos = Vector(115.3,0,61),
		exit = Vector(115.3,60,5),
		weapons = {"2A42", "9M120", "Hydra 70"}
	},
}


ENT.Weapons = {
	pods = {
		{
			class = "wac_pod_hydra",
			pos = Vector(3.22, 102.38, 59.59),
		},
		{
			class = "wac_pod_hydra",
			pos = Vector(3.22, -102.38, 59.59),
		},
	}
}


ENT.Sounds = {
	Start = "WAC/Heli/ah1_start.wav",
	Blades = "npc/attack_helicopter/aheli_rotor_loop1.wav",
	Engine = "WAC/heli/bellinternal.wav",
	MissileAlert = "HelicopterVehicle/MissileNearby.mp3",
	MissileShoot = "HelicopterVehicle/MissileShoot.mp3",
	MinorAlarm = "HelicopterVehicle/MinorAlarm.mp3",
	LowHealth = "HelicopterVehicle/LowHealth.mp3",
	CrashAlarm = "HelicopterVehicle/CrashAlarm.mp3",
}

