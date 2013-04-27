
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

ENT.Seats = {
	{
		pos = wdVector(70, 0, 48),
		exit = Vector(72,70,0),
	},
	{
		pos = Vector(120, 0, 42),
		exit = Vector(120,70,0),
	},
}


ENT.Sounds = {
	Start = "wac/Heli/ah1_start.wav",
	Blades = "npc/attack_helicopter/aheli_rotor_loop1.wav",
	Engine = "wac/heli/bellinternal.wav",
	MissileAlert = "HelicopterVehicle/MissileNearby.mp3",
	MissileShoot = "HelicopterVehicle/MissileShoot.mp3",
	MinorAlarm = "HelicopterVehicle/MinorAlarm.mp3",
	LowHealth = "HelicopterVehicle/LowHealth.mp3",
	CrashAlarm = "HelicopterVehicle/CrashAlarm.mp3",
}

