SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName			= "M249 (Para)"

SWEP.AimAng				= Angle(0,0,0)
SWEP.AimPos				= Vector(-4.45,2.57,2.12)
SWEP.RunPos				= Vector(-5,0,2)

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_mach_m249para.mdl"
SWEP.WorldModel			= "models/weapons/w_mach_m249para.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Sound		= Sound("weapons/m249/m249-1.wav")
SWEP.Primary.Damage		= 12
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay		= 0.1
SWEP.Primary.Recoil		= 0.7
SWEP.ViewPunch			= 1

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "smg1"

SWEP.BackPushY			= -0.4
SWEP.BackPushZ			= 0.05
