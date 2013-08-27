
SWEP.Base = "w_wac_base"

SWEP.Category				= wac.menu.category .. " Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
 
SWEP.ViewModel = "models/WeltEnSTurm/Weapons/v_wrench.mdl"
SWEP.WorldModel = "models/WeltEnSTurm/Weapons/w_wrench.mdl"
SWEP.ViewModelFlip=false
 
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.CanZoom = false
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:PrimaryAttack()
	if SERVER then
		self:SVRepair()
	end
	return true
end

function SWEP:SecondaryAttack()	
	if SERVER then
		self:SVAddCombat()
	end
	return true
end
