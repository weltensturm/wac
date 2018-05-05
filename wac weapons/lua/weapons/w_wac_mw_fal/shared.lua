SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Category				= wac.menu.category

SWEP.PrintName			= "FN FAL"

SWEP.AimAng				= Angle(1,0,0)
SWEP.AimPos				= Vector(-1.88, -1.5, 1.15)
SWEP.RunPos				= Vector(-4,1.5,-1)

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.SendZoomedAnim		= false

SWEP.ViewModel			= "models/weapons/v_erc_galil.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_galil.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Sound		= Sound("weapons/weapon_fal/galil-1.wav")
SWEP.Primary.Damage		= 11
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay		= 1/(700/60)
SWEP.Primary.Recoil		= 1
SWEP.Primary.Automatic	= true

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20

SWEP.BackPushY			= -0.2
SWEP.BackPushZ			= 0.01

SWEP.MuzzleFlashAdd 		= wac.weapons.muzzle.star
