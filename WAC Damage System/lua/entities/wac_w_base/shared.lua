 ENT.Type = "anim"
 ENT.Base = "base_gmodentity" 
 ENT.PrintName = "Tankgun"
 ENT.Author = wac.author
 ENT.Category = wac.menu.category
 ENT.IsWire = true

 ENT.Spawnable = false
 ENT.AdminSpawnable = false
 ENT.WireDebugName = "BF2 Tankgun"

function ENT:wacLink(e)
	if type(e) == "Vehicle" then
		if SERVER then
			self.vehicle = e
		end
		return true
	end
end
