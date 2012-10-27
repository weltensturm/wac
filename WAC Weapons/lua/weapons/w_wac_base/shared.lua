
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.HoldType			= "smg"

SWEP.PrintName			= "MP5"
SWEP.Category				= WAC.Names.WeaponCategory.CSS
SWEP.Author				= WAC.Names.Author
SWEP.Instructions			="Shoot stuff with  LMB. Reload with R.\nUse Ironsights/Scope with RMB.\nHold R to holster weapon and grab stuff with E."
SWEP.Slot					= 2

SWEP.ViewModel			= "models/weapons/v_smg_mp5.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mp5.mdl"
SWEP.AimPos				= Vector(4.74, -3.97, 1.71)
SWEP.AimAng				= Angle(-1.32,0,0)
SWEP.RunAng				= Angle(15, -50, 0)
SWEP.RunPos				= Vector(-5,-1,2)
SWEP.ZoomSpeed			= {x=20, y=20, z=20}
SWEP.CanReload			= false
SWEP.CanZoom				= true
SWEP.zoomStart			= 20
SWEP.zoomEnd				= false
SWEP.zoomAdd				= 0
SWEP.FakeZoomStart		= 0
SWEP.FakeZoomEnd		= 0

SWEP.SaveAmmo			= false --if you reload, magazine gets lost
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.ViewModelFlip 		= true
SWEP.ShootReZoom			= false
SWEP.SendShootAnim		= true
SWEP.Sway				= 0.1
SWEP.ReZoomTime			= 0.5
SWEP.ReZoomStart			= 0.1
SWEP.ViewPunch			= 0.5

SWEP.MinLerp				= 0
SWEP.MaxLerp				= 0.6

SWEP.Primary.Sound		= Sound("Weapon_MP5Navy.Single")
SWEP.Primary.Damage		= 10
SWEP.Primary.NumShots	= 1
SWEP.Primary.Recoil		= 0.2
SWEP.Primary.Cone			= 0.001
SWEP.Primary.Delay		= 0.1
SWEP.Primary.Automatic	= false

SWEP.SendZoomedAnim		= false
SWEP.BackPushY			= -0.2
SWEP.BackPushZ			= 0.1
SWEP.BackPushNY			= -1
SWEP.BackPushNZ			= 0.4

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "smg1"

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.AngM		=.01
SWEP.AngMax		=50
SWEP.AngMz		=0.001
SWEP.AngMaxz		=5

SWEP.wac_swep_alt		= true
SWEP.VMPosMax			= Vector(3, 0, 5)
SWEP.VMPosM				= Vector(0.08, 0.08, 0.08)*0.35
SWEP.VMPosMz			= Vector(0.08, 0.08, 0.08)*0.2
SWEP.VMPosOffset			= Vector(0,0,0)
SWEP.VMPosD				= Vector(0.15, 0.15, 0.15)
SWEP.VMPosDz			= Vector(0.16, 0.16, 0.16)*2
SWEP.VMPosMaxz			= Vector(4, 0, 4)
SWEP.VMAngM				= Vector(0.4, 0.4, 0)*0
SWEP.VMAngMax			= Vector(0, 0, 0)
SWEP.VMPosAdd 			= Vector(0,0,0)
SWEP.VMAngAdd 			= Angle(0,0,0)
SWEP.VMAngAddO		 	= Angle(0,0,0)
SWEP.MuzzleFlashAdd		= WAC.WeaponLib.NormalMuzzle
SWEP.NextRecoil			= 0
SWEP.NextHolster			= 0
SWEP.NextShoot			= 0
SWEP.NextZoomed			= 0
SWEP.NextZoom			= 0
SWEP.ReloadStart			= 0

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end
	
function SWEP:CustomAttack()
	return false
end

function SWEP:CustomThink()
	return false
end

function SWEP:CustomReload()
	return false
end

function SWEP:OnRestore()
	self.NextHolster=0
	self.NextZoom=0
	self.NextRecoil=0
	self:DoHolster(false)
	self.Weapon:SetNextPrimaryFire(CurTime()+1)
	self:Think()
end

function SWEP:Muzzle()
	if !IsValid(self.Owner) then return end
	local fx = EffectData()
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetEntity(self.Owner)
	fx:SetAngle(Angle(255,200,120))
	fx:SetRadius(24)
	util.Effect("ins_muzzle",fx,true)
end

function SWEP:Reload()
end

