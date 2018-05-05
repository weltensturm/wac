include("shared.lua")

SWEP.zmBlack 	=0
SWEP.zmFull		=false

--Disable the default weapon movement
SWEP.SwayScale 	= 0
SWEP.BobScale 	= 0

function SWEP:PrimaryAttack()
	if self:CustomAttack() then return end
	if !self:CanPrimaryAttack() or !self:CanAct() then return end
	if ((!self:Zoomed() or self.SendZoomedAnim) and self.SendShootAnim) then
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime()+0.5)
end

function SWEP:AddRecoil()
	self.RecoilTime=CurTime()+0.1
	self:Muzzle()
	if self.FakeUnzoom then
		self.FakeZoomStart=CurTime()+self.ReZoomStart
		self.FakeZoomEnd=CurTime()+self.ReZoomTime
	end
end

local point=Material("sprites/light_glow02_add")
local color=Color(200, 50, 50, 255)
local cyclesound=Sound("Default.Zoom")

function SWEP:CLThink()
	if self.zmFull then
		if self.zoomBlack == 255 then
			self.Weapon:EmitSound(cyclesound)
		end
		if !self.ScopeModel then
			self.ScopeModel=ClientsideModel("models/weltensturm/weapons/v_scope01.mdl", RENDERGROUP_TRANSLUCENT)
			self.ScopeModel:Spawn()
		end
		self.zoomBlack = wac.smoothApproach(self.zoomBlack, 0, 30)
	else
		if self.ScopeModel then
			self.ScopeModel:Remove()
			self.ScopeModel=nil
		end
	end
end

function SWEP:DrawHUD()
	if self.zmFull then
		surface.SetDrawColor(0,0,0,self.zoomBlack)
		surface.DrawRect(0,0, ScrW(), ScrH())
	end
end
