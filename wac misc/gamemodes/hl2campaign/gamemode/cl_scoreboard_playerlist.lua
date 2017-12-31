// Include the required lua files
include("cl_scoreboard_playerrow.lua")


// Start our new vgui element
local PANEL = {}


// Apply the scheme of things
function PANEL:ApplySchemeSettings()
	self.nameLabel:SetFont("DefaultSmall")
	
	self.scoreLabel:SetFont("DefaultSmall")
	
	self.deathsLabel:SetFont("DefaultSmall")
	
	self.pingLabel:SetFont("DefaultSmall")
end


// Called when our vgui element is created
function PANEL:Init()
	self.playerRows = {}
	
	self.nameLabel = vgui.Create("Label", self)
	self.nameLabel:SetText("Name")
	
	self.scoreLabel = vgui.Create("Label", self)
	self.scoreLabel:SetText("Score")
	
	self.deathsLabel = vgui.Create("Label", self)
	self.deathsLabel:SetText("Deaths")
	
	self.pingLabel = vgui.Create("Label", self)
	self.pingLabel:SetText("Ping")
end


// Called every frame
function PANEL:Paint()
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawLine(0, 13, self:GetWide(), 13)
end


// Does the actual layout
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


// Updates the scoreboard
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


// Register our scoreboard element
vgui.Register("scoreboard_playerlist", PANEL, "Panel")