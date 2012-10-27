SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Category				=WAC.Names.WeaponCategory.TW

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName			= "Ares Shrike"

SWEP.AimAng				= Angle(-0.28, 0, 0)
SWEP.AimPos				= Vector(-3.8, -1.21, 0.45)
SWEP.RunPos				= Vector(-5,0,2)

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_ares_shrikesb.mdl"
SWEP.WorldModel			= "models/weapons/w_ares_shrikesb.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Sound		= Sound("weapons/m249/m249-1.wav")
SWEP.Primary.Damage		= 12
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay		= 0.1
SWEP.Primary.Recoil		= 0.7
SWEP.ViewPunch			= 2

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "smg1"

SWEP.BackPushY			= -0.4
SWEP.BackPushZ			= 0.05
