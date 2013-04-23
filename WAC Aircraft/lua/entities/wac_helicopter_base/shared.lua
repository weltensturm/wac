
include("wac/aircraft.lua")

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


function ENT:setSounds()
	self.sounds = {}
	for name, s in pairs(self.Soundss) do
		self.sounds[name] = CreateSound(self, name)
	end
end
