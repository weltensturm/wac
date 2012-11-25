SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile("shared.lua")	
end

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName			= "AK47"

SWEP.AimAng				= Angle(-2.94, 0, 0)
SWEP.AimPos				= Vector(6.08, -5, 1.85)

SWEP.Slot				= 2
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak47.mdl"
SWEP.ViewModelFlip		= true

SWEP.Primary.Sound		= Sound("Weapon_AK47.Single")
SWEP.Primary.Damage		= 12
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone		= 0.01
SWEP.Primary.Delay		= 0.13
SWEP.Primary.Recoil		= 0.2

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"

SWEP.BackPushY			= -0.5
SWEP.BackPushZ			= 0.1
