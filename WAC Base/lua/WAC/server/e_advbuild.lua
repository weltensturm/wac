
local cb=CreateConVar("wac_advbuild_allow", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

concommand.Add("wac_advbuild_toggle", function(p,c,a)
	if cb:GetInt()==1 then
		p:SetNWBool("wac_advbuild_enable", !p:GetNWBool("wac_advbuild_enable"))
	else
		p:SetNWBool("wac_advbuild_enable", false)
	end
	local enabled=p:GetNWBool("wac_advbuild_enable")
	if enabled then
		p:SetMoveType(MOVETYPE_NONE)
		--p:Spectate(OBS_MODE_ROAMING)
	else
		--p:Spectate(OBS_MODE_NONE)
		p:SetMoveType(MOVETYPE_WALK)
	end
end)

concommand.Add("wac_advbuild_movecam", function(p,c,a)
	--[[local e=p
	if IsValid(e) then
		e:SetPos(Vector(a[1],a[2],a[3]))
	end]]
end)

concommand.Add("wac_advbuild_moveent", function(p,c,a)
	if cb:GetInt()==1 then
		local e=ents.GetByIndex(a[1])
		if IsValid(e) then
			e:SetPos(Vector(a[2],a[3],a[4]))
			e:GetPhysicsObject():EnableMotion(false)
		end
	end
end)

concommand.Add("wac_advbuild_rotateent", function(p,c,a)
	if cb:GetInt()==1 then
		local e=ents.GetByIndex(a[1])
		if IsValid(e) then
			e:SetAngles(Angle(a[2],a[3],a[4]))
			e:GetPhysicsObject():EnableMotion(false)
		end
	end
end)

concommand.Add("wac_advbuild_moveplayer", function(p,c,a)
	if cb:GetInt() then
		p:SetPos(Vector(a[1],a[2],a[3]))
	end
end)
