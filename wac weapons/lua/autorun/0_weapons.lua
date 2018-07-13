
include "wac/base.lua"


local function sprinting(p)
    if p and IsValid(p) then
        return ((p:KeyDown(IN_SPEED) and (p:GetVelocity():Length()+10)>100))
    end
end

local function runsReloadSequence(weapon)
    return string.find(weapon:GetSequenceName(weapon:GetSequence()), "reload")
end

local function zoomed(w)
    local p = LocalPlayer()
    if p and p:GetCanZoom() and w and !w.NoZoom and !sprinting(p) and not runsReloadSequence(w) then
        if p:KeyDown(IN_ATTACK2) or (w.Zoomed and w:Zoomed()) then
            return true
        end
    end
    if p:Alive() and IsValid(w) and w:GetClass()=="w_wac_test" then

    end
    return false
end


local VMPosAdd = Vector(0,0,0)

local cvars = {
    allow = CreateClientConVar("wac_cl_wep_allview", 1, true, true),
    offsetY = CreateClientConVar("wac_cl_wep_yoffset", 0, true, false),
    fov = CreateClientConVar("wac_cl_wep_fovmod", 0, true, false),
    bounce = CreateClientConVar("wac_cl_wep_bounce", 0.6, true, false),
    maxangle = CreateClientConVar("wac_cl_wep_maxangle", 15, true, false),
    numerator = CreateClientConVar("wac_cl_wep_numerator", 2.5, true, false),
    denominator = CreateClientConVar("wac_cl_wep_denominator", 5, true, false),
    exponent = CreateClientConVar("wac_cl_wep_exponent", 5, true, false),
}

local CV={
    CC=CreateClientConVar("wac_cl_customcrosshair", 0, true, true)
}

local function CheckSwep(self)
    if self.wac_weaponview_ignore then
        return
    end
    if self.wac and self.wac.weapons then
        return true
    end
    if IsValid(self) and !self.wac or !self.wac.weaponPrepared then
        if wac.weapons.weaponClasses[self:GetClass()] then
            print("WAC Weapons: Found registered class " .. self:GetClass())
            local data = wac.weapons.weaponClasses[self:GetClass()]
            if data.disable then
                self.wac_weaponview_ignore = true
                return
            end
            self.DrawCrosshair = false
            self.AimPos = data.pos
            self.AimAng = data.ang
            self.RunPos = data.runpos
            self.RunAng = data.runang
            self.NoZoom = !data.zoom
            self.wac = self.wac or {}
            self.wac.noSights = data.noSights
            self.wac.noSprint = data.noSprint
            self.IniCrosshair = data.crosshair
        elseif self.IsWACWeapon then
            if self.ZoomStages then
                self.zoomLevel = self.ZoomStages[1]
            else
                self.zoomLevel = 0
            end
        else
            return false
        end
        self.wac = self.wac or {}
        self.wac.weapons = {
            recoil = Vector(0, 0, 0)
        }
        self.zmFull=false
        return true
    end
    return false
end

local function CheckAllow(self, p)
    if !p:Alive() or p:InVehicle() or p:GetViewEntity()!=p then return false end
    if IsValid(self) and cvars.allow:GetInt()==1 or self.IsWACWeapon then return true end
    return false
end

function ChangeZoom(ply, bind, pressed)
    local self = ply:GetActiveWeapon()
    if GetGlobalBool("WAC_DISABLE_AIM") or self.wac_weaponview_ignore then return end
    if self.IsWACWeapon and zoomed(self) and self.zmFull and self.ZoomStages then
        if bind=="invprev" then
            if pressed then
                for k, v in pairs(self.ZoomStages) do
                    if v == self.zoomLevel and k < #self.ZoomStages then
                        self.zoomLevel = self.ZoomStages[k+1]
                        break
                    end
                end
            end
            return true
        elseif bind=="invnext" then
            if pressed then
                for k, v in pairs(self.ZoomStages) do
                    if v == self.zoomLevel and k > 1 then
                        self.zoomLevel = self.ZoomStages[k-1]
                        break
                    end
                end
            end
            return true
        end
    end
    if CheckAllow(self, ply) and (bind=="+attack" or bind=="+attack2") and (self:GetClass() != "weapon_physgun") then
        if sprinting(ply) then return true end
    end
end
wac.hook("PlayerBindPress", "wac_selfs_modifyzoom_alt", ChangeZoom)

