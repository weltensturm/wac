
function EFFECT:Init(data)
 	self.Offset=data:GetOrigin()
 	self.Ang=data:GetAngles()
	self.vUp=self.Ang:Up()
	self.vFw=self.Ang:Forward()
	self.vRi=self.Ang:Right()
	self.Scale=data:GetScale()
	self.emitter=ParticleEmitter(self.Offset)
	self:Normal()
	self.emitter:Finish()
 	self.Entity:SetPos(self.Offset)
end
 
 function EFFECT:Normal()
	for i = 0, 360, 10/self.Scale do
		local ptc = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.Offset)
		if (ptc) then
			ptc:SetVelocity(math.cos(i)*math.Rand(12,120)*self.vUp + math.sin(i)*math.Rand(12,120)*self.vRi + math.Rand(110, 600)*self.vFw)
			ptc:SetLifeTime(0)
			ptc:SetDieTime(math.Rand(1,3)*self.Scale)
			ptc:SetStartAlpha(math.Rand(10, 40)*self.Scale)
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(20)
			ptc:SetEndSize(50)
			ptc:SetAirResistance(300)
			ptc:SetRoll(math.Rand(0, 10))
			ptc:SetRollDelta(math.Rand(-0.2, 0.2))
			ptc:SetColor(200,200,200,20)
		end
		ptc = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.Offset)
		if (ptc) then
			ptc:SetVelocity(math.cos(i)*math.Rand(150,250)*self.vUp + math.sin(i)*math.Rand(150,250)*self.vRi + math.Rand(2,300)*self.vFw)
			ptc:SetLifeTime(0)
			ptc:SetDieTime(math.Rand(1,3)*self.Scale)
			ptc:SetStartAlpha(math.Rand(10, 40)*self.Scale)
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(20)
			ptc:SetEndSize(50)
			ptc:SetAirResistance(300/self.Scale)
			ptc:SetRoll(math.Rand(0, 60))
			ptc:SetRollDelta(math.Rand(-0.2, 0.2))
			ptc:SetColor(200,200,200,20)
		end
		ptc = self.emitter:Add("particles/flamelet"..math.random(1,5), self.Offset)
		if (ptc) then
			ptc:SetVelocity(math.cos(i)*math.Rand(10,200)*self.vUp*0.1 + math.sin(i)*math.Rand(10,200)*self.vRi*0.1 + math.Rand(15,350)*self.vFw)
			ptc:SetLifeTime(0)
			ptc:SetDieTime(math.Rand(0, 0.22)*self.Scale)
			ptc:SetStartAlpha(math.Clamp(math.Rand(200, 255)*self.Scale,200,255))
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(40)
			ptc:SetEndSize(10)
			ptc:SetRoll(math.Rand(0, 100))
			ptc:SetRollDelta(math.Rand(-0.2, 0.2))
			ptc:SetColor(255 , 210 , 220)
		end
	end
 end

function EFFECT:Think()
 	return false
end 

function EFFECT:Render()
end