
include("shared.lua")
include("entities/base_wire_entity/init.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("wac/aircraft.lua")

local NULLVEC=Vector(0,0,0)

ENT.IgnoreDamage	= true
ENT.wac_ignore		= true
ENT.WheelInfo		={}

ENT.UsePhysRotor = true
ENT.Submersible	= false
ENT.CrRotorWash	= true
ENT.RotorWidth = 200
ENT.TopRotorDir	= 1
ENT.BackRotorDir = 1
ENT.TopRotorPos	= Vector(0,0,50)
ENT.BackRotorPos = Vector(-185,-3,13)
ENT.EngineForce	= 20
ENT.BrakeMul = 1
ENT.AngBrakeMul	= 0.01
ENT.Weight = 1000
ENT.SeatSwitcherPos = Vector(0,0,50)
ENT.BullsEyePos	= Vector(20,0,50)
ENT.MaxEnterDistance = 50
ENT.WheelStabilize = -400
ENT.HatingNPCs={
	"npc_strider",
	"npc_combinegunship",
	"npc_combinedropship",
	"npc_helicopter",
	"npc_hunter",
	"npc_ministrider",
	"npc_turret_ceiling",
	"npc_turret_floor",
	"npc_turret_ground",
	"npc_rollermine",
	"npc_sniper",
}

function ENT:Initialize()

	self.Entity:SetModel(self.Model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Phys = self.Entity:GetPhysicsObject()
	if self.Phys:IsValid() then
		self.Phys:SetMass(self.Weight)
		self.Phys:Wake()
	end
	
	self.entities = {}
	
	self.OnRemoveFunctions = {}
	self.OnRemoveEntities = {}

	self.UpdateSecond = 0
	self.LastDamageTaken=0
	self.wac_seatswitch = true
	self.StartTime = 0
	self.HoverTime=0
	self.engineHealth = 100
	self.rotateX = 0
	self.rotateY = 0
	self.rotateZ = 0
	self.rotorRpm = 0
	self.upMul = 0
	self:SetNWFloat("health", 100)
	self.LastActivated = 0
	self.NextWepSwitch = 0
	self.NextCamSwitch = 0
	self.engineRpm = 0
	self.LastPhys=0
	self.Passenger={}
	
	self:setRotors()
	self:setSounds()
	self:setSeats()
	self:setWheels()
	self:addNpcTargets()
	self:AddAirResistanceMods()
	
end


function ENT:addEntity(name)
	local e = ents.Create(name)
	if !IsValid(e) then return nil end
	table.insert(self.entities, e)
	e.Owner = self.Owner
	e:SetNWEntity("Owner", self.Owner)
	return e
end


function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end


function ENT:AddAirResistanceMods()
	self.AirResistanceMods={
		[1]=Vector(0,0,0),				--avel=lvel.x*this
		[2]=Vector(-0.0005,0,0.004),	--avel=lvel.y*this
		[3]=Vector(0,-0.00005,0),		--avel=lvel.z*this
		[4]=Vector(0,0.003,0.003),		--general local air resistance
	}
end


function ENT:addNpcTargets()
	--[[self.npcTargets = {}
	for x = -1, 1 do
		for y = -1, 1 do
			for z = -1, 1 do
				local traceData = {
					start = self:WorldToLocal(Vector(x,y,z)*self:BoundingRadius()),
					endpos = self:GetPos()
				}
				local tr = util.TraceLine(traceData)
				local e = self:addEntity("npc_bullseye")
				e:SetPos(tr.HitPos + tr.HitNormal * 10)
				e:SetParent(self.Entity)
				e:SetKeyValue("health", "10000")
				e:SetKeyValue("spawnflags", "256")
				e:SetNotSolid(true)
				e:Spawn()
				e:Activate()
				for _,s in pairs(self.HatingNPCs) do
					e:Fire("SetRelationShip", s.." D_HT 99")
				end
				table.insert(self.npcTargets, e)
			end
		end
	end]]
	for _,s in pairs(self.HatingNPCs) do
		self:Fire("SetRelationShip", s.." D_HT 99")
	end
end


function ENT:setRotors()
	self.rotors = {}
	for _, data in pairs(self.Rotors) do
		local rotor = self:addEntity("prop_physics")
		rotor:SetModel(data.model)
		rotor:SetPos(self:LocalToWorld(data.pos))
		rotor:SetAngles(self:GetAngles()+data.angle)
		rotor:Spawn()
		rotor:Activate()
		rotor.force = data.force
		rotor.dir = data.dir
		constraint.Axis(self, rotor, 0, 0, data.pos, rotor:GetUp(), 0, 0, 0, 1)
		self:AddOnRemove(rotor)
		for _, r in pairs(self.rotors) do
			constraint.NoCollide(rotor, r)
		end
		table.insert(self.rotors, rotor)
	end
end


function ENT:setSeats()
	self.seats = {}
	local e = self:addEntity("wac_seat_connector")
	e:SetPos(self:LocalToWorld(self.SeatSwitcherPos))
	e:SetNoDraw(true)
	e:Spawn()
	e.wac_ignore = true
	e:SetNotSolid(true)
	e:SetParent(self)
	self.seatSwitcher = e
	for k,v in pairs(self.Seats) do
		local ang = self:GetAngles()
		v.wep_act = 1
		v.wep_next = 0
		for i,t in pairs(v.wep) do
			if type(t)=="table" then
				if t.Init then t.Init(self,t) end
				self:SetNWInt("seat_"..k.."_"..i.."_ammo",t.Ammo)
				self:SetNWInt("seat_"..k.."_"..i.."_nextshot",1)
				self:SetNWInt("seat_"..k.."_"..i.."_lastshot",0)
			else
				t=nil
			end
		end
		self:SetNWInt("seat_"..k.."_actwep", 1)
		self.seats[k] = self:addEntity("prop_vehicle_prisoner_pod")
		self.seats[k]:SetModel("models/nova/airboat_seat.mdl") 
		self.seats[k]:SetPos(self:LocalToWorld(v.Pos))
		if v.ang then
			local a=self:GetAngles()
			a.y = a.y-90
			a:RotateAroundAxis(Vector(0,0,1),v.Ang.y)
			self.seats[k]:SetAngles(a)
		else
			ang:RotateAroundAxis(self:GetUp(),-90)
			self.seats[k]:SetAngles(ang)
		end
		self.seats[k]:Spawn()
		self.seats[k]:SetNoDraw(true)
		self.seats[k].helicopter = self.Entity
		self.seats[k].phys = self.seats[k]:GetPhysicsObject()
		self.seats[k].phys:EnableGravity(true)
		self.seats[k].phys:SetMass(1)
		self.seats[k]:SetNotSolid(true)
		self.seats[k]:SetParent(self)
		self.seats[k].wac_ignore = true
		self.seats[k]:SetNWEntity("wac_aircraft", self)
		self.seats[k]:SetKeyValue("limitview", "0")
		self.seatSwitcher:AddVehicle(self.seats[k])
		self:AddOnRemove(self.seats[k])
	end
end


function ENT:setWheels()
	self.wheels = {}
	for _, data in pairs(self.Wheels) do
		local e = self:addEntity("prop_physics")
		e:SetModel(data.model)
		e:SetPos(self:LocalToWorld(data.pos))
		e:SetAngles(self:GetAngles())
		e:Spawn()
		e:Activate()
		local ph = e:GetPhysicsObject()
		if ph:IsValid() then
			if data.mass then
				ph:SetMass(data.mass)
			end
			ph:EnableDrag(false)
		else
			e:Remove()
		end
		constraint.Axis(e, self, 0, 0, data.pos, self:WorldToLocal(e:LocalToWorld(Vector(0,1,0))), 0, 0, data.friction, 1)
		self:AddOnRemove(e)
		table.insert(self.wheels, e)
	end
end


function ENT:setSounds()

end


function ENT:NextWeapon(t,k,p)
	if t.wep[t.wep_act].DeSelect then t.wep[t.wep_act].DeSelect(self.Entity, t.wep[t.wep_act], p) end
	t.wep_act=(t.wep_act<#t.wep)and(t.wep_act+1)or(1)
	t.wep_next=CurTime()+0.5
	self:SetNWInt("seat_"..k.."_actwep", t.wep_act)
end

function ENT:SeatSwitch(p, s)
	if !self.Seats[s] then return end
	local psngr = self.Seats[s]:GetPassenger()
	if !psngr or !psngr:IsValid() or !psngr:InVehicle() then
		p:ExitVehicle()
		p:EnterVehicle(self.Seats[s])
		self:UpdateSeats()
	end
end

function ENT:EjectPassenger(ply,idx,t)
	if ply.LastVehicleEntered and ply.LastVehicleEntered<CurTime() then
		if !idx then
			for k,p in pairs(self.Passenger) do
				if p==ply then idx=k end
			end
			if !idx then
				return
			end
		end
		ply.LastVehicleEntered = CurTime()+0.5
		ply:ExitVehicle()
		ply:SetPos(self:LocalToWorld(self.Seats[idx].ExitPos))
		ply:SetVelocity(self:GetPhysicsObject():GetVelocity()*1.2)
		ply:SetEyeAngles((self:LocalToWorld(self.Seats[idx].Pos-Vector(0,0,40))-ply:GetPos()):Angle())
		self:UpdateSeats()
	end
end

function ENT:Use(act, cal)
	if self.disabled then return end
	local crt = CurTime()
	if !act.LastVehicleEntered or act.LastVehicleEntered < crt then
		local d=self.MaxEnterDistance
		local v
		for k,veh in pairs(self.seats) do
			if veh and veh:IsValid() then
				local psngr = veh:GetPassenger(0)
				if !psngr or !psngr:IsValid() then
					local dist=veh:GetPos():Distance(util.QuickTrace(act:GetShootPos(),act:GetAimVector()*self.MaxEnterDistance,act).HitPos)
					if dist<d then
						d=dist
						v=veh
					end
				end
			end
		end
		if v then
			act.HelkeysDown={}
			act:EnterVehicle(v)
			act.LastVehicleEntered=crt+0.5		
		end
	end
	self:UpdateSeats()
end

function ENT:UpdateSeats()
	for k, veh in pairs(self.seats) do
		if !veh:IsValid() then return end
		local p = veh:GetPassenger(0)
		if self.Passenger[k] != p then
			if IsValid(self.Passenger[k]) then
				self.Passenger[k].HelkeysDown={}
				self.Passenger[k]:SetNWEntity("wac_aircraft", NULL)
				local t=self.Seats[k].wep[self.Seats[k].wep_act]
				if t and t.DeSelect then
					t.DeSelect(self,t,self.Passenger[k])
				end
			end
			self:SetNWEntity("passenger_"..k, p)
			p:SetNWInt("wac_passenger_id",k)
			p.wac_passenger_id=k
			self.Passenger[k]=p
		end
	end
end

function ENT:StopAllSounds()
	--for k, s in pairs(self.sounds) do
	--	s:Stop()
	--end
end

local keyids={
	[WAC_AIR_LEANP] ={7,8},
	[WAC_AIR_LEANY] ={9,10},
	[WAC_AIR_LEANR] ={6,5},
	[WAC_AIR_UPDOWN] ={3,4},
	[WAC_AIR_START] ={2,0},
	[WAC_AIR_FIRE] ={12,0},
	[WAC_AIR_CAM] ={11,0},
	[WAC_AIR_NEXTWEP] ={13,0},
	[WAC_AIR_HOVER]	= {14,0},
	[WAC_AIR_EXIT] = {1,0},
	[WAC_AIR_FREEAIM] = {15,0},
}

function ENT:RocketAlert()
	if self.rotorRpm > 0.1 then
		local b=false
		local rockets = ents.FindByClass("rpg_missile")
		table.Merge(rockets, ents.FindByClass("wac_w_rocket"))
		for _, e in pairs(rockets) do
			if e:GetPos():Distance(self:GetPos()) < 2000 then b = true break end
		end
		if self.Sound.MissileAlert:IsPlaying() then
			if !b then
				self.Sound.MissileAlert:Stop()
			end
		elseif b then
			self.Sound.MissileAlert:Play()
		end
	end
end

function ENT:setVar(name, var)
	if self:GetNWFloat(name) != var then
		self:SetNWFloat(name, var)
	end
end

function ENT:Think()
	local crt = CurTime()
	if !self.disabled then
		if self.UpdateSecond<crt then
			if self.Phys and self.Phys:IsValid() then
				self.Phys:Wake()
			end
			if self.Burning then
				self:DamageEngine(0.1)
			end
			if self.CrRotorWash then
				if self.rotorRpm > 0.6 then
					if !self.RotorWash then
						self.RotorWash = ents.Create("env_rotorwash_emitter")
						self.RotorWash:SetPos(self.Entity:GetPos())
						self.RotorWash:SetParent(self.Entity)
						self.RotorWash:Activate()
					end
				else
					if self.RotorWash then
						self.RotorWash:Remove()
						self.RotorWash = nil
					end
				end
			end
			self:RocketAlert()
			if self.Smoke then
				self.Smoke:SetKeyValue("renderamt", tostring(math.Clamp(self.rotorRpm*170, 0, 200)))
				self.Smoke:SetKeyValue("Speed", tostring(50+self.rotorRpm*50))
				self.Smoke:SetKeyValue("JetLength", tostring(50+self.rotorRpm*50))
			end
			self:UpdateSeats()
			self.UpdateSecond = crt+0.1
		end
		
		self:setVar("rotorRpm", math.Clamp(self.rotorRpm, 0, 150))
		self:setVar("engineRpm", self.engineRpm)
		self:setVar("up", self.upMul)

		if self.TopRotor and self.TopRotor:WaterLevel() > 0 then
			self:DamageEngine(0.5)
		end
		for k, t in pairs(self.Seats) do
			local p=self.Passenger[k]
			if p and p:IsValid() and p:InVehicle() and p:GetVehicle().Helicopter then
				if k==1 then
					if self:GetPLControl(p,WAC_AIR_START,0,true)>0 and self.StartTime<CurTime() then
						self:SwitchState()
						self.StartTime=CurTime()+1
					end
					if self:GetPLControl(p,WAC_AIR_HOVER,0,true)>0 and self.HoverTime<CurTime() then
						self:ToggleHover()
						self.HoverTime=CurTime()+1
					end
				end
				
				if !p.wac_air_thirdp_toggled and self:GetPLControl(p,WAC_AIR_THIRDP,0,true, 1!=k)>0 then
					umsg.Start("wac_toggle_thirdp", p)
					umsg.End()
					p.wac_air_thirdp_toggled = true
				end
				if p.wac_air_thirdp_toggled and self:GetPLControl(p,WAC_AIR_THIRDP,0,true, 1!=k)<=0 then
					p.wac_air_thirdp_toggled = false
				end
				
				if self:GetPLControl(p,WAC_AIR_CAM,0,true, 1!=k)>0 and (!p.NextCamSwitch or p.NextCamSwitch < crt) then
					p:SetNWBool("docam", !p:GetNWBool("docam"))
					p:SetNWBool("wac_mouse_seatinput", k==1 and p:GetNWBool("docam") or false)
					p.NextCamSwitch=crt+0.5
				end
				
				if t.wep then
					if self:GetPLControl(p,WAC_AIR_NEXTWEP,0,true, 1!=k)>0 and t.wep_next<CurTime() then
						self:NextWeapon(t, k, p)
					end
					if self:GetPLControl(p,WAC_AIR_FIRE,0,true, 1!=k)>0 then
						t.wep[t.wep_act].func(self.Entity, t.wep[t.wep_act], p)
						self:SetNWFloat("seat_"..k.."_"..t.wep_act.."_nextshot", t.wep[t.wep_act].NextShoot)
						self:SetNWFloat("seat_"..k.."_"..t.wep_act.."_lastshot", t.wep[t.wep_act].LastShot)
						self:SetNWInt("seat_"..k.."_"..t.wep_act.."_ammo", t.wep[t.wep_act].Ammo)
					end
					if t.wep[t.wep_act].Think then t.wep[t.wep_act].Think(self.Entity, t.wep[t.wep_act], p) end
				end
			end
		end
	end
	self:NextThink(crt)
	return true
end

function ENT:receiveInput(player, key, pressed)
	if key == keyids[WAC_AIR_EXIT][1] and pressed then
		self:EjectPassenger(player)
		return
	end
	player.HelkeysDown[key] = pressed
end

function ENT:GetPLControl(pl, id, cur, static, nopilot)
	local mul = tonumber(pl:GetInfo("wac_cl_air_sensitivity") or "1")
	local tempJoyVal=0
	if !nopilot and pl:GetInfo("wac_cl_air_usejoystick")=="1" and joystick then
		tempJoyVal=joystick.Get(pl, "wac_air_"..id)
		tempJoyVal=(type(tempJoyVal)=="number")and(tempJoyVal)or((tempJoyVal==true)and(1)or(0))
		local addiv=tempJoyVal/127.5-1
		if static then return addiv end
		return math.Clamp(math.pow(addiv, 3)*mul, -1, 1)
	else
		local swap=pl:GetInfo("wac_cl_air_mouse_swap")
		if (id==WAC_AIR_LEANP or (swap=="1"and id==WAC_AIR_LEANR) or (swap=="0" and id==WAC_AIR_LEANY)) and tonumber(pl:GetInfo("wac_cl_air_mouse"))==1 then
			if self.Passenger[1].HelkeysDown[keyids[WAC_AIR_FREEAIM][1]] then return 0 end
			local v=self:WorldToLocal(self:GetPos()+pl:GetAimVector())
			if id==WAC_AIR_LEANP then
				local m=(pl:GetInfo("wac_cl_air_mouse_invert_pitch")=="1" and -1 or 1)
				return math.Clamp(v.z*mul*-m*10,-1,1)
			else
				if swap=="1" then mul=mul*-1 end
				local m=(pl:GetInfo("wac_cl_air_mouse_invert_yawroll")=="1" and -1 or 1)
				return math.Clamp(v.y*mul*m*10,-1,1)
			end
		else
			if pl.HelkeysDown and keyids[id] and pl.HelkeysDown[keyids[id][1]] then
				return math.Clamp(cur+0.03*mul, -1, 1)
			elseif pl.HelkeysDown and keyids[id] and pl.HelkeysDown[keyids[id][2]] then
				return math.Clamp(cur-0.03*mul, -1, 1)
			end
			if static then
				return cur - cur/7
			end
		end
	end
	return 0
end

function ENT:HasPassenger()
	for k, p in pairs(self.Passenger) do
		if p and p:IsValid() then
			return true
		end
	end
end

function ENT:SetOn(b)
	if self.disabled or self.engineDead then b = false end
	if b then
		if self.Active then return end
		self.Active = true
	elseif self.Active then
		self.Active=false
	end
	self:SetNWBool("active", self.Active)
end

function ENT:SwitchState()
	self:SetOn(!self.Active)
end

function ENT:ToggleHover()
	self.DoHover=!self.DoHover
	self:SetNWBool("hover",self.DoHover)
end

function ENT:PhysicsUpdate(ph)
	if self.LastPhys == CurTime() then return end
	local vel = ph:GetVelocity()	
	local pos = self:GetPos()
	local ri = self:GetRight()
	local up = self:GetUp()
	local fwd = self:GetForward()
	local ang = self:GetAngles()
	local dvel = vel:Length()
	local lvel = self:WorldToLocal(pos+vel)

	local realism = 2
	local pilot = self.Passenger[1]
	if IsValid(pilot) then
		self.rotateY = self:GetPLControl(pilot, WAC_AIR_LEANP, self.rotateY)
		self.rotateZ = self.BackRotor and self:GetPLControl(pilot, WAC_AIR_LEANY, self.rotateZ) or 0
		self.rotateX = self:GetPLControl(pilot, WAC_AIR_LEANR, self.rotateX)
		self.upMul = self:GetPLControl(pilot, WAC_AIR_UPDOWN, self.upMul, true)
		realism = math.Clamp(tonumber(pilot:GetInfo("wac_cl_air_realism")),1,3)
	else
		self.rotateY=0
		self.rotateZ=0
		self.rotateX=0
	end

	local angbrake = ((self.TopRotor and self.BackRotor) and ph:GetAngleVelocity()*self.AngBrakeMul/math.pow(realism,2)*9 or NULLVEC)
	local t = self:CalculateHover(ph,pos,vel,ang)
	
	local rotateX = (self.rotateX*1.5+t.r)*self.rotorRpm
	local rotateY = (self.rotateY+t.p)*self.rotorRpm
	local rotateZ = self.rotateZ*1.5*self.rotorRpm
	
	local phm = (wac.aircraft.cvars.doubleTick:GetBool() and 2 or 1)
	if self.UsePhysRotor then
		if self.TopRotor and self.TopRotor.Phys and self.TopRotor.Phys:IsValid() then
			if self.RotorBlurModel then
				self.TopRotorModel:SetColor(Color(255,255,255,math.Clamp(1.3-self.rotorRpm,0.1,1)*255))
			end

			if self.Active and self.TopRotor:WaterLevel() <= 0 and !self.engineDead then
				self.engineRpm = math.Clamp(self.engineRpm+FrameTime()*0.1*wac.aircraft.cvars.startSpeed:GetFloat(),0,1)
				--self.TopRotor.Phys:AddAngleVelocity(Vector(0,0,math.pow(self.engineRpm,2)*16-self.upMul)*self.TopRotorDir*phm)
			else
				self.engineRpm = math.Clamp(self.engineRpm-FrameTime()*0.16*wac.aircraft.cvars.startSpeed:GetFloat(), 0, 1)
			end

			-- top rotor physics
			local rotor = {}
			rotor.phys = self.TopRotor.Phys
			rotor.angVel = rotor.phys:GetAngleVelocity()
			rotor.upvel = self.TopRotor:WorldToLocal(self.TopRotor:GetVelocity()+self.TopRotor:GetPos()).z
			rotor.brake =
				(math.abs(self.rotateX) + math.abs(self.rotateY) + math.abs(self.rotateZ))*0.01
				+ math.Clamp(math.abs(rotor.angVel.z) - 2950, 0, 100)/10 -- RPM cap
				+ math.pow(math.Clamp(1500 - math.abs(rotor.angVel.z), 0, 1500)/900, 3)
				+ math.abs(rotor.angVel.z/10000)
				- (rotor.upvel - self.rotorRpm)*self.upMul/1000

			rotor.targetAngVel =
				Vector(0, 0, math.pow(self.engineRpm,2)*self.TopRotorDir*10)
				- rotor.angVel*rotor.brake/200

			rotor.phys:AddAngleVelocity(rotor.targetAngVel)

			self.rotorRpm = math.Clamp(rotor.angVel.z/3000 * self.TopRotorDir, -1, 1)


			-- body physics
			local mind = (100-self.TopRotor.fHealth)/100
			ph:AddAngleVelocity(VectorRand()*self.rotorRpm*mind*phm)
			if IsValid(self.BackRotor) and self.BackRotor.Phys:IsValid() then
				--self.BackRotor.Phys:AddAngleVelocity(Vector(0,self.rotorRpm*300*self.BackRotorDir-self.BackRotor.Phys:GetAngleVelocity().y/10,0)*phm)
				if self.TwinBladed then
					self.BackRotor.Phys:AddAngleVelocity(rotor.targetAngVel*3)
				else
					self.BackRotor.Phys:AddAngleVelocity(Vector(0,self.rotorRpm*300*self.BackRotorDir-self.BackRotor.Phys:GetAngleVelocity().y/10,0)*phm)
				end

				self.BackRotor.Phys:AddAngleVelocity(self.BackRotor.Phys:GetAngleVelocity() * rotorBrake / 10)
			else
				ph:AddAngleVelocity((Vector(0,0,0-self.rotorRpm*self.TopRotorDir))*phm)
				ph:AddAngleVelocity(VectorRand()*self.rotorRpm*mind*phm)
				if !self.Sound.CrashAlarm:IsPlaying() and !self.disabled then
					self.Sound.CrashAlarm:Play()
				end
			end
			local temp=vel+up*(self.upMul*self.rotorRpm*1.7*self.EngineForce/15+self.rotorRpm*9)*phm
			temp=temp-self:LocalToWorld(lvel*self.AirResistanceMods[4]*dvel*dvel/500000)+pos
			ph:SetVelocity(temp)
			
			for _,e in pairs(self.wheels) do
				if IsValid(e) then
					local ph=e:GetPhysicsObject()
					if ph:IsValid() then
						local lpos=self:WorldToLocal(e:GetPos())
						e:GetPhysicsObject():AddVelocity(
								Vector(0,0,6)+self:LocalToWorld(Vector(
									0, 0, lpos.y*rotateX/math.pow(realism,1.3) - lpos.x*rotateY/math.pow(realism,1.3) - lpos.y*angbrake.x
								)/4)-pos
						)
						e:GetPhysicsObject():AddVelocity(up*ang.r*lpos.y/self.WheelStabilize)
						if self.upMul < -0.8 then -- apply wheel brake
							ph:AddAngleVelocity(ph:GetAngleVelocity()*-0.5)
						end
					end
				end
			end
			
		elseif IsValid(self.BackRotor) and self.BackRotor.Phys:IsValid() then
			local backSpeed = (self.BackRotor.Phys:GetAngleVelocity() - ph:GetAngleVelocity()).y
			ph:AddAngleVelocity(Vector(0,0,backSpeed/300))
			self.BackRotor.Phys:AddAngleVelocity(self.BackRotor.Phys:GetAngleVelocity()*-0.01)
		end
	else
		self.rotorRpm=math.Approach(self.rotorRpm, self.Active and 1 or 0, self.EngineForce/1000)
		ph:SetVelocity(vel*0.999+(up*self.rotorRpm*(self.upMul+1)*7 + (fwd*math.Clamp(ang.p*0.1, -2, 2) + ri*math.Clamp(ang.r*0.1, -2, 2))*self.rotorRpm)*phm)
	end

	ph:AddAngleVelocity((
			Vector(rotateX, rotateY, rotateZ) / math.pow(realism,1.3) * 4.17-angbrake+(
			lvel.x*self.AirResistanceMods[1]
			+lvel.y*self.AirResistanceMods[2]
			+lvel.z*self.AirResistanceMods[3]
	)*dvel/1000)*phm)
	
	for k,s in pairs(self.Seats) do
		if s.wep[s.wep_act].phys and IsValid(self.Passenger[k]) then
			s.wep[s.wep_act].phys(self,s.wep[s.wep_act],self.Passenger[k])
		end
	end

	if self.CustomPhysicsUpdate then self:CustomPhysicsUpdate(ph) end
	self.LastPhys=CurTime()
end

function ENT:CalculateHover(ph,pos,vel,ang)
	if self.DoHover then
		local v=self:WorldToLocal(pos+vel)
		local av=ph:GetAngleVelocity()
		if !self.EasyMode then
			return{
				p=math.Clamp(-ang.p*0.6-av.y*0.6-v.x*0.025,-0.65,0.65),
				r=math.Clamp(-ang.r*0.6-av.x*0.6+v.y*0.025,-0.65,0.65)
			}
		else
			return{
				p=math.Clamp(-ang.p*0.3-av.y*0.1-v.x*0.005,-0.1,0.1),
				r=math.Clamp(-ang.r*0.6-av.x*0.8+v.y*0.045,-0.6,0.6)
			}
		end
	else
		return {p=0,r=0}
	end
end

--[###########]
--[###] DAMAGE
--[###########]

function ENT:PhysicsCollide(cdat, phys)
	if cdat.DeltaTime > 0.5 then
		local mass = cdat.HitObject:GetMass()
		if cdat.HitEntity:GetClass() == "worldspawn" then
			mass = 1000
		end
		local dmg = (cdat.Speed*cdat.Speed*math.Clamp(mass, 0, 1000))/8000000
		if !dmg then return end
		self:TakeDamage(dmg*15)
		if dmg > 2 then
			self.Entity:EmitSound("vehicles/v8/vehicle_impact_heavy"..math.random(1,4)..".wav")
			local lasta=(self.LastDamageTaken<CurTime()+6 and self.LastAttacker or self.Entity)
			for k, p in pairs(self.Passenger) do
				if p and p:IsValid() then
					p:TakeDamage(dmg/5, lasta, self.Entity)
				end
			end
		end
	end
end

function ENT:DamageSmallRotor(amt)
	if amt < 1 then return end
	self.Entity:EmitSound("physics/metal/metal_box_impact_bullet"..math.random(1,3)..".wav", math.Clamp(amt*40,20,200))
	if self.BackRotor and self.BackRotor:IsValid() then
		self.BackRotor.fHealth = self.BackRotor.fHealth - amt
		self.BackRotor.Phys:AddAngleVelocity(self.BackRotor.Phys:GetAngleVelocity()*-amt/50)
		if self.BackRotor.fHealth < 0 then
			self:KillBackRotor()
			if !self.Sound.CrashAlarm:IsPlaying() and !self.disabled then
				self.Sound.CrashAlarm:Play()
			end
		end
		if self.BackRotor then
			self:SetNWFloat("rotorhealth", self.BackRotor.fHealth)
		else
			self:SetNWFloat("rotorhealth", -1)
		end
		self:DamageEngine(amt/10)
	end
end

function ENT:KillBackRotor()
	if !self.BackRotor then return end
	local e = self:addEntity("prop_physics")
	e:SetAngles(self.BackRotor:GetAngles())
	e:SetPos(self.BackRotor:GetPos())
	e:SetModel(self.BackRotor:GetModel())
	e:Spawn()
	e:SetVelocity(self.BackRotor:GetVelocity())
	e:GetPhysicsObject():AddAngleVelocity(self.BackRotor.Phys:GetAngleVelocity())
	e:GetPhysicsObject():SetMass(self.BackRotor.Phys:GetMass())
	self.BackRotor:Remove()
	self.BackRotor=nil
	timer.Simple(10, function()
		if e and e:IsValid() then
			e:Remove()
		end
	end)
end

function ENT:DamageBigRotor(amt)
	if amt < 1 then return end
	self.Entity:EmitSound("physics/metal/metal_box_impact_bullet"..math.random(1,3)..".wav", math.Clamp(amt*40,0,100))
	if self.TopRotor and self.TopRotor:IsValid() then
		self.TopRotor.fHealth = self.TopRotor.fHealth - amt
		self.TopRotor.Phys:AddAngleVelocity((self.TopRotor.Phys:GetAngleVelocity()*-amt)*0.001)
		if self.TopRotor.fHealth < 0 then
			self:KillTopRotor()
			if !self.Sound.CrashAlarm:IsPlaying() and !self.disabled then
				self.Sound.CrashAlarm:Play()
			end
		elseif self.TopRotor.fHealth < 50 and !self.Sound.MinorAlarm:IsPlaying() and !self.disabled then
			self.Sound.MinorAlarm:Play()
		end
		if self.TopRotor then
			self:SetNWFloat("rotorhealth", self.TopRotor.fHealth)
		else
			self:SetNWFloat("rotorhealth", -1)
		end
		self:DamageEngine(amt/10)
	end
end

function ENT:KillTopRotor()
	if !self.TopRotor then return end
	local e = self:addEntity("prop_physics")
	e:SetModel(self.RotorModel)
	e:SetPos(self.TopRotor:GetPos())
	e:SetAngles(self.TopRotor:GetAngles())
	e:Spawn()
	self:SetNWFloat("up",0)
	self:SetNWFloat("uptime",0)
	self.rotorRpm = 0
	local ph = e:GetPhysicsObject()
	e.wac_ignore=true
	if ph:IsValid() then
		ph:SetMass(1000)
		ph:EnableDrag(false)
		ph:AddAngleVelocity(self.TopRotor.Phys:GetAngleVelocity())
		ph:SetVelocity(self.TopRotor.Phys:GetAngleVelocity():Length()*self.TopRotor:GetUp()*0.5 + self.TopRotor:GetVelocity())
	end
	self.TopRotor:Remove()
	self.TopRotor = nil
	e:SetNotSolid(true)
	timer.Simple(15, function()
		if !e or !e:IsValid() then return end
		e:Remove()
	end)
	self:SetOn(false)
end
--[###] Rotor Damage


function ENT:OnTakeDamage(dmg)
	if !dmg:IsExplosionDamage() then
		dmg:ScaleDamage(0.10)
	end
	local rdmg = dmg:GetDamage()
	self:DamageEngine(rdmg/3)
	local pos=self:WorldToLocal(dmg:GetDamagePosition())
	if pos:Distance(self.TopRotorPos)<40 then
		self:DamageBigRotor(rdmg/15)	
	end
	if pos:Distance(self.BackRotorPos)<70 then
		self:DamageSmallRotor(rdmg/2)
	end
	self.LastAttacker=dmg:GetAttacker()
	self.LastDamageTaken=CurTime()
	self:TakePhysicsDamage(dmg)
end

function ENT:DamageEngine(amt)
	if self.disabled then return end
	self.engineHealth = self.engineHealth - amt

	if self.engineHealth < 80  then
		if !self.Sound.MinorAlarm:IsPlaying() then
			self.Sound.MinorAlarm:Play()
		end
		if !self.Smoke and self.engineHealth>0 then
			self.Smoke = self:CreateSmoke()
		end

		if self.engineHealth < 50 then
			if !self.Sound.LowHealth:IsPlaying() then
				self.Sound.LowHealth:Play()
			end
			self:SetOn(false)
			self.engineDead = true

			if self.engineHealth < 20 and !self.EngineFire then
				local fire = ents.Create("env_fire_trail")
				fire:SetPos(self:LocalToWorld(self.FirePos))
				fire:Spawn()
				fire:SetParent(self.Entity)
				self.Burning = true
				self.Sound.LowHealth:Play()
				self.EngineFire = fire
			end

			if self.engineHealth < 0 and !self.disabled then
				self.disabled = true
				local lasta=(self.LastDamageTaken<CurTime()+6 and self.LastAttacker or self.Entity)
				for k, p in pairs(self.Passenger) do
					if p and p:IsValid() then
						p:TakeDamage(p:Health() + 20, lasta, self.Entity)
					end
				end
				for k,v in pairs(self.Seats) do
					v:Remove()
				end
				self.Passenger={}
				self:StopAllSounds()
				self.IgnoreDamage = false
				local effectdata = EffectData()
				effectdata:SetStart( self.Entity:GetPos())
				effectdata:SetOrigin( self.Entity:GetPos())
				effectdata:SetScale( 1 )
				util.Effect("Explosion", effectdata)
				util.Effect("HelicopterMegaBomb", effectdata)
				util.Effect("cball_explode", effectdata)
				util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 300, 300)
				self:SetOn(false)
				if self.Smoke then
					self.Smoke:Remove()
					self.Smoke=nil
				end
				if self.RotorWash then
					self.RotorWash:Remove()
					self.RotorWash=nil
				end
				self:SetNWBool("locked", true)
			end
		end
	end
	if self.Smoke then
		local rcol = math.Clamp(self.engineHealth*3.4, 0, 170)
		self.Smoke:SetKeyValue("rendercolor", rcol.." "..rcol.." "..rcol)
	end
	self:SetNWFloat("health", self.engineHealth)
end

function ENT:CreateSmoke()
	local smoke = ents.Create("env_smokestack")
	smoke:SetPos(self:LocalToWorld(self.SmokePos))
	smoke:SetAngles(self:GetAngles()+Angle(-90,0,0))
	smoke:SetKeyValue("InitialState", "1")
	smoke:SetKeyValue("WindAngle", "0 0 0")
	smoke:SetKeyValue("WindSpeed", "0")
	smoke:SetKeyValue("rendercolor", "170 170 170")
	smoke:SetKeyValue("renderamt", "170")
	smoke:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
	smoke:SetKeyValue("BaseSpread", "2")
	smoke:SetKeyValue("SpreadSpeed", "2")
	smoke:SetKeyValue("Speed", "50")
	smoke:SetKeyValue("StartSize", "10")
	smoke:SetKeyValue("EndSize", "50")
	smoke:SetKeyValue("roll", "10")
	smoke:SetKeyValue("Rate", "15")
	smoke:SetKeyValue("JetLength", "50")
	smoke:SetKeyValue("twist", "5")
	smoke:Spawn()
	smoke:SetParent(self.Entity)
	smoke:Activate()
	return smoke
end

function ENT:AddOnRemove(f)
	if type(f)=="function" then
		table.insert(self.OnRemoveFunctions,f)	
	elseif type(f)=="Entity" or type(f)=="Vehicle" then
		table.insert(self.OnRemoveEntities,f)
	end
end

function ENT:OnRemove()
	self:StopAllSounds()
	for _,p in pairs(self.Passenger) do
		if IsValid(p) then
			p:SetNWInt("wac_passenger_id",0)
			p.wac_passenger_id=0
		end
	end
	for _,f in pairs(self.OnRemoveFunctions) do
		f()
	end
	for _,e in pairs(self.OnRemoveEntities) do
		if IsValid(e) then e:Remove() end
	end
end
