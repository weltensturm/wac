
include("shared.lua")

function ENT:Initialize()
	self.Seats={}
	self.Passenger={}
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:UpdateSeats()
	for i=1,9 do
		local e=self:GetNWEntity("seat"..i)
		if IsValid(e) then
			if self.Seats[i] != e then
				self.Seats[i]=e
				e.wac_seatswitcher=self.Entity
			end
			local p=e:GetPassenger()
			if IsValid(p) and self.Passenger[i] != p then
				self.Passenger[i]=p
			else
				self.Passenger[i]=nil
			end
		else
			self.Seats.wac_seatswitcher=nil
			self.Seats[i]=nil
			self.Passenger[i]=nil
		end
	end
end

function ENT:Think()
	local crt=CurTime()
	local p=LocalPlayer()
	self:UpdateSeats()
	for i=2, 10 do
		if input.IsKeyDown(i) and (!p.LastKeyDown or p.LastKeyDown < crt) and !vgui.CursorVisible() then
			RunConsoleCommand("wac_setseat", i-1)
			p.LastKeyDown=crt+0.1
			break
		end
	end
	self:NextThink(crt)
	return true
end

