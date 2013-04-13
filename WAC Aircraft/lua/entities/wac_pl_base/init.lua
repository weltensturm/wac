
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.IgnoreDamage = true
ENT.UsePhysRotor = true
ENT.Submersible	= false
ENT.CrRotorWash	= true
ENT.RotorWidth = 200
ENT.TopRotorDir	= 1
ENT.BackRotorDir = 1
ENT.TopRotorPos	= Vector(83, 0, 0.5)
ENT.BackRotorPos = Vector(-400,5,137)
ENT.EngineForce	= 140
ENT.BrakeMul = 1
ENT.AngBrakeMul	= 0.01
ENT.Weight = 800
ENT.CrRotorWash = false

--[[
	Defines how the aircraft handles depending on where wind is coming from.
	Rotation defines how it rotates,
	Lift how it rises, sinks or gets pushed right/left,
	Rail defines how stable it is on its path, the higher the less it drifts when turning
]]
ENT.Aerodynamics = {
	Rotation = {
		Front = Vector(0, 4, 0),
		Right = Vector(0, 0, 70), -- Rotate towards flying direction
		Top = Vector(0, -70, 0)
	},
	Lift = {
		Front = Vector(0, 0, 80), -- Go up when flying forward
		Right = Vector(0, 0, 0),
		Top = Vector(0, 0, -0.5)
	},
	Rail = Vector(1, 5, 20)
}

function ENT:Initialize()
	self.BaseClass.BaseClass.Initialize(self)
	self:GetPhysicsObject():EnableDrag(false)
end

function ENT:AddRotor()

	self.TopRotor = ents.Create("prop_physics")
	self.TopRotor:SetModel("models/props_junk/sawblade001a.mdl")
	self.TopRotor:SetPos(self:LocalToWorld(self.TopRotorPos))
	self.TopRotor:SetAngles(self:GetAngles() + Angle(90, 0, 0))
	self.TopRotor:SetOwner(self.Owner)
	self.TopRotor:Spawn()
	self.TopRotor:SetNotSolid(true)
	self.TopRotor.Phys = self.TopRotor:GetPhysicsObject()
	self.TopRotor.Phys:EnableGravity(false)
	self.TopRotor.Phys:SetMass(5)
	--self.TopRotor.Phys:EnableDrag(false)
	self.TopRotor:SetNoDraw(true)
	self.TopRotor.fHealth = 100
	self.TopRotor.wac_ignore = true
	if self.RotorModel then
		local e = ents.Create("wac_hitdetector")
		e:SetModel(self.RotorModel)
		e:SetPos(self:LocalToWorld(self.TopRotorPos))
		e:SetAngles(self:GetAngles())
		
		e.TouchFunc = function(e)
			local ph = e:GetPhysicsObject()
			if ph:IsValid() then
				local pass=true
				for k,p in pairs(self.Passenger) do
					if p==e then pass=false end
				end
				for _, ent in pairs(self.entities) do
					if ent == e then pass = false end
				end
				if pass and e != self and !string.find(e:GetClass(), "func*") and IsValid(self.TopRotor) and e:GetMoveType() != MOVETYPE_NOCLIP then
					local rotorVel = self.TopRotor:GetPhysicsObject():GetAngleVelocity():Length()
					local dmg=(rotorVel*rotorVel + ph:GetVelocity():Length()*ph:GetVelocity():Length())/100000
					ph:AddVelocity((e:GetPos()-self.TopRotor:GetPos())*dmg/e:GetPhysicsObject():GetMass()*10)
					self:DamageBigRotor(dmg)
					e:TakeDamage(dmg, IsValid(self.Passenger[1]) and self.Passenger[1] or self.Entity, self.Entity)
				end
			end
		end
		
		
		e:Spawn()
		e:SetOwner(self.Owner)
		e:SetParent(self.TopRotor)
		e.wac_ignore = true
		local obb=e:OBBMaxs()
		self.RotorWidth=(obb.x>obb.y and obb.x or obb.y)
		self.RotorHeight=obb.z
		self.TopRotorModel=e
		self:AddOnRemove(e)
	end
	constraint.Axis(self.Entity, self.TopRotor, 0, 0, self.TopRotorPos, Vector(0,0,1), 0,0,0.01,1)
	self:AddOnRemove(self.TopRotor)
	
	if self.EngineWeight then
		local e = ents.Create("prop_physics")
		e:SetModel("models/props_junk/PopCan01a.mdl")
		e:SetPos(self:LocalToWorld(self.TopRotorPos))
		e:Spawn()
		e:SetNotSolid(true)
		e:GetPhysicsObject():SetMass(self.EngineWeight.Weight)
		constraint.Weld(self.Entity, e, 0, 0, 0, true, false)
		self:AddOnRemove(e)
		self.EngineWeight.Entity = e
	end
end

