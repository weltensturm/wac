
if SERVER then
	AddCSLuaFile("shared.lua")	
end

SWEP.HoldType			= "normal"

SWEP.Base 				= "w_wac_base"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Category				= wac.menu.category

SWEP.PrintName			= "Hands"
SWEP.Instructions			= "Grab stuff with E"

SWEP.AimAng				= Angle(0,0,0)
SWEP.AimPos				= Vector(0,0,0)
SWEP.RunAng				= Angle(0,0,0)
SWEP.RunPos				= Vector(0,0,0)

SWEP.Slot					= 0

SWEP.ViewModelFOV		= 47
SWEP.ViewModel			= ""
SWEP.WorldModel			= ""

SWEP.Primary.Sound		= Sound(0)
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots	= 0
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay		= 0
SWEP.Primary.Recoil		= 0

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.Size		= 1
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:CustomReload()
	return true
end

function SWEP:Holstered()
	return true
end
