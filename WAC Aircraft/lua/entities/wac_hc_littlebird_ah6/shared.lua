
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Little Bird AH-6"

ENT.Model = "models/Flyboi/LittleBird/littlebirda_fb.mdl"
ENT.RotorPhModel = "models/props_junk/sawblade001a.mdl"
ENT.RotorModel = "models/Flyboi/LittleBird/littlebirdrotorm_fb.mdl"
ENT.BackRotorModel = "models/Flyboi/LittleBird/LittleBirdT_fb.mdl"

ENT.BackRotorDir = -1
ENT.TopRotorPos	= Vector(-10,0,100)
ENT.BackRotorPos = Vector(-217,9,73)
ENT.EngineForce = 20
ENT.Weight = 1300

ENT.SmokePos = Vector(-90,0,50)
ENT.FirePos = Vector(-50,0,100)

ENT.Seats = {
	{
		pos = Vector(22, 15, 49),
		exit = Vector(70,70,10),
		weapons = {"M134", "Hydra 70"}
	},
	{
		pos = Vector(22, -12, 49),
		exit = Vector(70,-70,10),
	},
}

ENT.Sounds = {
	Start = "WAC/Heli/h6_start.wav",
	Blades = "WAC/Heli/heli_loop_ext.wav",
	Engine = "WAC/Heli/heli_loop_int.wav",
	MissileAlert = "HelicopterVehicle/MissileNearby.mp3",
	MinorAlarm = "HelicopterVehicle/MinorAlarm.mp3",
	LowHealth = "HelicopterVehicle/LowHealth.mp3",
	CrashAlarm = "HelicopterVehicle/CrashAlarm.mp3",
}

ENT.Weapons = {
	profiles = {
		["M134"] = {
			pods = {1, 2},
		},
		["Hydra 70"] = {
			pods = {3, 4},
			sequential = true
		}
	},
	pods = {
		{
			class = "wac_pod_gatling",
			pos = Vector(40,40,30),
		},
		{
			class = "wac_pod_gatling",
			pos = Vector(40,-40,30),
		},
		{
			class = "wac_pod_hydra",
			pos = Vector(50,40,40),
		},
		{
			class = "wac_pod_hydra",
			pos = Vector(50,-40,40),
		}
	}
}
