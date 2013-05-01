
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
		pos = Vector(70, 0, 48),
		exit = Vector(72,70,0),
		weapons = {"Hydra 70"}
	},
	{
		pos = Vector(120, 0, 42),
		exit = Vector(120,70,0),
		weapons = {"Hellfire"}
	},
}

ENT.Weapons = {
	profiles = {
		["Hydra 70"] = { pods = {1, 2} },
		["Hellfire"] = {
			pods = {3, 4},
			sequential = true
		}
	},
	pods = {
		{
			class = "wac_pod_hydra",
			pos = Vector(40.25, 36.33, 32.93)
		},
		{
			class = "wac_pod_hydra",
			pos = Vector(40.25, -36.33, 32.93)
		},
		{
			class = "wac_pod_hydra",
			pos = Vector(50, 60, 40),
		},
		{
			class = "wac_pod_hydra",
			pos = Vector(50, -60, 40),
		}
	},
	attachments = {

		gunMount1 = {
			model = "models/BF2/helicopters/AH-1 Cobra/ah1z_g1.mdl",
			pos = Vector(136,0,29),
		},
		
		gunMount2 = {
			model = "models/BF2/helicopters/AH-1 Cobra/ah1z_g2.mdl",
			pos = Vector(138,0,23),
			localTo = "gunMount1",
		},

		gun = {
			model = "models/BF2/helicopters/AH-1 Cobra/ah1z_g.mdl",
			pos = Vector(138, 0, 23),
			localTo = "gunMount2"
		},
		
		radar1 = {
			model = "models/BF2/helicopters/AH-1 Cobra/ah1z_radar2.mdl",
			pos = Vector(175,0,51),
		},
		
		camera = {
			model = "models/BF2/helicopters/AH-1 Cobra/ah1z_radar1.mdl",
			pos = Vector(175,0,42),
			viewPos = Vector(-3, 0, 3),
			localTo = "radar1"
		},
		
	}
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

