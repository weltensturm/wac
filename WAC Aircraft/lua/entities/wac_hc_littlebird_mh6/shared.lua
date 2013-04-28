
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName			= "Little Bird MH-6"

ENT.Model			= "models/Flyboi/LittleBird/littlebird_fb.mdl"
ENT.RotorPhModel	= "models/props_junk/sawblade001a.mdl"
ENT.RotorModel		= "models/Flyboi/LittleBird/littlebirdrotorm_fb.mdl"
ENT.BackRotorModel	= "models/Flyboi/LittleBird/LittleBirdT_fb.mdl"

ENT.BackRotorDir	= -1
ENT.TopRotorPos	= Vector(-10,0,100)
ENT.BackRotorPos	= Vector(-217,9,73)
ENT.EngineForce	= 30
ENT.Weight		= 1010
ENT.ThirdPDist = 400
ENT.SmokePos	= Vector(-90,0,50)
ENT.FirePos		= Vector(-30,0,100)

ENT.Seats = {
	{
		pos = Vector(22, 15, 49),
		exit = Vector(70,60,10),
		NoHud = true,
	},
	{
		pos = Vector(22, -12, 49),
		exit = Vector(70,-60,10),
		NoHud = true,
	},
	{
		pos = Vector(-5, -45, 35),
		exit = Vector(20,-100,10),
		NoHud = true,
	},
	{
		pos = Vector(-5, 45, 35),
		exit = Vector(20,100,10),
		NoHud = true,
	},
}


ENT.Sounds = {
	Start = "WAC/Heli/h6_start.wav",
	Blades = "WAC/Heli/heli_loop_ext.wav",
	Engine = "WAC/Heli/heli_loop_int.wav",
	MissileAlert = "HelicopterVehicle/MissileNearby.mp3",
	MissileShoot = "HelicopterVehicle/MissileShoot.mp3",
	MinorAlarm = "HelicopterVehicle/MinorAlarm.mp3",
	LowHealth = "HelicopterVehicle/LowHealth.mp3",
	CrashAlarm = "HelicopterVehicle/CrashAlarm.mp3",
}

