 ENT.Type = "anim"
 ENT.Base = "base_gmodentity" 
 ENT.PrintName = "BF2 Gun Mount"
 ENT.Author = wac.author
 ENT.Category = wac.menu.category
 ENT.IsWire = true

 ENT.Spawnable = false
 ENT.AdminSpawnable = false
 ENT.WireDebugName = "BF2 Gun Mount"

function ENT:wacLink(e)
	if e:GetClass() == "Vehicle" then
		if SERVER then
			self.vehicle = e
		end
		return true
	end
end
