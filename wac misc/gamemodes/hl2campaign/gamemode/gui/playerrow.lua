local PANEL = {}
local FRIEND_INDICATOR = surface.GetTextureID("VGUI/ico_friend_indicator_scoreboard")

function PANEL:ApplySchemeSettings()
	self.nameLabel:SetFont("arial16Bold")
	self.statusLabel:SetFont("arial16Bold")
	self.scoreLabel:SetFont("arial16Bold")
	self.deathsLabel:SetFont("arial16Bold")
	self.pingLabel:SetFont("arial16Bold")
end

function PANEL:HigherOrLower(row)
	if !self.pl:IsValid() || self.pl:Team() == TEAM_CONNECTING then return false end
	if !row.pl:IsValid() || row.pl:Team() == TEAM_CONNECTING then return true end
	
	if self.pl:Frags() == row.pl:Frags() then
		return self.pl:Deaths() < row.pl:Deaths()
	end

	return self.pl:Frags() > row.pl:Frags()
end

function PANEL:Init()
	self.pl = 0
	self.avatarImage = vgui.Create("AvatarImage", self)
	self.nameLabel = vgui.Create("DLabel", self)
	self.statusLabel = vgui.Create("DLabel", self)
	self.scoreLabel = vgui.Create("DLabel", self)
	self.deathsLabel = vgui.Create("DLabel", self)
	self.pingLabel = vgui.Create("DLabel", self)
end

function PANEL:Paint()
	if LocalPlayer() == self.pl then
		surface.SetDrawColor(Color(125, 125, 125, 75))
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	end
	
	if self.pl:GetFriendStatus() == "friend" then
		surface.SetTexture(FRIEND_INDICATOR)
		surface.DrawTexturedRect(0, 0, 64, 64) 
	end
end

function PANEL:PerformLayout()
	self.avatarImage:SetPos(25, 1)
	self.avatarImage:SetSize(32, 32)
	self.nameLabel:SizeToContents()
	self.nameLabel:SetPos(58, 9)
	self.statusLabel:SizeToContents()
	self.statusLabel:SetPos(self:GetWide() - self.statusLabel:GetWide() - 200, 9)
	self.scoreLabel:SizeToContents()
	self.scoreLabel:SetPos(self:GetWide() - self.scoreLabel:GetWide() - 100, 9)
	self.deathsLabel:SizeToContents()
	self.deathsLabel:SetPos(self:GetWide() - self.deathsLabel:GetWide() - 50, 9)
	self.pingLabel:SizeToContents()
	self.pingLabel:SetPos(self:GetWide() - self.pingLabel:GetWide() - 5, 9)
end

function PANEL:SetPlayer(pl)
	self.pl = pl
	self.avatarImage:SetPlayer(pl)
end

function PANEL:UpdatePlayerRow()
	self.nameLabel:SetText(self.pl:Name())
	if self.pl:Team() != TEAM_ALIVE then
		self.statusLabel:SetText(team.GetName(self.pl:Team()))
	else
		self.statusLabel:SetText("")
	end
	self.scoreLabel:SetText(self.pl:Frags())
	self.deathsLabel:SetText(self.pl:Deaths())
	self.pingLabel:SetText(self.pl:Ping())
	self:InvalidateLayout()
end

vgui.Register("scoreboard_playerrow", PANEL, "Panel")
