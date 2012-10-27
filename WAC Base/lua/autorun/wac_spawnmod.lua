
local enable = CreateConVar("wac_spawnmod_enable", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

if SERVER then--##Server

	local function updateseats(p)
		p.wac_spawns=p.wac_spawns or {}
		local team=p:Team()
		for k,e in pairs(ents.FindByClass("wac_playerspawn")) do
			if !table.HasValue(p.wac_spawns, e) and (!e.Team or team==e.Team) then
				table.insert(p.wac_spawns, e)
			end
		end
		for k,e in pairs(ents.FindByClass("wac_playerspawn_custom")) do
			if e:GetOwner()==p and !table.HasValue(p.wac_spawns, e) and (!e.Team or e.Team==team) then
				table.insert(p.wac_spawns, e)
			end
		end
		for k,e in pairs(p.wac_spawns) do
			if !IsValid(e) or (e:GetClass()=="wac_playerspawn_custom" and e:GetOwner() != p) or (e.Team and e.Team!=team) then
				table.remove(p.wac_spawns,k)
			end
		end
	end
	
	wac.hook("PlayerSpawn", "wac_spawnmod_spawn", function(p)
		if enable:GetInt()==1 and !p:GetNWBool("wac_spawnmod_pending") then
			updateseats(p)
			if #p.wac_spawns==0 then return end
			p:SetNWInt("wac_spawnmod_spawnid",1)
			p:SetModel("")
			local eid=1
			if IsValid(p.wac_spawns[eid]) then
				p:SetPos(p.wac_spawns[eid]:GetPos()+Vector(0,0,1)*p.wac_spawns[eid]:OBBMaxs().z)
				p:SetNWEntity("wac_spawnmod_spawnplatform",p.wac_spawns[eid])
			end
			p:KillSilent()
			p:SetNWBool("wac_spawnmod_pending", true)
			p.NextSpawnTime=CurTime()+99999999999
		end
	end)
	
	local function lspawn(p)
		updateseats(p)
		if enable:GetInt()==1 and #p.wac_spawns != 0 then
			local ang=p:EyeAngles()
			local eid=p:GetNWInt("wac_spawnmod_spawnid")
			p.NextSpawnTime=CurTime()
			p:Spawn()
			p:SetPos(p.wac_spawns[eid]:GetPos()+Vector(0,0,1)*p.wac_spawns[eid]:OBBMaxs().z)
			p:SetNWBool("wac_spawnmod_pending", false)
			p:SetMoveType(MOVETYPE_WALK)
			p:SnapEyeAngles(ang)
		end
	end
	
	local keys={
		next=IN_ATTACK2,
		prev=IN_ATTACK,
		spawn=IN_JUMP
	}
	
	local function press(p, k)
		if enable:GetInt()==1 and table.HasValue(keys, k) and p:GetNWBool("wac_spawnmod_pending") then
			updateseats(p)
			if #p.wac_spawns==0 then
				lspawn(p)
			else
				local eid=p:GetNWInt("wac_spawnmod_spawnid")
				if k==keys.next then
					eid=((eid>=#p.wac_spawns)and(1)or(eid+1))
					p:SetNWInt("wac_spawnmod_spawnid", eid)
				elseif k==keys.prev then
					eid=((eid<=1)and(#p.wac_spawns)or(eid-1))
					p:SetNWInt("wac_spawnmod_spawnid", eid)
				elseif k==keys.spawn then
					if IsValid(p.wac_spawns[eid]) then
						lspawn(p)
						return
					end
				end
				if IsValid(p.wac_spawns[eid]) then
					p:SetPos(p.wac_spawns[eid]:GetPos()+Vector(0,0,1)*p.wac_spawns[eid]:OBBMaxs().z)
					p:SetNWEntity("wac_spawnmod_spawnplatform",p.wac_spawns[eid])
				end
			end
		end
	end
	WAC.Hook("KeyPress", "wac_spawnmod_keypress", press)
	
	lastthink=0
	local function think()
		if lastthink<CurTime() then
			for _,p in pairs(player.GetAll()) do
				if p:Alive() then break end
				local e=p:GetNWEntity("wac_spawnmod_spawnplatform")
				local eid=p:GetNWInt("wac_spawnmod_spawnid")
				updateseats(p)
				if e and e:IsValid() then
					if e!=p.wac_spawns[eid] then
						e:SetNWEntity("wac_spawnmod_spawnplatform", p.wac_spawns[eid])
					end
				end
			end
			lastthink=CurTime()+0.1
		end
	end
	WAC.Hook("Think", "wac_spawnmod_think", think)
	
else--##Client

	local viewt={}
	local pos=Vector(0,0,0)
	local AddVector=Vector(0,0,30)
	wac.hook("CalcView", "wac_spawnmod_view", function(p, lpos, lang, fov)
		if p:GetNWBool("wac_spawnmod_pending") and enable:GetInt()==1 and IsValid(p:GetNWEntity("wac_spawnmod_spawnplatform")) then
			WAC.SmoothApproachVector(pos,p:GetNWEntity("wac_spawnmod_spawnplatform"):GetPos(),60)
			local trd={}
			trd.start=pos+AddVector
			trd.endpos=trd.start-lang:Forward()*90
			local tr=util.TraceLine(trd)
			viewt.origin=tr.HitPos+lang:Forward()*10
			return viewt
		end
	end)
	
	local col_Bg = Color(15,15,15,150)
	local col_Text = Color(250,190,50,200)
	local function ldraw()
		if LocalPlayer():GetNWBool("wac_spawnmod_pending") and enable:GetInt()==1 then
			local SW=ScrW()
			local SH=ScrH()
			draw.RoundedBox(8, SW/2-200, SH-150, 400, 80, col_Bg)
			draw.SimpleTextOutlined(" <LMB", "ConsoleText", SW/2-200, SH-95, col_Text,0,0,1,col_Bg)
			draw.SimpleTextOutlined(LocalPlayer():GetNWInt("wac_spawnmod_spawnid"), "ConsoleText", SW/2, SH-95, col_Text,1,0,1,col_Bg)
			draw.SimpleTextOutlined("RMB> ", "ConsoleText", SW/2+200, SH-95, col_Text,2,0,1,col_Bg)
			draw.SimpleTextOutlined("PRESS SPACE TO SPAWN", "TargetID", SW/2, SH-140, col_Text,1,0,1,col_Bg)
		end
	end
	WAC.Hook("HUDPaint", "wac_spawnmod_draw", ldraw)
	
end
