

NULLVEC=Vector(0,0,0)
NULLANG=Vector(0,0,0)

WAC.Hook=function(gmhook,name,func,func1)
	if gmhook=="CalcView" then
		error("Could not add CalcView with WAC.Hook")
	else
		hook.Add(gmhook,name,func)
		table.insert(WAC.__hooks, {gmhook,name,func,func1})
	end
end


--[[#############
----Networked Variables
--#############]]
local nv_lud=0
WAC.NVars={}
WAC.Hook("Think", "wac_nvars_think", function()
	if nv_lud+0.5<CurTime() then
		for n,t in pairs(WAC.NVars) do
			for k,v in pairs(t) do
				if GetGlobalFloat("WAC_"..n.."_"..k) != v then
					if SERVER then
						SetGlobalFloat("WAC_"..n.."_"..k, v)
					else
						t[k]=GetGlobalFloat("WAC_"..n.."_"..k)
					end
				end
			end
		end
		nv_lud=CurTime()
	end
end)
WAC.SetVar=function(st,sst,v)
	if !WAC.NVars[st] then
		WAC.NVars[st]={}
	end
	WAC.NVars[st][sst]=v
end
WAC.GetVar=function(st,sst)
	if !WAC.NVars[st] or !WAC.NVars[st][sst] then return 0 end
	return tonumber(WAC.NVars[st][sst])
end
if SERVER then
	local function cv(p,c,a)
		if !p:IsAdmin() or !a[1] or !a[2] or !a[3] or !WAC.NVars[a[1]] or !WAC.NVars[a[1]][a[2]] then return end
		WAC.NVars[a[1]][a[2]]=a[3]
	end
	concommand.Add("wac_var_change", cv)
end
local function PrintAllVars()
	for k,t in pairs(WAC.NVars) do
		MsgN(k)
		for n,v in pairs(t) do
			MsgN("	"..n.."	".."=".." "..v)
		end
	end
end
concommand.Add("wac_var_printall"..(CLIENT and "_cl" or ""), PrintAllVars)


--[[#############
----Names of Stuff
--#############]]
WAC.Names={
	Base="WAC",
	WeaponCategory={
		Main		="WAC",
		NewWeps		="WAC",
		OldWeps		="WAC Old",
		MW			="WAC Modern Warfare",
		TW			="WAC Tactical",
		CSS			="WAC CSS",
	},
	ToolCategory	="WAC",
	Menu={
		Tab			="Options",
		Category	="WAC",
	},
	OptionsServer	="WAC Server",
	OptionsClient	="WAC Client",
	Sents={
		Weapons		="WAC Weapons",
		WAC			="WAC",
		Misc		="WAC Misc",
	},
	Author = "WeltEnSTurm",
}
WAC.AmmoTypes={
	["AlyxGun"]					=5.7,
	["Pistol"]					=9,
	["357"]						=0.357,
	["SniperRound"]				=0.5,
	["SniperPenetratedRound"]	=0.45,
	["Gravity"]					=0.46,
	["Battery"]					=9,
	["CombineCannon"]			=0.50,
	["AirboatGun"]				=5.56,
	["StriderMinigun"]			=7.62,
}

WAC.WeaponLib={
	StarMuzzle={	
		Speed = 20,
		Vector(1, 1, 1),
		Vector(1, 1, -1),
		Vector(-1, 1, 1),
		Vector(-1, 1, -1)
	},
	NormalMuzzle={
		Speed = 15,
		Vector(0, 1, 0)
	}
}

--[[#############
----Menu Panel System
--#############]]
WAC.MenuPanels=WAC.MenuPanels or {}
WAC.AddMenuPanel=function(c,n,f,t2)
	WAC.MenuPanels[c]=WAC.MenuPanels[c] or {}
	WAC.MenuPanels[c][n]=WAC.MenuPanels[c][n] or {}
	local t = WAC.MenuPanels[c][n]
	t.name=n
	t.func=f
	if t.updatevars then
		for k,v in pairs(t.updatevars) do
			t.updatevars[k]=""
		end
	else
		t.updatevars={}
	end
	if t2 then
		for _,v in pairs(t2) do
			t.updatevars[v]=""
		end
	end
end
WAC.Hook("PopulateToolMenu", "wac_menu_addpanels", function()
	for c,t in pairs(WAC.MenuPanels) do
		for n,t2 in pairs(t) do
			spawnmenu.AddToolMenuOption(WAC.Names.Menu.Tab, c, n, n, "", "", function(CP)
				WAC.MenuPanels[c][n].panel=CP
				CP:Clear()
				--CP:AddHeader()
				--CP:AddDefaultControls()
				t2.func(CP,{})
			end, {})
		end
	end
end)
WAC.AddMenuUpdateVar=function(c,n,s)
	if WAC.MenuPanels[c] and WAC.MenuPanels[c][n] then
		WAC.MenuPanels[c][n].updatevars[s]=""
	end
end
--[[#############
----Useful Functions
--#############]]
WAC.Sprinting=function(p)
	if p and IsValid(p) then
		local b=((p:KeyDown(IN_SPEED) and (p:GetVelocity():Length()+10)>100))
		if
			b
			and (
				p:GetActiveWeapon().NDS_Allocated
				or p:GetActiveWeapon().wac_swep_alt
			)
			and p:GetActiveWeapon():GetClass() != "weapon_physgun"
		then
			p:ConCommand("-attack")
			p:ConCommand("-attack2")
			return true
		end
		return false
	end
end

--[[if SERVER then
	local nextcamthink = 0
	WAC.Hook("Think", "wac_vehiclethink",function()
		for _,v in pairs(ents.GetAll()) do
			if v:IsVehicle() then
				local nwpsng=v:GetNWEntity("__passenger")
				local rpsng=v:GetPassenger()
				if rpsng!=nwpsng then
					v:SetNWEntity("__passenger", rpsng)
				end
			end
		end
		nextcamthink=crt+0.1
	end)
end]]

if CLIENT then
	local ply = FindMetaTable("Player")
	function ply:GetViewEntity()
		return GetViewEntity()
	end
	local veh=FindMetaTable("Entity")
	function veh:GetPassenger()
		for _,p in pairs(player.GetAll()) do
			if p:GetVehicle()==self then
				return p
			end
		end
		--return self:GetNWEntity("__passenger")
	end
end

function WAC.SubstractAngles(a1,a2)
	return Angle(math.AngleDifference(a1.p,a2.p),math.AngleDifference(a1.y,a2.y),math.AngleDifference(a1.r,a2.r))
end

function WAC.SmoothApproach(x,y,s,c)
	local FrT=math.Clamp(FrameTime(), 0.001, 0.035)*0.3
	c=(c and c*FrT)or(99999)
	return x-math.Clamp((x-y)*s*FrT,-c,c)
end

function WAC.SmoothApproachAngle(x,y,s,c)
	local FrT=math.Clamp(FrameTime(), 0.001, 0.035)*0.3
	c=(c and c*FrT)or(99999)
	return x-math.Clamp(math.AngleDifference(x,y)*s*FrT,-c,c)
end

function WAC.SmoothApproachAngles(a1,a2,s,c)
	if !a1 or !a2 then error("one argument is nil", 2) end
	return Angle(
		WAC.SmoothApproachAngle(a1.p, a2.p, s,c),
		WAC.SmoothApproachAngle(a1.y, a2.y, s,c),
		WAC.SmoothApproachAngle(a1.r, a2.r, s,c)
	)
end

function WAC.SmoothApproachVector(Vec1, Vec2, s, c)
	local dir=(Vec1-Vec2):Normalize()
	local dist=Vec1:Distance(Vec2)
	local var=WAC.SmoothApproach(0,dist,s,c)
	local v=Vec1-dir*var
	Vec1.x=v.x
	Vec1.y=v.y
	Vec1.z=v.z
	--[[Vec1.x=WAC.SmoothApproach(Vec1.x,Vec2.x,s,c)
	Vec1.y=WAC.SmoothApproach(Vec1.y,Vec2.y,s,c)
	Vec1.z=WAC.SmoothApproach(Vec1.z,Vec2.z,s,c)]]
	return Vec1
end

