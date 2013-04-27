
ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = ""
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""

ENT.Spawnable = false
ENT.AdminSpawnable = false


ENT.Name = "M134"
ENT.Ammo = 800
ENT.FireRate = 2000

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Ammo");
	self:NetworkVar("Float", 0, "LastShot")
	self:NetworkVar("Float", 1, "NextShot")
end