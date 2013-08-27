include('shared.lua')

function ENT:Draw()
	local pl = self:GetNWEntity("player")
	if pl and pl:IsValid() and pl==LocalPlayer() then return end
	self:DrawModel()
end
