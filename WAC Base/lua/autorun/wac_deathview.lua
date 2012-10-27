
if !CLIENT then return end

include("wac/base.lua")

local models={}
models["alyx"]=Vector(-2,0,0)

local fade=0
local dead=false
local view
local NULLVEC=Vector(0,0,0)
local b_Col=CreateClientConVar("wac_cl_colordeath", 1, true, false)
local b_Fp=CreateClientConVar("wac_cl_fpdeath", 1, true, false)
local ragdoll;
wac.hook("CalcView", "wac_cl_deathview", function(pl, origin, angles, fov)
	if pl:GetViewEntity()==pl then
		dead=true
		ragdoll=pl:GetRagdollEntity()
		if !IsValid(ragdoll) then dead=false return end
		local m=ragdoll:GetModel()
		local eyepos=Vector(-4,0,-2)
		for k,v in pairs(models) do
			if string.find(m,k) then
				eyepos=v
				break
			end
		end
		if b_Fp:GetInt()!=1 then return end
		local eyes=ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
		if IsValid(ragdoll) then
			local bone=ragdoll:LookupBone("ValveBiped.Bip01_Head1")
			local matrix=ragdoll:GetBoneMatrix(bone)
			if !matrix then return end
			matrix:Scale(NULLVEC)
			ragdoll:SetBoneMatrix(bone,matrix)		
		end
		view={
			origin=eyes.Pos+eyes.Ang:Forward()*eyepos.x+eyes.Ang:Up()*eyepos.z,
			angles=eyes.Ang
		}
		return view
	end
end)

local mat=Material("pp/blurscreen")
wac.hook("RenderScreenspaceEffects", "wac_pldeathblur",function()
	if !IsValid(LocalPlayer():GetViewEntity()) then return end
	if ((dead or LocalPlayer():GetNWBool("wac_spawnmod_pending")) and b_Col:GetInt()==1) or LocalPlayer():GetViewEntity():GetClass()=="map_camera" then
		fade=WAC.SmoothApproach(fade,100,5)
		mat:SetFloat("$blur", fade/100*3+1)
		render.UpdateScreenEffectTexture()
		render.SetMaterial(mat)
		render.DrawScreenQuad()
		DrawMotionBlur(fade*5+1, 0.88, 0.01)
		local tab = {}		
		tab[ "$pp_colour_addr" ] 		=0
		tab[ "$pp_colour_addg" ] 	=0
		tab[ "$pp_colour_addb" ] 	=0
		tab[ "$pp_colour_brightness" ] =-fade/500
		tab[ "$pp_colour_contrast" ] 	=1
		tab[ "$pp_colour_colour" ] 	=1-(fade/150)
		tab[ "$pp_colour_mulr" ] 		=0
		tab[ "$pp_colour_mulg" ] 	=0
		tab[ "$pp_colour_mulb" ] 	=0
		DrawColorModify(tab)
	else
		fade=0
	end
end)

wac.hook("HUDShouldDraw","wac_cl_hidestuff",function(n)
	local p=LocalPlayer()
	if IsValid(p) and !p:Alive() and n!="CHudChat" then
		return false
	end
end)
