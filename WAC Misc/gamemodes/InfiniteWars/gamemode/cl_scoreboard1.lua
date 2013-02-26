
local showboard = false

function GM:ScoreboardShow()
	GAMEMODE.ShowScoreboard = true
end

function GM:ScoreboardHide()
	GAMEMODE.ShowScoreboard = false
end

local UPDATETIME = 0
function GM:GetPlayerScoreInfo()
	local info = {}
	for _,p in pairs(player.GetAll()) do
		table.insert(info, p:GetNWInt("score"), {
			name = p:Name(),
			team = p:Team(),
			class = p:GetNWString("class"),
			score = p:GetNWInt("score"),
			deaths = p:Deaths(),
			frags = p:Frags(),
			ping = p:Ping()
		})
	end
	return info
end

local COL_MAINFRAME = Color(5,5,5,220)
local COL_MAINFRAME_OUTL = Color(255,150,0,220)
local COL_TEXT = Color(200,200,200,255)
local INFO = {}
local fAlpha = 0
local SW=ScrW()
local SH=ScrH()
local pBaseFrame={
	{
		["x"]=SW/2-330,
		["y"]=80,
	},
	{
		["x"]=SW/2-300,
		["y"]=50,
	},
	{
		["x"]=SW/2+300,
		["y"]=50,
	},
	{
		["x"]=SW/2+330,
		["y"]=80,
	},
	{
		["x"]=SW/2+330,
		["y"]=500,
	},
	{
		["x"]=SW/2+300,
		["y"]=530,
	},
	{
		["x"]=SW/2-300,
		["y"]=530,
	},
	{
		["x"]=SW/2-330,
		["y"]=500,
	},
}

local cTeams={
	[1]=Color(10,10,200,200),
	[2]=Color(200,10,10,200),
}

function GM:HUDDrawScoreBoard()
	if (!GAMEMODE.ShowScoreboard and fAlpha == 0) then return end
	if GAMEMODE.ShowScoreboard then
		fAlpha = math.Clamp(fAlpha+FrameTime()*5, 0, 1)
	else
		fAlpha = math.Clamp(fAlpha-FrameTime()*5, 0, 1)
	end
	if UPDATETIME < CurTime() then
		UPDATETIME = CurTime()+1
		INFO = self:GetPlayerScoreInfo()
	end

	cTeams[1].a=200*fAlpha
	cTeams[2].a=200*fAlpha
	surface.SetDrawColor(cTeams[1])
	surface.DrawLine(SW/2-2,52, SW/2-2,528)
	surface.DrawLine(SW/2-2,52, SW/2-298, 52)
	surface.DrawLine(SW/2-298, 52, SW/2-328, 82)
	surface.DrawLine(SW/2-328, 82, SW/2-328, 498)
	surface.DrawLine(SW/2-328, 498, SW/2-298, 528)
	surface.DrawLine(SW/2-298, 528, SW/2-2, 528)
	surface.SetDrawColor(cTeams[2])
	surface.DrawLine(SW/2+2,52, SW/2+2,528)
	surface.DrawLine(SW/2+2,52, SW/2+298, 52)
	surface.DrawLine(SW/2+298, 52, SW/2+328, 82)
	surface.DrawLine(SW/2+328, 82, SW/2+328, 498)
	surface.DrawLine(SW/2+328, 498, SW/2+298, 528)
	surface.DrawLine(SW/2+298, 528, SW/2+2, 528)
	--[[local TEXT_W_ALPHA = Color(COL_TEXT.r, COL_TEXT.g, COL_TEXT.b, COL_TEXT.a*ALPHA)
	local X_CLASS 	= SW/4
	local X_SCORE 	= SW/2-LAP*2-120
	local X_FRAGS 	= SW/2-LAP*2-90
	local X_DEATHS 	= SW/2-LAP*2-60
	local X_PING 	= SW/2-LAP*2-10
	for i=1, 2 do
		local X = T1X
		if i == 2 then X = T2X end
		local Y = LAP+HEADLAP-14
		draw.SimpleText("Name", "ScoreboardText", X, Y, TEXT_W_ALPHA,0)
		draw.SimpleText("Class", "ScoreboardText", X+X_CLASS, Y, TEXT_W_ALPHA,1)
		draw.SimpleText("Score", "ScoreboardText", X+X_SCORE, Y, TEXT_W_ALPHA,2)
		draw.SimpleText("K", "ScoreboardText", X+X_FRAGS, Y, TEXT_W_ALPHA,2)
		draw.SimpleText("D", "ScoreboardText", X+X_DEATHS, Y, TEXT_W_ALPHA,2)
		draw.SimpleText("Ping", "ScoreboardText", X+X_PING, Y, TEXT_W_ALPHA,2)
	end
	local ppos = 0
	for i,tbl in pairs(INFO) do
		if tbl.team != 3 then
			ppos = ppos + 1
			local X = T1X
			if tbl.team == 2 then X = T2X end
			local Y = LAP+HEADLAP+ppos*14
			draw.SimpleText(tbl.name, "ScoreboardText", X, Y, TEXT_W_ALPHA,0)
			draw.SimpleText(tbl.class, "ScoreboardText", X+X_CLASS, Y, TEXT_W_ALPHA,1)
			draw.SimpleText(tbl.score, "ScoreboardText", X+X_SCORE, Y, TEXT_W_ALPHA,2)
			draw.SimpleText(tbl.frags, "ScoreboardText", X+X_FRAGS, Y, TEXT_W_ALPHA,2)
			draw.SimpleText(tbl.deaths, "ScoreboardText", X+X_DEATHS, Y, TEXT_W_ALPHA,2)
			draw.SimpleText(tbl.ping, "ScoreboardText", X+X_PING, Y, TEXT_W_ALPHA,2)
		else
			local add = ", "
			if s == "Spectators: " then add = "" end
			s = s..add..tbl.name
		end
	end
	draw.SimpleText(s, "ScoreboardText", LAP*2, SH-LAP*2, TEXT_W_ALPHA)
--###################]]
end