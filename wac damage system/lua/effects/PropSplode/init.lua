
 function EFFECT:Init( data ) 
 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time 
 	self.vOffset = data:GetOrigin()
 	self.vAng = data:GetAngles()
	self.vScale = data:GetScale()
 	self.vUp = self.vAng:Forward()
 	self.vFw = self.vAng:Up()
 	self.vRi = self.vAng:Right()
	self.emitter = ParticleEmitter(self.vOffset)
	for i = 0, 360, 10 do
		--inner dark cloud
		local particle = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.vOffset )
		if (particle) then
			particle:SetVelocity((math.cos(i) * math.Rand(12,120) * self.vUp + math.sin(i) * math.Rand(12,120) * self.vRi + math.Rand(-150,150) * self.vFw)*self.vScale*0.03)
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 0.01, 0.02 * self.vScale ) )
			particle:SetStartAlpha( math.Rand( 100, 130 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 0.80*self.vScale )
			particle:SetEndSize( 1.2*self.vScale )
			particle:SetAirResistance( 300 )
			particle:SetRoll( math.Rand(0, 10) )
			particle:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle:SetColor( 94, 84, 79 )
		end
		--outer circle 1
		local particle2 = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.vOffset )
		if (particle2) then
			particle2:SetVelocity((math.cos(i) * math.Rand(150,250) * self.vUp + math.sin(i) * math.Rand(150,250) * self.vRi + math.Rand(-50,50) * self.vFw)*self.vScale*0.03)
			particle2:SetLifeTime( 0 )
			particle2:SetDieTime( math.Rand( 0.01, 0.016 * self.vScale ) )
			particle2:SetStartAlpha( math.Rand( 100, 170 ) )
			particle2:SetEndAlpha( 0 )
			particle2:SetStartSize( 0.60*self.vScale )
			particle2:SetEndSize( 1.2*self.vScale )
			particle2:SetAirResistance( 300 )
			particle2:SetRoll( math.Rand(0, 60) )
			particle2:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle2:SetColor( 104, 94, 89 )
		end
		--flame
		local flame = self.emitter:Add( "particles/flamelet"..math.random(1,5), self.vOffset )
		if (flame) then
			flame:SetVelocity( (math.cos(i) * math.Rand(10,200) * self.vUp + math.sin(i) * math.Rand(10,200) * self.vRi + math.Rand(0,150) * self.vFw)*self.vScale*0.03)
			flame:SetLifeTime( 0 )
			flame:SetDieTime( math.Rand( 0.01, 0.002 * self.vScale ) )
			flame:SetStartAlpha( math.Rand( 200, 255 ) )
			flame:SetEndAlpha( 0 )
			flame:SetStartSize( 0.10*self.vScale )
			flame:SetEndSize( 0.80*self.vScale )
			flame:SetAirResistance( 300 )
			flame:SetRoll( math.Rand(0, 100) )
			flame:SetRollDelta( math.Rand(-0.2, 0.2) )
			flame:SetColor(255 , 210 , 220)
		end
	end
	for i = 1, 6 do
		local randomvector = Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(0,1))
		for i = 1, 20 do	
			local particle = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset)
			if (particle) then
				particle:SetVelocity(randomvector*i*self.vScale*0.8)
				particle:SetLifeTime(0)
				particle:SetDieTime( math.Rand( 0.01, 0.03 * self.vScale))
				particle:SetStartAlpha( math.Rand( 100, 130))
				particle:SetEndAlpha(0)
				particle:SetStartSize(0.03*self.vScale*(30-i))
				particle:SetEndSize( 0.03*self.vScale*(30-i) )
				particle:SetAirResistance(300)
				particle:SetRoll(math.Rand(0, 10))
				particle:SetRollDelta(math.Rand(-0.2, 0.2))
				particle:SetColor(94, 84, 79)
			end
			local flame = self.emitter:Add("particles/flamelet"..math.random(1,5), self.vOffset)
			if (flame) then
				flame:SetVelocity(randomvector*i*self.vScale*0.8)
				flame:SetLifeTime(0)
				flame:SetDieTime( 0.0031 * self.vScale)
				flame:SetStartAlpha(math.Rand(150, 200))
				flame:SetEndAlpha(0)
				flame:SetStartSize(0.03*self.vScale*(30-i))
				flame:SetEndSize(0.03*self.vScale*(30-i))
				flame:SetAirResistance(300)
				flame:SetRoll(math.Rand(0, 100))
				flame:SetRollDelta(math.Rand(-0.2, 0.2))
				flame:SetColor(255 , 210 , 220)
			end
		end
	end
	self.emitter:Finish()
 	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
 	self.Entity:SetPos(self.vOffset) 
end 
  
function EFFECT:Think()
   	return false
end 

function EFFECT:Render()
end  