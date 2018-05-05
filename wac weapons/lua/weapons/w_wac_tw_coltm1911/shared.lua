SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Category				=wac.menu.category .. " Tactical Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName			= "Colt M1911"

SWEP.AimAng				= Angle(-0.08, 0, 0)
SWEP.AimPos				= Vector(-2.83, 2, 1.33)
SWEP.RunAng				= Angle(20, -0, 0)
SWEP.RunPos				= Vector(0,0,0)

SWEP.Slot					= 1
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_pistcolt1911.mdl"
SWEP.WorldModel			= "models/weapons/w_pistcolt1911.mdl"
SWEP.ViewModelFlip		= true
SWEP.SendShootAnim		= true
SWEP.SendZoomedAnim		= true

SWEP.Primary.Sound		= Sound("weapons/glock/colt-1.wav")
SWEP.Primary.Damage		= 10
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay		= 0.06
SWEP.Primary.Recoil		= 0.6

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo		= "pistol"

SWEP.BackPushY			= -1
SWEP.BackPushZ			= 0.23
