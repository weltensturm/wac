
local FCVAR={FCVAR_REPLICATED,FCVAR_ARCHIVE}

WAC.WalkMod={
	ws 			= CreateConVar("wac_walkm_walkspeed",	195,	FCVAR),
	rs			= CreateConVar("wac_walkm_runspeed",		310,	FCVAR),
	jp			= CreateConVar("wac_walkm_jumpp",		200,	FCVAR),
	b			= CreateConVar("wac_walkm_enable",		1,		FCVAR),
}

WAC.ScaleMod={
	b	=CreateConVar("wac_scalemod_enable",0,FCVAR),
	s	=CreateConVar("wac_scalemod_scale",1,FCVAR),
}

if SERVER then
	local function update(p)
		local s=1
		if WAC.ScaleMod.b:GetInt()==1 then
			s=WAC.ScaleMod.s:GetFloat()
			local m=Vector(-16*s,-16*s,0)
			p:SetHull(m,Vector(16*s,16*s,72*s))
			p:SetHullDuck(m,Vector(16*s,16*s,36*s))
			p:SetViewOffset(Vector(0,0,68*s))
			p:SetViewOffsetDucked(Vector(0,0,32*s))
			p:SetStepSize(30*s)
		end
		if WAC.WalkMod.b:GetInt()==1 and !GetGlobalBool("wac_walkmod_disable") then
			timer.Simple(0.1, function()
				for _, ply in pairs(player.GetAll()) do
					ply:SetCrouchedWalkSpeed(0.6)
					ply:SetWalkSpeed(WAC.WalkMod.ws:GetFloat())
					ply:SetRunSpeed(WAC.WalkMod.rs:GetFloat())
					ply:SetJumpPower(WAC.WalkMod.jp:GetFloat())
				end
			end)
		end
	end
	WAC.Hook("PlayerSpawn", "wac_walkmod_spawn", update)
	WAC.Hook("Move", "wac_scalemod_scalemove", function(p,d)
		if WAC.ScaleMod.b:GetInt()==1 then
			local dir=(p:GetRight()*(p:KeyDown(IN_MOVELEFT) and 1 or p:KeyDown(IN_MOVERIGHT) and -1 or 0)+p:GetForward()*(p:KeyDown(IN_FORWARD) and 1 or p:KeyDown(IN_BACK) and -1 or 0)):Normalize()
			d:SetVelocity(dir*(p:KeyDown(IN_SPEED) and WAC.WalkMod.rs:GetInt() or WAC.WalkMod.ws:GetInt())*WAC.ScaleMod.s:GetFloat())
			return d
		end
	end)
	concommand.Add("wac_walkm_update", update)
else
	local RENDERING=false
	local cd={
		x=0,
		y=0,
		w=ScrW(),
		h=ScrH(),
		drawhud=true,
		drawviewmodel=true,
		znear=0.1,
		fov=75,
	}
	WAC.Hook("HUDPaint", "wac_cl_resizeplayer_hudpaint", function(p,pos,ang,fov)
		cd.fov=fov
		cd.origin=pos
		cd.angles=ang
	end)
	WAC.Hook("HUDPaint", "wac_cl_resizeplayer_hudpaint", function()
		if WAC.ScaleMod.b:GetInt()==1 and !RENDERING then
			RENDERING=true
			render.RenderView(cd)
			RENDERING=false
		end
	end)
end
