
include("shared.lua")

function ENT:Initialize()
	self.seats = {}
	self.passenger = {}
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:updateSeats()
	for i=1,9 do
		local e = self:GetNWEntity(i)
		if IsValid(e) then
			if self.seats[i] != e then
				MsgN("added seat number " .. i)
				self.seats[i] = e
				e.wac_seatswitcher = self.Entity
			end
			local p = e:GetPassenger()
			self.passenger[i] = (IsValid(p) and p or nil)
		else
			self.seats[i] = nil
			self.passenger[i] = nil
		end
	end
end

function ENT:Think()
	local crt = CurTime()
	local p = LocalPlayer()
	for i = 2, 10 do
		if input.IsKeyDown(i) and (!p.LastKeyDown or p.LastKeyDown < crt) and !vgui.CursorVisible() then
			RunConsoleCommand("wac_setseat", i-1)
			p.LastKeyDown = crt+0.1
			break
		end
	end
	self:updateSeats()
	self:NextThink(crt)
	return true
end

