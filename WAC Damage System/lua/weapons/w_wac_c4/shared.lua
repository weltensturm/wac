SWEP.Base = "w_wac_base"

SWEP.Category				= wac.menu.category .. " Weapons"

if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
end

if CLIENT then
	SWEP.PrintName = "C4"
	SWEP.Slot = 0
	SWEP.SlotPos = 9
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = false
	language.Add("StriderMinigun_ammo","C4")
end

SWEP.Purpose = "Explode shit"
SWEP.Instructions = "Left click to place C4, right click to detonate it"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.CanZoom = false
 
SWEP.ViewModel = "models/WeltEnSTurm/Weapons/c4_v.mdl"
SWEP.WorldModel = "models/WeltEnSTurm/bf2/c4.mdl"
SWEP.ViewModelFlip=false
 
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "StriderMinigun"
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.c4table = {}

SWEP.Boomsound = "C4/C4_deploy_1p.wav"

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
	if SERVER then
		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then		
			local pos = self.Owner:EyePos()
			local fwd = self.Owner:GetAimVector()
			local ang = fwd:Angle()
				local C4 = ents.Create("wac_c4")
					C4:SetPos((pos-Vector(0,0,10))+fwd*30)
					ang:RotateAroundAxis(ang:Right(),90)
					C4:SetAngles(ang)
					C4:Spawn()
					C4:Activate()
					C4.phys = C4:GetPhysicsObject()
					C4.phys:SetVelocity(self.Owner:GetAimVector()*250+Vector(0,0,80))
					C4.Owner = self.Owner
					C4.Weapon = self.Weapon			
				table.insert(self.c4table,C4)		
			self.Weapon:SetNextPrimaryFire(CurTime()+1)
			self.Weapon:TakePrimaryAmmo(1)	
		else	
			self.Weapon:SetNextPrimaryFire(CurTime()+2)
			return
		end		
		return true
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		for _,c4 in pairs(self.c4table) do		
			timer.Simple(0.1,function()
				if c4:IsValid() then 
					c4:Explode() 
				end 
			end)	
		end	
		self.Owner:EmitSound(self.Boomsound)
	end
end
