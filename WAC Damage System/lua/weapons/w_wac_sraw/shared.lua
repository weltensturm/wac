SWEP.Base = "w_wac_base"

SWEP.Category			= wac.menu.category .. " Weapons"

if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType		= "rpg"
	SWEP.Weight			= 30
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= false
end

SWEP.AngM		=.01
SWEP.AngMax		=50
SWEP.AngMz		=10
SWEP.AngMaxz		=10

if  CLIENT then
	SWEP.PrintName = "SRAW";
	SWEP.Slot = 4;
	SWEP.SlotPos = 11;
	SWEP.DrawAmmo = true;
	SWEP.DrawCrosshair = false;
	SWEP.TraceArmor = 0
	language.Add("SniperPenetratedRound_ammo","Anti-Tank Rockets")
end

SWEP.Contact 			= "wat"
SWEP.Purpose 			= "Fight tanks on foot"
SWEP.Instructions 			= "Left click to spawn and activate a wire-steered rocket\nRight click to zoom"

SWEP.Primary.BulletNum	= 0
SWEP.reloaded 			= true
SWEP.Sound 				= "USATP_predator/fire_1p.wav"
SWEP.Reloadsound 		= "USATP_predator/eryx_reload_1p.wav"
SWEP.AimPos				= Vector(-3.7, -13, 4.44)
SWEP.AimAng				= Angle(0,0,0)
SWEP.RunAng			= Angle(20, -20, 0)
SWEP.RunPos				= Vector(0,0,0)
SWEP.zoomStages			={25}
SWEP.ViewModelFlip 		= false

SWEP.ViewModel = "models/WeltEnSTurm/Weapons/v_sraw.mdl"
SWEP.WorldModel   = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "SniperPenetratedRound"
 
function SWEP:CustomReload()
	if SERVER then
		if self.Owner:GetActiveWeapon() != self.Weapon then return true end
		if !self.reloaded and !self.reloading and (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
			self.rocket = nil
			self.Owner:EmitSound(self.Reloadsound)
			self.Weapon:SetNextPrimaryFire(CurTime() + 4.5)
			timer.Simple(3.8, function() self.reloaded = true self.reloading = false end)
		end
	end
	return true
end

function SWEP:CustomThink()
	if self.rocket then
		local pos = self.Owner:EyePos()
		local trace = {}
		trace.start = pos
		trace.endpos = pos + (self.Owner:GetAimVector():Angle()+self.VMAngAdd):Forward()*99999
		trace.filter = {self.rocket,self.Owner}
		local tr = util.TraceLine(trace)
		if tr.Hit then self.rocket.targetpos = tr.HitPos end
	end
	return false
end

function SWEP:CustomAttack()
	if SERVER then
		if self.reloading then return end
		if (self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) and !self.reloaded then self:CustomReload() return end
		if self.rocket then
			self.rocket.weapon=nil
			self.rocket=nil
		end
		local pos = self.Owner:EyePos()
		local ri = self.Owner:GetRight()
		local up = self.Owner:GetUp()
		local shootvec = (self.Owner:GetAimVector():Angle()+self.VMAngAdd*1.6):Forward()
		self.Owner:EmitSound(self.Sounds)		
		local bulletstartpos = Vector(0,0,0)		
		if self.Zoomed then
			bulletstartpos = pos + shootvec * 30 + ri * 5 + up * -2
		else
			bulletstartpos = pos + shootvec * 30 + ri * 15 + up * -20
		end		
		local bullet = ents.Create("wac_w_rocket")
		bullet:SetAngles(shootvec:Angle())
		bullet:SetPos(bulletstartpos)
		bullet.ConTable={
			["bulletspeed"]={0,100},
			["radius"]={0,100},
			["damage"]={0,100},
			["effect"]={0,"wac_tankshell_impact"},
		}
		bullet:Spawn()
		bullet:Activate()
		bullet.tracehitang = bullet:GetAngles()
		bullet.Owner = self.Owner
		bullet.StartTime = 1
		bullet.Team = self.Owner:Team()
		self.rocket = bullet
		self.rocket.weapon = self.Weapon
		if !bullet.phys then bullet.phys = bullet:GetPhysicsObject() end	
		if bullet.phys:IsValid() then
			bullet.phys:SetVelocity(self.Owner:GetVelocity()+shootvec*400)
		end
		self.Weapon:TakePrimaryAmmo(1)
		self.reloaded = false	
	end	
	return true
end
