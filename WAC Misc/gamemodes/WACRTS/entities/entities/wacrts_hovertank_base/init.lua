
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Range=200
ENT.Damage=100
ENT.FireRate=1
--ENT.FireSound=
ENT.Speed=10
ENT.Height=10
ENT.Turnspeed=10
ENT.Maxturnspeed=100
ENT.IsRTSUnit=true

ENT.NextFire=0

function ENT:Initialize()
	self.Entity:SetModel("models/WeltEnSTurm/RTS/tanks/tankh01_body.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys=self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
		self.phys:EnableGravity(false)
	end
end

local NULLVEC=Vector(0,0,0)
function ENT:PhysicsUpdate(ph)
	local angvel=ph:GetAngleVelocity()
	local CrT=CurTime()
	local ang=self:GetAngles()
	local selfpos=self:GetPos()
	local pos=selfpos
	local range=self.Range/100
	if ValidEntity(self.Target) then
		pos=self.Target:GetPos()
		range=self.Range
	elseif self.DesiredPos then
		pos=self.DesiredPos
	end
	local yaw=ang.y
	local tr=util.QuickTrace(self:GetPos(),Vector(0,0,-self.Height*100),self.Entity)
	local hitang=tr.HitNormal:Angle()
	pos.z=tr.HitPos.z+self.Height
	if pos != selfpos then
		yaw=(pos-self:GetPos()):Angle().y
	end
	local speed=(math.Clamp(8/math.abs(math.AngleDifference(yaw, ang.y)),0,1)+self.Speed/50)*math.Clamp((pos-selfpos):Length()-range,0,50)/50
	if speed<0.1 and self.DesiredPos then self:SetDesiredPos() end
	ph:SetVelocity(ph:GetVelocity()*0.9-Vector(0,0,selfpos.z-pos.z)+self:GetForward()*self.Speed*speed)
	ph:AddAngleVelocity(Vector(-ang.r,-ang.p,(yaw and math.Clamp(math.AngleDifference(yaw, ang.y)*self.Turnspeed,-self.Maxturnspeed,self.Maxturnspeed) or 0))-angvel)
end

function ENT:SearchForTargets()
	for _,e in pairs(ents.FindInSphere(self:GetPos(),self.Range)) do
		if e.IsRTSUnit and e:GetOwner() != self:GetOwner() then
			self:SetTarget(e)
			self.DesiredPos=nil
			return
		end
	end
end

function ENT:DoFire()
	local bullet = {}
	bullet.Num		= 1
	bullet.Src 		= self:GetPos()+self:GetForward()*10+self:GetUp()*2
	bullet.Dir 		= self:GetForward()
	bullet.Force		= self.Damage/10
	bullet.Damage	= self.Damage
	bullet.Spread	= Vector(0,0,0)
	bullet.Tracer		= 1
	self:FireBullets(bullet)
end

function ENT:Think()
	if !ValidEntity(self.Target) and !self.DesiredPos then
		self:SearchForTargets()
	elseif ValidEntity(self.Target) and self.NextFire<CurTime() then
		local tr=util.QuickTrace(self:GetPos(),self:GetForward()*self.Range,self.Entity)
		if tr.Hit and tr.Entity==self.Target then
			self:DoFire()
			self.NextFire=CurTime()+self.FireRate
		end
	end
end

function ENT:IsInRange(e)
	if !ValidEntity(e) then return end
	return (e:GetPos():Distance(self:GetPos())<self.Range)
end

function ENT:SetTarget(ent)
	self.Target=ent
end

function ENT:SetDesiredPos(pos)
	self.DesiredPos=pos
	self.Target=nil
end

function ENT:SetDesiredYaw(f)
	self.DesiredYaw=f
end