local function AddRecoil(um)
    if GetGlobalBool("WAC_DISABLE_AIM") then return end
    local wep = LocalPlayer():GetActiveWeapon()
    if um:ReadBool() then
        wep.RecoilTime = CurTime()+0.1
    end
    if wep.FakeUnzoom and wep.Zoomed then
        timer.Simple(wep.Primary.Delay*0.1, function()
            wep.FakeZoomTime = CurTime() + wep.ReZoomTime
        end)
    end
end
usermessage.Hook("wac_self_alt_addrecoil", AddRecoil)

local lastzoom=0
wac.hook("Think", "wac_cl_weapon_zoomthink", function()
    local crt=CurTime()
end)

local lastFootstep = 0
local footstepTime = 0
wac.hook("PlayerFootstep", "wac_cl_weapon_footstep_time", function(ply, pos, foot, sound, volume, filter)
    if CLIENT and ply == LocalPlayer() then
        footstepTime = CurTime() - lastFootstep
        lastFootstep = lastFootstep + footstepTime
    end
end)

local viewtime = 0

local vars = {
    zoom = 0,
    holster = 0,
    ground = 0,
    speed = Vector(0,0,0),
    collide = Vector(0,0,0),
    ang = Angle(0,0,0),
    angAdd = Angle(0,0,0),
    angLag = Angle(0,0,0),
    angDelta = Angle(0,0,0),
    sprinting = 0,
    zoomLevel = 0,
    reloading = 0,
    smoothen = function(self, lvel, weapon, FrT, tr, vang, ang, flip)
        self.zoom = wac.ripTarget(self.zoom, (zoomed(weapon))and(1)or(0), 0, 6, FrT)
        self.holster = 0--wac.smoothApproach(self.holster,(weapon.Holstered(weapon))and(1)or(0),50,5)
        self.reloading = wac.ripTarget(self.reloading, runsReloadSequence(weapon) and 1 or 0, 1, 5, FrT)
        self.sprinting = wac.ripTarget(
            self.sprinting,
            (sprinting(weapon.Owner) or ((weapon:GetClass()=="w_wac_test")
                and(GetConVar("wac_cl_wep_help_sprint"):GetInt()==1)))and(1)or(0),
            0,
            7,
            FrT
        )
        if weapon.zoomLevel then
            self.zoomLevel = wac.ripTarget(self.zoomLevel, weapon.zoomLevel, 1, 20, FrT)
        end
        self.ground = wac.ripTarget(self.ground, (weapon.Owner:OnGround())and(1)or(0), 1, 20, FrT)
        --wac.smoothApproachVector(v_smWall, tr.StartPos+tr.Normal*23-tr.HitPos, 25)
        self.speed = wac.ripVector(self.speed, lvel*0.6, 0, 7, FrT)
        self.speed.x = math.Clamp(self.speed.x,-700,700)
        self.speed.y = math.Clamp(self.speed.y,-700,700)
        self.speed.z = math.Clamp(self.speed.z,-700,700)
        self.angAdd.p = wac.ripTarget(self.angAdd.p, math.AngleDifference(vang.p,ang.p), 10, 30, FrT)
        self.angAdd.y = wac.ripTarget(self.angAdd.y, math.AngleDifference(vang.y,ang.y)*flip, 10, 30, FrT)

        self.angLag = Angle(
            wac.ripTarget(self.angLag.p, vang.p, 5, 10, FrT),
            wac.ripTarget(self.angLag.y, vang.y, 5, 10, FrT),
            wac.ripTarget(self.angLag.r, vang.r, 5, 10, FrT)
        )

        self.angDelta = Angle(
            math.AngleDifference(self.angLag.p, vang.p),
            math.AngleDifference(self.angLag.y, vang.y),
            math.AngleDifference(self.angLag.r, vang.r)
        )

    end
}

local v_smSway=Vector(0,0,0)
local zoomrmb=false
local lastzoom=0
local OldAimAngles = Angle(0, 0, 0)

