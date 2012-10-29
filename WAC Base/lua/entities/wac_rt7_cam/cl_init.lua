
include("shared.lua")

local rts={}
local mats={}
for i=1, 7 do
	rts[i]=GetRenderTarget("Screen_RT"..i, 512, 512)
	mats[i]=Material("WeltEnSTurm/rt7/rt7_"..i)
end

local camdata={
	x=0,
	y=0,
	w=512,
	h=512,
	fov=50,
	drawhud=false,
	drawviewmodel=false,
}
local RENDERING={}

function ENT:Draw()
	for i=1, 7 do
		if GetGlobalEntity("wac_cam_rt"..i)==self.Entity and RENDERING[i] then
			return
		end
	end
	self:DrawModel()
end

local VIEW_DRAW=false
local function Draw()
	for i=1, 7 do
		local self=GetGlobalEntity("wac_cam_rt"..i)
		if self and self:IsValid() then
			local oldrt=render.GetRenderTarget()
			mats[i]:SetMaterialTexture("$basetexture", rts[i])
			if self:IsPlayer() then
				camdata.angles=self:GetAimVector():Angle()
				camdata.origin=self:EyePos()
			else
				camdata.angles=self:GetAngles()
				camdata.origin=self:GetPos()
			end
			render.SetRenderTarget(rts[i])
			cam.Start2D()
			LocalPlayer():GetViewModel():SetNoDraw(true)
			VIEW_DRAW=true
			RENDERING[i]=true
			render.RenderView(camdata)
			VIEW_DRAW=false
			RENDERING[i]=false
			LocalPlayer():GetViewModel():SetNoDraw(false)
			cam.End2D()
			render.SetRenderTarget(oldrt)
		end
	end
end
hook.Add("HUDPaint", "wac_rt7_draw", Draw)

wac.hook("HUDShouldDraw", "wac_cl_rt7_shoulddraw", function(n)
	if VIEW_DRAW then
		return false
	end
end)
