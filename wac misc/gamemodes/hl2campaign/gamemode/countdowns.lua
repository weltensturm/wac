
if CLIENT then

    local countdown = {time=0, msg="", msg_done=""}

    hook.Add("NextMap", "hl2c_countdown_nextmap", function(map)
        countdown.time = CurTime()+NEXT_MAP_TIME
        countdown.msg = "Next Map in {remaining_seconds}"
        countdown.msg_done = "Changing Map!"
    end)

    hook.Add("RestartMap", "hl2c_countdown_restartmap", function(map)
        print("asdf")
        countdown.time = CurTime()+RESTART_MAP_TIME
        countdown.msg = "Restarting Map in {remaining_seconds}"
        countdown.msg_done = "Restarting Map!"
    end)
    
    hook.Add("StartCampaign", "hl2c_countdown_startcampaign", function(name)
        countdown.time = CurTime()+NEXT_MAP_TIME
        countdown.msg = "Restarting campaign in {remaining_seconds}"
        countdown.msg_done = "Starting Campaign!"
    end)

    hook.Add("HUDPaint", "hl2c_countdown_draw", function()
        if countdown.time > 0 then
            local w = ScrW()
            local h = ScrH()
            local centerX = w / 2
            local centerY = h / 2
            local remaining_seconds = math.Round(countdown.time - CurTime())
            if remaining_seconds > 0 then
                local text = string.Replace(countdown.msg, "{remaining_seconds}", remaining_seconds)
                draw.DrawText(text, "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
            else
                draw.DrawText(countdown.msg_done, "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
            end
        end
    end)

end
