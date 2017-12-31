if !ntf then ntf = {} end

function ntf.GetColor(t)
	local col = Color(0,0,0,0)
	if t==0 or t==3 then
		col = Color(220,220,220,220)
	elseif t==1 then
		col = Color(220,10,10.220)
	else
		col = Color(255,220,60,220)
	end
	return col
end

NOTIFY_GENERIC			= 0
NOTIFY_ERROR			= 1
NOTIFY_UNDO				= 2
NOTIFY_HINT				= 3
NOTIFY_CLEANUP			= 4

local HUDNotes = {}

function GM:AddNotify(str, t, len)
	local notify = {}
	notify.time = CurTime()+len
	notify.color = ntf.GetColor(t)
	notify.string = str
	notify.pos = table.getn(HUDNotes)
	table.insert(HUDNotes, notify)
end

local white = Color(20,20,20,220)
local function DrawDeath(y, death)
	local w = ScrW()
	local h = ScrH()
	local fadeout = (death.time-0.1) - CurTime()
	local alpha = math.Clamp(fadeout * 1655, 0, 255)
	death.color.a = alpha
	white.a = alpha
	draw.SimpleText(death.string, "TargetID", w - 16, 570+y*20, white, TEXT_ALIGN_RIGHT)
	draw.SimpleText(death.string, "TargetID", w - 15, 571+y*20, death.color, TEXT_ALIGN_RIGHT)
end

local function DrawHintNotice()
	local num = table.getn(HUDNotes)
	if num > 7 and !HUDNotes[1].Expired then
		HUDNotes[1].time = CurTime()+0.2
		HUDNotes[1].Expired = true
	end
	for i=1, num do
		if HUDNotes[i] then
			if HUDNotes[i].time > CurTime() then
				if HUDNotes[i].pos != i then
					HUDNotes[i].pos = i - HUDNotes[i].pos*0.1
				end
				DrawDeath(HUDNotes[i].pos, HUDNotes[i])
			else
				table.remove(HUDNotes, i)
			end
		end
	end
	if HUDNotes and num < 1 then
		HUDNotes = {}
	end
end
hook.Add("HUDPaint", "drawlol", DrawHintNotice)

local twon = 3
local drawtime = 0
local bgcol = Color(20,20,20,170)
local stringcol = Color(255,255,255,190)

local function DrawWinningTeam()
	local crt = CurTime()
	if drawtime > crt then
		local sw = ScrW()
		local name = team.GetName(twon)
		local alpha = math.Clamp(((drawtime-1)-crt), 0, 1)
		bgcol.a = 100*alpha
		stringcol.a = 250*alpha
		draw.RoundedBox(4, sw/2-150, 50, 300, 30, bgcol)
		draw.DrawText("Team "..name.." has won the round.", "TargetID", sw/2, 55, stringcol,1)
	end
end
hook.Add("HUDPaint", "drawlol2", DrawWinningTeam)

local function WinLoose(um)
	twon = um:ReadLong()
	pteam = um:ReadLong()
	if twon == pteam then
		surface.PlaySound("if_team_win.mp3")
	else
		surface.PlaySound("if_team_loose.mp3")
	end
	drawtime = CurTime()+20
	GAMEMODE.PauseTime=drawtime
end
usermessage.Hook("WinLoose", WinLoose)
