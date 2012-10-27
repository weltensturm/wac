
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.EngineForce = 50
ENT.Weight = 7000
ENT.MaxEnterDistance = 100

function ENT:SpawnFunction(p, tr)
	if (!tr.Hit) then return end
	local e = ents.Create(ClassName)
	e:SetPos(tr.HitPos)
	e.Owner = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:AddStuff()
	local ang=self:GetAngles()
	local e1=ents.Create("prop_physics")
	e1:SetModel("models/BF2/helicopters/AH-1 Cobra/ah1z_g1.mdl")
	e1:SetPos(self:LocalToWorld(Vector(136,0,29)))
	e1:SetAngles(ang)
	e1:Spawn()
	e1:Activate()
	local ph=e1:GetPhysicsObject()
	if ph:IsValid() then
		ph:EnableDrag(false)
		ph:EnableGravity(false)
		ph:SetMass(10)
	end
	constraint.AdvBallsocket(e1,self,0,0,Vector(0,0,0),self:WorldToLocal(e1:LocalToWorld(Vector(0,0,1))),0,0,0,0,ang.y-100,0,0,ang.y+100,0,0,0,0,1)
	e1:SetNotSolid(true)
	self:AddOnRemove(e1)
	self.GunMount1=e1
	e1.wac_ignore=true
	
	local e2=ents.Create("prop_physics")
	e2:SetModel("models/BF2/helicopters/AH-1 Cobra/ah1z_g2.mdl")
	e2:SetPos(self:LocalToWorld(Vector(138,0,23)))
	e2:SetAngles(ang)
	e2:Spawn()
	e2:Activate()
	local ph=e2:GetPhysicsObject()
	if ph:IsValid() then
		ph:EnableDrag(false)
		ph:EnableGravity(false)
		ph:SetMass(10)
	end
	constraint.AdvBallsocket(e2,e1,0,0,Vector(2,0,0),e1:WorldToLocal(e2:LocalToWorld(Vector(2,0,1))),0,0,0,ang.p-50,0,0,ang.p+5,0,0,0,0,0,1)
	e2:SetNotSolid(true)
	self:AddOnRemove(e2)
	self.GunMount2=e2
	e2.wac_ignore=true
	
	local e3=ents.Create("prop_physics")
	e3:SetModel("models/BF2/helicopters/AH-1 Cobra/ah1z_g.mdl")
	e3:SetPos(e2:GetPos())
	e3:SetAngles(ang)
	e3:Spawn()
	e3:Activate()
	local ph=e3:GetPhysicsObject()
	if ph:IsValid() then
		ph:EnableDrag(false)
		ph:EnableGravity(false)
	end
	constraint.Axis(e3,e2,0,0,Vector(0,0,0),e2:WorldToLocal(e2:GetForward()+e2:GetPos()),0,0,0,1)
	e3:SetNotSolid(true)
	self.Gun=e3
	self:AddOnRemove(e3)
	self:SetNWEntity("gun",e3)
	e3.wac_ignore=true
	
	local e4=ents.Create("prop_physics")
	e4:SetModel("models/BF2/helicopters/AH-1 Cobra/ah1z_radar2.mdl")
	e4:SetPos(self:LocalToWorld(Vector(175,0,51)))
	e4:SetAngles(ang)
	e4:Spawn()
	e4:Activate()
	local ph=e4:GetPhysicsObject()
	if ph:IsValid() then
		ph:EnableDrag(false)
		ph:EnableGravity(false)
		ph:SetMass(10)
	end
	constraint.AdvBallsocket(e4,self,0,0,Vector(0,0,0),self:WorldToLocal(e4:LocalToWorld(Vector(0,0,1))),0,0,0,0,ang.y-100,0,0,ang.y+100,0,0,0,0,1)
	e4:SetNotSolid(true)
	self.Radar1=e4
	self:AddOnRemove(e4)
	e4.wac_ignore=true
	
	local e5=ents.Create("prop_physics")
	e5:SetModel("models/BF2/helicopters/AH-1 Cobra/ah1z_radar1.mdl")
	e5:SetPos(self:LocalToWorld(Vector(175,0,42)))
	e5:SetAngles(ang)
	e5:Spawn()
	e5:Activate()
	local ph=e5:GetPhysicsObject()
	if ph:IsValid() then
		ph:EnableDrag(false)
		ph:EnableGravity(false)
		ph:SetMass(10)
	end
	constraint.AdvBallsocket(e5,e4,0,0,Vector(0,0,0),e4:WorldToLocal(e5:LocalToWorld(Vector(0,0,1))),0,0,0,ang.p-50,0,0,ang.p+5,0,0,0,0,0,1)
	e5:SetNotSolid(true)
	self:AddOnRemove(e5)
	self.Radar2=e5
	self:SetNWEntity("wac_air_radar",e5)
	e5.wac_ignore=true
end

function ENT:CustomPhysicsUpdate(ph)
	if IsValid(self.GunMount1) and IsValid(self.GunMount2) and IsValid(self.Radar1) and IsValid(self.Radar2) and IsValid(self.Gun) then
		local angleVelocity = ph:GetAngleVelocity()
		local v = self.MouseVector or Vector(0,0,0)
		local mountPh = self.Radar1:GetPhysicsObject()
		mountPh:AddAngleVelocity(ph:GetAngleVelocity()-mountPh:GetAngleVelocity()+Vector(0,0,v.y*200))
		local radarPh = self.Radar2:GetPhysicsObject()
		radarPh:AddAngleVelocity(ph:GetAngleVelocity()-radarPh:GetAngleVelocity()+Vector(0,v.z*-200,0))
		
		local tr = util.QuickTrace(self.Radar2:GetPos(),self.Radar2:GetForward()*5000,{self,self.Radar1,self.Radar2})
		
		local gunMountPh = self.GunMount1:GetPhysicsObject()
		local dir1 = self.GunMount1:WorldToLocal(tr.HitPos):GetNormal()*20
		gunMountPh:AddAngleVelocity(angleVelocity-gunMountPh:GetAngleVelocity()+Vector(0,0,dir1.y*50)+Vector(0,0,v.y*150))
		
		local gunPh = self.GunMount2:GetPhysicsObject()
		local dir2 = self.GunMount2:WorldToLocal(tr.HitPos):GetNormal()*20
		gunPh:AddAngleVelocity(angleVelocity-gunPh:GetAngleVelocity()-Vector(0,dir2.z*50,0)+Vector(0,v.z*-200,0))
		
		local barrelPh = self.Gun:GetPhysicsObject()
		barrelPh:AddAngleVelocity(barrelPh:GetAngleVelocity()*-0.03)
	end
end
