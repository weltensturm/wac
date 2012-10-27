
local cm=CreateClientConVar("wac_cl_wep_defmuzzle",0,true,false)

function EFFECT:Init(data)
	self.Parent = data:GetEntity()
	if(not IsValid(self.Parent)) then return end
	self.Entity:SetParent(self.Parent)
	local radius = tonumber(data:GetRadius()) or 1
	if(radius > 1) then
		self.Size = radius
	end
	self.Entity:SetRenderBounds(Vector()*self.Size*(-2),Vector()*self.Size*2)
end


function EFFECT:Think()
	local viewmodel
	if !self.Parent then return end
	if(self.Parent == LocalPlayer() and self.Parent == self.Parent:GetViewEntity()) then
		viewmodel = self.Parent:GetViewModel()
	else
		if(self.Parent.GetActiveWeapon) then
			viewmodel = self.Parent:GetActiveWeapon()
		end
	end
	if(not IsValid(viewmodel)) then return end;
	local attach = viewmodel:GetAttachment(1)
	if(not attach) then return end
	if attach.Pos then
		start = attach.Pos
	end
	
	self.Table = self.Parent:GetActiveWeapon().MuzzleFlashAdd
	self.Forward = self.Parent:GetAimVector()
	self.Angle	= self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = self.Parent:GetVelocity()	
	local emitter = ParticleEmitter(start)		

	if cm:GetInt()==0 then
		local particle = emitter:Add("sprites/heatwave", start - self.Forward*4)
		particle:SetVelocity(80*self.Forward + 20*VectorRand() + 1.05*AddVel)
		particle:SetDieTime(math.Rand(0.18,0.25))
		particle:SetStartSize(math.random(5,10))
		particle:SetEndSize(3)
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetGravity(Vector(0,0,100))
		particle:SetAirResistance(160)
		local particle = emitter:Add("particle/particle_smokegrenade", start)
		particle:SetVelocity(80*self.Forward + 1.1*AddVel)
		particle:SetDieTime(math.Rand(0.36,0.38))
		particle:SetStartAlpha(math.Rand(50,60))
		particle:SetStartSize(math.random(3,4))
		particle:SetEndSize(math.Rand(17,28))
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(245,245,245)
		particle:SetLighting(true)
		particle:SetAirResistance(80)
	end
	
	for i=1,2 do
		local particle = emitter:Add("effects/muzzleflash"..math.random(1,4), start - 3*self.Forward)
		particle:SetVelocity(40*(10-i)*self.Forward + AddVel)
		particle:SetGravity(AddVel)
		particle:SetDieTime(0.1)
		particle:SetStartAlpha(150)
		particle:SetStartSize((8-i)/1.3)
		particle:SetEndSize((12-i)/1.3)
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(255,255,255)	
	end
	
	if !self.Table then return false end
	for k, v in pairs(self.Table) do
		if type(v) == "Vector" then
			v = v:Normalize()
			if cm:GetInt()==0 then
				for j=1, 2 do
					local particle = emitter:Add("particle/particle_smokegrenade", start)
					particle:SetVelocity(self.Table.Speed*self.Right*v.x*j + self.Table.Speed*v.y*self.Forward*j + self.Table.Speed*v.z*self.Angle:Up()*j + 1.1*AddVel)
					particle:SetDieTime(math.Rand(0.16,0.2))
					particle:SetStartAlpha(math.Rand(50,60))
					particle:SetStartSize(math.random(2,3))
					particle:SetEndSize(math.Rand(3*j, 4*j))
					particle:SetRoll(math.Rand(180,480))
					particle:SetRollDelta(math.Rand(-1,1))
					particle:SetColor(245,245,245)
					particle:SetLighting(true)
					particle:SetAirResistance(160)
				end
			end
			if math.random(1,4) > 1 then
				for j=1,2 do
					local particle = emitter:Add("effects/muzzleflash"..math.random(1,4), start - 3*self.Forward)
					particle:SetVelocity(self.Table.Speed*self.Right*v.x*j*2 + self.Table.Speed*v.y*self.Forward*j*2 + self.Table.Speed*v.z*self.Angle:Up()*j*2 + 1.1*AddVel)
					particle:SetGravity(AddVel)
					particle:SetDieTime(0.05)
					particle:SetStartAlpha(100)
					particle:SetStartSize(j/2)
					particle:SetEndSize(2*j)
					particle:SetRoll(math.Rand(180,480))
					particle:SetRollDelta(math.Rand(-1,1))
					particle:SetColor(255,255,255)	
				end
			end
		end
	end
	
	emitter:Finish()
	return false	
end


function EFFECT:Render()	
end



