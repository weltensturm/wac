
local Deaths = {}

local dnt = 20

function GM:AddDeathNotice(v, t1, w, k, t2)
	local Death = {}
	Death.victim = v
	Death.attacker = k
	Death.time = CurTime()+dnt
	Death.pos = table.getn(Deaths)+1
	if t1==-1 or v:IsNPC() then return end
	local atn = ""
	if k:IsPlayer() then
		atn = k:Nick()
	elseif k:IsNPC() then
		atn = k:GetClass()
	else
		k = v
	end
	if t1 == t2 and k != v then
		w = "teamkill"
	end
	k = self:CheckLanguage(k)
	v = self:CheckLanguage(v)
	w = self:CheckLanguage(w)
	if v == k then
		Death.string = "["..w.."] "..v:Nick()
	else
		Death.string = atn.." ["..w.."] "..v:Nick()
	end
	LocalPlayer():PrintMessage(HUD_PRINTCONSOLE, Death.string)
	Death.color1 = table.Copy(team.GetColor(t2))
	table.insert(Deaths, Death)
end

local function plbypl(um)
	local v = um:ReadEntity()
	local w = um:ReadString()
	local k = um:ReadEntity()
	local t1 = v:Team()
	local t2 = -1
	if k and k:IsPlayer() then
		t2 = k:Team()
	end
	GAMEMODE:AddDeathNotice(v, t1, w, k, t2)
end
usermessage.Hook("PlayerKilledByPlayer", plbypl)

local function GetNotify(um)
	local str = um:ReadString()
	local t = um:ReadLong()
	local tm = um:ReadLong()
	local Death = {}

	Death.time = CurTime()+dnt
	Death.color1 = table.Copy(team.GetColor(tm))
	Death.string = str
	Death.pos = table.getn(Deaths)
	table.insert(Deaths, Death)
end
usermessage.Hook("SendNotify", GetNotify)

local white = Color(20,20,20,220)
local function DrawDeath(y, death)
	local w = ScrW()
	local h = ScrH()
	local fadeout = (death.time-0.1) - CurTime()
	local alpha = math.Clamp(fadeout * 1655, 0, 255)
	death.color1.a = alpha
	white.a = alpha
	draw.SimpleText(death.string, "TargetID", w - 14, 81+y*20, white, TEXT_ALIGN_RIGHT)
	draw.SimpleText(death.string, "TargetID", w - 15, 80+y*20, death.color1, TEXT_ALIGN_RIGHT)
end

local function DrawDeathNotice()
	if GAMEMODE.PauseTime and GAMEMODE.PauseTime>CurTime() then Deaths={} return end
	local num = table.getn(Deaths)
	if num > 7 and !Deaths[1].Expired then
		Deaths[1].time = CurTime()-0.1
		Deaths[1].Expired = true
	end
	for i=1, num do
		if Deaths[i] then
			if Deaths[i].time > CurTime() then
				Deaths[i].pos = i - Deaths[i].pos*0.1
				DrawDeath(Deaths[i].pos, Deaths[i])
			else
				table.remove(Deaths, i)
			end
		end
	end
	if Deaths and num < 1 then
		Deaths = {}
	end
end
hook.Add("HUDPaint", "drawshitlol", DrawDeathNotice)
