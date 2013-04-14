
include "wac/aircraft.lua"
include "wac/keyboard.lua"

if SERVER then

	AddCSLuaFile("autorun/wac_aircraft_input.lua")

	concommand.Add("wac_air_input", function(p, c, a)
		if IsValid(p) and p:Alive() then
			local e = p:GetVehicle():GetNWEntity("wac_aircraft")
			if IsValid(e) then
				e:receiveInput(p, a[1], tonumber(a[2]))
			end
		end
	end)


else

	wac.key.addHook("wac_cl_aircraft_keyboard", function(key, pressed)
		if (
			!LocalPlayer():GetVehicle():GetNWEntity("wac_aircraft"):IsValid()
			or vgui.CursorVisible()
		) then return end
		local k = 0
		for name, range in pairs(wac.aircraft.controls) do
			if type(range) == "boolean" then
				if GetConVar("wac_cl_air_key_" .. name):GetInt() == key then
					RunConsoleCommand("wac_air_input", name, (pressed and "1" or "0"))
				end
			else
				if GetConVar("wac_cl_air_key_" .. name .. "_Inc"):GetInt() == key then
					RunConsoleCommand("wac_air_input", name, tostring(pressed and range[2] or "0"))
				elseif GetConVar("wac_cl_air_key_" .. name .. "_Dec"):GetInt() == key then
					RunConsoleCommand("wac_air_input", name, tostring(pressed and range[1] or "0"))
				end
			end
		end
	end)


	for name, key in pairs(wac.aircraft.controls) do
		if type(key) == "boolean" then
			CreateClientConVar(
				"wac_cl_air_key_" .. name,
				wac.aircraft.keybindings[name] or 0,
				true, true
			)
		else
			CreateClientConVar(
				"wac_cl_air_key_" .. name .. "_Inc",
				wac.aircraft.keybindings[name .. "_Inc"] or 0,
				true, true
			)
			CreateClientConVar(
				"wac_cl_air_key_" .. name .. "_Dec",
				wac.aircraft.keybindings[name .. "_Dec"] or 0,
				true, true
			)
		end
	end


	-- block player use button and menu when in vehicle
	wac.hook("PlayerBindPress", "wac_cl_air_exit", function(p,bind)
		if bind == "+use" then
			local heli = p:GetVehicle():GetNWEntity("wac_aircraft")
			if IsValid(heli) then
				return true
			end
		end
	end)


end

