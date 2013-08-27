
EFFECT.ParticleMat = "LaserTag/impactparticle"
EFFECT.SmokeMat = "particle/particle_smokegrenade1"
EFFECT.BaseMat = Material("LaserTag/impactburst")
EFFECT.RingMat = Material("LaserTag/impactring")

function EFFECT:Init(data)
	self.StartPos 	= data:GetOrigin()
	self.Magnitude 	= data:GetMagnitude()
	self.Owner	 	= data:GetEntity()
	self.Offset 	= Vector(8,8,8)
	self.Color 		= Color(255,255,255,255)
	self.Alpha 		= 255
	self.Width		= 15 * self.Magnitude
	self.Entity:SetRenderBoundsWS(self.StartPos - Vector(32,32,32),self.StartPos + Vector(32,32,32))
	if self.Owner and self.Owner:IsValid() and self.Owner:IsPlayer() then self.Color = team.GetColor(self.Owner:Team()) end
	self.Emitter = ParticleEmitter(self.StartPos)
		for i=1, self.Magnitude*32 do
			self:BurstParticle(self.StartPos)
		end
		for i=1, 32 do
			self:SmokeParticle(self.StartPos)
		end
	self.Emitter:Finish()
end

function EFFECT:BurstParticle(startpos)
	local offset = Vector(math.Rand(-self.Offset.x,self.Offset.x),math.Rand(-self.Offset.y,self.Offset.y),math.Rand(-self.Offset.z,self.Offset.z))
	local pos = startpos + offset
	local particle = self.Emitter:Add(self.ParticleMat,startpos)
	if particle then
		particle:SetColor(ExpColor(LerpColor(math.Rand(0,1),self.Color,color_white)))
		particle:SetDieTime(1)
		particle:SetStartSize(2)
		particle:SetEndSize(0)
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(0)
		particle:SetRoll(math.random(0,360))
		particle:SetRollDelta(math.random(1,10))
		particle:SetVelocity((pos - startpos)*(self.Magnitude*5)) // How this works is we choose a random position within an offset around us
		particle:SetAirResistance(50)
	end
end

function EFFECT:SmokeParticle(startpos)
	local offset = Vector(math.Rand(-self.Offset.x,self.Offset.x),math.Rand(-self.Offset.y,self.Offset.y),math.Rand(-self.Offset.z,self.Offset.z))
	local pos = startpos + offset
	local particle = self.Emitter:Add(self.SmokeMat,startpos)
	if particle then
		particle:SetDieTime(2)
		particle:SetStartSize(math.random(15,30))
		particle:SetEndSize(math.random(15,30))
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(0)
		particle:SetRoll(math.random(0,360))
		particle:SetRollDelta(math.random(-5,5))
		particle:SetVelocity((pos - startpos)*(self.Magnitude*2))
		particle:SetGravity(Vector(0,0,math.random(-25,25)))
	end
end

function EFFECT:Render( )
	if self.Alpha < 1 then return end
	local white = Color(255,255,255,self.Alpha)
	render.SetMaterial(self.BaseMat)
	render.DrawSprite(self.StartPos, self.Width, self.Width, Color(self.Color.r,self.Color.g,self.Color.b,self.Alpha))
	render.DrawSprite(self.StartPos, self.Width/2, self.Width/2, white)
end