wac.hook("CreateMove", "wac_self_alt_recoil", function(user)
    local pl = LocalPlayer()
    local self = pl:GetActiveWeapon()
    if self.wac_weaponview_ignore or not self.wac or not self.wac.weapons then return end
    local AimAngles = user:GetViewAngles()
    if !CheckAllow(self, pl) or !IsValid(self) or !CheckSwep(self) then return end
    local NewAimAngles = AimAngles
    local vel = pl:GetVelocity()
    local lvel = vel:Length()
    local crt = CurTime()
    local self=pl:GetActiveWeapon()
    if pl:KeyDown(IN_ATTACK2) then
        if lastzoom < crt then
            if !self.wac.noSights and !zoomrmb then
                self.InZoom = !self.InZoom
                zoomrmb=true
                lastzoom=crt+0.2
            end
        end
    else
        zoomrmb=false
    end
    local vm=pl:GetViewModel()
    if self.InZoom and (vm:GetSequence()==vm:LookupSequence("reload") or sprinting(pl)) then
        self.InZoom=false
    end
    local FrT=math.Clamp(FrameTime(), 0.001, 0.035)
    if self.RecoilTime and self.RecoilTime > crt then
        local maxrec = self.Primary.Recoil
        if zoomed(self) then
            maxrec = maxrec-maxrec/3
        end
        if pl:KeyDown(IN_DUCK) then
            maxrec = maxrec-maxrec/3
        end
        if lvel > 0 then
            maxrec = maxrec + lvel/500
        end
        local mul=(self.RecoilTime-crt)
        if (zoomed(self) and !self.SendZoomedAnim) then
            local recoil = Vector(
                math.Clamp(self.BackPushY*mul*500*FrT, -1, 1),
                0,
                math.Clamp(self.BackPushZ*mul*10*FrT, -1, 1)
            )
            self.wac.weapons.recoil = self.wac.weapons.recoil + recoil
        elseif (!zoomed(self) and !self.SendShootAnim) then
            VMPosAdd.y=math.Clamp(self.BackPushNY*mul*1000*FrT, -3, 3)
            VMPosAdd.z=math.Clamp(self.BackPushNZ*mul*1000*FrT, -3, 3)      
        end
        NewAimAngles = NewAimAngles + Angle(
                math.Rand(-maxrec*2, maxrec*0.5)*mul*300*FrT,
                math.Rand(-maxrec*2, maxrec*2)*mul*300*FrT,
                0
        )
    end
    if (self.wac_swep_alt and self:Zoomed()) and self.ZoomOverlay and self.zmFull then
        NewAimAngles = NewAimAngles + Angle(
                math.AngleDifference(OldAimAngles.p, AimAngles.p)*(90-vars.zoomLevel)/90,
                math.AngleDifference(OldAimAngles.y, AimAngles.y)*(90-vars.zoomLevel)/90,
                math.AngleDifference(OldAimAngles.r, AimAngles.r)*0.85
            )
    end
    NewAimAngles.p = math.Clamp(NewAimAngles.p,-90+10*vars.sprinting,90-vars.sprinting*30)
    OldAimAngles = NewAimAngles
    local m=(pl:KeyDown(IN_DUCK) and 0.5 or 1)
    m=(zoomed(self) and m*0.8 or m*1)
    --wac.smoothApproachVector(v_smSway,VectorRand()*0.5*m,10)
    NewAimAngles=NewAimAngles+Angle(v_smSway.x,v_smSway.y,0)
    user:SetViewAngles(NewAimAngles)
end)


local watches = {}

local function watch(name, value)
    watches[name] = value
end

wac.hook("HUDPaint", "wac_cl_customcrosshair_paint", function()
    local p=LocalPlayer()
    local wep=p:GetActiveWeapon()
    if !IsValid(p) or !p:Alive() or !IsValid(wep) then return end
    if GetGlobalBool("WAC_DISABLE_AIM") or wep.wac_weaponview_ignore then return end
    
    if
            CheckAllow(wep, p)
            and (
                (
                    (
                        GetConVar("wac_allow_crosshair")
                        and GetConVar("wac_allow_crosshair"):GetInt()==1
                    )   or (
                        wep:GetClass() == "gmod_tool" or wep:GetClass() == "weapon_physgun"
                    )
                ) and (
                    CV.CC:GetInt()==1
                    or wep.IniCrosshair
                )
            )
            and !sprinting(p)
            and !zoomed(wep)
    then
        local pos = util.QuickTrace(p:EyePos(),p:GetAimVector()*1000,p).HitPos:ToScreen()
        
        surface.SetDrawColor(255,255,255,255)
        surface.SetTexture(surface.GetTextureID("vgui/crosshair"))
        surface.DrawTexturedRect(pos.x-32, pos.y-32, 64, 64)

    end
    if p:Alive() and IsValid(wep) and wep:GetClass()=="w_wac_test" then
        local pos=util.QuickTrace(p:EyePos(),p:GetAimVector()*99999,p).HitPos:ToScreen()
        surface.SetDrawColor(255,255,255,255)
        surface.DrawLine(pos.x-10,pos.y,pos.x+10,pos.y)
        surface.DrawLine(pos.x,pos.y+10,pos.x,pos.y-10)
        local screen = {w = ScrW(), h = ScrH()}
        surface.DrawLine(screen.w/2-10, screen.h/2, screen.w/2+10, screen.h/2)
        surface.DrawLine(screen.w/2, screen.h/2-10, screen.w/2, screen.h/2+10)
    end
    local watchOffset = 0
    local screen = {w = ScrW(), h = ScrH()}
    for name, value in pairs(watches) do
        
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(50, screen.h-200+watchOffset, 300, 18)
        
        surface.SetTextColor(255,255,255,255)
        surface.SetFont("DermaDefault")
        surface.SetTextPos(55, screen.h-200+watchOffset)
        surface.DrawText(name .. ": " .. tostring(value))
        watchOffset = watchOffset + 18
    end
end)

