
include "wac/base.lua"

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");

if wire then
	include('entities/base_wire_entity/init.lua'); 
end

function ENT:Initialize()
	self.Entity:SetModel(self.vars.model)
	self.Entity.Sound = CreateSound(self.Entity, self.vars.sound)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
		if self.Weight and self.Weight != 0 then
			self.phys:SetMass(math.Clamp(self.Weight, 1, 500))
		end
	end
	if wire then
		self.Inputs = Wire_CreateInputs(self.Entity, {"ZPos", "Hovermode", "Add to Z", "Activate", "AirbrakeX" , "AirbrakeY" , "AirbrakeZ" , "GlobalBrake"})
	end
	self.CanUse = true
	self.IsGravcontroller = true
	self.PitchStartup = 0
	self.Active = false
	self.ConstrainedEntities = {}
	
	--Hoverball-like stuff
	self.ZPos = self:GetPos().z
	self.ZAddValue = 0
	self.ZAddByKey = 0
	self.HoverSpeed = 1
	self.ZAddMultiplicator = 10
	self.NextHMChange = 0
	self.NextCheckConstrained=0
	self.LastConstrained={}
end


function ENT:TriggerInput(iname, value)
	if(iname == "Activate") then		
		if(value == 1) then
			self:ActivateIt(true)
		else
			self:ActivateIt(false)
		end
	end
	if(iname == "AirbrakeX") then
		self.AirbrakeX = math.Clamp(value, 0, 100)
	end
	if(iname == "AirbrakeY") then
		self.AirbrakeY = math.Clamp(value, 0, 100)
	end
	if(iname == "AirbrakeZ") then
		self.AirbrakeZ = math.Clamp(value, 0, 100)
	end
	if(iname == "GlobalBrake") then
		self.brakepercent = math.Clamp(value, 0, 100)
	end	
	if(iname == "ZPos") then
		self.ZPos = value
	end
	if(iname == "Hovermode") then
		self:SetHoverMode(value)
	end
	if(iname == "Add to Z") then
		self.ZAddValue = value
	end
end

function ENT:ActivateIt(bool)
	if !bool and self.Active then
		self.phys:Wake()
		self:SetNWBool("drawsprite", false)
		self.Active = false
	elseif bool and !self.Active then 		
		if self.vars.drawSprite == 1 then self:SetNWBool("drawsprite",true) end
		self.Sound:Play()
		self.SoundPlaying = true
		self.Sound:ChangePitch(self.PitchStartup,0)
		self.Active = true
	end
	self.ConstrainedEntities=constraint.GetAllConstrainedEntities(self.Entity)
	if self.vars.brakeOnly == 0 or self.vars.stargateNode==1 then
		if self.vars.stargateNode==1 then
			self.TargetPos=self.Entity:GetPos()
		end
		for _, e in pairs(self.ConstrainedEntities) do
			if bool and self.Active then
				self:SetEntGravity(e, true)
			elseif !bool and !self.Active then
				self:SetEntGravity(e, false)
			end
		end	
	end
end

function ENT:Use(a, c)
	if !a:KeyPressed(IN_USE) then return false end
	if !(a == self.Owner) then return end
	if self.Active and self.CanUse then
		self:ActivateIt(false)
	elseif !self.Active and self.CanUse then
		self:ActivateIt(true)
	end
	return false
end

