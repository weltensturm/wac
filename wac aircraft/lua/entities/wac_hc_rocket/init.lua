
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:SetModel("models/weltensturm/wac/rockets/rocket01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:SetMass(400)
		self.phys:EnableGravity(false)
		self.phys:EnableCollisions(true)
		self.phys:EnableDrag(false)
		self.phys:Wake()
	end
	self.sound = CreateSound(self.Entity, "WAC/rocket_idle.wav")
	self.matType = MAT_DIRT
	self.hitAngle = Angle(270, 0, 0)
end

function ENT:Explode(tr)
	if self.Exploded then return end
	self.Exploded = true
	util.BlastDamage(self, self.Owner or self, self:GetPos(), self.Radius, self.Damage)
	local explode = ents.Create("env_physexplosion")
	explode:SetPos(self:GetPos())
	explode:Spawn()
	explode:SetKeyValue("magnitude", self.Damage)
	explode:SetKeyValue("radius", self.Radius*0.75)
	explode:SetKeyValue("spawnflags","19")
	explode:Fire("Explode", 0, 0)
	local ed = EffectData()
	ed:SetEntity(self.Entity)
	ed:SetOrigin(self:GetPos())
	ed:SetScale(self.Scale or 10)
	ed:SetRadius(self.matType)
	ed:SetAngles(self.hitAngle)
	util.Effect("wac_tankshell_impact",ed)
	self.Entity:Remove()
end

function ENT:OnTakeDamage(dmginfo)
	self:Explode()
end

function ENT:OnRemove()
	self.sound:Stop()
end

function ENT:StartRocket()
	if self.Started then return end	
	self.Owner = self.Owner or self.Entity
	self.Fuel=self.Fuel or 1000
	self.Started = true
	local pos = self:GetPos()
	local ang = self:GetAngles()
	--[[self.SmokeTrail=ents.Create("env_rockettrail")
	self.SmokeTrail:SetPos(self:GetPos())
	self.SmokeTrail:SetParent(self.Entity)
	self.SmokeTrail:SetLocalAngles(Vector(0,0,0))
	self.SmokeTrail:Spawn()]]
	local ed=EffectData()
	ed:SetOrigin(pos)
	ed:SetScale(1)
	ed:SetRadius(self.TrailLength)
	ed:SetMagnitude(self.SmokeDens)
	ed:SetEntity(self.Entity)
	util.Effect("wac_rocket_trail", ed)
	local light = ents.Create("env_sprite")
	light:SetPos(self.Entity:GetPos())
	light:SetKeyValue("renderfx", "0")
	light:SetKeyValue("rendermode", "5")
	light:SetKeyValue("renderamt", "255")
	light:SetKeyValue("rendercolor", "250 200 100")
	light:SetKeyValue("framerate12", "20")
	light:SetKeyValue("model", "light_glow03.spr")
	light:SetKeyValue("scale", "0.4")
	light:SetKeyValue("GlowProxySize", "50")
	light:Spawn()
	light:SetParent(self.Entity)
	self.sound:Play()
	self.OldPos=self:GetPos()
	self.phys:EnableCollisions(false)
end

function ENT:GetFuelMul()
	self.MaxFuel=self.MaxFuel or self.Fuel or 0
	if self.Fuel then
		return math.Clamp(self.Fuel/self.MaxFuel*5,0,1)
	end
	return 1
end

function ENT:PhysicsUpdate(ph)
	if !self.Started or self.HasNoFuel then return end
	local trd = {
		start = self.OldPos,
		endpos = self:GetPos(),
		filter = {self,self.Owner,self.Launcher},
		mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER + CONTENTS_WINDOW + CONTENTS_WATER,
	}
	local tr = util.TraceLine(trd)
	if tr.Hit and !self.Exploded then
		if tr.HitSky then self:Remove() return end
		util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		self.matType = tr.MatType
		self.hitAngle = tr.HitNormal:Angle()
		self:Explode()
		return
	end
	self.OldPos = trd.endpos
	local vel = self:WorldToLocal(self:GetPos()+self:GetVelocity())*0.4
	vel.x = 0
	local m = self:GetFuelMul()
	ph:AddVelocity(self:GetForward()*m*self.Speed-self:LocalToWorld(vel*Vector(0.1, 1, 1))+self:GetPos())
	ph:AddAngleVelocity(
		ph:GetAngleVelocity()*-0.4
		+ Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1))*5
		+ Vector(0, -vel.z, vel.y)
	)
	if self.calcTarget then
		local target = self:calcTarget()
		local dist = self:GetPos():Distance(target)
		if dist > 2000 then
			target = target + Vector(0,0,200)
		end
		local v = self:WorldToLocal(target + Vector(
			0, 0, math.Clamp((self:GetPos()*Vector(1,1,0)):Distance(target*Vector(1,1,0))/5 - 50, 0, 1000)
		)):GetNormal()
		v.y = math.Clamp(v.y*10,-0.5,0.5)*300
		v.z = math.Clamp(v.z*10,-0.5,0.5)*300
		self:TakeFuel(math.abs(v.y) + math.abs(v.z))
		ph:AddAngleVelocity(Vector(0,-v.z,v.y))
	end
	self:TakeFuel(self.Speed)
end

function ENT:TakeFuel(amt)
	self.Fuel = self.Fuel-amt/10*FrameTime()
	if self.Fuel < 0 then
		self:Remove()
	end
end

function ENT:Think()
	if self.StartTime and self.StartTime < CurTime() and !self.Started then
		self:StartRocket()
	end
end