local view={}
local viewang
local oldang
local lastpos=Vector(0,0,0)
local SprintTime = 0

wac.hook("HUDShouldDraw", "wac_weapons_hidehud", function(name)
    local player = LocalPlayer()
    if !IsValid(player) then return end
    local weapon = player:GetActiveWeapon()
    if CheckAllow(weapon, player) and name == "CHudCrosshair" then
        return false
    end
end)

local viewModelTransform = nil

local function CalculateViewModel(weapon, isWAC, vars, runAnim, flip, swayMul, playerSpeed, angDelta)

    local vm = Matrix()
    --PrintTable(vm:ToTable())
    local localVelocity = WorldToLocal(vars.speed, Angle(0,0,0), Vector(0,0,0), viewang)
    local flipv = Vector(1, flip, 1)
    vm:Rotate(viewang - vars.angAdd * 0.75)
    vm:Translate(Vector(
        (Vector(0, flip*0.05, -0.05)*(1-vars.zoom)
        - Vector(0, -flip*0.01, 0.01)*vars.zoom)
        * Vector(0, angDelta.y, angDelta.p)
    ))
    if weapon.UseWACSway then
        vm:Translate(Vector(0, runAnim.y, runAnim.x)*math.Clamp(localVelocity:Length()/500, 0.1, 2)*(1-vars.zoom*0.95)*cvars.bounce:GetFloat())
    end
    
    if isWAC then
        vm:Translate(flipv*-localVelocity/100*(1-vars.zoom*0.9))
        vm:Rotate(weapon.AimAng*vars.zoom)
        vm:Translate(Vector(weapon.AimPos.y, -flip*weapon.AimPos.x, weapon.AimPos.z)*vars.zoom*(1-vars.reloading*0.5))
        vm:Translate(Vector(cvars.offsetY:GetFloat()*(1-vars.zoom)*(1-vars.sprinting), 0, 0))
        --vm:Translate(-flip*vars.speed*(1.5-vars.zoom)*0.004)
        vm:Translate(weapon.wac.weapons.recoil)
        vm:Translate(Vector(
            weapon.RunPos.y,
            flip*weapon.RunPos.x,
            weapon.RunPos.z
        )*vars.sprinting*(1-vars.reloading*0.5))
        vm:Rotate(Angle(
            weapon.RunAng.p,
            -flip*weapon.RunAng.y,
            -flip*weapon.RunAng.r
        )*vars.sprinting*(1-vars.holster)*(1-vars.reloading*0.5))
    end
    
    return vm

end


