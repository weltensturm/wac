SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Category				=WAC.Names.WeaponCategory.TW

SWEP.PrintName			= "M14"

SWEP.AimAng				= Angle(0.25,0,0)
SWEP.AimPos				= Vector(-5.06, -6, 2.6)

SWEP.VMPosMz			= Vector(0,0,0)
SWEP.VMPosDz			= Vector(0.5, 0.5, 0.5)
SWEP.VMPosMaxz			= Vector(0, 0, 0)
SWEP.Sway				= 0.01

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.SendZoomedAnim		= false

SWEP.ViewModel			= "models/weapons/v_rif_m1444.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m1444.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Sound		= Sound("weapons/galil/m14-1.wav")
SWEP.Primary.Damage		= 12
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay		= 0.14
SWEP.Primary.Recoil		= 0.6

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20

SWEP.BackPushY			= -0.5
SWEP.BackPushZ			= 0.01

SWEP.MuzzleFlashAdd 		= WAC.WeaponLib.StarMuzzle