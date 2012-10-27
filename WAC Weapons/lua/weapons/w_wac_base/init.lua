
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true


SWEP.BulletTable={
	Num=1,
	Spread=Vector(0,0,0),
	Tracer=0,
	TracerName="Tracer",
}


if SERVER then
	function SWEP:PrimaryAttack()
		if self:CustomAttack() then return end
		if !self:CanPrimaryAttack() or !self:CanAct() then return end
		self.NextShoot=CurTime()+self.Primary.Delay
		self.Owner:EmitSound(self.Primary.Sound or "")
		WAC.CreatePhysBullet(self.Owner:GetShootPos(), self.Owner:GetAimVector(), self.Primary.Damage, 400, self.Primary.Cone, self.Owner, self.Primary.NumShots, self.BulletTable)
		self:CallOnClient("AddRecoil", "")
		self:Muzzle()
		self.Owner:ViewPunch(Angle((self:Zoomed() and -self.ViewPunch/10 or -self.ViewPunch), 0, 0))
		if ((!self:Zoomed() or self.SendZoomedAnim) and self.SendShootAnim) then
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		end
		self:TakePrimaryAmmo(1)
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self.Weapon:SetNextSecondaryFire(CurTime()+0.5)
	end
end
