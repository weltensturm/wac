SWEP.Base = "w_wac_base_shot"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Category				=WAC.Names.WeaponCategory.CSS

SWEP.PrintName			= "M3"

SWEP.AimAng				= Angle(-0.08, 0, 0)
SWEP.AimPos				= Vector(5.72, -2.62, 3.06)

SWEP.Slot					= 2
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_shot_m3super90.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_m3super90.mdl"
SWEP.ViewModelFlip		= true
SWEP.FakeUnzoom			= true
SWEP.ReZoomTime			= 0.8
SWEP.ReZoomStart			= 0.2
SWEP.SendZoomedAnim 	= true

SWEP.Primary.Sound		= Sound("weapons/m3/m3-1.wav")
SWEP.Primary.Damage		= 12
SWEP.Primary.NumShots	= 12
SWEP.Primary.Cone			= 0.06
SWEP.Primary.Delay		= 1.1
SWEP.Primary.Recoil		= 1.5
SWEP.ReloadDelay			= 0.6
SWEP.EndReload			= 1.2
SWEP.ViewPunch			= 3

SWEP.Primary.FinalPump	= ""
SWEP.Primary.InsertBuck	= ""

SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic	= true

SWEP.BackPushY			= -1
SWEP.BackPushZ			= 0.05