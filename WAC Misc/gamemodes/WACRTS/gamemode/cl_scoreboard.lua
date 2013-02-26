
function GM:ScoreboardShow()
	GAMEMODE.ShowScoreboard = true
end

function GM:ScoreboardHide()
	GAMEMODE.ShowScoreboard = false
end

function GM:GetTeamScoreInfo()
	local TeamInfo = {}	
	for id,pl in pairs( player.GetAll() ) do	
		local _team = pl:Team()
		local _frags = pl:Frags()
		local _deaths = pl:Deaths()
		local _ping = pl:Ping()		
		if (not TeamInfo[_team]) then
			TeamInfo[_team] = {}
			TeamInfo[_team].TeamName = team.GetName( _team )
			TeamInfo[_team].Color = team.GetColor( _team )
			TeamInfo[_team].Players = {}
		end		
		local PlayerInfo = {}
		PlayerInfo.Frags = _frags
		PlayerInfo.Deaths = _deaths
		PlayerInfo.Score = pl:GetNWInt("score")
		PlayerInfo.Ping = _ping
		if _team != 3 then
			PlayerInfo.Name = (pl:Nick().." ("..pl:GetNWString("class")..")")
		else
			PlayerInfo.Name = pl:Nick()
		end
		PlayerInfo.PlayerObj = pl
		local insertPos = #TeamInfo[_team].Players + 1
		for idx,info in pairs(TeamInfo[_team].Players) do
			if (PlayerInfo.Frags > info.Frags) then
				insertPos = idx
				break
			elseif (PlayerInfo.Frags == info.Frags) then
				if (PlayerInfo.Deaths < info.Deaths) then
					insertPos = idx
					break
				elseif (PlayerInfo.Deaths == info.Deaths) then
					if (PlayerInfo.Name < info.Name) then
						insertPos = idx
						break
					end
				end
			end
		end		
		table.insert(TeamInfo[_team].Players, insertPos, PlayerInfo)
	end	
	return TeamInfo
end

