
include "wac/aircraft.lua"
include "wac/keyboard.lua"

wac.hook("wacAirAddInputs", "wac_aircraft_baseinputs", function()

	wac.aircraft.addControls("Flight Controls", {
		Throttle = {{-1, 1}, KEY_W, KEY_S},
		Pitch = {{-1, 1}, KEY_W, KEY_S},
		Yaw = {{-1, 1}, KEY_Q, KEY_E},
		Roll = {{-1, 1}, KEY_D, KEY_A},
		Start = {true, KEY_R},
		Hover = {true, MOUSE_4},
	})

	wac.aircraft.addControls("Common", {
		Exit = {true, KEY_E},
		FreeView = {true, KEY_SPACE},
		Camera = {true, KEY_ALT},
	})

	wac.aircraft.addControls("Weapons", {
		Fire = {true, MOUSE_LEFT},
		NextWeapon = {true, MOUSE_RIGHT}
	})

end)


wac.hook("JoystickInitialize", "wac_air_jcon_init", function()
	wac.aircraft.initialize()
	wac.aircraft.joyControls = {}
	for i, category in pairs(wac.aircraft.controls) do
		for name, control in pairs(category.list) do
			wac.aircraft.joyControls[name] = jcon.register({
				uid = "wac_air_"..name,
				type = ((control[1] == true) and "digital" or "analog"),
				description = name,
				category = "WAC Aircraft"
			})
		end
	end
	wac.aircraft.joyInitialized = true
	wac.aircraft.joyCache = {}
end)



if SERVER then

	AddCSLuaFile("autorun/wac_aircraft_input.lua")

	concommand.Add("wac_air_input", function(p, c, a)
		if IsValid(p) and p:Alive() then
			local e = p:GetVehicle():GetNWEntity("wac_aircraft")
			if IsValid(e) then
				e:receiveInput(a[1], tonumber(a[2]), p:GetNWInt("wac_passenger_id"))
			end
		end
	end)


	wac.hook("Think", "wac_aircraft_mouseinput", function()
		for _, p in pairs(player.GetAll()) do
			local e = p:GetVehicle():GetNWEntity("wac_aircraft")
			if IsValid(e) and p.wac.mouseInput and p:GetInfo("wac_cl_air_mouse") == "1" then
				local m = tonumber(p:GetInfo("wac_cl_air_sensitivity") or "1")
				local v = e:WorldToLocal(e:GetPos() + p:GetAimVector())
				local pid = p:GetNWInt("wac_passenger_id")
				e:receiveInput(
					"Pitch",
					math.Clamp(v.z*m*(p:GetInfo("wac_cl_air_mouse_invert_pitch")=="1" and 1 or -1)*10, -1, 1),
					pid
				)
				e:receiveInput(
					p:GetInfo("wac_cl_air_mouse_swap")=="0" and "Yaw" or "Roll",
					math.Clamp(v.y*m*(p:GetInfo("wac_cl_air_mouse_invert_yawroll")=="1" and 1 or -1)*10, -1, 1),
					pid
				)
			end
		end
	end)


	wac.hook("Think", "wac_aircraft_joyinput", function() 
		if wac.aircraft.joyInitialized then
			for _, p in pairs(player.GetAll()) do
				local e = p:GetVehicle():GetNWEntity("wac_aircraft")
				if IsValid(e) then
					for i, category in pairs(wac.aircraft.controls) do
						for name, control in pairs(category.list) do
							local n = joystick.Get(p, "wac_air_"..name)
							if n != wac.aircraft.joyCache[name] then
								wac.aircraft.joyCache[name] = n
								n = (n == true and 1 or (n == false and 0 or (n/127.5-1)))
								e:receiveInput(name, n, p:GetNWInt("wac_passenger_id"))
							end
						end
					end
				end
			end
		end
	end)


else

	wac.hook("wacKey", "wac_cl_aircraft_keyboard", function(key, pressed)
		local vehicle = LocalPlayer():GetVehicle():GetNWEntity("wac_aircraft")
		if !IsValid(vehicle) or vgui.CursorVisible() then return end
		local k = 0
		for i, category in pairs(wac.aircraft.controls) do
			for name, k in pairs(category.list) do
				if !k[3] then
					if GetConVar("wac_cl_air_key_" .. name):GetInt() == key then
						RunConsoleCommand("wac_air_input", name, (pressed and "1" or "0"))
						vehicle:receiveInput(name, pressed and 1 or 0, LocalPlayer():GetNWInt("wac_passenger_id"))
					end
				else
					if GetConVar("wac_cl_air_key_" .. name .. "_Inc"):GetInt() == key then
						RunConsoleCommand("wac_air_input", name, tostring(pressed and k[1][2] or "0"))
						vehicle:receiveInput(name, pressed and k[1][2] or 0, LocalPlayer():GetNWInt("wac_passenger_id"))
					elseif GetConVar("wac_cl_air_key_" .. name .. "_Dec"):GetInt() == key then
						RunConsoleCommand("wac_air_input", name, tostring(pressed and k[1][1] or "0"))
						vehicle:receiveInput(name, pressed and k[1][1] or 0, LocalPlayer():GetNWInt("wac_passenger_id"))
					end
				end
			end
		end
	end)

	
	wac.hook("Initialize", "wac_aircraft_finishinputs", function(p)
		if !wac.aircraft.init then
			hook.Run("wacAirAddInputs")
			wac.aircraft.init = true

			for i, category in pairs(wac.aircraft.controls) do	
				for name, key in pairs(category.list) do
					if !key[3] then
						CreateClientConVar("wac_cl_air_key_" .. name, key[2], true, true)
					else
						CreateClientConVar("wac_cl_air_key_" .. name .. "_Inc", key[2], true, true)
						CreateClientConVar("wac_cl_air_key_" .. name .. "_Dec", key[3], true, true)
					end
				end
			end
		end
	end)


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

