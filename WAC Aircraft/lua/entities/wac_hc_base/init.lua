
include("shared.lua")
include("entities/base_wire_entity/init.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("wac/aircraft.lua")


util.AddNetworkString("wac.aircraft.updateWeapons")


ENT.IgnoreDamage = true
ENT.wac_ignore = true

ENT.UsePhysRotor = true
ENT.Submersible = false
ENT.CrRotorWash = true
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


ENT.engineHealth = 100


--[[
	Defines how the aircraft handles depending on where wind is coming from.
	Rotation defines how it rotates,
	Lift how it rises, sinks or gets pushed right/left,
	Rail defines how stable it is on its path, the higher the less it drifts when turning
]]
ENT.Aerodynamics = {
	Rotation = {
		Front = Vector(0, 0.5, 0),
		Right = Vector(0, 0, 30), -- Rotate towards flying direction
		Top = Vector(0, -5, 0)
	},
	Lift = {
		Front = Vector(0, 0, 3), -- Go up when flying forward
		Right = Vector(0, 0, 0),
		Top = Vector(0, 0, -0.5)
	},
	Rail = Vector(0.3, 3, 2),
	RailRotor = 1, -- like Z rail but only active when moving and the rotor is turning
	Drag = {
		Directional = Vector(0.01, 0.01, 0.01),
		Angular = Vector(0.01, 0.01, 0.01)
	}
}


ENT.Agility = {
	Rotate = Vector(1, 1, 1),
	Thrust = 1
}


ENT.Weapons = {}



function ENT:Initialize()
	wac.aircraft.initialize()
	self.Entity:SetModel(self.Model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self:GetPhysicsObject()
	if self.phys:IsValid() then
		self.phys:SetMass(self.Weight)
		self.phys:Wake()
	end
	
	self.entities = {}
	
	self.OnRemoveEntities={}
	self.OnRemoveFunctions={}
	self.wheels = {}
	
	self.nextUpdate = 0
	self.LastDamageTaken=0
	self.wac_seatswitch = true
	self.rotorRpm = 0
	self:SetNWFloat("health", 100)
	self.LastActivated = 0
	self.NextWepSwitch = 0
	self.NextCamSwitch = 0
	self.engineRpm = 0
	self.LastPhys=0
	self.Passenger={}
	
	self.controls = {
		throttle = -1,
		pitch = 0,
		yaw = 0,
		roll = 0,
	}

	self:addRotors()
	self:addSounds()
	self:addWheels()
	self:addWeapons()
	self:addSeats()
	self:addStuff()
	self:addNpcTargets()

	self.phys:EnableDrag(false)
	
end

function ENT:addEntity(name)
	local e = ents.Create(name)
	if !IsValid(e) then return nil end
	table.insert(self.entities, e)
	e.Owner = self.Owner
	e:SetNWString("Owner", "World")
	return e
end


function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end


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


function ENT:addRotors()
	if self.UsePhysRotor then
		self.TopRotor = self:addEntity("prop_physics")
		self.TopRotor:SetModel("models/props_junk/sawblade001a.mdl")
		self.TopRotor:SetPos(self:LocalToWorld(self.TopRotorPos))
		self.TopRotor:SetAngles(self:GetAngles())
		self.TopRotor:SetOwner(self.Owner)
		self.TopRotor:SetNotSolid(true)
		self.TopRotor:Spawn()
		self.TopRotor.Phys = self.TopRotor:GetPhysicsObject()
		self.TopRotor.Phys:EnableGravity(false)
		self.TopRotor.Phys:SetMass(5)
		self.TopRotor.Phys:EnableDrag(false)
		self.TopRotor:SetNoDraw(true)
		self.TopRotor.fHealth = 100
		self.TopRotor.wac_ignore = true
		if self.RotorModel then
			local e = self:addEntity("wac_hitdetector")
			self:SetNWEntity("wac_air_rotor_main", e)
			e:SetModel(self.RotorModel)
			e:SetPos(self:LocalToWorld(self.TopRotorPos))
			e:SetAngles(self:GetAngles())
			
			e.TouchFunc = function(touchedEnt, pos)
				local ph = touchedEnt:GetPhysicsObject()
				if ph:IsValid() then
					if 
							!table.HasValue(self.Passenger, touchedEnt)
							and !table.HasValue(self.entities, touchedEnt)
							and touchedEnt != self
							and !string.find(touchedEnt:GetClass(), "func*")
							and IsValid(self.TopRotor)
							and touchedEnt:GetMoveType() != MOVETYPE_NOCLIP
					then
						local rotorVel = self.TopRotor:GetPhysicsObject():GetAngleVelocity():Length()
						local dmg, mass;
						if touchedEnt:GetClass() == "worldspawn" then
							dmg = rotorVel*rotorVel/100000
							mass = 10000
						else
							dmg=(rotorVel*rotorVel + ph:GetVelocity():Length()*ph:GetVelocity():Length())/100000
							mass = touchedEnt:GetPhysicsObject():GetMass()
						end
						ph:AddVelocity((pos-self.TopRotor:GetPos())*dmg/mass)
						self.phys:AddVelocity((self.TopRotor:GetPos() - pos)*dmg/mass)
						self:DamageBigRotor(dmg)
						e.Entity:TakeDamage(dmg, IsValid(self.Passenger[1]) and self.Passenger[1] or self.Entity, self.Entity)
					end
				end
			end
			
			e:Spawn()
			e:SetNotSolid(true)
			e:SetParent(self.TopRotor)
			e.wac_ignore = true
			local obb=e:OBBMaxs()
			self.RotorWidth=(obb.x>obb.y and obb.x or obb.y)
			self.RotorHeight=obb.z
			self.TopRotorModel=e
		end
		self.BackRotor = self:AddBackRotor()
		self:SetNWEntity("rotor_rear",self.BackRotor)
		constraint.Axis(self.Entity, self.TopRotor, 0, 0, self.TopRotorPos, Vector(0,0,1),0,0,0,1)
		if self.TwinBladed then
			constraint.Axis(self.Entity, self.BackRotor, 0, 0, self.BackRotorPos, Vector(0,0,1),0,0,0,1)
		else
			constraint.Axis(self.Entity, self.BackRotor, 0, 0, self.BackRotorPos, Vector(0,1,0),0,0,0,1)
		end
		self:AddOnRemove(self.TopRotor)
		self:AddOnRemove(self.BackRotor)
	end
end


function ENT:AddBackRotor()
	local e = self:addEntity("wac_hitdetector")
	e:SetModel(self.BackRotorModel)
	e:SetAngles(self:GetAngles())
	e:SetPos(self:LocalToWorld(self.BackRotorPos))
	e.Owner = self.Owner
	e:SetNWFloat("rotorhealth", 100)
	e.wac_ignore = true
	e.TouchFunc = function(touchedEnt, pos)
		local ph = touchedEnt:GetPhysicsObject()
		if ph:IsValid() then
			if
					!table.HasValue(self.Passenger, touchedEnt)
					and !table.HasValue(self.entities, touchedEnt)
					and touchedEnt != self
					and !string.find(touchedEnt:GetClass(), "func*")
					and IsValid(self.TopRotor)
					and touchedEnt:GetMoveType() != MOVETYPE_NOCLIP
			then
				local rotorVel = self.BackRotor:GetPhysicsObject():GetAngleVelocity():Length()
				local dmg, mass;
				if touchedEnt:GetClass() == "worldspawn" then
					dmg = rotorVel*rotorVel/100000
					mass = 10000
				else
					dmg=(rotorVel*rotorVel + ph:GetVelocity():Length()*ph:GetVelocity():Length())/100000
					mass = touchedEnt:GetPhysicsObject():GetMass()
				end
				ph:AddVelocity((pos-self.BackRotor:GetPos())*dmg/mass)
				self.phys:AddVelocity((self.BackRotor:GetPos() - pos)*dmg/mass)
				self:DamageSmallRotor(dmg)
				touchedEnt:TakeDamage(dmg, IsValid(self.Passenger[1]) and self.Passenger[1] or self, self)
			end
		end
	end
	e.OnTakeDamage = function(e, dmg)
		if !dmg:IsExplosionDamage() then
			dmg:ScaleDamage(0.2)
		end
		self.LastAttacker = dmg:GetAttacker()
		self.LastDamageTaken = CurTime()
		self:DamageSmallRotor(dmg:GetDamage())
		e:TakePhysicsDamage(dmg)
	end
	e.Think = function(self) end
	e:Spawn()
	e.Phys=e:GetPhysicsObject()
	if e.Phys:IsValid() then
		e.Phys:Wake()
		e.Phys:EnableGravity(false)
		e.Phys:EnableDrag(false)
		e.Phys:SetMass(10)
	end
	e.fHealth = 40
	self:SetNWEntity("wac_air_rotor_rear", e)
	return e
end


function ENT:addStuff() end


function ENT:addWeapons()
	self.weapons = {}
	for i, w in pairs(self.Weapons) do
		if i != "BaseClass" then
			local pod = ents.Create(w.class)
			pod:SetPos(self:GetPos())
			pod:SetParent(self)
			for index, value in pairs(w.info) do
				pod[index] = value
			end
			pod.aircraft = self
			pod:Spawn()
			pod:Activate()
			pod:SetNoDraw(true)
			pod.podIndex = i
			self.weapons[i] = pod
		end
	end

	if self.Camera then
		self.camera = ents.Create("prop_physics")
		self.camera:SetModel("models/props_junk/popcan01a.mdl")
		self.camera:SetNoDraw(true)
		self.camera:SetPos(self:LocalToWorld(self.Camera.pos))
		self.camera:SetParent(self)
		self.camera:Spawn()
	end
end

function ENT:addSeats()
	self.seats = {}
	local e = self:addEntity("wac_seat_connector")
	e:SetPos(self:LocalToWorld(self.SeatSwitcherPos))
	e:SetNoDraw(true)
	e:Spawn()
	e:Activate()
	e.wac_ignore = true
	e:SetNotSolid(true)
	e:SetParent(self)
	self:SetSwitcher(e)
	for k, v in pairs(self.Seats) do
		if k != "BaseClass" then
			self.Seats[k].activeProfile = 0
			local ang = self:GetAngles()
			self.seats[k] = self:addEntity("prop_vehicle_prisoner_pod")
			self.seats[k]:SetModel("models/nova/airboat_seat.mdl") 
			self.seats[k]:SetPos(self:LocalToWorld(v.pos))
			self.seats[k]:Spawn()
			self.seats[k]:Activate()
			self.seats[k]:SetNWInt("selectedWeapon", 0)
			if v.ang then
				local a = self:GetAngles()
				a.y = a.y-90
				a:RotateAroundAxis(Vector(0,0,1), v.ang.y)
				self.seats[k]:SetAngles(a)
			else
				ang:RotateAroundAxis(self:GetUp(), -90)
				self.seats[k]:SetAngles(ang)
			end
			self.seats[k]:SetNoDraw(true)
			self.seats[k]:SetNotSolid(true)
			self.seats[k]:SetParent(self)
			self.seats[k].wac_ignore = true
			self.seats[k]:SetNWEntity("wac_aircraft", self)
			self.seats[k]:SetKeyValue("limitview","0")
			e:addVehicle(self.seats[k])
		end
	end
end


function ENT:addWheels()
	for _,t in pairs(self.Wheels) do
		if t.mdl then
			local e=self:addEntity("prop_physics")
			e:SetModel(t.mdl)
			e:SetPos(self:LocalToWorld(t.pos))
			e:SetAngles(self:GetAngles())
			e:Spawn()
			e:Activate()
			local ph=e:GetPhysicsObject()
			if t.mass then
				ph:SetMass(t.mass)
			end
			ph:EnableDrag(false)
			constraint.Axis(e,self,0,0,Vector(0,0,0),self:WorldToLocal(e:LocalToWorld(Vector(0,1,0))),0,0,t.friction,1)
			table.insert(self.wheels,e)
			self:AddOnRemove(e)
		end
	end
end


function ENT:fireWeapon(bool, seat, t)
	if !t.weapons then return end
	local pod = self.weapons[t.weapons[t.activeProfile]]
	if !pod then return end
	pod.shouldFire = bool
	pod:trigger(bool, self.seats[seat])
end


function ENT:nextWeapon(t,k,p)
	if !t.weapons then return end

	local pod = self.weapons[t.weapons[t.activeProfile]]
	if pod then
		pod:select(false)
		pod.seat = nil
	end

	if t.activeProfile == #t.weapons then
		t.activeProfile = 0
	else
		t.activeProfile = t.activeProfile + 1
	end
	if t.weapons[t.activeProfile] then
		local weapon = self.weapons[t.weapons[t.activeProfile]]
		weapon:select(true)
		weapon.seat = self.seats[k]
	end
	self:SetNWInt("seat_"..k.."_actwep", t.activeProfile)
end


function ENT:EjectPassenger(ply,idx,t)
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
	ply:SetPos(self:LocalToWorld(self.Seats[idx].exit))
	ply:SetVelocity(self:GetPhysicsObject():GetVelocity()*1.2)
	ply:SetEyeAngles((self:LocalToWorld(self.Seats[idx].pos-Vector(0,0,40))-ply:GetPos()):Angle())
	self:updateSeats()
end


function ENT:Use(act, cal)
	if self.disabled then return end
	local d = self.MaxEnterDistance
	local v
	for k, veh in pairs(self.seats) do
		if veh and veh:IsValid() then
			local psngr = veh:GetPassenger(0)
			if !psngr or !psngr:IsValid() then
				local dist = veh:GetPos():Distance(util.QuickTrace(act:GetShootPos(),act:GetAimVector()*self.MaxEnterDistance,act).HitPos)
				if dist < d then
					d = dist
					v = veh
				end
			end
		end
	end
	if v then
		act:EnterVehicle(v)
	end
	self:updateSeats()
end


function ENT:updateSeats()
	for k, veh in pairs(self.seats) do
		if !veh:IsValid() then return end
		local p = veh:GetPassenger(0)
		if self.Passenger[k] != p then
			if IsValid(self.Passenger[k]) then
				self.Passenger[k]:SetNWEntity("wac_aircraft", NULL)
			end
			self:SetNWEntity("passenger_"..k, p)
			p:SetNWInt("wac_passenger_id",k)
			self.Passenger[k] = p
			if IsValid(p) then
				p.wac = p.wac or {}
				p.wac.mouseInput = true
				net.Start("wac.aircraft.updateWeapons")
				net.WriteEntity(self)
				net.WriteInt(table.Count(self.weapons), 8)
				for name, weapon in pairs(self.weapons) do
					net.WriteString(name)
					net.WriteEntity(weapon)
				end
				net.Send(p)
			end
		end
	end
	self:GetSwitcher():updateSeats()
end


function ENT:StopAllSounds()
	for k, s in pairs(self.sounds) do
		s:Stop()
	end
end


function ENT:RocketAlert()
	if self.rotorRpm > 0.1 then
		local b=false
		local rockets = ents.FindByClass("rpg_missile")
		table.Merge(rockets, ents.FindByClass("wac_w_rocket"))
		for _, e in pairs(rockets) do
			if e:GetPos():Distance(self:GetPos()) < 2000 then b = true break end
		end
		if self.sounds.MissileAlert:IsPlaying() then
			if !b then
				self.sounds.MissileAlert:Stop()
			end
		elseif b then
			self.sounds.MissileAlert:Play()
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
		if self.nextUpdate<crt then
			if self.phys and self.phys:IsValid() then
				self.phys:Wake()
			end

			if IsValid(self.camera) then
				local p = self.seats[self.Camera.seat]:GetDriver()
				if IsValid(p) then
					local view = self:WorldToLocalAngles(p:GetAimVector():Angle())
					local ang = Angle(self.Camera.restrictPitch and 0 or view.p, self.Camera.restrictYaw and 0 or view.y, 0)
					if self.Camera.minAng then
						ang.p = (ang.p > self.Camera.minAng.p and ang.p or self.Camera.minAng.p)
						ang.y = (ang.y > self.Camera.minAng.y and ang.y or self.Camera.minAng.y)
					end
					if self.Camera.maxAng then
						ang.p = (ang.p < self.Camera.maxAng.p and ang.p or self.Camera.maxAng.p)
						ang.y = (ang.y < self.Camera.maxAng.y and ang.y or self.Camera.maxAng.y)
					end
					self.camera:SetAngles(self:LocalToWorldAngles(ang))
				end
			end

			local target = math.floor(math.Clamp(self.rotorRpm, 0, 0.99)*3)
			if self.bodyGroup != target then
				self.bodyGroup = target
				if IsValid(self.TopRotorModel) then
					self.TopRotorModel:SetBodygroup(1, self.bodyGroup)
				end
				if IsValid(self.BackRotor) then
					self.BackRotor:SetBodygroup(1, self.bodyGroup)
				end
			end

			if self.skin != self:GetSkin() then
				self.skin = self:GetSkin()
				self:updateSkin(self.skin)
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
			self:updateSeats()
			self.nextUpdate = crt+0.1
		end
		
		self:setVar("rotorRpm", math.Clamp(self.rotorRpm, 0, 150))
		self:setVar("engineRpm", self.engineRpm)
		self:setVar("up", self.controls.throttle)

		if self.TopRotor and self.TopRotor:WaterLevel() > 0 then
			self:DamageEngine(FrameTime())
		end
	end
	self:NextThink(crt)
	return true
end


function ENT:receiveInput(name, value, seat)
	if seat == 1 then
		if name == "Start" and value>0.5 then
			self:setEngine(!self.active)
		elseif name == "Throttle" then
			self.controls.throttle = value
		elseif name == "Pitch" then
			self.controls.pitch = value
		elseif name == "Yaw" then
			self.controls.yaw = value
		elseif name == "Roll" then
			self.controls.roll = value
		elseif name == "Hover" and value>0.5 then
			self:SetHover(!self:GetHover())
		elseif name == "FreeView" then
			self.Passenger[seat].wac.mouseInput = (value < 0.5)
		end
	end
	if name == "Exit" and value>0.5 then
		self:EjectPassenger(self.Passenger[seat])
	elseif name == "Fire" then
		self:fireWeapon(value > 0.5, seat, self.Seats[seat])
	elseif name == "NextWeapon" and value > 0.5 then
		self:nextWeapon(self.Seats[seat], seat, self.Passenger[seat])
	end
end


function ENT:getSeat(player)
	for i, p in pairs(self.Passenger) do
		if p == player then
			return self.seats[i]
		end
	end
end


function ENT:setEngine(b)
	if self.disabled or self.engineDead then b = false end
	if b then
		if self.active then return end
		self.active = true
	elseif self.active then
		self.active=false
	end
	self:SetNWBool("active", self.active)
end


function ENT:calcAerodynamics(ph)

	local dvel = self:GetVelocity():Length()
	local lvel = self:WorldToLocal(self:GetPos() + self:GetVelocity())

	local targetVelocity = 
		- self:LocalToWorld(self.Aerodynamics.Rail * lvel * dvel * dvel / 1000000000) + self:GetPos()
		+ self:LocalToWorld(
			self.Aerodynamics.Lift.Front * lvel.x * dvel / 10000000 +
			self.Aerodynamics.Lift.Right * lvel.y * dvel / 10000000 +
			self.Aerodynamics.Lift.Top * lvel.z * dvel / 10000000
		) - self:GetPos()

	local targetAngVel =
		(
			lvel.x*self.Aerodynamics.Rotation.Front +
			lvel.y*self.Aerodynamics.Rotation.Right +
			lvel.z*self.Aerodynamics.Rotation.Top
		) / 10000
		- ph:GetAngleVelocity()*self.Aerodynamics.Drag.Angular

	return targetVelocity, targetAngVel
end


function ENT:calcHover(ph,pos,vel,ang)
	if self:GetHover() then
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
		realism = math.Clamp(tonumber(pilot:GetInfo("wac_cl_air_realism")), 1, 3)
	end

	local t = self:calcHover(ph,pos,vel,ang)
	
	local rotateX = (self.controls.roll*1.5+t.r)*self.rotorRpm
	local rotateY = (self.controls.pitch+t.p)*self.rotorRpm
	local rotateZ = self.controls.yaw*1.5*self.rotorRpm
	
	--local phm = (wac.aircraft.cvars.doubleTick:GetBool() and 2 or 1)
	local phm = FrameTime()*66
	if self.UsePhysRotor then
		if self.TopRotor and self.TopRotor.Phys and self.TopRotor.Phys:IsValid() then
			if self.RotorBlurModel then
				self.TopRotorModel:SetColor(Color(255,255,255,math.Clamp(1.3-self.rotorRpm,0.1,1)*255))
			end

			if self.active and self.TopRotor:WaterLevel() <= 0 and !self.engineDead then
				self.engineRpm = math.Clamp(self.engineRpm+FrameTime()*0.1*wac.aircraft.cvars.startSpeed:GetFloat(),0,1)
			else
				self.engineRpm = math.Clamp(self.engineRpm-FrameTime()*0.16*wac.aircraft.cvars.startSpeed:GetFloat(), 0, 1)
			end

			-- top rotor physics
			local rotor = {}
			rotor.phys = self.TopRotor.Phys
			rotor.angVel = rotor.phys:GetAngleVelocity()
			rotor.upvel = self.TopRotor:WorldToLocal(self.TopRotor:GetVelocity()+self.TopRotor:GetPos()).z
			rotor.brake =
				math.Clamp(math.abs(rotor.angVel.z) - 2950, 0, 100)/10 -- RPM cap
				+ math.pow(math.Clamp(1500 - math.abs(rotor.angVel.z), 0, 1500)/900, 3)
				+ math.abs(rotor.angVel.z/10000)
				- (rotor.upvel - self.rotorRpm)*self.controls.throttle/1000

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
					self.BackRotor.Phys:AddAngleVelocity(rotor.targetAngVel)
				else
					self.BackRotor.Phys:AddAngleVelocity(Vector(0,self.rotorRpm*300*self.BackRotorDir-self.BackRotor.Phys:GetAngleVelocity().y/10,0)*phm)
				end

				self.BackRotor.Phys:AddAngleVelocity(self.BackRotor.Phys:GetAngleVelocity() * rotorBrake / 10)
			else
				ph:AddAngleVelocity((Vector(0,0,0-self.rotorRpm*self.TopRotorDir*2))*phm)
				ph:AddAngleVelocity(VectorRand()*self.rotorRpm*mind*phm)
				if !self.sounds.CrashAlarm:IsPlaying() and !self.disabled then
					self.sounds.CrashAlarm:Play()
				end
			end

			local throttle = self.Agility.Thrust*up*(self.controls.throttle*self.rotorRpm*1.7*self.EngineForce/15+self.rotorRpm*9.15)*phm
			local brakez = self:LocalToWorld(Vector(0, 0, lvel.z*dvel*self.rotorRpm/100000*self.Aerodynamics.RailRotor)) - pos
			ph:AddVelocity((throttle - brakez)*phm)
			
		elseif IsValid(self.BackRotor) and self.BackRotor.Phys:IsValid() then
			local backSpeed = (self.BackRotor.Phys:GetAngleVelocity() - ph:GetAngleVelocity()).y
			ph:AddAngleVelocity(Vector(0,0,backSpeed/300))
			self.BackRotor.Phys:AddAngleVelocity(self.BackRotor.Phys:GetAngleVelocity()*-0.01)
		end
	else
		self.rotorRpm=math.Approach(self.rotorRpm, self.active and 1 or 0, self.EngineForce/1000)
		ph:SetVelocity(vel*0.999+(up*self.rotorRpm*(self.controls.throttle+1)*7 + (fwd*math.Clamp(ang.p*0.1, -2, 2) + ri*math.Clamp(ang.r*0.1, -2, 2))*self.rotorRpm)*phm)
	end

	local controlAng = Vector(rotateX, rotateY, IsValid(self.BackRotor) and rotateZ or 0) / math.pow(realism, 1.3) * 4.17 * self.Agility.Rotate

	local aeroVelocity, aeroAng = self:calcAerodynamics(ph)

	ph:AddAngleVelocity((aeroAng + controlAng)*phm)
	ph:AddVelocity((aeroVelocity)*phm)

	for _,e in pairs(self.wheels) do
		if IsValid(e) then
			local ph=e:GetPhysicsObject()
			if ph:IsValid() then
				local lpos=self:WorldToLocal(e:GetPos())
				e:GetPhysicsObject():AddVelocity(
						Vector(0,0,6)+self:LocalToWorld(Vector(
							0, 0, lpos.y*rotateX/math.pow(realism,1.3) - lpos.x*rotateY/math.pow(realism,1.3)
						)/4)-pos
				)
				e:GetPhysicsObject():AddVelocity(up*ang.r*lpos.y/self.WheelStabilize)
				if self.controls.throttle < -0.8 then -- apply wheel brake
					ph:AddAngleVelocity(ph:GetAngleVelocity()*-0.5)
				end
			end
		end
	end
	
	self.LastPhys = CurTime()
end


--[###########]
--[###] DAMAGE
--[###########]

function ENT:PhysicsCollide(cdat, phys)
	if cdat.DeltaTime > 0.5 then
		local mass = cdat.HitObject:GetMass()
		if cdat.HitEntity:GetClass() == "worldspawn" then
			mass = 5000
		end
		local dmg = (cdat.Speed*cdat.Speed*math.Clamp(mass, 0, 5000))/10000000
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
			if !self.sounds.CrashAlarm:IsPlaying() and !self.disabled then
				self.sounds.CrashAlarm:Play()
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
	e:SetSkin(self.BackRotor:GetSkin())
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
			if !self.sounds.CrashAlarm:IsPlaying() and !self.disabled then
				self.sounds.CrashAlarm:Play()
			end
		elseif self.TopRotor.fHealth < 50 and !self.sounds.MinorAlarm:IsPlaying() and !self.disabled then
			self.sounds.MinorAlarm:Play()
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
	e:SetPos(self.TopRotor:GetPos())
	e:SetAngles(self.TopRotor:GetAngles())
	e:SetModel(self.RotorModel)
	e:SetSkin(self.TopRotorModel:GetSkin())
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
	self:setEngine(false)
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
		if !self.sounds.MinorAlarm:IsPlaying() then
			self.sounds.MinorAlarm:Play()
		end
		if !self.Smoke and self.engineHealth>0 then
			self.Smoke = self:CreateSmoke()
		end

		if self.engineHealth < 50 then
			if !self.sounds.LowHealth:IsPlaying() then
				self.sounds.LowHealth:Play()
			end
			self:setEngine(false)
			self.engineDead = true

			if self.engineHealth < 20 and !self.EngineFire then
				local fire = ents.Create("env_fire_trail")
				fire:SetPos(self:LocalToWorld(self.FirePos))
				fire:Spawn()
				fire:SetParent(self.Entity)
				self.Burning = true
				self.sounds.LowHealth:Play()
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
				for k,v in pairs(self.seats) do
					v:Remove()
				end
				self.Passenger={}
				self:StopAllSounds()
				self.IgnoreDamage = false
				for name, vec in pairs(self.Aerodynamics.Rotation) do
					vec = VectorRand()*100
				end
				local effectdata = EffectData()
				effectdata:SetStart(self.Entity:GetPos())
				effectdata:SetOrigin(self.Entity:GetPos())
				effectdata:SetScale(1)
				util.Effect("Explosion", effectdata)
				util.Effect("HelicopterMegaBomb", effectdata)
				util.Effect("cball_explode", effectdata)
				util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 300, 300)
				self:setEngine(false)
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
		end
	end
	for _,f in pairs(self.OnRemoveFunctions) do
		f()
	end
	for _,e in pairs(self.OnRemoveEntities) do
		if IsValid(e) then e:Remove() end
	end
end
