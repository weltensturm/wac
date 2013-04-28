
ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.PrintName = "Base Helicopter"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""


ENT.Name = "Base"
ENT.Ammo = 10
ENT.FireRate = 100 -- rpm


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Ammo");
	self:NetworkVar("Float", 0, "LastShot")
	self:NetworkVar("Float", 1, "NextShot")
end
