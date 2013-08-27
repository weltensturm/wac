
include('shared.lua')

surface.CreateFont( "coolvetica", 64, 500, true, false, "SandboxLabel" )

ENT.LabelColor = Color( 255, 255, 255, 255 )


// Default Draw Routine..
function ENT:Draw( bDontDrawModel )

	if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && 
	     EyePos():Distance( self:GetPos() ) < 256 ) then
	
		if ( self.RenderGroup == RENDERGROUP_OPAQUE ) then
			self.OldRenderGroup = self.RenderGroup
			self.RenderGroup = RENDERGROUP_TRANSLUCENT
		end

		if ( self:GetOverlayText() != "" ) then
			AddWorldTip( self:EntIndex(), self:GetOverlayText(), 0.5, self:GetPos(), self.Entity  )
		end

	else
	
		if ( self.OldRenderGroup != nil ) then
		
			self.RenderGroup = self.OldRenderGroup
			self.OldRenderGroup = nil
		
		end
	
	end

	if ( !bDontDrawModel ) then self:DrawModel() end
	
end

function ENT:DrawTranslucent( bDontDrawModel )

	if ( bDontDrawModel ) then return end
	
	if (  LocalPlayer():GetEyeTrace().Entity == self.Entity && 
		  EyePos():Distance( self:GetPos() ) < 256 ) then
	
		self:DrawEntityOutline( 1.0 )
		
	end
	
	self:Draw()

end

function ENT:DrawOverlayText()
	
	if ( !self:SetLabelVariables() ) then return end
	
	self:DrawLabel()

end

function ENT:DrawFlatLabel( size )

	local TargetAngle 	= self:GetAngles()
	local TargetPos 	= self:GetPos() - TargetAngle:Forward() * 16
	
	TargetAngle:RotateAroundAxis( TargetAngle:Up(), 90 )
	
	cam.Start3D2D( TargetPos, TargetAngle, 0.05 * size * self.LabelScale )
	
		local Shadow = Color( 0, 0, 0, self.LabelAlpha * 255 )
		draw.DrawText( self.LabelText, self.LabelFont,  3,  3, Shadow, TEXT_ALIGN_CENTER )

		self.LabelColor.a = self.LabelAlpha * 255
		draw.DrawText( self.LabelText, self.LabelFont, 0, 0, self.LabelColor, TEXT_ALIGN_CENTER )
		
	cam.End3D2D()

end

function ENT:SetLabelVariables()

	// Override this to set the label position, return true to draw and false to not draw.
	
	self.LabelText = self:GetOverlayText()
	if ( self.LabelText == "" ) then return false end
	
	// Only draw if so close
	self.LabelDistance = EyePos():Distance( self:GetPos() )
	if ( self.LabelDistance > 256 ) then return false end
		
	// Which way should our quad face
	self.LabelAngles = self:GetAngles()
	self.LabelAngles:RotateAroundAxis( self.LabelAngles:Right(), 90 )
	
	// Make sure we're standing in front of it (so we can see it)
	local ViewNormal = EyePos() - self:GetPos()
	ViewNormal:Normalize()
	local ViewDot = ViewNormal:Dot( self.LabelAngles:Forward() )
	if ( ViewDot < 0 ) then return false end
	
	// Set the label position
	self.LabelPos = self:GetPos() + self.LabelAngles:Forward() + self.LabelAngles:Up() * 4
	
	// Alpha
	self.LabelAlpha = (1 - self.LabelDistance / 256)^0.4
	
	self.LabelFont 	= "SandboxLabel"
	self.LabelScale = 1
	
	return true

end


local matOutlineWhite 	= Material( "white_outline" )
local ScaleNormal		= Vector()
local ScaleOutline1		= Vector() * 1.05
local ScaleOutline2		= Vector() * 1.1
local matOutlineBlack 	= Material( "black_outline" )

function ENT:DrawEntityOutline( size )
	
	size = size or 1.0
	render.SuppressEngineLighting( true )
	render.SetAmbientLight( 1, 1, 1 )
	render.SetColorModulation( 1, 1, 1 )
	
		// First Outline	
		self:SetModelScale( ScaleOutline2 * size )
		SetMaterialOverride( matOutlineBlack )
		self:DrawModel()
		
		
		// Second Outline
		self:SetModelScale( ScaleOutline1 * size )
		SetMaterialOverride( matOutlineWhite )
		self:DrawModel()
		
		// Revert everything back to how it should be
		SetMaterialOverride( nil )
		self:SetModelScale( ScaleNormal )
		
	render.SuppressEngineLighting( false )
	
	local r, g, b = self:GetColor()
	render.SetColorModulation( r/255, g/255, b/255 )

end
