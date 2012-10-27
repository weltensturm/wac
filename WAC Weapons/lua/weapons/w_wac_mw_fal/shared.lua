SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Category				= WAC.Names.WeaponCategory.MW

SWEP.PrintName			= "FN FAL"

SWEP.AimAng				= Angle(1,0,0)
SWEP.AimPos				= Vector(-1.88,-1.65,1.17)
SWEP.RunPos				= Vector(-4,1.5,1)
SWEP.VMPosM				= Vector(0.08, 0.05, 0.05)*0.2
SWEP.VMPosMz			= Vector(0.08, 0.05, 0.05)*0.1
SWEP.VMPosOffset			= Vector(1.5,0,0)

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.SendZoomedAnim		= false

SWEP.ViewModel			= "models/weapons/v_erc_galil.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_galil.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Sound		= Sound("weapons/weapon_fal/galil-1.wav")
SWEP.Primary.Damage		= 30
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.005
SWEP.Primary.Delay		= 0.1
SWEP.Primary.Recoil		= 0.6
SWEP.Primary.Automatic	= false

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20

SWEP.BackPushY			= -0.3
SWEP.BackPushZ			= 0.05

SWEP.MuzzleFlashAdd 		= WAC.WeaponLib.StarMuzzle