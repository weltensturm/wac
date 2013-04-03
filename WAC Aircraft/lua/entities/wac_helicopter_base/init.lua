
include("shared.lua")
include("entities/base_wire_entity/init.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("wac/aircraft.lua")

ENT.IgnoreDamage	= true
ENT.wac_ignore		= true

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

ENT.Weight = 1000
ENT.MaxEnterDistance = 50
ENT.WheelStabilize = -400

ENT.new = true

function ENT:Initialize()

	self.Entity:SetModel(self.Model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	
	if self.phys:IsValid() then
		self.phys:SetMass(self.Weight)
		self.phys:Wake()
	end
	
	self.players = {}
	self.entities = {}
	
	self.OnRemoveFunctions = {}
	self.OnRemoveEntities = {}

	self.wac_seatswitch = true

	self.controls = {
		throttle = 0,
		pitch = 0,
		yaw = 0,
		roll = 0,
	}

	self.engineRpm = 0

	self:SetNWFloat("health", 100)
	
	self:setRotors()
	self:setSounds()
	self:setSeats()
	self:setWheels()
	
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Health");
	--self:NetworkVar( "Vector", 1, "BloodPos");
	--self:NetworkVar( "Vector", 2, "UrinePos");
end

function ENT:addEntity(name)
	local e = ents.Create(name)
	if !IsValid(e) then return nil end
	table.insert(self.entities, e)
	e.Owner = self.Owner
	e:SetNWEntity("Owner", self.Owner)
	return e
end


function ENT:setRotors()
	self.rotors = {}
	for _, data in pairs(self.Rotors) do
		local rotor = self:addEntity("wac_rotor")
		rotor.model = data.model
		rotor:SetPos(self:LocalToWorld(data.pos))
		rotor:SetAngles(self:GetAngles()+data.angle)
		rotor:Spawn()
		rotor:Activate()
		rotor.force = data.force
		rotor.dir = data.dir
		rotor.phys = rotor:GetPhysicsObject()
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
	e:SetPos(self:GetPos())
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
		--constraint.Axis(e, self, 0, 0, data.pos, self:WorldToLocal(e:LocalToWorld(Vector(0,1,0))), 0, 0, data.friction, 1)
		constraint.Axis(e,self,0,0,Vector(0,0,0),self:WorldToLocal(e:LocalToWorld(Vector(0,1,0))),0,0,data.friction,1)
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
		self:updateSeats()
	end
end

function ENT:EjectPassenger(ply,idx,t)
	if ply.LastVehicleEntered and ply.LastVehicleEntered<CurTime() then
		if !idx then
			for k,p in pairs(self.players) do
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
		self:updateSeats()
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
	self:updateSeats()
end

function ENT:updateSeats()
	for k, veh in pairs(self.seats) do
		if !veh:IsValid() then return end
		local p = veh:GetPassenger(0)
		if self.players[k] != p then
			if IsValid(self.players[k]) then
				self.players[k].HelkeysDown={}
				self.players[k]:SetNWEntity("wac_aircraft", NULL)
				local t=self.Seats[k].wep[self.Seats[k].wep_act]
				if t and t.DeSelect then
					t.DeSelect(self,t,self.players[k])
				end
			end
			self:SetNWEntity("passenger_"..k, p)
			p:SetNWInt("wac_passenger_id",k)
			p.wac_passenger_id = k
			self.players[k] = p
			if k == 1 then
				self.pilot = p
			end
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
end

function ENT:receiveInput(player, id, value)
	if id == "Start" and value==1 then
		self:setEngine(!self.Active)
	elseif id == "Throttle" then
		self.controls.throttle = value
	elseif id == "Pitch" then
		self.controls.pitch = value
	elseif id == "Yaw" then
		self.controls.yaw = value
	elseif id == "Roll" then
		self.controls.roll = value
	elseif id == "Exit" and value==1 then
		self:EjectPassenger(player)
	end
end

function ENT:HasPassenger()
	for k, p in pairs(self.players) do
		if p and p:IsValid() then
			return true
		end
	end
end

function ENT:setEngine(b)
	if self.disabled or self.engineDead then b = false end
	if b then
		if self.Active then return end
		self.Active = true
	elseif self.Active then
		self.Active=false
	end
	MsgN(self.Active)
	self:SetNWBool("active", self.Active)
end

function ENT:SwitchState()
	self:setEngine(!self.Active)
end

function ENT:ToggleHover()
	self.DoHover=!self.DoHover
	self:SetNWBool("hover",self.DoHover)
end

function ENT:PhysicsUpdate(ph)
	if self.Lastphys == CurTime() then return end
	local vel = ph:GetVelocity()	
	local pos = self:GetPos()
	local ri = self:GetRight()
	local up = self:GetUp()
	local fwd = self:GetForward()
	local ang = self:GetAngles()
	local dvel = vel:Length()
	local lvel = self:WorldToLocal(pos+vel)

	if self.Active and !self.engineDead then
		self.engineRpm = math.Clamp(self.engineRpm+FrameTime()*0.1*wac.aircraft.cvars.startSpeed:GetFloat(),0,1)
		--self.TopRotor.phys:AddAngleVelocity(Vector(0,0,math.pow(self.engineRpm,2)*16-self.upMul)*self.TopRotorDir*phm)
	else
		self.engineRpm = math.Clamp(self.engineRpm-FrameTime()*0.16*wac.aircraft.cvars.startSpeed:GetFloat(), 0, 1)
	end

	for _, rotor in pairs(self.rotors) do
		rotor.phys:AddAngleVelocity(Vector(0,0, self.engineRpm*rotor.dir*100))
		rotor.throttle = self.controls.throttle+0.5
	end


	--[[

	local realism = 2
	local pilot = self.players[1]
	if IsValid(pilot) then
		realism = math.Clamp(tonumber(pilot:GetInfo("wac_cl_air_realism")),1,3)
	end

	local angbrake = ((self.TopRotor and self.BackRotor) and ph:GetAngleVelocity()*self.AngBrakeMul/math.pow(realism,2)*9 or NULLVEC)
	local t = self:CalculateHover(ph,pos,vel,ang)
	
	local roll = (self.controls.roll*1.5+t.r)*self.rotorRpm
	local pitch = (self.controls.pitch+t.p)*self.rotorRpm
	local yaw = self.controls.yaw*1.5*self.rotorRpm
	
	local phm = (wac.aircraft.cvars.doubleTick:GetBool() and 2 or 1)
	if self.UsephysRotor then
		if self.TopRotor and self.TopRotor.phys and self.TopRotor.phys:IsValid() then
			if self.RotorBlurModel then
				self.TopRotorModel:SetColor(Color(255,255,255,math.Clamp(1.3-self.rotorRpm,0.1,1)*255))
			end

			if self.Active and self.TopRotor:WaterLevel() <= 0 and !self.engineDead then
				self.engineRpm = math.Clamp(self.engineRpm+FrameTime()*0.1*wac.aircraft.cvars.startSpeed:GetFloat(),0,1)
				--self.TopRotor.phys:AddAngleVelocity(Vector(0,0,math.pow(self.engineRpm,2)*16-self.upMul)*self.TopRotorDir*phm)
			else
				self.engineRpm = math.Clamp(self.engineRpm-FrameTime()*0.16*wac.aircraft.cvars.startSpeed:GetFloat(), 0, 1)
			end

			-- top rotor physics
			local rotor = {}
			rotor.phys = self.TopRotor.phys
			rotor.angVel = rotor.phys:GetAngleVelocity()
			rotor.upvel = self.TopRotor:WorldToLocal(self.TopRotor:GetVelocity()+self.TopRotor:GetPos()).z
			rotor.brake =
				(math.abs(self.controls.roll) + math.abs(self.controls.pitch) + math.abs(self.controls.yaw))*0.01
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
			if IsValid(self.BackRotor) and self.BackRotor.phys:IsValid() then
				--self.BackRotor.phys:AddAngleVelocity(Vector(0,self.rotorRpm*300*self.BackRotorDir-self.BackRotor.phys:GetAngleVelocity().y/10,0)*phm)
				if self.TwinBladed then
					self.BackRotor.phys:AddAngleVelocity(rotor.targetAngVel*3)
				else
					self.BackRotor.phys:AddAngleVelocity(Vector(0,self.rotorRpm*300*self.BackRotorDir-self.BackRotor.phys:GetAngleVelocity().y/10,0)*phm)
				end

				self.BackRotor.phys:AddAngleVelocity(self.BackRotor.phys:GetAngleVelocity() * rotorBrake / 10)
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
									0, 0, lpos.y*roll/math.pow(realism,1.3) - lpos.x*pitch/math.pow(realism,1.3) - lpos.y*angbrake.x
								)/4)-pos
						)
						e:GetPhysicsObject():AddVelocity(up*ang.r*lpos.y/self.WheelStabilize)
						if self.upMul < -0.8 then -- apply wheel brake
							ph:AddAngleVelocity(ph:GetAngleVelocity()*-0.5)
						end
					end
				end
			end
			
		elseif IsValid(self.BackRotor) and self.BackRotor.phys:IsValid() then
			local backSpeed = (self.BackRotor.phys:GetAngleVelocity() - ph:GetAngleVelocity()).y
			ph:AddAngleVelocity(Vector(0,0,backSpeed/300))
			self.BackRotor.phys:AddAngleVelocity(self.BackRotor.phys:GetAngleVelocity()*-0.01)
		end
	else
		self.rotorRpm=math.Approach(self.rotorRpm, self.Active and 1 or 0, self.EngineForce/1000)
		ph:SetVelocity(vel*0.999+(up*self.rotorRpm*(self.upMul+1)*7 + (fwd*math.Clamp(ang.p*0.1, -2, 2) + ri*math.Clamp(ang.r*0.1, -2, 2))*self.rotorRpm)*phm)
	end

	ph:AddAngleVelocity((
			Vector(controls.roll, controls.pitch, controls.yaw) / math.pow(realism,1.3) * 4.17-angbrake+(
			lvel.x*self.AirResistanceMods[1]
			+lvel.y*self.AirResistanceMods[2]
			+lvel.z*self.AirResistanceMods[3]
	)*dvel/1000)*phm)
	
	for k,s in pairs(self.Seats) do
		if s.wep[s.wep_act].phys and IsValid(self.players[k]) then
			s.wep[s.wep_act].phys(self,s.wep[s.wep_act],self.players[k])
		end
	end

	if self.CustomphysicsUpdate then self:CustomphysicsUpdate(ph) end
	self.Lastphys=CurTime()
	]]
	
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

function ENT:physicsCollide(cdat, phys)
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
			for k, p in pairs(self.players) do
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
		self.BackRotor.phys:AddAngleVelocity(self.BackRotor.phys:GetAngleVelocity()*-amt/50)
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
	e:GetPhysicsObject():AddAngleVelocity(self.BackRotor.phys:GetAngleVelocity())
	e:GetPhysicsObject():SetMass(self.BackRotor.phys:GetMass())
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
		self.TopRotor.phys:AddAngleVelocity((self.TopRotor.phys:GetAngleVelocity()*-amt)*0.001)
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
		ph:AddAngleVelocity(self.TopRotor.phys:GetAngleVelocity())
		ph:SetVelocity(self.TopRotor.phys:GetAngleVelocity():Length()*self.TopRotor:GetUp()*0.5 + self.TopRotor:GetVelocity())
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
	self:TakephysicsDamage(dmg)
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
			self:setEngine(false)
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
				for k, p in pairs(self.players) do
					if p and p:IsValid() then
						p:TakeDamage(p:Health() + 20, lasta, self.Entity)
					end
				end
				for k,v in pairs(self.Seats) do
					v:Remove()
				end
				self.players={}
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
	for _,p in pairs(self.players) do
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

