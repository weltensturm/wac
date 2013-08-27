
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Explodesounds = {
	Normal = {
		Sound("bf2_tank_gun/Tank_Shell_01.wav"),
		Sound("bf2_tank_gun/Tank_Shell_02.wav"),
		Sound("bf2_tank_gun/Tank_Shell_03.wav"),
		Sound("bf2_tank_gun/Tank_Shell_04.wav"),
		Sound("bf2_tank_gun/Tank_Shell_05.wav"),
	},
	Metal = {
		Sound("bf2_tank_gun/Tank_shell_metal_01.wav"),
		Sound("bf2_tank_gun/Tank_shell_metal_02.wav"),
		Sound("bf2_tank_gun/Tank_shell_metal_03.wav"),
		Sound("bf2_tank_gun/Tank_shell_metal_04.wav"),		
	},
}

ENT.MaxAimAng = 50
ENT.AngSpeed = 1
ENT.Damage = 100
ENT.AngMul = 1

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:SetModel("models/WeltEnSTurm/WAC/Rockets/rocket01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	--self.Entity:SetCollisionGroup(11)
	if self.phys:IsValid() then
		self.phys:SetMass(1)
	end	
	if (self.phys:IsValid()) then
		self.phys:Wake()
		self.phys:EnableGravity(false)
		self.phys:EnableDrag(true)
		self.phys:EnableCollisions(true)
		self.phys:AddVelocity(Vector(0,0,-100))
	end
	self.Sounds=CreateSound(self.Entity, "rocket_engine_start_idle.wav")
	self.gravon=false
	self.IsBullet = true
	self:NextThink(CurTime())
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true	
	local pos = self:GetPos()	
	local trace = {}
	trace.start = pos
	trace.endpos = pos + self:GetForward()*300
	trace.filter = self.Entity
	local tr = util.TraceLine( trace )
	if tr.Hit then
		if !tr.HitSky then
			self.tr=tr
		else
			self:Remove()
			return
		end
	else
		self.tr={
			HitPos=pos,
			HitNormal=self:GetForward(),
			Entity=self.Entity,
			Material=MAT_GLASS,
		}
	end
	wac.damageSystem.explosion(pos, self.ConTable.radius, self.ConTable.damage, self.Entity, self.Owner)
	util.Decal("Scorch", self.tr.HitPos+self.tr.HitNormal, self.tr.HitPos-self.tr.HitNormal)
	local ed = EffectData()
	ed:SetEntity(self.Entity)
	ed:SetOrigin(tr.HitPos)
	ed:SetStart(tr.HitPos)
	ed:SetScale(self.ConTable.radius/100)
	ed:SetRadius(tr.MatType)
	ed:SetAngle(tr.HitNormal:Angle())
	util.Effect(self.ConTable.effect, ed)
	self.Entity:Remove()
end

function ENT:PhysicsCollide(d,p)	
	self.DamagedObj = p:GetEntity()
	self:Explode()
end

function ENT:OnTakeDamage(dmginfo)
	self:Explode()		
end

function ENT:OnRemove()
	self.Sounds:Stop()
	if self.weapon and self.weapon.Owner then
		self.weapon.rocket = nil
		self.weapon:Reload()
	end
end

function ENT:StartRocket()
	if self.Started then return end	
	self.Started = true
	local pos = self:GetPos()
	local ang = self:GetAngles()	
	local ed=EffectData()
	ed:SetOrigin(pos)
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
end

function ENT:PhysicsUpdate()
	if !self.Started then return end
	local x = Vector(0,0,0)
	if (self.targetpos or self.targetang) and (!self.noaimtime or self.noaimtime > CurTime()) then	
		self.CurAngles = self:GetAngles()
		local AimVec = self.targetang or (self.targetpos - self:GetPos()):Angle()		
		AimVec.p = math.AngleDifference(AimVec.p, self.CurAngles.p)*self.AngMul
		AimVec.y = math.AngleDifference(AimVec.y, self.CurAngles.y)*self.AngMul
		if AimVec.p > self.MaxAimAng or AimVec.p < -self.MaxAimAng or AimVec.y > self.MaxAimAng or AimVec.y < -self.MaxAimAng then
			AimVec.p = 0
			AimVec.y = 0
		end		
		x = Vector(1-AimVec.y/6,AimVec.p,AimVec.y)*self.AngSpeed
	end
	self.phys:AddAngleVelocity((self.phys:GetAngleVelocity()*-1)+x+Vector(self:GetAngles().r*-1,0,0))
	self.phys:AddVelocity(self.Entity:GetForward()*self.ConTable.bulletSpeed)
end

function ENT:Think()
	if self.StartTime and self.StartTime < CurTime() and !self.Started then
		self:StartRocket()
	end
	if !self.Started then return end
	if self:WaterLevel() > 0 then
		self:Explode()
		return
	end
	self.Sounds:ChangePitch(100+math.sin(CurTime()), 0)
	self:NextThink(CurTime())
	return true
end
