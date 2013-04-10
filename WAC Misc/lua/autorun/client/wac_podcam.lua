
include "wac/base.lua"

local view={
	origin=Vector(0,0,0),
	angles=Angle(0,0,0),
}
local angles = Angle(0,0,0)

wac.hook("CalcView", "wac_podcam_view", function(p, pos, ang, fov)
	local self = p:GetNWEntity("wac_cam")
	if self and self:IsValid() and self:GetClass()=="wac_v_camera" and p:GetViewEntity() == p then
		angles = p:GetAimVector():Angle()
		angles.r = ang.r
		view.angles = angles
		view.origin = self:GetPos()
		if !self:GetNWBool("freelook") then
			view.angles=self:GetAngles()
		end
		return view
	end
end)

--"dev/dev_prisontvoverlay002"
--local iOvl=surface.GetTextureID("effects/combine_binocoverlay")
local overlay = Material("effects/combine_binocoverlay")
wac.hook("HUDPaint", "wac_podcam_draw", function()
	local p=LocalPlayer()
	local self=p:GetNWEntity("wac_cam")
	if self and self:IsValid() and self:GetClass()=="wac_v_camera" and self:GetNWBool("drawcrosshair") then
		render.SetMaterial(overlay)
		render.DrawScreenQuad()
		local vec = self:GetPos()+self:GetForward()*20
		local pos = vec:ToScreen()
		if pos.visible then
			--surface.SetDrawColor(Color(50,200,0,255))
			surface.SetDrawColor(255,255,255,220)
			surface.DrawLine(pos.x-15,pos.y,pos.x+15,pos.y)
			surface.DrawLine(pos.x,pos.y-15,pos.x,pos.y+15)
			surface.SetDrawColor(10,10,10,220)
			surface.DrawLine(pos.x-16,pos.y-1,pos.x-16,pos.y+1)	--left small
			surface.DrawLine(pos.x+16,pos.y-1,pos.x+16,pos.y+1)	--right small
			surface.DrawLine(pos.x-1,pos.y+16,pos.x+1,pos.y+16)	--down small
			surface.DrawLine(pos.x-1,pos.y-16,pos.x+1,pos.y-16)	--up small
			surface.DrawLine(pos.x+1,pos.y-16,pos.x+1,pos.y-1)	--up right
			surface.DrawLine(pos.x-1,pos.y-1,pos.x-1,pos.y-16)		--up left
			surface.DrawLine(pos.x+1,pos.y+16,pos.x+1,pos.y+1)	--down right
			surface.DrawLine(pos.x-1,pos.y+16,pos.x-1,pos.y+1)	--down left
			surface.DrawLine(pos.x-16,pos.y+1,pos.x-1,pos.y+1)
			surface.DrawLine(pos.x+16,pos.y+1,pos.x+1,pos.y+1)
			surface.DrawLine(pos.x-16,pos.y-1,pos.x-1,pos.y-1)
			surface.DrawLine(pos.x+16,pos.y-1,pos.x+1,pos.y-1)
		end
	end
end)