function ENT:PhysicsUpdate(ph)
	if self.LastPhys==CurTime() then return end
	local vel = ph:GetVelocity()	
	local pos=self:GetPos()
	local ri=self:GetRight()
	local up=self:GetUp()
	local fwd=self:GetForward()
	local ang=self:GetAngles()
	local dvel=vel:Length()
	local lvel=self:WorldToLocal(pos+vel)
	
	local t=self:CalculateHover(ph,pos,vel,ang)

	local realism = 3
	local phm = FrameTime()*66 --(wac.aircraft.cvars.doubleTick:GetBool() and 2 or 1)
	
	if !self.disabled then
		if self.Passenger[1] and self.Passenger[1]:IsValid() and self.Passenger[1]:IsPlayer() then
			self.rotateX	= self:GetPLControl(self.Passenger[1], WAC_AIR_LEANR, self.rotateX)
			self.rotateY = self:GetPLControl(self.Passenger[1], WAC_AIR_LEANP, self.rotateY)
			self.rotateZ 	= self:GetPLControl(self.Passenger[1], WAC_AIR_LEANY, self.rotateZ)
			if self.Passenger[1]:GetInfo("wac_cl_air_usejoystick")=="1" and joystick then
				self.upMul = self:GetPLControl(self.Passenger[1], WAC_AIR_UPDOWN, self.upMul, true)/2+0.5
			else
				self.upMul = math.Clamp(self.upMul + self:GetPLControl(self.Passenger[1], WAC_AIR_UPDOWN, 0)/2, 0, 1)
			end
			realism = math.Clamp(tonumber(self.Passenger[1]:GetInfo("wac_cl_air_realism")),1,3)
		else
			self.rotateX=0
			self.rotateY=0
			self.rotateZ=0
		end
	
		if self.TopRotor and self.TopRotor.Phys and self.TopRotor.Phys:IsValid() then
			if self.RotorBlurModel then
				self.TopRotorModel:SetColor(255,255,255,math.Clamp(1.3-self.rotorRpm,0.1,1)*255)
			end
			self.rotorRpm = math.Clamp(self.TopRotor.Phys:GetAngleVelocity().z/3500*self.TopRotorDir*phm,-1,1)
			if self.Active and self.TopRotor:WaterLevel() <= 0 then
				self.engineRpm = math.Clamp(self.engineRpm+FrameTime(),0,1)
				self.TopRotor.Phys:AddAngleVelocity(Vector(0,0,self.engineRpm*30 + self.upMul*self.engineRpm*20)*self.TopRotorDir*phm)
			else
				self.engineRpm = math.Clamp(self.engineRpm-FrameTime()*0.16*wac.aircraft.cvars.startSpeed:GetFloat(), 0, 1)
			end
		end
		
		for k,s in pairs(self.SeatsT) do
			if s.wep[s.wep_act].Phys and IsValid(self.Passenger[k]) then
				s.wep[s.wep_act].Phys(self,s.wep[s.wep_act],self.Passenger[k])
			end
		end
	end
	
	local angbrake=((self.TopRotor) and ph:GetAngleVelocity()*self.AngBrakeMul/math.pow(realism,2)*9 or Vector(0,0,0))

	local targetVelocity = 
		fwd * (self.upMul * self.rotorRpm + self.rotorRpm/10) * self.EngineForce / 35
		- self:LocalToWorld(self.Aerodynamics.Rail * lvel * dvel * dvel / 1000000000) + pos
		+ self:LocalToWorld(
			self.Aerodynamics.Lift.Front * lvel.x * dvel / 10000000 +
			self.Aerodynamics.Lift.Right * lvel.y * dvel / 10000000 +
			self.Aerodynamics.Lift.Top * lvel.z * dvel / 10000000
		) - pos
	
	if self.TopRotor then
		local brake = (self.upMul+1)*self.rotorRpm/900+self.TopRotor.Phys:GetAngleVelocity().z/100
		self.TopRotor.Phys:AddAngleVelocity(Vector(0,0,-brake + lvel.x*lvel.x/500000)*self.TopRotorDir*phm)
	end

	for _,e in pairs(self.Wheels) do
		if IsValid(e) and e:GetPhysicsObject():IsValid() then
		local ph=e:GetPhysicsObject()
			local lpos=self:WorldToLocal(e:GetPos())
			
			e:GetPhysicsObject():AddVelocity((self:LocalToWorld(Vector(0, 0,
					lpos.y*(self.rotateX*1.5+t.r)/math.pow(realism,1.3) -
					lpos.x*(self.rotateY+t.p)/math.pow(realism,1.3) -
					lpos.y*angbrake.x
			)/4)-pos --+ up*ang.r*lpos.y/self.WheelStabilize
			+ targetVelocity)*phm)

			if self.upMul < 0.5 then
				ph:AddAngleVelocity(ph:GetAngleVelocity()*(self.upMul-0.5)*phm)
			end
		end
	end

	local targetAngVel = (
			Vector(
				(self.rotateX+t.r)*dvel/400,
				(self.rotateY+t.p)*dvel/400,
				self.rotateZ*1.5*math.Clamp(lvel.x/20, 0, 1)
			) / math.pow(realism,1.3) * 4.17 - angbrake +
			(
				lvel.x*self.Aerodynamics.Rotation.Front +
				lvel.y*self.Aerodynamics.Rotation.Right +
				lvel.z*self.Aerodynamics.Rotation.Top
			) / 10000
	)
	
	ph:AddAngleVelocity(targetAngVel*phm)
	ph:AddVelocity(targetVelocity*phm)
	
	if self.EngineWeight and IsValid(self.EngineWeight.Entity) then
		self.EngineWeight.Entity:GetPhysicsObject():AddVelocity((
			up * targetAngVel.x
			+ ri * targetAngVel.z
			+ targetVelocity
			- Vector(0,0, math.pow(lvel.x/100,3)*self:WorldToLocal(self.EngineWeight.Entity:GetPos()).x/200000)
		)*phm)
	end
	
	if self.CustomPhysicsUpdate then self:CustomPhysicsUpdate(ph) end
	self.LastPhys=CurTime()
end

