
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.PositionSize=30
ENT.Range=800
ENT.CalculateRange=false
ENT.Damage=50
ENT.BulletSpeed=1500
ENT.BulletWeight=1
ENT.BulletRadius=10
ENT.FireRate=1
ENT.Speed=10
ENT.Height=10
ENT.Turnspeed=10
ENT.Maxturnspeed=100

ENT.FireSound="WAC/tank/T98_cannon_3p.wav"
ENT.FireSoundLevel=70

ENT.Model="models/WeltEnSTurm/RTS/tanks/tank02_body.mdl"
ENT.Mass=100

ENT.TopParts={
	turret={
		model="models/WeltEnSTurm/RTS/tanks/tank02_turret.mdl",
		pos=Vector(0,0,5.6),
	},
	gun={
		model="models/WeltEnSTurm/RTS/tanks/tank02_gun.mdl",
		pos=Vector(0,3,7),
	}
}

ENT.NextFire=0

function ENT:Initialize()
	self.Entity:SetModel(self.Model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys=self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
		self.phys:SetMass(100)
		self.phys:SetMaterial("gmod_ice")
	end
	self:SetNWInt("range", self.Range)
	self.PitchReady=false
	self.YawReady=false
	self.MoveTable={}
	self.LastHealthUpdate=0
	
	self.NDSctr={
		cbt={
			health=0,
			maxhealth=0,
		}
	}
	
	local pos=self:GetPos()
	local fwd=self:GetForward()
	local up=self:GetUp()
	local ri=self:GetRight()
	
	local e=ents.Create("prop_physics")
	e:SetPos(pos+up*self.TopParts.turret.pos.z+ri*self.TopParts.turret.pos.x+fwd*self.TopParts.turret.pos.y)
	e:SetModel(self.TopParts.turret.model)
	e:Spawn()
	e:SetColor(self:GetColor())
	e:SetOwner(self:GetOwner())
	local ph=e:GetPhysicsObject()
	if ph:IsValid() then
		ph:SetMass(50)
	end
	e:SetOwner(self:GetOwner())
	constraint.Axis(self,e, 0, 0, Vector(0,0,0), self:GetUp(), 0, 0, 0, 1)
	e:SetNWEntity("tank",self)
	self.Turret=e
	self.Turret:SetAngles(self:GetAngles())
	
	e=ents.Create("prop_physics")
	e:SetPos(pos+up*self.TopParts.gun.pos.z+ri*self.TopParts.gun.pos.x+fwd*self.TopParts.gun.pos.y)
	e:SetModel(self.TopParts.gun.model)
	e:Spawn()
	e:SetColor(self:GetColor())
	e:SetOwner(self:GetOwner())
	local ph=e:GetPhysicsObject()
	if ph:IsValid() then
		ph:SetMass(50)
		ph:EnableGravity(false)
	end
	e:SetNWEntity("tank",self)
	constraint.NoCollide(self,e,0,0)
	self.Gun=e
	self.Gun:SetAngles(self:GetAngles())

	constraint.AdvBallsocket(self.Gun,  self.Turret,  0,  0,  Vector(0,0,0),  Vector(0,1,0),  0,  0,  0,  -5,  0,  0,  90,  0,  0,  0, 0, 0, 1)
	self.Gun.Tank=self
	self.Turret.Tank=self
	if self.CalculateRange then
		self.Range=self:CalculateRange()
	end
	
	self.LastThink=0
end

local NULLVEC=Vector(0,0,0)
function ENT:PhysicsUpdate(ph)
	local angvel=ph:GetAngleVelocity()
	local CrT=CurTime()
	local ang=self:GetAngles()
	local selfpos=self:GetPos()
	local ri=self:GetRight()
	local up=self:GetUp()
	local fwd=self:GetForward()
	pos=(self.MoveTable[1] and self.MoveTable[1].pos) or selfpos
	local yaw=ang.y
	local tr=util.QuickTrace(self:GetPos(),Vector(0,0,-self.Height*100),self.Entity)
	local hitang=tr.HitNormal:Angle()
	pos.z=tr.HitPos.z+self.Height
	if pos != selfpos then
		yaw=(pos-selfpos):Angle().y
	end
	local length=(pos-selfpos):Length()
	local add=NULLVEC
	if length>15 then
		local speed=(math.Clamp(8/math.abs(math.AngleDifference(yaw, ang.y)),0,1)+self.Speed/50)*math.Clamp(length-2,0,50)/50
		add=fwd*self.Speed*speed
		ph:AddAngleVelocity(Vector(-ang.r,-ang.p,(yaw and math.Clamp(math.AngleDifference(yaw, ang.y)*self.Turnspeed,-self.Maxturnspeed,self.Maxturnspeed) or 0)))
	elseif #self.MoveTable>1 then
		table.remove(self.MoveTable,1)
	elseif self.MoveTable[1] and self.MoveTable[1].ang and self.MoveTable[1].ang!=0 then
		ph:AddAngleVelocity(Vector(0,0,math.Clamp(math.AngleDifference(self.MoveTable[1].ang, ang.y)*self.Turnspeed,-self.Maxturnspeed,self.Maxturnspeed)))
		add=(pos-selfpos)*0.4
	end
	ph:AddAngleVelocity(NULLVEC-angvel)
	ph:SetVelocity(ph:GetVelocity()*0.8+add)
	
	if !ValidEntity(self.Gun) or !ValidEntity(self.Turret) then return end
	
	local targetpos=self.TargetPosition
	local targetvel=nil
	if !targetpos and ValidEntity(self.Target) then
		targetpos=self.Target:GetPos()
		targetvel=self.Target:GetVelocity()
	elseif !targetpos then
		targetpos=self:CalculateIdleTarget()
	end
	targetpos=self:CalculateTravel(targetpos,targetvel)

	local dist=targetpos:Distance(selfpos)
	
	local ph=self.Turret:GetPhysicsObject()
	local zadd=(self.Turret:WorldToLocal(targetpos)/dist*100).y*self.Turnspeed
	self.YawReady=(math.abs(zadd)<self.Turnspeed and true or false)
	ph:AddAngleVelocity(Vector(0,0,math.Clamp(zadd,-self.Maxturnspeed,self.Maxturnspeed))-ph:GetAngleVelocity()+angvel)
	
	local ph=self.Gun:GetPhysicsObject()
	--local yadd=math.AngleDifference(self.Gun:GetAngles().p, -(dist/self.BulletSpeed*8+(targetpos.z-selfpos.z)*dist/self.BulletSpeed/10))
	--self.PitchReady=(math.abs(yadd)<self.Turnspeed and true or false)
	--ph:AddAngleVelocity(Vector(0,math.Clamp(yadd*-10,-self.Maxturnspeed,self.Maxturnspeed),0)-ph:GetAngleVelocity()+angvel)
	local yadd=(self.Gun:WorldToLocal(targetpos)/dist*100).z*self.Turnspeed
	self.PitchReady=(math.abs(yadd)<self.Turnspeed and true or false)
	ph:AddAngleVelocity(Vector(0,math.Clamp(-yadd,-self.Maxturnspeed,self.Maxturnspeed),0)-ph:GetAngleVelocity()+angvel)
end

function ENT:CalculateIdleTarget()
	return self:GetPos()+self:GetForward()*100
end

function ENT:SearchForTargets()
	for _,e in pairs(ents.FindInSphere(self:GetPos(),self.Range)) do
		if e.IsRTSUnit and e:GetOwner() != self:GetOwner() then
			self:SetTarget(e)
			return
		end
	end
end

function ENT:CalculateTravel(vTarget,vVelocity)
	local dist=vTarget:Distance(self.Gun:GetPos())
	if vVelocity then
		vTarget=vTarget+vVelocity*dist*1.5/self.BulletSpeed
	end
	vTarget.z=vTarget.z+math.pow(dist*18/self.BulletSpeed,2.03)
	return vTarget
end

function ENT:DoFire()
	local e=ents.Create("wacrts_shell_base")
	e:SetPos(self.Gun:GetPos()+self.Gun:GetForward()*self.Gun:OBBMaxs().x*1.1)
	e:SetAngles(self.Gun:GetAngles())
	e:Spawn()
	e:GetPhysicsObject():SetMass(self.BulletWeight)
	e:GetPhysicsObject():SetVelocity(self.Gun:GetForward()*self.BulletSpeed)
	self.Entity:EmitSound(self.FireSound, self.FireSoundLevel)
	e.Damage=self.Damage
	e.Radius=self.BulletRadius
	e.Speed=self.BulletSpeed
	e.Weapon=self.Entity
end

function ENT:Think()
	if !ValidEntity(self.Target) and !self.TargetPosition then
		self:SearchForTargets()
	elseif (ValidEntity(self.Target) or self.TargetPosition) and self.NextFire<CurTime() and ValidEntity(self.Gun) and ValidEntity(self.Turret) and self.YawReady and self.PitchReady then
		local pos=self.TargetPosition
		if !pos then pos=self.Target:GetPos() end
		if self:GetPos():Distance(pos)>self.Range then
			self.Target=nil
		else
			self:DoFire()
			self.NextFire=CurTime()+self.FireRate
		end
	end
	local crt=CurTime()
	if self.cbt and self.LastHealthUpdate+1<crt then
		self.LastHealthUpdate=crt
		self.cbt.health=math.Clamp(self.cbt.health+1,0,self.cbt.maxhealth)
		self:SetNWInt("wac_health",self.cbt.health)
		if self.cbt.health<=self.cbt.maxhealth/2 then
			if !self.Smoke then
				local col=self.cbt.health/self.cbt.maxhealth*400
				local smoke = ents.Create("env_smokestack")
				smoke:SetPos(self.Entity:GetPos()+self:GetUp()*5+self:GetForward()*-7)
				smoke:SetAngles(self:GetAngles()+Angle(-40,0,0))
				smoke:SetKeyValue("InitialState", "1")
				smoke:SetKeyValue("WindAngle", "0 0 0")
				smoke:SetKeyValue("WindSpeed", "0")
				smoke:SetKeyValue("rendercolor", col.." "..col.." "..col)
				smoke:SetKeyValue("renderamt", 150-col)
				smoke:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
				smoke:SetKeyValue("BaseSpread", "2")
				smoke:SetKeyValue("SpreadSpeed", "2")
				smoke:SetKeyValue("Speed", "10")
				smoke:SetKeyValue("StartSize", "10")
				smoke:SetKeyValue("EndSize", "20")
				smoke:SetKeyValue("roll", "10")
				smoke:SetKeyValue("Rate", "7")
				smoke:SetKeyValue("JetLength", "15")
				smoke:SetKeyValue("twist", "5")
				smoke:Spawn()
				smoke:SetParent(self.Entity)
				smoke:Activate()
				self.Smoke=smoke
			end
		elseif self.Smoke then
			self.Smoke:Remove()
			self.Smoke=nil
		end
	end
	if self.Smoke then
		local col=self.cbt.health/self.cbt.maxhealth*400
		self.Smoke:SetKeyValue("rendercolor", col.." "..col.." "..col)
		self.Smoke:SetKeyValue("renderamt", 200-col)
	end
	if ValidEntity(self.Gun) and !ValidEntity(self.Turret) then
		self.Gun:GetPhysicsObject():EnableGravity(true)
		self.Gun=nil
	end
	if self:WaterLevel()>0 then
		self:TakeDamage((CurTime()-self.LastThink)*100, self.Entity)
	end
	self.LastThink=CurTime()
end

function ENT:SetTargetYaw(y)
	self.TargetYaw=y
end

function ENT:ResetTargetPos()
	table.Empty(self.MoveTable)
end

function ENT:SetAttackPosition(v)
	self.Target=nil
	self.TargetPosition=v
end

function ENT:IsInRange(e)
	if !ValidEntity(e) then return end
	return (e:GetPos():Distance(self:GetPos())<self.Range)
end

function ENT:SetTarget(ent)
	self.Target=ent
end

function ENT:SetDesiredPos(pos,ang)
	local t={
		pos=pos,
		ang=tonumber(ang),
	}
	table.insert(self.MoveTable,t)
	self.Target=nil
	self.TargetPosition=nil
end

function ENT:SetDesiredYaw(f)
	self.DesiredYaw=f
end

function ENT:OnRemove()
	if ValidEntity(self.Gun) then
		WAC.Damage.WreckIt(self.Gun,self.Entity,self.Entity)
	end
	if ValidEntity(self.Turret) then
		WAC.Damage.WreckIt(self.Turret,self.Entity,self.Entity)
	end
end