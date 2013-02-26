

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false



function ENT:SetOverlayText( text )
	self:SetNetworkedString( "GModOverlayText", text )
end

function ENT:GetOverlayText()

	local txt = self:GetNetworkedString( "GModOverlayText" )
	
	if ( txt == "" ) then
		return ""
	end
	
	if ( SinglePlayer() ) then
		return txt
	end

	local PlayerName = self:GetPlayerName()

	return txt .. "\n(" .. PlayerName .. ")"
	
end



function ENT:SetPlayer( ply )

	self:SetVar( "Founder", ply )
	self:SetVar( "FounderIndex", ply:UniqueID() )
	
	self:SetNetworkedString( "FounderName", ply:Nick() )
	
end

function ENT:GetPlayer()

	return self:GetVar( "Founder", NULL )
	
end

function ENT:GetPlayerIndex()

	return self:GetVar( "FounderIndex", 0 )
	
end

function ENT:GetPlayerName()

	local ply = self:GetPlayer()
	if ( ply != NULL ) then
		return ply:Nick()
	end

	return self:GetNetworkedString( "FounderName" )
	
end

