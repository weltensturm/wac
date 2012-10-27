SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Category				=WAC.Names.WeaponCategory.TW

SWEP.PrintName			= "G36"

SWEP.AimAng				= Angle(0.23, 0, 0)
SWEP.AimPos				= Vector(3.6, -2.62, 0.51)
--SWEP.RunPos				= Vector(-5,1,3)

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_rif_g36.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_g36.mdl"
SWEP.ViewModelFlip		= true

SWEP.SendZoomedAnim		= false

SWEP.Primary.Sound		= Sound("RL_SW/g36_1.wav")
SWEP.Primary.Damage		= 14
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay		= 0.08
SWEP.Primary.Recoil		= 0.35

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "smg1"

SWEP.BackPushY			= -0.4
SWEP.BackPushZ			= 0.03

SWEP.MuzzleFlashAdd 		= WAC.WeaponLib.StarMuzzle