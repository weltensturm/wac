
local c=wac.menu.category
local n="Damage System"

local DrawVar = 0
local DrawHit = false
local mat = Material("pp/blurscreen")


wac.hook("Think", "wac_cl_blur_think",function()
	if !DrawHit then return end
	if (LocalPlayer() == NULL) then return end	
	DrawVar = math.max(DrawVar - FrameTime(), 0)
end)

wac.hook("RenderScreenspaceEffects", "wac_cl_blur_rse",function()
	if !DrawHit then return end
	mat:SetMaterialFloat("$blur", DrawVar*5+1)
	render.UpdateScreenEffectTexture()
	render.SetMaterial(mat)
	render.DrawScreenQuad()
	DrawMotionBlur(DrawVar*5+1, 0.88, 0.01)
	--DrawBloom(0.65, DrawVar, 9, 9, 9, DrawVar, 0.3, 0.3, 0.3)	
	if DrawVar <= 0 then
		DrawHit = false
	end	
end)

function WAC.HitHook(um)
	DrawVar = math.Clamp(um:ReadFloat(), 0, 2)
	if DrawVar>=0 then
		DrawHit = true
	end
end
usermessage.Hook("HitHook", WAC.HitHook)

WAC.AddMenuPanel(c,n,function(CPanel,t)
	CPanel:AddControl("Label", {Text = "Damage"})
	CPanel:CheckBox("Enable","wac_dmgsys_enable")
	CPanel:AddControl("Slider", {
		Label = "Damage to Entities",
		Type = "float",
		Min = 0.01,
		Max = 10,
		Command = "wac_dmgsys_mul",
	})
	CPanel:AddControl("Slider", {
		Label = "Damage to Contraption",
		Type = "float",
		Min = 0.01,
		Max = 10,
		Command = "wac_dmgsys_mul_s",
	})
	CPanel:AddControl("Slider", {
		Label = "Damage by non-explosives",
		Type = "float",
		Min = 0.01,
		Max = 10,
		Command = "wac_dmgsys_mul_nw",
	})
	CPanel:AddControl("Label", {Text = "\nEntities"})
	CPanel:CheckBox("Allow Custom Weapons","wac_weaponcr_adminmode")
end)
