SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName			= "M4"

SWEP.Category				= wac.menu.category .. " Modern Warfare"

SWEP.AimAng				= Angle(-0.25, 0, 0)
SWEP.AimPos				= Vector(2.37,-2.43,0.44)
SWEP.RunPos				= Vector(-5,2,0)
SWEP.VMPosM				= Vector(0.08, 0.05, 0.05)*0.2
SWEP.VMPosMz			= Vector(0.08, 0.05, 0.05)*0.1

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_erc_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"
SWEP.ViewModelFlip		= true

SWEP.Primary.Sound		= Sound( "weapons/weapon_m4a1/m4a1-1.wav" )
SWEP.Primary.Damage		= 14
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.005
SWEP.Primary.Delay		= 0.1
SWEP.Primary.Recoil		= 0.3

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "smg1"

SWEP.BackPushY			= -0.3
SWEP.BackPushZ			= 0.03

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.AngMz		=0.0001

SWEP.MuzzleFlashAdd 		= wac.weapons.muzzle.star