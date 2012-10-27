
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.WheelStabilize	=-150

ENT.WheelInfo={
	{
		mdl="models/BF2/helicopters/Mil Mi-28/mi28_w2.mdl",
		pos=Vector(-416.87,0,53.31),
		friction=100,
		mass=200,
	},
	{
		mdl="models/BF2/helicopters/Mil Mi-28/mi28_w1.mdl",
		pos=Vector(48.68,-49.39,4.15),
		friction=100,
		mass=200,
	},
	{
		mdl="models/BF2/helicopters/Mil Mi-28/mi28_w1.mdl",
		pos=Vector(48.68,49.39,4.15),
		friction=100,
		mass=200,
	},
}

function ENT:SpawnFunction(p, tr)
	if (!tr.Hit) then return end
	local e = ents.Create(ClassName)
	e:SetPos(tr.HitPos + tr.HitNormal*15)
	e.Owner = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:AddStuff()
	local ang=self:GetAngles()
	local e1=ents.Create("prop_physics")
	e1:SetModel("models/BF2/helicopters/Mil Mi-28/mi28_g2.mdl")
	e1:SetPos(self:LocalToWorld(Vector(120,0,33)))
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
	self:AddOnRemove(e1)
	self.GunMount1=e1
	e1.wac_ignore=true
	
	local e2=ents.Create("prop_physics")
	e2:SetModel("models/BF2/helicopters/Mil Mi-28/mi28_g1.mdl")
	e2:SetPos(self:LocalToWorld(Vector(120,0,20)))
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
	constraint.NoCollide(self,e2,0,0)
	self:AddOnRemove(e2)
	self.GunMount2=e2
	self.Gun=e2
	e2.wac_ignore=true
	self:SetNWEntity("gun",e2)
	
	local e4=ents.Create("prop_physics")
	e4:SetModel("models/BF2/helicopters/Mil Mi-28/mi28_radar1.mdl")
	e4:SetPos(self:LocalToWorld(Vector(181.44,0,56.65)))
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
	self.Radar1=e4
	self:AddOnRemove(e4)
	e4.wac_ignore=true
	
	local e5=ents.Create("prop_physics")
	e5:SetModel("models/BF2/helicopters/Mil Mi-28/mi28_w2.mdl")
	e5:SetPos(self:LocalToWorld(Vector(175,0,42)))
	e5:SetAngles(ang)
	e5:Spawn()
	e5:SetColor(0,0,0,0)
	e5:Activate()
	local ph=e5:GetPhysicsObject()
	if ph:IsValid() then
		ph:EnableDrag(false)
		ph:EnableGravity(false)
		ph:SetMass(10)
	end
	constraint.AdvBallsocket(e5,e4,0,0,Vector(0,0,0),e4:WorldToLocal(e5:LocalToWorld(Vector(0,0,1))),0,0,0,ang.p-50,0,0,ang.p+5,0,0,0,0,0,1)
	constraint.NoCollide(self,e5,0,0)
	self:AddOnRemove(e5)
	self.Radar2=e5
	self:SetNWEntity("wac_air_radar",e5)
	e5.wac_ignore=true
end

function ENT:CustomPhysicsUpdate(ph)
	if IsValid(self.GunMount1) and IsValid(self.GunMount2) and IsValid(self.Radar1) and IsValid(self.Radar2) and IsValid(self.Gun) then
		local avel=ph:GetAngleVelocity()
		local v=self.MouseVector or Vector(0,0,0)
		local ph1=self.Radar1:GetPhysicsObject()
		ph1:AddAngleVelocity(ph:GetAngleVelocity()-ph1:GetAngleVelocity()+Vector(0,0,v.y*200))
		local ph2=self.Radar2:GetPhysicsObject()
		ph2:AddAngleVelocity(ph:GetAngleVelocity()-ph2:GetAngleVelocity()+Vector(0,v.z*-200,0))
		
		local tr=util.QuickTrace(self.Radar2:GetPos(),self.Radar2:GetForward()*5000,{self,self.Radar1,self.Radar2})
		
		local ph3=self.GunMount1:GetPhysicsObject()
		local dir1=self.GunMount1:WorldToLocal(tr.HitPos):GetNormal()*20
		ph3:AddAngleVelocity(avel-ph3:GetAngleVelocity()+Vector(0,0,dir1.y*100)+Vector(0,0,v.y*150))
		
		local ph4=self.GunMount2:GetPhysicsObject()
		local dir2=self.GunMount2:WorldToLocal(tr.HitPos):GetNormal()*20
		ph4:AddAngleVelocity(avel-ph4:GetAngleVelocity()-Vector(0,dir2.z*100,0)+Vector(0,v.z*-200,0))
	end
end
