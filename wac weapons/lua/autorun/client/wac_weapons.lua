
CreateClientConVar("wac_cl_weapons_showdevhelp", 1, true, true)

wac.addMenuPanel("Options", "WAC", "Weapons",
    function(panel, info)

        panel:AddControl("Label", {Text = "Settings"})

        panel:AddControl("Label", {Text = "Client Settings"})
        
        panel:CheckBox("Free View","wac_cl_wep_allview")
        
        local function slider(name, min, max, command)
            panel:AddControl("Slider", {
                Label=name,
                Type="float",
                Min=min,
                Max=max,
                Command=command,
            })
        end

        slider("Max Angle", 0, 50, "wac_cl_wep_maxangle")
        slider("Numerator", 1, 20, "wac_cl_wep_numerator")
        slider("Denominator", 1, 20, "wac_cl_wep_denominator")
        slider("Exponent", 1, 20, "wac_cl_wep_exponent")

        slider("Y Offset", 0, 3, "wac_cl_wep_yoffset")
        slider("FOV Offset", -90, 90, "wac_cl_wep_fovmod")
        slider("Sway", 0, 1, "wac_cl_wep_bounce")
        
        if game.SinglePlayer() then
            panel:CheckBox("Dev Helper","wac_cl_weapons_showdevhelp")
            if info["wac_cl_weapons_showdevhelp"]=="1" then

                panel:AddControl("Button", {
                    Label = "Give Viewmodel Weapon",
                    Command = "give w_wac_test",
                })

                panel:AddControl("Button", {
                    Label = "Get model of current weapon",
                    Command = "wac_cl_wep_help_setmodel 1",
                })

                panel:AddControl("TextBox", {
                    Label="Model",
                    MaxLength=512,
                    Text="",
                    Command="wac_cl_wep_help_model",
                })

                slider("X", -10, 10, "wac_cl_wep_help_x")
                slider("Y", -10, 10, "wac_cl_wep_help_y")
                slider("Z", -10, 10, "wac_cl_wep_help_z")

                slider("Pitch", -10, 10, "wac_cl_wep_help_pitch")
                slider("Yaw", -10, 10, "wac_cl_wep_help_yaw")
                slider("Roll", -10, 10, "wac_cl_wep_help_roll")

                --    M=CreateClientConVar("wac_cl_wep_help_model", "models/weapons/v_357.mdl", true, false),

                panel:CheckBox("Flip","wac_cl_wep_help_flip")
                panel:CheckBox("Sprint","wac_cl_wep_help_sprint")
                panel:CheckBox("Zoom","wac_cl_wep_help_zoom")
            
            
                slider("Running X", -90, 90, "wac_cl_wep_help_rx")
                slider("Running Y", -90, 90, "wac_cl_wep_help_ry")
                slider("Running Z", -90, 90, "wac_cl_wep_help_rz")
                slider("Running Pitch", -90, 90, "wac_cl_wep_help_rap")
                slider("Running Yaw", -90, 90, "wac_cl_wep_help_ray")
                slider("Running Roll", -90, 90, "wac_cl_wep_help_rar")

                panel:AddControl("Button", {
                    Label = "Print to console",
                    Command = "wac_cl_weaponhelp_print",
                })
            end
        end
    end,
    "wac_cl_weapons_showdevhelp"
)