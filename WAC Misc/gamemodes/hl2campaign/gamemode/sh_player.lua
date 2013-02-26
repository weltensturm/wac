// Finds the player meta table or terminates
local meta = FindMetaTable("Player")
if !meta then return end


// Blinds the player by setting view out into the void
function meta:RemoveVehicle()
	if CLIENT || !self:IsValid() then 
		return
	end
	
	if self.vehicle && self.vehicle:IsValid() then
		if self.vehicle:GetName()!="jeep" then
			self.vehicle:Remove()
		end
	end
end