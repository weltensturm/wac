
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('entities/base_wire_entity/init.lua')
include("shared.lua")

ENT.Explodesounds = {
	Sound("C4/C4_explosion_01.wav"),
	Sound("C4/C4_explosion_02.wav"),
	Sound("C4/C4_explosion_03.wav"),
}

function ENT:Initialize()

	self.Entity:SetModel("models/WeltEnSTurm/BF2/C4.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake();
	end
	if wire then
		self.Inputs = Wire_CreateInputs(self.Entity, {"Detonate"})
	end
	self.hlth = 20

	self.cbt = {}
	self.cbt.health = 5000
	self.cbt.armor = 500
	self.cbt.maxhealth = 5000
	self.IsBullet=true
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end

function ENT:OnRemove()
end

function ENT:TriggerInput(iname, value)
	if iname == "Detonate" then
		if value >= 1 then
			self:Explode()
		end
	end
end

function ENT:Explode()
	if !self.Exploded then
		self.Exploded = true
		local pos = self:GetPos()
		local ang = self:GetAngles()
		local up = self:GetUp()
		local ent = self.Entity
		if !self.Owner then self.Owner = self.Entity end
		self.Entity:EmitSound(self.Explodesounds[math.random(1,3)], 500)
		util.Decal("Scorch",pos + up, pos + up*-1)
		local effectdata1 = EffectData()
		effectdata1:SetOrigin(pos)
		effectdata1:SetStart(pos)
		effectdata1:SetAngles(ang)
		effectdata1:SetScale(200)
		util.Effect("bf2_c4splode", effectdata1)		
		wac.damageSystem.explosion(pos, 300, 1000, self.Entity, self.Owner)
		if WAC then
			WAC.SimpleSplode(pos, 300, 1000, 60, true, self.Entity, self.Owner)
		end			
		self:Remove()		
	end
end

function ENT:Touch()

	self:WeldMeLol()

end

function ENT:PhysicsCollide()
	self:Touch()
end

function ENT:WeldMeLol()

	if !self.Welded then
		local pos = self:GetPos()
		local trace = {}
		trace.start = pos
		trace.endpos = pos + self:GetUp()*-20
		trace.filter = {self.Entity}
		local tr = util.TraceLine(trace)
		if tr.Hit then
			if tr.Entity:IsPlayer() then return end
			if tr.HitSky then self:Remove() return end
			--self:SetParent(tr.Entity)
			self:SetPos(tr.HitPos)
			local ang = tr.HitNormal:Angle()
			ang:RotateAroundAxis(ang:Right(), -90)
			self:SetAngles(ang)
			timer.Simple(0.01, function()
				constraint.Weld(self.Entity, tr.Entity, tr.PhysicsBone, 0, 0, true)
			end)
			self.Welded = true
			self.SE = tr.Entity
		end
	end
	
end

function ENT:OnTakeDamage(dmginfo)

	if self.Exploded then return false end

	self.Entity:TakePhysicsDamage(dmginfo)
	
	dmg = dmginfo:GetDamage()
	
	if self.hlth < dmg then 
		self:Explode()
	else
		self.hlth = self.hlth - dmg
	end
	
end
