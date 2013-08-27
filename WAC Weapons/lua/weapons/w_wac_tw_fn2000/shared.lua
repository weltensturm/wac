SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Category				=wac.menu.category .. " Tactical Weapons"

SWEP.PrintName			= "F2000"

SWEP.AimAng				= Angle(0.23, 0, 0)
SWEP.AimPos				= Vector(3.6, -2.62, 1)
--SWEP.RunPos				= Vector(-5,1,3)
SWEP.zoomStart			= 40
SWEP.zoomEnd				= 40
SWEP.ZoomOverlay			= "weltensturm/weapons/scope/scope01"

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_fnf2000.mdl"
SWEP.WorldModel			= "models/weapons/w_fnf2000.mdl"
SWEP.ViewModelFlip		= true
SWEP.SendShootAnim		= true
SWEP.FakeUnzoom			= false
SWEP.SendZoomedAnim		= false

SWEP.SendZoomedAnim		= false

SWEP.Primary.Sound		= Sound("weapons/F2000/f2000_fire.wav")
SWEP.Primary.Damage		= 14
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay		= 0.08
SWEP.Primary.Recoil		= 0.35

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "smg1"

SWEP.BackPushY			= -0.8
SWEP.BackPushZ			= 0.09

SWEP.MuzzleFlashAdd 		= wac.weapons.muzzle.star