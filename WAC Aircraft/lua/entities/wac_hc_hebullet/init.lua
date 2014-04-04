
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/popcan01a.mdl")		
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if self.phys:IsValid() then
		self.phys:SetMass(5)
	end	
	if (self.phys:IsValid()) then
		self.phys:Wake()
		self.phys:EnableGravity(true)
	end
	self.oldpos=self:GetPos()-self:GetAngles():Forward()*self.Speed
	self:SetNotSolid(true)
	self.cbt={}
	self.cbt.health=5000
	self.cbt.armor=500
	self.cbt.maxhealth=5000
	self:SetNWInt("size", self.Size)
	self:SetNWFloat("width", self.Width)
	local col=Color(self.col.r,self.col.g,self.col.b,255)
	self:SetColor(col)
	col.a=50
	local trail=util.SpriteTrail(self.Entity, 0, col, false, self.Size/2, self.Size/8, self.Size/40, 1/self.Size/2*0.5, "trails/smoke.vmt")	
	self.startTime=CurTime()
	self.canThink=true
	self.IsBullet=true
	self:NextThink(CurTime())
end

ENT.Explode=function(self,tr)
	if self.Exploded then return end
	self.Exploded = true
	if !tr.HitSky then
		self.Owner = self.Owner or self.Entity
		local explode=ents.Create("env_physexplosion")
		explode:SetPos(tr.HitPos)
		explode:SetOwner(self.Owner)
		explode:Spawn()
		explode:SetKeyValue("magnitude", self.Damage/4)
		explode:SetKeyValue("radius", self.Radius)
		explode:Fire("Explode", 0, 0)
		timer.Simple(5,function() explode:Remove() end)
		util.BlastDamage(self, self.Owner, tr.HitPos, self.Radius, self.Damage)
		local ed = EffectData()
		ed:SetEntity(self.Entity)
		ed:SetOrigin(tr.HitPos)
		ed:SetStart(tr.HitPos)
		ed:SetScale(self.Radius)
		ed:SetRadius(tr.MatType)
		ed:SetAngles(tr.HitNormal:Angle())
		ed:SetNormal(tr.HitNormal)
		util.Effect("wac_impact_small", ed)
	end
	self.Entity:Remove()
end

function ENT:PhysicsUpdate(ph)
	if !util.IsInWorld(self:GetPos()) then self:Remove() end
	local speed=self.Speed
	if !self.oldpos then self:Remove() return end
	local pos=self:GetPos()
	local difference = (pos - self.oldpos)
	if !self.canThink or speed<50 or self.NoTele then
		self:SetVelocity(difference*1000)
	end
	self.oldpos = pos
	local trace = {}
	trace.start = pos
	trace.endpos = pos+difference
	trace.filter = self.Entity
	trace.mask=CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER + CONTENTS_WINDOW + CONTENTS_WATER
	local tr = util.TraceLine(trace)
	if tr.Hit then
		self.Explode(self,tr)
	elseif (self.canThink or speed>50) and !self.NoTele then
		self.Entity:SetPos(pos + difference)
	end
end

function ENT:Think()
	self.phys:Wake()
end
