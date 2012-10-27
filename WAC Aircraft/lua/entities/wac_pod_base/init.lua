
include("wac/aircraft.lua")

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:sound(path)
	return CreateSound(self.Entity, path)
end
