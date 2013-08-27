SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
end

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Category				= wac.menu.category .. " Modern Warfare"

SWEP.PrintName			= "Cheytac Intervention"

SWEP.AimAng				= Angle(0,0,0)
SWEP.AimPos				= Vector(3.46,-3.27,0.3)
SWEP.RunPos				= Vector(-5,2,1)
SWEP.zoomStages			= {45, 60, 65}
SWEP.zoomStart			= 45
SWEP.zoomEnd				= 67
SWEP.ViewPunch			= 5

SWEP.Slot					= 3
SWEP.IconLetter			= "z"

SWEP.ViewModel			= "models/weapons/v_eric_scout.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_sg550.mdl"
SWEP.ViewModelFlip			= true
SWEP.SendShootAnim		= true
SWEP.FakeUnzoom			= false
SWEP.SendZoomedAnim		= false
SWEP.AddZ				= -1
SWEP.ZoomOverlay			= "weltensturm/scopeoverlay_1"

SWEP.Primary.Sound			= Sound( "weapons/weapon_intervention/scout_fire-1.wav" )
SWEP.Primary.Damage		= 100
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001
SWEP.Primary.Delay			= 1.5
SWEP.Primary.Recoil			= 1

SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip		= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "sniperround"