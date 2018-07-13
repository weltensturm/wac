
SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Category				=wac.menu.category

SWEP.PrintName			= "M4 Aimpoint"

SWEP.AimAng				= Angle(1.21, 0, 0)
SWEP.AimPos				= Vector(-2.62, 3.79, 1.45)

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_scp_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_scp_m4a1.mdl"
SWEP.ViewModelFlip			= true

SWEP.Primary.Sound			= Sound("weapons/m4a1/m4a1_unsil-1.wav")
SWEP.Primary.Damage		= 12
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay			= 0.08
SWEP.Primary.Recoil			= 0.6

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip		= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.BackPushY			= -1
SWEP.BackPushZ			= 0.05

SWEP.MuzzleFlashAdd 		= wac.weapons.muzzle.star
