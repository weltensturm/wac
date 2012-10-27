include('shared.lua')     
 
language.Add("wac_wreck","Exploded Wreck")
 
function ENT:Draw()
	self.Entity:DrawModel()
end

local function kill_2(um)
	local self=um:ReadEntity()
	self:SetKeyValue("renderfx", 6.00)
	self:SetRenderMode(3.00)
end
usermessage.Hook("wac_wreck_kill_2", kill_2)