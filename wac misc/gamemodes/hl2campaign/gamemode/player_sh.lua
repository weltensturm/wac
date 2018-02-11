local meta = FindMetaTable("Player")
if !meta then return end

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