
include('shared.lua')

function GM:PositionScoreboard(ScoreBoard)
	ScoreBoard:SetSize(700, ScrH() - 100)
	ScoreBoard:SetPos((ScrW() - ScoreBoard:GetWide())/2, 50)
end