local NULLVEC=Vector(0,0,0)
function ENT:PhysicsUpdate(phys)
	if !phys:IsValid() then return end
	local actvel = phys:GetVelocity()
	local vel = NULLVEC
	local pos = self.Entity:GetPos()
	if self.vars.stargateNode != 1 then
		if self.vars.relativeToGround == 0 and self.HoverMode then
			if self.ZAddValue != 0 then
				self.ZPos = self.ZPos + self.ZAddValue
			end
			if !self.ZAddByKey then self.ZAddByKey = 0 end
			if self.ZAddByKey != 0 then
				self.ZPos = self.ZPos + self.ZAddByKey
			end
		elseif self.HoverMode then
			local trd={
				start=pos,
				endpos=self:LocalToWorld(self.StartVector*self.vars.heightAboveGround),
				filter=self.Entity,
				mask=MASK_SHOT_HULL+MASK_WATER,
			}
			local tr = util.TraceLine(trd)
			if tr.Hit then
				vel = vel-(trd.endpos-tr.HitPos)*self.vars.hoverSpeed
			end
		end
		if(self.vars.brakeGlobal == 0 and !self.ActiveSPC and (self.Active or self.vars.brakeAlways == 1)) then
			local veladd = self.Entity:WorldToLocal(self.Entity:GetVelocity()+pos)
			veladd.x = veladd.x - veladd.x*self.vars.brakeX/100
			veladd.y = veladd.y - veladd.y*self.vars.brakeY/100
			veladd.z = veladd.z - veladd.z*self.vars.brakeZ/100
			vel = vel + self.Entity:LocalToWorld(veladd)-pos
		elseif(self.vars.brakeGlobal == 1 and (self.Active or self.vars.brakeAlways == 1)) then	
			vel = vel + actvel*((100.0 - self.vars.brakeMul)/100.0)
		end
		if self.HoverMode and self.vars.relativeToGround == 0 then
			if (self.ZPos and self.ZPos != 0) then
				vel = vel + Vector(0,0, self.ZPos - pos.z)*self.vars.hoverSpeed/3
			end
		end
		if (self.vars.brakeAng == 1 and (self.Active or self.vars.brakeAlways == 1)) then
			if self.vars.brakeAngMul > 100 then self.vars.brakeAngMul = 100 end
			phys:AddAngleVelocity((self.vars.brakeAngMul/100)*-phys:GetAngleVelocity())
		end
	elseif self.Active and self.TargetPos then
		vel = self.TargetPos-pos-actvel/2
	end
	local pitch = self.Entity:GetVelocity():Length()
	if pitch > 900 then pitch = 900  end
	self.Sound:ChangePitch(self.PitchStartup+(pitch/6)*self.vars.pitchMul*self.PitchStartup/100,0.01)	
	if vel != NULLVEC then
		phys:SetVelocity(vel)
	end
end

function ENT:SetHoverMode(b)
	local crt = CurTime()
	if self.NextHMChange > crt then return end
	local adp = 0
	local div = 0
	self.ConstrainedEntities.GravControllers = {}
	for _,e in pairs(self.ConstrainedEntities) do
		if e.IsGravcontroller then
			adp = adp + e:GetPos().z
			div = div + 1
			table.insert(self.ConstrainedEntities.GravControllers, e)
		end
	end
	for _,gc in pairs(self.ConstrainedEntities.GravControllers) do
		gc.ZPos = adp/div
		gc.NextHMChange = crt + 1
		if !b or b == 0 then
			gc.HoverMode = false
		else
			gc.HoverMode = true
		end
	end
end

function ENT:OnRemove()
	self.Sound:Stop()
end

function ENT:SetEntGravity(e, b)
	if !e.phys then
		e.phys = e:GetPhysicsObject()
	end
	if e.phys and e.phys:IsValid() then
		local gb=e:GetGravity()
		if !b and !gb then
			if !(e.environment and (e.environment:IsSpace() or e.environment:IsStar())) then
				e.phys:EnableGravity(true)
			end
			e.IgnoreGravity = false
		elseif b and gb then
			e.phys:EnableGravity(false)
			e.IgnoreGravity = true
		end	
	end
end

function ENT:Think()
	local crt = CurTime()
	if crt>self.NextCheckConstrained and self.vars.liveGravity == 1 and self.vars.brakeOnly == 0 or self.vars.stargateNode == 1 then
		for _,e in pairs(self.ConstrainedEntities) do
			if e:GetGravity() == self.Active then
				self:SetEntGravity(e, self.Active)
			end
		end
		self.NextCheckConstrained=crt+1
	end
	self.PitchStartup=math.Clamp(self.PitchStartup+(self.Active and 1 or -1),0,100)
	if !self.Active and self.PitchStartup == 0 and self.SoundPlaying then
		self.Sound:Stop()
		self.SoundPlaying = false
	end
	if self.SoundPlaying then
		self.Sound:ChangePitch(self.PitchStartup,0.01)
	end
	if self.PitchStartup < 100 then
		self:NextThink(crt)
		return true
	end
end

numpad.Register("GoUp", function(p, e)
	if !e or !e:IsValid() then return end
	e.ZAddByKey = e.vars.hoverSpeed
end)

numpad.Register("GoDown", function(p, e)
	if !e or !e:IsValid() then return end
	e.ZAddByKey = -e.vars.hoverSpeed
end)

numpad.Register("GoStop", function(p, e)
	if !e or !e:IsValid() then return end
	e.ZAddByKey = 0
end)

numpad.Register("ToggleHoverMode", function(p, e)
	if !e or !e:IsValid() then return end
	if !e.HoverMode then
		e:SetHoverMode(1)
	else
		e:SetHoverMode(0)
	end
end)

numpad.Register("FireGravitycontroller", function(ply, ent)
	if !ent:IsValid() then return false end
	if ent.Active then
		ent:ActivateIt(false)
	else
		ent:ActivateIt(true)
	end
end)

