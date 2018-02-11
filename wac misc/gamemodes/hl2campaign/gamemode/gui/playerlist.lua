include("playerrow.lua")

local PANEL = {}

function PANEL:ApplySchemeSettings()
	self.nameLabel:SetFont("DefaultSmall")
	self.scoreLabel:SetFont("DefaultSmall")
	self.deathsLabel:SetFont("DefaultSmall")
	self.pingLabel:SetFont("DefaultSmall")
end

function PANEL:Init()
	self.playerRows = {}
	self.nameLabel = vgui.Create("DLabel", self)
	self.nameLabel:SetText("Name")
	self.scoreLabel = vgui.Create("DLabel", self)
	self.scoreLabel:SetText("Score")
	self.deathsLabel = vgui.Create("DLabel", self)
	self.deathsLabel:SetText("Deaths")
	self.pingLabel = vgui.Create("DLabel", self)
	self.pingLabel:SetText("Ping")
end

function PANEL:Paint()
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawLine(0, 13, self:GetWide(), 13)
end

function PANEL:PerformLayout()
	self.nameLabel:SizeToContents()
	self.nameLabel:SetPos(58, 0)
	self.scoreLabel:SizeToContents()
	self.scoreLabel:SetPos(self:GetWide() - self.scoreLabel:GetWide() - 100, 0)
	self.deathsLabel:SizeToContents()
	self.deathsLabel:SetPos(self:GetWide() - self.deathsLabel:GetWide() - 50, 0)
	self.pingLabel:SizeToContents()
	self.pingLabel:SetPos(self:GetWide() - self.pingLabel:GetWide() - 5, 0)
	local playerRowsSorted = {}
	for _, row in pairs(self.playerRows) do
		table.insert(playerRowsSorted, row)
	end
	table.sort(playerRowsSorted, function (a, b) return a:HigherOrLower(b) end)
	local y = 15
	for _, row in ipairs(playerRowsSorted) do
		row:SetPos(0, y)	
		row:SetSize(self:GetWide(), 35)
		row:UpdatePlayerRow()
		y = y + 35
	end
end

function PANEL:UpdatePlayerList()
	for pl, row in pairs(self.playerRows) do
		if !pl:IsValid() || pl:Team() != self.teamToList then
			row:Remove()
			self.playerRows[pl] = nil
		end
	end
	
	for _, pl in pairs(player.GetAll()) do
		if !self.playerRows[pl] then
			local playerRow = vgui.Create("scoreboard_playerrow", self)
			playerRow:SetPlayer(pl)
			self.playerRows[pl] = playerRow
		end
	end
	self:InvalidateLayout()
end

vgui.Register("scoreboard_playerlist", PANEL, "Panel")