function GM:HUDDrawScoreBoard()
	if (!GAMEMODE.ShowScoreboard) then return end	
	if (GAMEMODE.ScoreDesign == nil) then	
		GAMEMODE.ScoreDesign = {}
		GAMEMODE.ScoreDesign.HeaderY = 0
		GAMEMODE.ScoreDesign.Height = ScrH() / 2	
	end	
	local alpha = 255
	local ScoreboardInfo = self:GetTeamScoreInfo()	
	local xOffset = ScrW() / 10
	local yOffset = 32
	local scrWidth = ScrW()
	local scrHeight = ScrH() - 64
	local boardWidth = scrWidth - (2* xOffset)
	local boardHeight = scrHeight
	local colWidth = 35
	boardWidth = math.Clamp( boardWidth, 400, 600 )
	boardHeight = GAMEMODE.ScoreDesign.Height	
	xOffset = (ScrW() - boardWidth) / 2.0
	yOffset = (ScrH() - boardHeight) / 2.0
	yOffset = yOffset - ScrH() / 4.0
	yOffset = math.Clamp( yOffset, 32, ScrH() )	
	// Background
	surface.SetDrawColor( 30, 30, 30, 200 )
	surface.DrawRect( xOffset, yOffset, boardWidth, GAMEMODE.ScoreDesign.HeaderY)	
	surface.SetDrawColor( 10, 10, 10, 200 )
	surface.DrawRect(xOffset, yOffset+GAMEMODE.ScoreDesign.HeaderY, boardWidth, boardHeight-GAMEMODE.ScoreDesign.HeaderY)
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawOutlinedRect(xOffset, yOffset, boardWidth, boardHeight)
	surface.SetDrawColor(0, 0, 0, 50)
	surface.DrawOutlinedRect(xOffset-1, yOffset-1, boardWidth+2, boardHeight+2)	
	local hostname = GetHostName()
	local gamemodeName = game.GetMap()
	surface.SetTextColor(255, 255, 255, 255)	
	if (string.len(hostname) > 32) then
		surface.SetFont("ScoreboardSub")
	else
		surface.SetFont("ScoreboardHead")
	end
	local txWidth, txHeight = surface.GetTextSize(hostname)
	local y = yOffset + 15
	surface.SetTextPos(xOffset + (boardWidth / 2) - (txWidth/2), y)
	surface.DrawText(hostname)
	y = y + txHeight + 2	
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetFont("ScoreboardSub")
	local txWidth, txHeight = surface.GetTextSize(gamemodeName)
	surface.SetTextPos(xOffset + (boardWidth / 2) - (txWidth/2), y)
	surface.DrawText(gamemodeName)
	y = y + txHeight + 4
	GAMEMODE.ScoreDesign.HeaderY = y - yOffset
	surface.SetFont( "ScoreboardText" )
	local txWidth, txHeight = surface.GetTextSize( "W" )	
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawRect( xOffset, y, boardWidth, txHeight + 6 )
	y = y + 2	
	surface.SetTextPos( xOffset + 16,								y)	surface.DrawText("#Name")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*4) - 18,	y)	surface.DrawText("Score")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*3) + 8,	y)	surface.DrawText("K")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*2) + 8,	y)	surface.DrawText("D")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*1) + 8,	y)	surface.DrawText("P")	
	y = y + txHeight + 4
	local yPosition = y
	for team,info in pairs(ScoreboardInfo) do		
		local teamText = info.TeamName .. "  (" .. #info.Players .. " Players)"		
		surface.SetFont( "ScoreboardText" )
		surface.SetTextColor( 0, 0, 0, 255 )		
		txWidth, txHeight = surface.GetTextSize( teamText )
		surface.SetDrawColor( info.Color.r, info.Color.g, info.Color.b, 255 )
		surface.DrawRect( xOffset+1, yPosition, boardWidth-2, txHeight + 4)
		yPosition = yPosition + 2
		surface.SetTextPos( xOffset + boardWidth/2 - txWidth/2, yPosition )
		surface.DrawText( teamText )
		yPosition = yPosition + 2	
		yPosition = yPosition + txHeight + 2		
		for index,plinfo in pairs(info.Players) do		
			surface.SetFont( "ScoreboardText" )
			surface.SetTextColor( info.Color.r, info.Color.g, info.Color.b, 200 )
			surface.SetTextPos( xOffset + 16, yPosition )
			txWidth, txHeight = surface.GetTextSize( plinfo.Name )			
			if (plinfo.PlayerObj == LocalPlayer()) then
				surface.SetDrawColor( info.Color.r, info.Color.g, info.Color.b, 50 )
				surface.DrawRect( xOffset+1, yPosition, boardWidth - 2, txHeight + 2)
				surface.SetTextColor( info.Color.r, info.Color.g, info.Color.b, 255 )
			end			
			local px, py = xOffset + 16, yPosition
			local textcolor = Color( info.Color.r, info.Color.g, info.Color.b, alpha )
			local shadowcolor = Color( 0, 0, 0, alpha * 0.8 )
			draw.SimpleText( plinfo.Name, "ScoreboardText", px+1, py+1, shadowcolor )
			draw.SimpleText( plinfo.Name, "ScoreboardText", px, py, textcolor )
			px = xOffset + boardWidth - (colWidth*4) - 18
			draw.SimpleText( plinfo.Score, "ScoreboardText", px+1, py+1, shadowcolor )
			draw.SimpleText( plinfo.Score, "ScoreboardText", px, py, textcolor )
			px = xOffset + boardWidth - (colWidth*3) + 8
			draw.SimpleText( plinfo.Frags, "ScoreboardText", px+1, py+1, shadowcolor )
			draw.SimpleText( plinfo.Frags, "ScoreboardText", px, py, textcolor )
			px = xOffset + boardWidth - (colWidth*2) + 8			
			draw.SimpleText( plinfo.Deaths, "ScoreboardText", px+1, py+1, shadowcolor )
			draw.SimpleText( plinfo.Deaths, "ScoreboardText", px, py, textcolor )			
			px = xOffset + boardWidth - (colWidth*1) + 8			
			draw.SimpleText( plinfo.Ping, "ScoreboardText", px+1, py+1, shadowcolor )
			draw.SimpleText( plinfo.Ping, "ScoreboardText", px, py, textcolor )
			yPosition = yPosition + txHeight + 3
		end
	end	
	yPosition = yPosition + 8	
	GAMEMODE.ScoreDesign.Height = (GAMEMODE.ScoreDesign.Height * 2) + (yPosition-yOffset)
	GAMEMODE.ScoreDesign.Height = GAMEMODE.ScoreDesign.Height / 3
	
end

