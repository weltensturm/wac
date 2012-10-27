
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("entities/base_wire_entity/init.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
		self.phys:EnableGravity(false)
		self.phys:SetMass((self.ConTable["damage"][2]+self.ConTable["radius"][2])/(self.ConTable["shootdelay"][2]+self.ConTable["reloadtime"][2]))
	end
	self.Reloaded=true
	self.Inputs=Wire_CreateInputs(self.Entity, {"Fire"})
	self.Outputs=Wire_CreateOutputs(self.Entity, {"Ammo","CanFire"})
	self.fireIn=0
	self.NextShoot=0
	self.Sound = CreateSound(self.Entity,self.ConTable["soundShoot"][2])
	self.SoundStop=0
	self.MagazineLoad=self.ConTable["msize"][2]
end

function ENT:TriggerInput(iname, value)
	if iname=="Fire" then
		self.fireIn=value
	end
end

function ENT:AddVehicle(e)
	self.Vehicle=e
end

function ENT:FireGun(act)
	local crt=CurTime()
	if self.NextShoot<=crt and self.MagazineLoad>0 then
		self.NextShoot=crt+self.ConTable["shootdelay"][2]
		self.SoundPlayed=false
		self.Sound:Stop()
		self.SoundStop=crt+1
		local shootvec = self:GetUp()*(self:OBBMaxs().z+5)
		local selfpos = self:GetPos()
		local selfspeed = self:GetVelocity()
		if self.ConTable["mode"][2]==0 or self.ConTable["mode"][2]==2 then
			local bullet = ents.Create("wac_w_base_bullet")
			bullet.ConTable=table.Copy(self.ConTable)
			constraint.NoCollide(self.Entity, bullet, 0, 0)
			bullet:SetAngles(self:GetAngles())
			bullet:SetPos(selfpos + shootvec)
			bullet:Spawn()
			bullet:Activate()
			bullet.targetpos = vec
			bullet.oldpos = (selfpos - shootvec)
			bullet.tracehitang = self:GetAngles()
			bullet.Owner = act or self.Owner
			if !bullet.phys then bullet.phys = bullet:GetPhysicsObject() end		
			local effectdata = EffectData()
			effectdata:SetOrigin(selfpos + shootvec)
			effectdata:SetAngle(shootvec:Angle())
			effectdata:SetScale(self.ConTable["damage"][2]/150)
			util.Effect("wac_tank_shoot", effectdata)		
			if self.phys:IsValid() then
				self.phys:AddVelocity(shootvec*-self.ConTable["damage"][2]/10)
			end
			self.Sound:ChangeVolume(450)
			self.Sound:Play()
			if bullet.phys:IsValid() then
				bullet.phys:SetVelocity(selfspeed + shootvec*3500)
			end
		elseif self.ConTable["mode"][2]==1 then
			local bullet = ents.Create("wac_w_rocket")
			bullet:SetAngles(shootvec:Angle())
			bullet:SetPos(selfpos+shootvec)
			bullet:Spawn()
			bullet:Activate()
			bullet.tracehitang=bullet:GetAngles()
			bullet.Owner = act or self.Owner
			bullet.StartTime=1
			bullet.ConTable=table.Copy(self.ConTable)
			self.Rocket=bullet
			self.Sound:ChangeVolume(450)
			self.Sound:Play()
			if !bullet.phys then bullet.phys = bullet:GetPhysicsObject() end	
			if bullet.phys:IsValid() then
				bullet.phys:SetVelocity(self.Owner:GetVelocity()+shootvec*400)
			end
		end
		self.MagazineLoad=self.MagazineLoad-1
	end
end

function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)	
end

function ENT:Think()
	local crt=CurTime()
	if self.ConTable["mode"][2]==1 then
		if ValidEntity(self.Rocket) then
			self.Rocket.targetpos=util.QuickTrace(self:GetPos(),self:GetAngles():Up()*9999999,self.Entity).HitPos
		end
	end
	if self.SoundStop<=crt then
		self.Sound:Stop()
	end
	if self.Inputs["Fire"].Value>=1 then
		self:FireGun()
	end
	if self.MagazineLoad==0 and crt>self.NextShoot-self.ConTable["reloadtime"][2]/2 and !self.SoundPlayed then
		self.SoundPlayed=true
		self.Entity:EmitSound(self.ConTable["soundReload"][2], 300)
	end
	if self.MagazineLoad==0 and crt+self.ConTable["reloadtime"][2]>self.NextShoot then
		self.MagazineLoad=self.ConTable["msize"][2]
		self.NextShoot=CurTime()+self.ConTable["reloadtime"][2]
	end
	if ValidEntity(self.Vehicle) and self.Vehicle:GetPassenger():IsValid() then
		if self.Vehicle:GetPassenger():KeyDown(IN_ATTACK) then
			self:FireGun(self.Vehicle:GetPassenger())
		end
	end
	Wire_TriggerOutput(self.Entity, "Ammo", self.MagazineLoad)
	Wire_TriggerOutput(self.Entity, "CanFire", (self.NextShoot<crt and self.MagazineLoad>0) and 1 or 0)
	self:NextThink(crt)
	return true
end

function ENT:BuildDupeInfo()
	local info = WireLib.BuildDupeInfo(self.Entity) or {}
	if (self.Vehicle) and (self.Vehicle:IsValid()) then
		info.v = self.Vehicle:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo(ply, ent, info, GetEntByID)
	if (info.v) then
		self.Vehicle = GetEntByID(info.v)
		if (!self.Vehicle) or self.Vehicle != GetEntByID(info.v) then
			self.Vehicle = ents.GetByIndex(info.v)
		end
	end
end

local function FireGun(p, e)
	if !e or !e:IsValid() then return end
	e.Inputs["Fire"].Value=1
end
numpad.Register("fireGun", FireGun)

local function stopFire(p, e)
	if !e or !e:IsValid() then return end
	e.Inputs["Fire"].Value=0
end
numpad.Register("stopFire", stopFire)

function ENT:OnRemove()
	self.Sound:Stop()
end