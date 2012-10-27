
if CLIENT then

	include("wac/base.lua")

	local enable = CreateClientConVar("wac_cl_speed_blur", 0, true, false)
	local inNoclip = CreateClientConVar("wac_cl_speed_blur_noclip", 1, true, false)

	local sound
	local blurSmooth=0
	wac.hook("RenderScreenspaceEffects", "wac_cl_speedblur", function()
		local p = LocalPlayer()
		local doll = p:GetRagdollEntity()
		vel=((p:GetMoveType()!=MOVETYPE_NOCLIP or inNoclip:GetInt()==1) and !p:InVehicle() and p:GetViewEntity()==p and enable:GetInt()==1) and p:GetVelocity():Length()-200 or 0
		blurSmooth = blurSmooth-(blurSmooth-vel)*FrameTime()*4
		if blurSmooth > 0 then
			if !sound then
				sound = CreateSound(p, "vehicles/fast_windloop1.wav")
				sound:Play()
				sound:ChangeVolume(0)
			end
			DrawMotionBlur(1-math.Clamp(blurSmooth/500,0,0.9), math.Clamp(blurSmooth/500,0,1), 0.01)
		end
		if sound then
			sound:ChangeVolume(math.Clamp(blurSmooth/1000, 0, 1))
			sound:ChangePitch(math.Clamp(blurSmooth/10, 0, 200))
		end
	end)

end