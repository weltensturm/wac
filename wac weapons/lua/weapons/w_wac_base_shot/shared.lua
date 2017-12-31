SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")
	SWEP.HoldType		= "shotgun"
end

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName			= "M1014"

SWEP.Slot					= 2
SWEP.IconLetter			= "k"

SWEP.ViewModel			= "models/weapons/v_shot_xm1014.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_xm1014.mdl"
SWEP.ViewModelFlip		= true

SWEP.AimAng				= Angle(0, -0.9, 0)
SWEP.AimPos				= Vector(5.19, -4.58, 2.17)

SWEP.Primary.Sound		= Sound("Weapon_XM1014.Single")
SWEP.Primary.Damage		= 6
SWEP.Primary.NumShots	= 9
SWEP.Primary.Recoil		= 1.5
SWEP.Primary.Delay		= 0.3
SWEP.Primary.EndReload	= 0.3
SWEP.Primary.Cone			= 0.05
SWEP.Primary.ClipSize		= 10
SWEP.Primary.DefaultClip	= 64
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "buckshot"
SWEP.Primary.InsertBuck	= ""
SWEP.Primary.FinalPump	= ""

SWEP.BackPushX			= -1
SWEP.BackPushZ			= 0.2
SWEP.BackPushNX			= -1
SWEP.BackPushNZ			= 1
SWEP.ViewPunch			= 3

SWEP.ReloadDelay			= 0.4
SWEP.AbortReload			= false
SWEP.LastReload			= 0
SWEP.LastPumpTime		= 0

SWEP.IsShotgun			= true

function SWEP:CustomReload()
	if self.LastReload+1>CurTime() then return true end
	self.LastReload=CurTime()
	if self.CanReload then return true end
 	if self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
 		self.CanReload = true
 		self.nextReload = CurTime() + self.ReloadDelay + 0.1
		self.Weapon:SetNextPrimaryFire(CurTime() + 9999)
 		self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
 	end
	return true
end

function SWEP:CustomAttack()
	return false
end

function SWEP:CustomThink()
	if CLIENT then return false end
	if self.LastPumpTime!=0 and self.LastPumpTime<CurTime() then
		self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		self.Owner:EmitSound(self.Primary.FinalPump)
		self.Weapon:SetNextPrimaryFire(CurTime()+self.Primary.EndReload)
		self.LastPumpTime=0
		self.Reloading=false
		self.CanReload=false
		self.NextIdle=CurTime()+self.Owner:GetViewModel():SequenceDuration()
		self.Owner:GetViewModel():SequenceDuration()
	end
	if self.NextIdle and self.NextIdle<=CurTime() then
		self:SendWeaponAnim(ACT_VM_IDLE)
		self.NextIdle=nil
	end
	if self.CanReload then
		self.Reloading = true
		if (self.Owner:KeyDown(IN_ATTACK) and self.Weapon:Clip1() > 0) then
			self.AbortReload = true
		end
		if (self.nextReload or 0) < CurTime() then
			if self.Primary.ClipSize <= self.Weapon:Clip1() or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
				self.CanReload = false
				return false
			end
			self.nextReload = CurTime() + self.ReloadDelay
			self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
			self.Owner:EmitSound(self.Primary.InsertBuck)
			self.Owner:RemoveAmmo(1, self.Primary.Ammo, false)
			self.Weapon:SetClip1(self.Weapon:Clip1()+1)
			if self.Primary.ClipSize <= self.Weapon:Clip1() or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 or self.AbortReload then
				self.CanReload = false
				self.AbortReload = false
				self.nextReload = CurTime()+self.ReloadDelay + self.Primary.EndReload
				self.LastPumpTime=CurTime()+self.ReloadDelay
			end
		end
	elseif (self.nextReload or 0) + 0.1 < CurTime() and self.Reloading then
		self.Reloading = false
	end
	return false
end
