
function EFFECT:Init( data ) 

 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time 
	
	self.vEntity = data:GetEntity()
 	self.vOffset = data:GetOrigin()
 	self.vAng = data:GetAngle()
	self.vScale = data:GetScale()
 	self.vFw = self.vAng:Forward()
 	self.vUp = self.vAng:Up()
 	self.vRi = self.vAng:Right()
	
	self.emitter = ParticleEmitter(self.vOffset)
	local dlight = DynamicLight(self.vEntity:EntIndex()) 
	if (dlight) then 
		dlight.Pos = self.vOffset
		dlight.r = 255
		dlight.g = 220
		dlight.b = 0
		dlight.Brightness = 3
		dlight.Decay = 1700
		dlight.Size = 112
		dlight.DieTime = CurTime() + 0.5
	end
	--every 10 degrees
	for i = 0, 360, 10 do
	
		--[[Upward crap
		local particle = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.vOffset )
		if (particle) then
			particle:SetVelocity((math.cos(i) * self.vUp + math.sin(i) * self.vRi) * 70 + self.vFw * math.Rand(80,350)	)
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 0.5, 1 ) )
			particle:SetStartAlpha( math.Rand( 80, 90 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 10 )
			particle:SetEndSize( 60 )
			particle:SetGravity( Vector( 0,0,-600 ) )
			particle:SetAirResistance( 100 )
			particle:SetRoll( math.Rand(0, 10) )
			particle:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle:SetColor( 94, 84, 79 )
		end]]
		
		--outer circle 1
		local particle2 = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.vOffset )
		if (particle2) then
			particle2:SetVelocity((math.cos(i) * self.vUp + math.sin(i) * self.vRi )* 100)
			particle2:SetLifeTime( 0 )
			particle2:SetDieTime( math.Rand( 0.4, 0.8 ) )
			particle2:SetStartAlpha( math.Rand( 60, 90 ) )
			particle2:SetEndAlpha( 0 )
			particle2:SetStartSize( 5)
			particle2:SetEndSize( 30 )
			particle2:SetAirResistance( 300 )
			particle2:SetRoll( math.Rand(0, 60) )
			particle2:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle2:SetColor( 94, 84, 79 )
		end
		
		local particle1 = self.emitter:Add( "particles/flamelet"..math.random(1,5), self.vOffset )
		if (particle1) then
			particle1:SetVelocity(math.cos(i) * self.vUp * math.Rand(10,50) + math.sin(i) * self.vRi * math.Rand(10,50) + self.vFw * math.Rand(10,60))
			particle1:SetLifeTime( 0 )
			particle1:SetDieTime( 0.1 )
			particle1:SetStartAlpha( 250 )
			particle1:SetEndAlpha( 0 )
			particle1:SetStartSize( 4 )
			particle1:SetEndSize( 17 )
			particle1:SetRoll( math.Rand(0, 100) )
			particle1:SetRollDelta( math.Rand(-0.2, 0.2) )
			particle1:SetColor( 220 , 220 , 220 )
		end
				
	end
	local scount = math.Rand( 3, 5 )
		for i = 1, scount do
			
			local particle2 = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.vOffset )
			if (particle2) then
				particle2:SetVelocity( self.vFw * 10 )
				particle2:SetLifeTime( 0 )
				particle2:SetDieTime( math.Rand( 0.1, 1.2 ) )
				particle2:SetStartAlpha( math.Rand( 150, 160 ) )
				particle2:SetEndAlpha( 0 )
				particle2:SetStartSize(30)
				particle2:SetEndSize(50)
				particle2:SetAirResistance( 200 )
				particle2:SetRoll( math.Rand(0, 60) )
				particle2:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle2:SetColor( 94, 84, 79 )
			end
		end
	self.emitter:Finish()
	
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetPos( self.vOffset )  
end 
 
function EFFECT:Think()
 	return (self.LifeTime > CurTime())
 	 
end 
 
function EFFECT:Render()
end  