wac.hook("CalcView", "wac_weapons_cview", function(p, pos, ang, fov)
    local pl=LocalPlayer()
    if pl:InVehicle() or !pl:Alive() then return end
    local self=p:GetActiveWeapon()
    if GetGlobalBool("WAC_DISABLE_AIM") or self.wac_weaponview_ignore then
        view = null
        return
    end
    if !IsValid(self) then return end
    if !CheckAllow(self, pl) then
        view = nil
        viewang=ang
        viewang.r=0
        return
    end
    local isWAC = CheckSwep(self)
    if not view then
        view = {}
    end
    local vel=pl:GetVelocity()
    local FrT=FrameTime()
    local flip = self.ViewModelFlip and -1 or 1

    viewang = viewang or ang
    local AngleDiff = {
        p = math.AngleDifference(viewang.p, ang.p),
        y = math.AngleDifference(viewang.y, ang.y)
    }

    limit = {
        p = math.max(math.abs(AngleDiff.p)-cvars.maxangle:GetFloat()*(1-vars.sprinting), 0),
        y = math.max(math.abs(AngleDiff.y)-cvars.maxangle:GetFloat()*(1-vars.sprinting), 0)
    }

    viewang.p = viewang.p - wac.rip(AngleDiff.p/cvars.denominator:GetFloat(), 0, 4+limit.p, FrT)*cvars.numerator:GetFloat()
    viewang.y = viewang.y - wac.rip(AngleDiff.y/cvars.denominator:GetFloat(), 0, 4+limit.y, FrT)*cvars.numerator:GetFloat()
    viewang.r = ang.r

    local ri = viewang:Right()
    local up = viewang:Up()
    
    local TraceForward = util.QuickTrace(pos, ang:Forward()*23, self.Owner)
    
    vars:smoothen(vel, self, FrT, TraceForward, viewang, ang, flip)

    local lvel = vars.speed:Length()/100

    SprintTime = SprintTime+math.Clamp(lvel*1.05,0.1,2)*FrT+0.0001
    local runAnim = {
        x = math.sin(SprintTime*10)*vars.ground,
        y = math.sin(SprintTime*5)*vars.ground
    }
    local SwayMul = (0.1*math.Clamp(1-vars.zoom,0.05,1)*(p:KeyDown(IN_DUCK) and 0.1 or 1))

    if isWAC then
        wac.ripVector(self.wac.weapons.recoil, Vector(0, 0, 0), 1, 5, FrT)

        if (vars.zoom >= 0.9 and zoomed(self) and self.ZoomOverlay and !self.zmFull) then
            self.zmFull = true
            self.zoomBlack=255
            pl:GetViewModel():SetNoDraw(true)
        elseif self.zmFull and vars.zoom < 0.9 then
            self.zmFull = false
            pl:GetViewModel():SetNoDraw(false)
        end

        view.fov = math.Clamp(
                    fov - ((fov-vars.zoomLevel)*((vars.zoom>=0.9 and self.ZoomStages) and 1 or 0))
                        * vars.zoom
                        - (not self.ZoomStages and 20 or 0)*vars.zoom
                        + cvars.fov:GetFloat(),
                    1.5,
                    100
                )
        if self.ScopeModel then
            local fwd = viewang:Forward()
            fwd.z=math.Clamp(fwd.z,-1,(1-vars.sprinting))
            self.ScopeModel:SetPos(pos+vars.speed.x*fwd*-0.01+vars.speed.y*ri*0.002+vars.speed.z*up*-0.002)
            self.ScopeModel:SetAngles(viewang-Angle(vars.angAdd.p,vars.angAdd.y*flip,vars.angAdd.r))
            local scale = Vector(0.5, view.fov/90, view.fov/90)
            local mat = Matrix()
            mat:Scale(scale)
            self.ScopeModel:EnableMatrix("RenderMultiply", mat)
        end

    else
        view.fov = fov
    end

    vm = CalculateViewModel(self, isWAC, vars, runAnim, flip, SwayMul, lvel, vars.angDelta)

    view.angles_orig = ang
    view.origin_orig = pos
    view.angles = viewang
    view.origin = pos
    -- + Angle(0+runAnim.x*0,0,vars.speed.y*-0.0125)
      --                      * (lvel/250)
        --                    * vars.ground*cvars.bounce:GetFloat()
    viewModelTransform = vm
    view.vm_angles = vm:GetAngles()
    -- view.znear=1
    return view
end)



local disableNextModelView = false

wac.hook("CalcViewModelView", "wac_calc_weaponsview_viewmodel", function(wep, entity, oldPos, oldAng, pos, ang)
    if disableNextModelView then
        return
    end
    if view and viewModelTransform then
        disableNextModelView = true
        r_pos, r_ang = hook.Run("CalcViewModelView", wep, entity, oldPos, oldAng,  pos, ang)
        disableNextModelView = false
        local addAng = Angle(0,0,0)
        if r_pos and r_ang and view.origin then
            local localOffset = pos-r_pos
            localOffset:Rotate(-view.angles_orig)
            local transformBack = Matrix()
            transformBack:Translate(view.origin_orig)
            transformBack:Rotate(view.angles_orig)
            viewModelTransform:Translate(transformBack:GetInverse()*r_pos)

            local translation = viewModelTransform:GetTranslation()
            viewModelTransform:Rotate(r_ang-ang)
        end
        p = viewModelTransform:GetTranslation()+view.origin_orig
        a = viewModelTransform:GetAngles()
        return p, a
    end
end)
