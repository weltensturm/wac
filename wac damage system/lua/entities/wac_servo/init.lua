
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("entities/base_wire_entity.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.sound = CreateSound(self.Entity, "WAC/tank/turret.wav")
	self.sound:Play()
	self.sound:ChangeVolume(0,0)
	self.sound:ChangePitch(0,0)
	self.soundPitch = 0
	if Wire then
		self.Inputs = Wire_CreateInputs(self.Entity, {"Pitch"})
	end
	--self.Sounds=CreateSound(self.Entity, "vehicles/tank_turret_loop1.wav")
end

function ENT:TriggerInput(name, v)
	if name == "Pitch" then
		self.targetAngle = v
	end
end

function ENT:PhysicsUpdate(ph)
	if self.GunBase and self.GunBase:IsValid() then
		local angvel=ph:GetAngleVelocity()
		local basevel=self.GunBase.phys:GetAngleVelocity()
		local length=(angvel-basevel):Length()
		local CrT=CurTime()
		local selfpos=self:GetPos()
		local ri=self:GetRight()
		local up=self:GetUp()
		local pos=selfpos+self:GetForward()*1000
		
		if length>10 then
			self.SndTm = self.SndTm or CrT
		else self.SndTm = nil end
		self.SndSm = math.Clamp(self.SndSm+((self.SndTm and (self.SndTm+0.1<CrT))and(0.1)or(-0.1)),0,1)
		
		if self.GunBase.Vehicle and self.GunBase.Vehicle:IsValid() and self.GunBase.Vehicle:GetPassenger():IsValid() then
			pos = selfpos + self.GunBase.Vehicle:GetPassenger():GetAimVector()*100
		else
			pos = self.GunBase:LocalToWorld(Angle(self.iPitch,0,0):Forward()*100)
		end
		ph:AddAngleVelocity(Vector(0,math.Clamp(self:WorldToLocal(pos).z/selfpos:Length(pos)*-7000*self.speed, -self.maxspeed, self.maxspeed),0)+(basevel-angvel))
		
		if self.nosound == 0 then
			self.Sounds:ChangeVolume(math.Clamp(length/self.maxspeed*100*self.SndSm, 0,100),0.1)
			self.Sounds:ChangePitch(math.Clamp(length/self.maxspeed*50*self.SndSm, 30, 80),0.1)
		else
			self.Sounds:ChangePitch(0,0)
			self.Sounds:ChangeVolume(0,0)
		end
	end
end

function ENT:BuildDupeInfo()
	local info = WireLib.BuildDupeInfo(self.Entity) or {}
	if (self.GunBase) and (self.GunBase:IsValid()) then
		info.base = self.GunBase:EntIndex()
	end
	info.speed=self.speed
	info.maxspeed=self.maxspeed
	info.nosound=self.nosound
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo(ply, ent, info, GetEntByID)
	if (info.base) then
		self.GunBase=GetEntByID(info.base)
		if (!self.GunBase) then
			self.GunBase=ents.GetByIndex(info.base)
		end
	end
	self.speed=info.speed
	self.maxspeed=info.maxspeed
	self.nosound=info.nosound
	self.Owner=ply
end

function ENT:PreEntityCopy()
	local DupeInfo = self:BuildDupeInfo()
	if(DupeInfo) then
		duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",DupeInfo)
	end
end

function ENT:OnRemove()
end

function ENT:OnRestore()
end
