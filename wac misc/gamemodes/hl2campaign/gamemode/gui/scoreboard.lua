include("playerlist.lua")

local PANEL = {}

function PANEL:ApplySchemeSettings()
	self.hostnameLabel:SetFont("arial16")
	self.hostnameLabel:SetTextColor(Color(255, 220, 0, 255))
	
	self.numPlayersLabel:SetFont("arial16")
	self.numPlayersLabel:SetTextColor(Color(255, 220, 0, 255))
end

function PANEL:Init()
	self.hostnameLabel = vgui.Create("DLabel", self)
	
	self.numPlayersLabel = vgui.Create("DLabel", self)
	
	self.playerList = vgui.Create("scoreboard_playerlist", self)
	
	self:UpdateScoreboard()
	timer.Create("hl2c_scoreboard_updater", 0.5, 0, function() self:UpdateScoreboard() end, self)
end

function PANEL:Paint()
	draw.RoundedBox(0, 1, 1, self:GetWide() - 2, self:GetTall() - 2, Color(0, 0, 0, 170))
end

function PANEL:PerformLayout()
	local size = { w=700, h=ScrH()*0.6 }
	self:SetSize(size.w, size.h)
	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)
	
	self.hostnameLabel:SizeToContents()
	self.hostnameLabel:SetPos(10, 5)
	
	self.numPlayersLabel:SizeToContents()
	self.numPlayersLabel:SetPos(self:GetWide() - self.numPlayersLabel:GetWide() - 10, 5)
	
	self.playerList:SetPos(5, 30)
	self.playerList:SetSize(self:GetWide() - 10, self:GetTall() - 10)
end

function PANEL:UpdateScoreboard(force)
	if !force && !self:IsVisible() then return end
	self.hostnameLabel:SetText(GetGlobalString("ServerName"))
	local numPlayers = #player.GetAll()
	if numPlayers == 1 then
		self.numPlayersLabel:SetText("1 player")
	else
		self.numPlayersLabel:SetText(numPlayers.." players")
	end
	self:InvalidateLayout()
	self.playerList:UpdatePlayerList()
end

vgui.Register("scoreboard", PANEL, "Panel")
