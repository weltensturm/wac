SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName			= "AK47"

SWEP.Category				= wac.menu.category .. " Modern Warfare"

SWEP.AimAng				= Angle(0,0.21,0)
SWEP.AimPos				= Vector(4.4,-7,1.17)
SWEP.RunPos				= Vector(-6,0,2)

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_erc_ak47.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak47.mdl"
SWEP.ViewModelFlip		= true

SWEP.Primary.Sound		= Sound( "weapons/weapon_ak47/ak47-1.wav" )
SWEP.Primary.Damage		= 16
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.005
SWEP.Primary.Delay		= 0.13
SWEP.Primary.Recoil		= 0.4

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "smg1"

SWEP.BackPushY			= -0.35
SWEP.BackPushZ			= 0.05

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.AngMz		=0.0001

SWEP.MuzzleFlashAdd 		= wac.weapons.muzzle.star