function SWEP:DoReload()
	if self:Holstered() or self.NextHolster>CurTime() or self.Owner:KeyDown(IN_RELOAD) or self.Reloading or self:CustomReload() then return end
	if self:DefaultReload(ACT_VM_RELOAD) then
		if !self.SaveAmmo then
			self.Weapon:SetClip1(0)
		end
		self.NextHolster=CurTime()+2
		self:SetNextPrimaryFire(CurTime()+2)
		self.Reloading=true
		self.ReloadStart=CurTime()
	end
end

function SWEP:DoHolster(b)
	if b==nil then b=!self:Holstered() end
	local CrT=CurTime()
	if self.NextHolster<=CrT then
		if SERVER and self.Holstered(self) != b then
			self.Owner:SetNWBool("NDS_Holstered", b)
			self:SetWeaponHoldType((b)and("normal")or(self.Weapon.HoldType))
			self.Owner:DrawWorldModel(!b)
			self.Owner:EmitSound("weapons/sniper/sniper_zoomout.wav")
		end
		self.NextHolster=CrT+1
		return true
	end
end

function SWEP:CanAct()
	if self:Holstered() or WAC.Sprinting(self.Owner) or (SERVER and self.NextHolster>CurTime()) then return false end
	return true
end

function SWEP:Think()
	if CLIENT then self:CLThink() end
	if self:CustomThink() or !self.Owner then return end
	if self.Owner:KeyDown(IN_RELOAD) then
		local CrT=CurTime()
		self.HolsterTime=self.HolsterTime or CrT
		if self.HolsterTime+0.5<CrT then
			if self:DoHolster() then self.HolsterTime=nil end
		end
	elseif self.HolsterTime then
		self:DoReload()
		self.HolsterTime=nil
	end
	if self.Reloading and self:Clip1()>0 and self.ReloadStart+1<CurTime() then
		self.Reloading=false
		if !self.IsShotgun then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end
	local vmang = self.Owner:GetAimVector():Angle()
	if SERVER then
		if self:Holstered() then
			if self.Owner:KeyDown(IN_USE) then
				local trd={}
				trd.start=self.Owner:EyePos()
				local dist=100
				trd.endpos=trd.start+self.Owner:GetAimVector()*dist
				trd.filter=self.Owner
				local tr=util.TraceLine(trd)
				if tr.Hit and !self.TrEntity then
					self.TrEntity=tr.Entity
					self.TrEntity.WeaponHoldPos=self.TrEntity.WeaponHoldPos or self.TrEntity:WorldToLocal(tr.HitPos)
					self.TrEntity.WeaponHoldDistance=trd.start:Distance(tr.HitPos)
				end
				if self.TrEntity and IsValid(self.TrEntity) and self.TrEntity.WeaponHoldPos then
					local pos=self.TrEntity:LocalToWorld(self.TrEntity.WeaponHoldPos)
					dist=self.TrEntity.WeaponHoldDistance
					if pos:Distance(trd.start)>120 then
						self.TrEntity.WeaponHoldPos=nil
						self.TrEntity=nil
					else
						local ph=self.TrEntity:GetPhysicsObject()
						if ph and ph:IsValid() then
							ph:ApplyForceOffset((self.TrEntity:GetVelocity()*-0.1+trd.start+tr.Normal*dist-pos)*200*math.Clamp(300-ph:GetMass(),0,250)/300*math.Clamp(ph:GetMass()-1,0.1,15)/15, pos)
							ph:AddAngleVelocity(ph:GetAngleVelocity()*-0.1)
						end
					end
				end
			elseif self.TrEntity then
				self.TrEntity.WeaponHoldPos=nil
				self.TrEntity=nil
			end
		end
	end
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:DoHolster(false)
	self.NextHolster=CurTime()+1.1
	self:SetNextPrimaryFire(CurTime()+1.1)
	return true
end

function SWEP:Holster()
	self.CanReload=false
	self.Reloading=false
	return true
end

function SWEP:Holstered(s)
	self=self or s
	return self.Owner:GetNWBool("NDS_Holstered") or self.Owner:GetMoveType() == MOVETYPE_LADDER
end

function SWEP:Zoomed()
	local CrT=CurTime()
	if self.CanZoom and self.Owner:KeyDown(IN_ATTACK2) and !WAC.Sprinting(self.Owner) and !self:Holstered() and !self.Reloading and !(self.FakeZoomStart<CrT and self.FakeZoomEnd>CrT) then return true end
	return false
end

function SWEP:SecondaryAttack()
end

