
include("shared.lua")


function ENT:Initialize()
	self.seats = {}
	self.passengers = {}
end


wac.hook("wacKey", "wac_seatswitcher_input", function(key, pressed)
	if not pressed or vgui.CursorVisible() then return end
	if key >= 2 and key <= 10 then
		RunConsoleCommand("wac_setseat", key-1)
	end
end)


net.Receive("wac.seatSwitcher.switch", function(length)
	local switcher = net.ReadEntity()
	local count = net.ReadInt(8)
	for i = 1, count do
		local e = net.ReadEntity()
		e.wac_seatswitcher = switcher
		switcher.seats[i] = e
		switcher.passengers[i] = IsValid(e) and e:GetPassenger() or nil
	end
end)