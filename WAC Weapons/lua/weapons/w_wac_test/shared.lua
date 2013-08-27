SWEP.Base = "w_wac_base"

if SERVER then
	AddCSLuaFile ("shared.lua")	
	SWEP.HoldType			= "smg"
end

local TEST = {
	X=CreateClientConVar("wac_cl_wep_help_x", 4, true, false),
	Y=CreateClientConVar("wac_cl_wep_help_y", -2, true, false),
	Z=CreateClientConVar("wac_cl_wep_help_z", 2, true, false),
	Pitch=CreateClientConVar("wac_cl_wep_help_pitch", 0, true, false),
	Yaw=CreateClientConVar("wac_cl_wep_help_yaw", 0, true, false),
	Roll=CreateClientConVar("wac_cl_wep_help_roll", 0, true, false),
	M=CreateClientConVar("wac_cl_wep_help_model", "models/weapons/v_357.mdl", true, false),
	Flip=CreateClientConVar("wac_cl_wep_help_flip", 0, true, false),
	RX=CreateClientConVar("wac_cl_wep_help_rx", -5, true, false),
	RY=CreateClientConVar("wac_cl_wep_help_ry", -2, true, false),
	RZ=CreateClientConVar("wac_cl_wep_help_rz", 2, true, false),
	Rp=CreateClientConVar("wac_cl_wep_help_rap", 15, true, false),
	Ry=CreateClientConVar("wac_cl_wep_help_ray", -50, true, false),
	Rr=CreateClientConVar("wac_cl_wep_help_rar", 0, true, false),
	Sprint=CreateClientConVar("wac_cl_wep_help_sprint",0,true,false),
}

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.PrintName			= "Ironsight Positioner"

SWEP.Slot					= 2
SWEP.IconLetter			= "z"
SWEP.SendZoomedAnim		= false

function SWEP:CustomThink()
	if CLIENT then
		self.AimPos=Vector(TEST.X:GetFloat(), TEST.Y:GetFloat(), TEST.Z:GetFloat())
		self.AimAng=Angle(TEST.Pitch:GetFloat(), TEST.Yaw:GetFloat(), TEST.Roll:GetFloat())
		self.RunPos=Vector(TEST.RX:GetFloat(), TEST.RY:GetFloat(), TEST.RZ:GetFloat())
		self.RunAng=Angle(TEST.Rp:GetFloat(), TEST.Ry:GetFloat(), TEST.Rr:GetFloat())
		local t=self:GetTable()
		t.ViewModel=TEST.M:GetString()
		self.ViewModel=t.ViewModel
		LocalPlayer():GetViewModel():SetModel(t.ViewModel)
		self:SendWeaponAnim(ACT_VM_IDLE)
		self.ViewModelFlip=(TEST.Flip:GetInt()==1 and true or false)
	end
	return false
end

function SWEP:Zoomed()
	if !self.Owner:KeyDown(IN_ATTACK2) and !WAC.Sprinting(self.Owner) and TEST.Sprint:GetInt()==0 then
		return true
	end
end

SWEP.ViewModel			= TEST.M:GetString()
SWEP.WorldModel			= "models/weapons/w_shot_m3super90.mdl"
SWEP.AimPos				= Vector(4, 0, 2)
SWEP.ViewModelFlip		= false

SWEP.Primary.Damage		= 15
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone			= 0.004
SWEP.Primary.Delay		= 0.1
SWEP.Primary.Recoil		= 0
SWEP.SendZoomedAnim 	= true
SWEP.SendShootAnim		= true

SWEP.PushBackNY			= 0
SWEP.PushBackNZ			= 0

SWEP.Primary.ClipSize		= 101
SWEP.Primary.DefaultClip	= 400
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "smg1"

local function Print()
	local s=("SWEP.AimPos=Vector("..TEST.X:GetFloat()..","..TEST.Y:GetFloat()..","..TEST.Z:GetFloat()..")\nSWEP.AimAng=Angle("..TEST.Pitch:GetFloat()..","..TEST.Yaw:GetFloat()..","..TEST.Roll:GetFloat()..")\nSWEP.ViewModelFlip="..(TEST.Flip:GetInt()==1 and "true" or "false"))
	print(s)
	s=("SWEP.RunPos=Vector("..TEST.RX:GetFloat()..","..TEST.RY:GetFloat()..","..TEST.RZ:GetFloat()..")\nSWEP.RunAng=Angle("..TEST.Rp:GetFloat()..","..TEST.Ry:GetFloat()..","..TEST.Rr:GetFloat()..")")
	print(s)
end
concommand.Add("wac_cl_weaponhelp_print", Print)

concommand.Add("wac_cl_weaponhelp_iniprint", function()
	local s="[aimpos]\nx="
	s=s..TEST.X:GetFloat().."\ny="
	s=s..TEST.Y:GetFloat().."\nz="
	s=s..TEST.Z:GetFloat().."\n"
	s=s.."[aimang]\np="
	s=s..TEST.Pitch:GetFloat().."\ny="
	s=s..TEST.Yaw:GetFloat().."\nr="
	s=s..TEST.Roll:GetFloat().."\n"
	s=s.."[runpos]\nx="
	s=s..TEST.RX:GetFloat().."\ny="
	s=s..TEST.RY:GetFloat().."\nz="
	s=s..TEST.RZ:GetFloat().."\n"
	s=s.."[runang]\np="
	s=s..TEST.Rp:GetFloat().."\ny="
	s=s..TEST.Ry:GetFloat().."\nr="
	s=s..TEST.Rr:GetFloat().."\n"
	print(s)
end)
