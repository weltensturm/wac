
function EFFECT:Init(data)
 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time 
 	self.vOffset = data:GetOrigin()
 	self.vAng = data:GetAngles()
	self.vScale = data:GetScale()
 	self.vUp = self.vAng:Forward()
 	self.vFw = self.vAng:Up()
 	self.vRi = self.vAng:Right()
	
	self.emitter = ParticleEmitter(self.vOffset)
	
	--every 10 degrees
	for i = 0, 360, 10 do
	
		--inner dark cloud
		local particle = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset)
		if (particle) then
			particle:SetVelocity((math.cos(i) * math.Rand(12,120) * self.vUp + math.sin(i) * math.Rand(12,120) * self.vRi + math.Rand(-150,150) * self.vFw)*self.vScale*0.03)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.01, 0.02*self.vScale))
			particle:SetStartAlpha(math.Rand(50, 70))
			particle:SetEndAlpha(0)
			particle:SetStartSize(0.80*self.vScale)
			particle:SetEndSize(1.2*self.vScale)
			particle:SetCollide(true)
			particle:SetBounce(1)
			particle:SetAirResistance(300)
			particle:SetRoll(math.Rand(0, 10))
			particle:SetRollDelta(math.Rand(-0.2, 0.2))
			particle:SetColor(94, 84, 79)
		end
		
		--outer circle 1
		local particle2 = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset)
		if (particle2) then
			particle2:SetVelocity((math.cos(i) * math.Rand(150,250) * self.vUp + math.sin(i) * math.Rand(150,250) * self.vRi + math.Rand(-50,50) * self.vFw)*self.vScale*0.03)
			particle2:SetLifeTime(0)
			particle2:SetDieTime(math.Rand(0.01, 0.016*self.vScale))
			particle2:SetStartAlpha(math.Rand(60, 90))
			particle2:SetEndAlpha(0)
			particle2:SetStartSize(0.60*self.vScale)
			particle2:SetEndSize(1.2*self.vScale)
			particle2:SetBounce(1)
			particle2:SetCollide(true)
			particle2:SetAirResistance(300)
			particle2:SetRoll(math.Rand(0, 60))
			particle2:SetRollDelta(math.Rand(-0.2, 0.2))
			particle2:SetColor(104, 94, 89)
		end
		
		--flame
		for i=1,10 do
			local flame = self.emitter:Add("particles/flamelet"..math.random(1,5), self.vOffset)
			if (flame) then
				flame:SetVelocity((math.cos(i) * math.Rand(10,200) * self.vUp + math.sin(i) * math.Rand(10,200) * self.vRi + math.Rand(-150,150) * self.vFw)*self.vScale*0.01)
				flame:SetLifeTime(0)
				flame:SetDieTime(math.Rand(0.001, 0.0015*self.vScale))
				flame:SetStartAlpha(math.Rand(200, 255))
				flame:SetEndAlpha(0)
				flame:SetCollide(true)
				flame:SetBounce(1)
				flame:SetStartSize(0.1*self.vScale)
				flame:SetEndSize(0.8*self.vScale)
				flame:SetRoll(math.Rand(0, 100))
				flame:SetRollDelta(math.Rand(-0.2, 0.2))
				flame:SetColor(255 , 210 , 220)
			end
		end
		
	end
	
	local particle = self.emitter:Add("particle/particle_glow_04", self.vOffset)
	if (particle) then
		particle:SetVelocity(self.vFw * 10)
		particle:SetLifeTime(0)
		particle:SetDieTime(0.2)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(30)
		particle:SetEndSize(850)
		particle:SetAirResistance(200)
		particle:SetRoll(math.Rand(0, 60))
		particle:SetRollDelta(math.Rand(-0.2, 0.2))
		particle:SetColor(255,200,200)
	end
	
	self.emitter:Finish()
	
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl") 
	self.Entity:SetPos(self.vOffset)  
end 
  
function EFFECT:Think()
	return self.LifeTime > CurTime()
end 

function EFFECT:Render() 

end


