
include('shared.lua')

ENT.thirdPerson = {
	distance = 700
}

function ENT:Think()
	if self.IsOn then
		if !self.Sound.Radio:IsPlaying() then
			self.Sound.Radio:Play()
		end
	elseif self.Sound.Radio:IsPlaying() then
		self.Sound.Radio:Stop()
	end
	self.BaseClass.Think(self)
end
