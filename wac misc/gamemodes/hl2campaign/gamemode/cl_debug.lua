

local debug_enable = CreateClientConVar("hl2c_debug", 0, true, false)


--[[
if file.Exists("gamemodes/hl2campaign/gamemode/maps/"..game.GetMap()..".lua", "GAME") then
	include("maps/"..game.GetMap()..".lua")
end
]]


hook.Add("PostDrawTranslucentRenderables", "hl2c_debug", function(depth, skybox)
    if depth or skybox or not debug_enable:GetBool() then
        return
    end

	if TRIGGER_CHECKPOINT then
		for _, checkpoint in pairs(TRIGGER_CHECKPOINT) do
            render.DrawWireframeBox(Vector(0,0,0), Angle(0,0,0), checkpoint[1], checkpoint[2], {r=255,g=0,b=0,a=255}, false)
		end
	end

    if TRIGGER_DELAYMAPLOAD then
		local t = TRIGGER_DELAYMAPLOAD
        render.DrawWireframeBox(Vector(0,0,0), Angle(0,0,0), t[1], t[2], {r=0,g=0,b=255,a=255}, false)
	end
end)
