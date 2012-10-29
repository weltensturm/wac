
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:SetModel("models/WeltEnSTurm/BF2/bf2_physbullet.mdl")		
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if self.phys:IsValid() then
		self.phys:SetMass(5)
	end	
	if (self.phys:IsValid()) then
		self.phys:Wake()
		if self.ConTable.mode==2 then
			self.phys:EnableGravity(false)
		end
	end
	self:SetNotSolid(true)
	self.cbt={}
	self.cbt.health=5000
	self.cbt.armor=500
	self.cbt.maxhealth=5000
	self:SetNWInt("size", self.ConTable.size)
	self:SetNWFloat("width", self.ConTable.width)
	local col=Color(self.ConTable.col_r,self.ConTable.col_g,self.ConTable.col_b,255)
	self:SetColor(col.r,col.g,col.b,col.a)
	col.a=50
	local trail=util.SpriteTrail(self.Entity, 0, col, false, self.ConTable.size/2, self.ConTable.size/8, self.ConTable.size/20, 1/self.ConTable.size/2*0.5, "trails/smoke.vmt")	
	self.startTime=CurTime()
	self.canThink=true
	self.IsBullet=true
	self:NextThink(CurTime())
end

function ENT:Explode(tr)
	if self.Exploded then return end
	self.Exploded = true
	if !tr.HitSky then
		self.Owner = self.Owner or self.Entity
		if self.ConTable.decal != 0 then
			util.Decal(self.ConTable.decal, tr.HitPos+tr.HitNormal, tr.HitPos-tr.HitNormal)
		end
		if WAC then
			WAC.SimpleSplode(tr.HitPos, self.ConTable.radius, self.ConTable.damage, 7, false, self.Entity, self.Owner)
			WAC.Hit(tr.Entity, self.ConTable.damage, 7, self.Entity, self.Owner)
		end	
		self.HitPlayers = {}	
		local HitEnts = ents.FindInSphere(tr.HitPos, 100)
		--self.Entity:EmitSound(self.ConTable.soundExplode, 80)
		local ed = EffectData()
		ed:SetEntity(self.Entity)
		ed:SetOrigin(tr.HitPos)
		ed:SetStart(tr.HitPos)
		ed:SetScale(self.ConTable.radius)
		ed:SetRadius(tr.MatType)
		ed:SetAngles(tr.HitNormal:Angle())
		util.Effect(self.ConTable.effect, ed)
	end
	self.Entity:Remove()
end

function ENT:PhysicsUpdate(ph)
	if !util.IsInWorld(self:GetPos()) then self:Remove() end
	local speed=self.ConTable.bulletSpeed
	if !self.oldpos then self:Remove() return end
	local pos=self:GetPos()
	local difference = (pos-self.oldpos):GetNormal()*FrameTime()*70
	if !self.canThink or speed<50 or self.ConTable.dport==1 then
		self:SetVelocity(difference*1000)
	end
	self.oldpos = pos
	local trace = {}
	trace.start = pos
	trace.endpos = pos + difference * speed * 3
	trace.filter = self.Entity
	local tr = util.TraceLine(trace)
	if tr.Hit then
		self:Explode(tr)
	elseif (self.canThink or speed>50) and self.ConTable.dport==0 then
		self.Entity:SetPos(pos + difference * speed)
	end
end

function ENT:Think()
	self.phys:Wake()
end
