
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName			= "MP5"
SWEP.Category				= "Metroid"
SWEP.Author				= "WeltEnSTurm"

SWEP.Slot					= 2

SWEP.ViewModel			= "models/WeltEnSTurm/weapons/v_powerbeam.mdl"
SWEP.WorldModel			= "models/WeltEnSTurm/weapons/w_powerbeam.mdl"
SWEP.MinLerp				= 0
SWEP.MaxLerp				= 0.4

SWEP.DrawAmmo			= false
SWEP.DrawCrosshair			= false
SWEP.ViewModelFlip 			= false
SWEP.DrawCustomCrosshair	= true

SWEP.Sounds={
	Attack1="mp2/pb_shoot1.wav",
	Attack2=""
}

SWEP.Primary.Damage		= 10
SWEP.Primary.NumShots		= 1
SWEP.Primary.Recoil			= 0.5
SWEP.Primary.Cone			= 0.001
SWEP.Primary.Delay			= 0.11

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip		= 1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.NDSMember			= true
SWEP.Shots				= 0

if SERVER then
	AddCSLuaFile("cl_init.lua")
	SWEP.HoldType = "shotgun"
end

function SWEP:Initialize()
	if SERVER then
		self:SetWeaponHoldType(self.HoldType)
		timer.Simple(1, function()
			local fx=EffectData()
			fx:SetOrigin(self:GetPos())
			fx:SetEntity(self.Owner)
			util.Effect("metroid_muzzle", fx)
		end)
	else
		self.Muzzle={
			Shots=0,
			Alpha=0,
		}
	end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if self.Shots < 3 then
		if SERVER then
			self:ShootBullets()
		end
		if CLIENT then
			self:Muzzle(1)
		end
		self.Weapon:EmitSound(self.Sounds.Attack1)
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self.Owner:MuzzleFlash()
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Shots=self.Shots+1
	else
		if self.Shots<7 then
			self.Shots=self.Shots+1
		end
	end
end

function SWEP:Reload()
end

function SWEP:ShootBullets()
	local AimVec = self.Owner:GetAimVector()
	local addp=self.Owner:GetRight()*5+self.Owner:GetUp()*-3
	--				pos					dir		power					wep		owner
	CreateMetroidBullet(self.Owner:EyePos()+addp, AimVec, math.Clamp(self.Shots-4, 1, 10), self.Weapon, self.Owner)
	umsg.Start("m_recoil", self.Owner)
	umsg.End()
end

function SWEP:Think()
	if SERVER then
		self:SetNWInt("shots", self.Shots)
	end
	if self.Shots>0 and self.Shots<=4 and !self.Owner:KeyDown(IN_ATTACK) then
		self.Shots=0
	elseif self.Shots>4 and !self.Owner:KeyDown(IN_ATTACK) then
		if SERVER then
			self:ShootBullets()
		end
		self.Shots=0
		self.Weapon:EmitSound(self.Sounds.Attack2)
	end
end

function SWEP:SecondaryAttack()
end
