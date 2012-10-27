
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('entities/base_wire_entity/init.lua')
include("shared.lua")

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/w_irifle.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
    self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
    self.Entity:SetSolid( SOLID_VPHYSICS )
	self.phys = self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake();
	end
	self:AddLauncher(self.Entity)
	self.Reloaded = true
	self.Inputs = Wire_CreateInputs( self.Entity, {"Fire"} )
	self.Reloadtime = 5
	self.FireValue = 0
	
	self.ChargeSound = CreateSound(self.Entity,"weapons/cguard/charging.wav")
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 20
	local ent = ents.Create( "wac_w_cball" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply	
	return ent
	
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end

function ENT:TriggerInput(iname, value)
	if iname == "Fire" then
		if value >= 1 then
			self:FireGun()
		end
		self.FireValue = value
	end
end

function ENT:AddLauncher(selfent)

	local e = ents.Create("point_combine_ball_launcher")
	e:SetKeyValue("minspeed",3000)
	e:SetKeyValue("maxspeed",3000)
	e:SetKeyValue("origin", tostring(self:GetPos()))
	e:SetKeyValue("ballcount",3000)
	e:SetKeyValue("spawnflags",2)
	e:SetKeyValue("ballradius",20)
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetUp(), 180)
	e:SetAngles(ang)
	e:SetParent(selfent)
	selfent.CanFire = true
	self.Launcher = e
	
end

function ENT:OnRemove()
	self.ChargeSound:Stop()
end

function ENT:FireGun()

	if self.CanFire then
		self.ChargeSound:Play()
		timer.Simple(0.8, function() if !self.Entity or !self.Entity:IsValid() then return end
			self.ChargeSound:Stop()
			self.Entity:EmitSound("weapons/Irifle/irifle_fire2.wav")
			self.Launcher:Fire("LaunchBall")
		end)
		self:SetNextFire(1.4)
	end
	
end

function ENT:Use(a,c)

	self:FireGun()

end

function ENT:SetNextFire(t)
	self.CanFire = false
	timer.Simple(t, function()
		if self.Entity and self.Entity:IsValid() then
			self.CanFire = true
			if self.FireValue >= 1 then
				self:FireGun()
			end
		end
	end)
end

function ENT:OnTakeDamage( dmginfo )

	self.Entity:TakePhysicsDamage( dmginfo )
	
end
