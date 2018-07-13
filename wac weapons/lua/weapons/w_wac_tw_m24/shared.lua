SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Category			=wac.menu.category

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.PrintName		= "M24"

SWEP.AimAng			= Angle(0,0,0)
SWEP.AimPos			= Vector(-3, -5, 1.92)
SWEP.RunPos			= Vector(-5,0,1)
SWEP.ZoomStages		= {15, 5}
SWEP.ViewPunch		= 5

SWEP.Slot				= 3
SWEP.IconLetter		= "z"

SWEP.ViewModel		= "models/weapons/v_lazr_scout.mdl"
SWEP.WorldModel		= "models/weapons/w_lazr_scout.mdl"
SWEP.ViewModelFlip		= true
SWEP.SendShootAnim	= true
SWEP.FakeUnzoom		= true
SWEP.ReZoomTime		= 1.2
SWEP.SendZoomedAnim	= true
SWEP.ZoomOverlay		= "weltensturm/scopeoverlay_1"

SWEP.Primary.Sound		= Sound("weapons/turboscout/scout_fire-1.wav")
SWEP.Primary.Damage	= 100
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone		= 0.0001
SWEP.Primary.Delay		= 1.3
SWEP.Primary.Recoil		= 1.7

SWEP.Primary.ClipSize	= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo		= "sniperround"