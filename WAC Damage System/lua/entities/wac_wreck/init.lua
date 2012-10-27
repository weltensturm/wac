
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.Explodesounds = {
	Tankexplode = {
		Sound("WAC/tank/Tank_explode_01.wav"),
		Sound("WAC/tank/Tank_explode_02.wav"),
		Sound("WAC/tank/Tank_explode_03.wav"),
		--Sound("bf2_tank_explode/Tank_explode_04.wav"),
		Sound("WAC/tank/Tank_explode_05.wav"),
	},
	Wreckexplode = {
		Sound("WAC/wreck/Wreck_explosion_01.wav"),
		Sound("WAC/wreck/Wreck_explosion_02.wav"),
		Sound("WAC/wreck/Wreck_explosion_03.wav"),
		Sound("WAC/wreck/Wreck_explosion_04.wav"),
		Sound("WAC/wreck/Wreck_explosion_05.wav"),
	},
}


function ENT:Initialize()   
	math.randomseed(CurTime())
	self.exploded = false
	self.fuseleft = CurTime() + math.Rand(6,8)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetColor(120,120,120,255)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.phys = self.Entity:GetPhysicsObject()
	if !self.phys or !self.phys:IsValid() then self:Remove() return end
	self.phys:SetMass(self.mass or 10)
	self.phys:Wake()
	if self.angvel then
		self.phys:AddAngleVelocity(self.angvel)
	end
	if self.velocity then
		self.phys:SetVelocity(self.velocity)
	end
	local pos = self.Entity:GetPos()
	self.br = self.Entity:BoundingRadius()
	self.soundbr=math.Clamp(self.br,60,500)
	if self.phys:IsValid() then
		self.health = self.phys:GetMass()
	else
		self:Remove()
	end	
end   

function ENT:Explode()
	if !self.Exploded then
		self.Exploded = true
		self.Entity:EmitSound(self.Explodesounds.Tankexplode[math.random(1,4)], self.soundbr)
		self:DrawEffect()
	end
end

function ENT:ExplodeFinal()
	if !self.FinalExploded then
		self.FinalExploded = true
		if WAC.Damage.CVars.DdMode:GetInt()==1 then
			self.Entity:EmitSound(self.Explodesounds.Wreckexplode[math.random(1,5)], self.soundbr)
			self:DrawEffect()
			self:Remove()
		elseif WAC.DMode:GetInt()==2 then
			umsg.Start("wac_wreck_kill_2")
			umsg.Entity(self.Entity)
			umsg.End()
			self:SetKeyValue("renderfx", 6.00)
			self:SetRenderMode(3.00)
			timer.Simple(0.1,function()
				self.Entity:SetMoveType(MOVETYPE_NONE)
				self.Entity:SetSolid(SOLID_NONE)
				timer.Simple(3, function() self:Remove() end)
			end)
		end
	end
end

function ENT:DrawEffect()
	local pos = self:LocalToWorld(self:OBBCenter())
	local angle = self:GetAngles()
	WAC.SimpleSplode(pos, self.br, self.br, 8, false, self.Entity, self.Entity)
	local effectdata1 = EffectData()
	effectdata1:SetOrigin(pos)
	effectdata1:SetStart(pos)
	effectdata1:SetAngle(angle)
	effectdata1:SetScale(self.br)
	util.Effect("PropSplode", effectdata1)		
end

function ENT:Think()
	if WAC.Damage.CVars.DdMode:GetInt()!=1 then
		self.fuseleft=self.fuseleft+FrameTime()+0.1
	else
		if (self.fuseleft < CurTime()) then
			self:ExplodeFinal()
		end
	end
	self.Entity:NextThink(CurTime() + 0.1)
	return true
end

function ENT:OnTakeDamage(dmg)
	if WAC.Damage.CVars.DdMode:GetInt()!=1 then return end
	self.Entity:TakePhysicsDamage(dmg)	
	local damage=dmg:GetDamage()
	local attacker=dmg:GetAttacker()
	if attacker:GetClass()=="wac_wreck" then return end
	if self.health < damage then 
		self:ExplodeFinal()
	else
		self.health = self.health - damage
	end	
end
