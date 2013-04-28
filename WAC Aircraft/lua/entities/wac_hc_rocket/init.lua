
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:SetModel("models/WeltEnSTurm/WAC/Rockets/rocket01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:SetMass(400)
		--self.phys:EnableGravity(false)
		self.phys:EnableCollisions(true)
		self.phys:EnableDrag(false)
		self.phys:Wake()
	end
	self.Sounds=CreateSound(self.Entity, "WAC/rocket_idle.wav")
end

function ENT:Explode(tr)
	if self.Exploded then return end
	self.Exploded=true
	if tr.HitSky then self:Remove() return end
	util.BlastDamage(self, self.Owner or self, tr.HitPos+tr.HitNormal, self.Radius, self.Damage)
	local explode=ents.Create("env_physexplosion")
	explode:SetPos(tr.HitPos+tr.HitNormal)
	explode:Spawn()
	explode:SetKeyValue("magnitude", self.Damage)
	explode:SetKeyValue("radius", self.Radius*0.75)
	explode:SetKeyValue("spawnflags","19")
	explode:Fire("Explode", 0, 0)
	util.Decal("Scorch",tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
	local ed = EffectData()
	ed:SetEntity(self.Entity)
	ed:SetOrigin(tr.HitPos+tr.HitNormal*10)
	ed:SetScale(self.Scale or 10)
	ed:SetRadius(tr.MatType)
	ed:SetAngles(tr.HitNormal:Angle())
	util.Effect("wac_tankshell_impact",ed)
	self.Entity:Remove()
end

function ENT:OnTakeDamage(dmginfo)
	--self:Explode()		
end

function ENT:OnRemove()
	self.Sounds:Stop()
end

function ENT:StartRocket()
	if self.Started then return end	
	self.Owner = self.Owner or self.Entity
	self.Fuel=self.Fuel or 100
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
	self.Sounds:Play()
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
	local tr=util.TraceLine(trd)
	if tr.Hit then
		self:Explode(tr)
		return
	end
	self.OldPos=trd.endpos
	local vel=self:WorldToLocal(self:GetPos()+self:GetVelocity())*0.4
	vel.x=0
	local m = self:GetFuelMul()
	ph:AddVelocity(self:GetForward()*m*self.Speed-self:LocalToWorld(vel*Vector(0.1, 1, 1))+self:GetPos())
	ph:AddAngleVelocity(ph:GetAngleVelocity()*-0.5 + Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1)))
	if self.Aimed==1 and IsValid(self.Owner) and IsValid(self.Launcher) then
		local v=self.Launcher:WorldToLocal(self.Launcher:GetPos()+self.Owner:GetAimVector()*5)*m/2
		local clamp=Vector(v.x,v.y,v.z)
		clamp.x=0
		clamp=clamp:Normalize()*5*m/2
		clamp.y=math.abs(clamp.y)
		clamp.z=math.abs(clamp.z)
		v.y=math.Clamp(v.y,-clamp.y,clamp.y)
		v.z=math.Clamp(v.z,-clamp.z,clamp.z)
		if v:Length()>3 then
			v=v:Normalize()*3
		end
		v.z=v.z*-1
		v=v*10
		self:TakeFuel(math.abs(v.y)*2)
		self:TakeFuel(math.abs(v.z)*2)
		ph:AddAngleVelocity(Vector(0,v.z,v.y))
	elseif self.Aimed==2 and IsValid(self.Launcher) and self.TargetPos then
		local dist=self:GetPos():Distance(self.TargetPos)
		local v=self:WorldToLocal(self.TargetPos + Vector(
			0, 0, math.Clamp((self:GetPos()*Vector(1,1,0)):Distance(self.TargetPos*Vector(1,1,0))/5 - 50, 0, 1000)
	))
		v.y=math.Clamp(v.y/dist,-10,10)*100
		v.z=math.Clamp(v.z/dist,-10,10)*100
		self:TakeFuel(math.abs(v.y)*2)
		self:TakeFuel(math.abs(v.z)*2)
		ph:AddAngleVelocity(Vector(0,-v.z,v.y))
	end
	self:TakeFuel(self.Speed)
end

function ENT:TakeFuel(amt)
	self.MaxFuel=self.MaxFuel or self.Fuel
	self.Fuel=self.Fuel-amt/10*FrameTime()
	if self.Fuel<=0 then
		if self.Aimed and self.Owner:GetViewEntity()==self then
			self.Owner:SetViewEntity(self.Owner)
		end
	end
end

function ENT:Think()
	if self.StartTime and self.StartTime < CurTime() and !self.Started then
		self:StartRocket()
	end
end
