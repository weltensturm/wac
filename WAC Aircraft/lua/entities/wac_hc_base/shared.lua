
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

ENT.Seats = {
	{
		pos = Vector(68, 0, 48),
		exit = Vector(72,70,0),
	},
}


ENT.Sounds = {
	Start = "HelicopterVehicle/HeliStart.mp3",
	Blades = "vehicles/Airboat/fan_blade_idle_loop1.wav",
	Engine = "WAC/Heli/heli_loop_int.wav",
	MissileAlert = "HelicopterVehicle/MissileNearby.mp3",
	MinorAlarm = "HelicopterVehicle/MinorAlarm.mp3",
	LowHealth = "HelicopterVehicle/LowHealth.mp3",
	CrashAlarm = "HelicopterVehicle/CrashAlarm.mp3",
}

ENT.Wheels = {}


function ENT:addSounds()
	self.sounds = {}
	for name, value in pairs(self.Sounds) do
		if name != "BaseClass" then
			self.sounds[name] = CreateSound(self, value)
		end
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Hover");
end
