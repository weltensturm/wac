NEXT_MAP = "d3_c17_07"

TRIGGER_CHECKPOINT = {
	{Vector(3537, 1539, 256), Vector(3616, 1581, 349)}
}

hook.Add("InitPostEntity", "hl2cInitPostEntity", function()
	for _, fdr in pairs(ents.FindByClass("func_door_rotating")) do
		if fdr:GetName() == "long_plank_1_rotator" then
			fdr:SetMoveType(0)
			fdr:SetAngles(fdr:GetAngles() + Angle(0, -45, 0))
		end
	end
end)
