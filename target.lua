local addonName, ns = ...

local font1 = [[Interface\AddOns\oUF_NugTarget\fonts\if706.TTF]]
local font1size = 8
-- local font2 = [[Interface\AddOns\oUF_NugTarget\fonts\Unvers.TTF]]
-- local font2 = [[Interface\AddOns\oUF_NugTarget\fonts\if706.TTF]]
local font2 = [[Interface\AddOns\oUF_NugTarget\fonts\AlegreyaSans-Bold.ttf]]
local font3 = [[Interface\AddOns\oUF_NugTarget\fonts\AlegreyaSans-Bold.ttf]]
local font2size = 13

local LibSpellLocks = LibStub("LibSpellLocks")
local LibAuraTypes = LibStub("LibAuraTypes")

local isClassic = select(4,GetBuildInfo()) <= 19999

oUF.Tags.Events["shorthp"] = "UNIT_HEALTH"
oUF.Tags.Methods["shorthp"] = [[
function(u)
    local format = string.format
    local v = UnitHealth(u)
    local ms = v/1000000
    if ms >= 10 then
        return format("%dM", ms)
    elseif ms >= 1 then
        return format("%.1fM", ms)
    else
        local ks = v/1000
        if ks >= 10 then
            return format("%dK", ks)
        elseif ks >= 1 then
            return format("%.1fK", ks)
        else
            return v
        end
    end
end
]]

local format = string.format

oUF.Tags.Events["tankthreat"] = "UNIT_THREAT_LIST_UPDATE"
oUF.Tags.Methods["tankthreat"] = function(unit)
    local isTanking, status, percentage, rawPercentage = UnitDetailedThreatSituation("player", unit)
    if isTanking then
        local lead = UnitThreatPercentageOfLead("player", unit)
        if not lead or lead == 0 then return end
        if lead > 999 then lead = 999 end
        local leadhex = ns:GetThresholdHexColor(lead, 100, 130, 200, 400)
        -- print(isTanking, lead)
        return format("|cff%s%d|r", leadhex, lead)
    elseif percentage and percentage > 50 then
        -- threathex = ns:GetThresholdHexColor(rawPercentage, 0, 100, 110)
        -- return format("|cff%s%d|r", threathex, rawPercent)
        local threathex = ns:GetThresholdHexColor(percentage, 100, 0)
        -- print(isTanking, percentage, rawPercentage)
        return format("|cff%s%d|r", threathex, percentage)
    end
end

local mana = {.4, .4, 1}
local colors = setmetatable({
    health = { .8, 0.15, 0.15},
    execute = { 1, .3, .45 },
	power = setmetatable({
		["MANA"] = mana,
		["RAGE"] = {0.9, 0, 0},
        -- ["FOCUS"] = {0.71, 0.43, 0.27},
		["ENERGY"] = {1, 1, 0.4},
        -- ["HAPPINESS"] = {0.19, 0.58, 0.58},
        -- ["RUNES"] = {0.55, 0.57, 0.61},
        -- ["RUNIC_POWER"] = {0, 0.82, 1},
        -- ["AMMOSLOT"] = {0.8, 0.6, 0},
        -- ["FUEL"] = {0, 0.55, 0.5},
        -- ["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
        -- ["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	}, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

ns.colors = colors



local IsInExecuteRange

function ns.UpdateExecute(new_execute)
    IsInExecuteRange = new_execute
end

local UnitIsTapDenied = UnitIsTapDenied
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local PostUpdateHealth = function(self, unit, cur, max)
    local health = self
    local self = health:GetParent()
    local r, g, b, t

    if (health.colorTapping and not UnitPlayerControlled(unit) and
        UnitIsTapDenied(unit) ) then
        t = self.colors.tapped
        health.model:SetAlpha(0)
    elseif(health.colorDisconnected and not UnitIsConnected(unit)) then
        t = self.colors.disconnected
        health.model:SetAlpha(0)
    -- elseif(health.colorClass and UnitIsPlayer(unit)) or
    --     (health.colorClassNPC and not UnitIsPlayer(unit)) or
    --     (health.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
    --     local _, class = UnitClass(unit)
    --     t = self.colors.class[class]
    --     health.model:SetAlpha(1)
    -- elseif(health.colorReaction and UnitReaction(unit, 'player')) then
    --     t = self.colors.reaction[UnitReaction(unit, "player")]
    --     health.model:SetAlpha(1)
    -- elseif(health.colorSmooth) then
    --     r, g, b = self.ColorGradient(min, max, unpack(health.smoothGradient or self.colors.smooth))
    elseif IsInExecuteRange and IsInExecuteRange(cur/max, unit, cur, max) then
        t = self.colors.execute
        health.model:SetAlpha(1)
    elseif(health.colorHealth) then
        t = self.colors.health
        health.model:SetAlpha(1)
    end

    if(t) then
        r, g, b = t[1], t[2], t[3]
    end

    if(b) then
        health:SetStatusBarColor(r, g, b)

        local bg = health.bg
        if(bg) then local mu = bg.multiplier or 1
            bg:SetVertexColor(r * mu, g * mu, b * mu)
        end
    end
end

local Redraw = function(self)
    if not self.model_path then return end

    self:SetModelScale(1)
    self:SetPosition(0,0,0)

    self:SetModel(self.model_path)

    self:SetModelScale(self.model_scale)
    self:SetPosition(self.ox, self.oy, self.oz)
end

local ResetTransformations = function(self)
    self:SetModelScale(1)
    self:SetPosition(0,0,0)
end

local MakeModelRegion = function(parent,w,h,model_path, x,y,z)
    local pmf = CreateFrame("PlayerModel", nil, parent )
    pmf:SetSize(w,h)

    pmf.model_scale = 1
    pmf.ox = x
    pmf.oy = y
    pmf.oz = z
    pmf.model_path = model_path

    pmf:SetScript("OnHide", ResetTransformations)
    pmf:SetScript("OnShow", Redraw)
    pmf.Redraw = Redraw
    pmf.ResetTransformations = ResetTransformations
    pmf:Redraw()

    -- local pmf = CreateFrame("Frame", nil, self )
    -- pmf:SetSize(w,h)

    -- local t = pmf:CreateTexture(nil, "ARTWORK", 2)
    -- t:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    -- t:SetVertexColor(0,0,0,0.4)
    -- t:SetAllPoints(pmf)

    return pmf
end

local ScrollFrameSetValue = function(self, cur)
    local max = self._max
    local min = self._min
    self._cur = cur
    local total = (max - min)
    local v =0
    if total ~= 0 then
        v = (cur - min) / total
    end
    if v > 1 then v = 1 end
    if v <= 0 then v = 0.001 end
    local H = self._width
    v = 1 - v
    local h = v*H
    -- print(h, 1-h, -(1-h))
    self:SetHorizontalScroll(h)
    -- self:SetHeight(h)
end

local ScrollFrameSetMinMaxValues = function(self, min, max)
    self._min = min
    self._max = max
end

local ScrollFrameGetMinMaxValues = function(self)
    return self._min, self._max
end
local ScrollFrameGetValue = function(self)
    return self._cur or 0
end
local ScrollFrameSetStatusBarTexture = function() end

local function GetPercentColor(percent)
    if percent <= 0 then
        return 1, 0, 0
    elseif percent <= 0.5 then
        return 1, percent*2, 0
    elseif percent >= 1 then
        return 0, 1, 0
    else
        return 2 - percent*2, 1, 0
    end
end

-- local function CreateThreatBar(parent)
--     local f = CreateFrame("StatusBar", "$parent_ThreatBar", parent)
--     local width, height= 3, 20
--     local tex = [[Interface\AddOns\oUF_NugTarget\vstatusbar]]
--     f:SetOrientation("VERTICAL")
--     f:SetWidth(width)
--     f:SetHeight(height)
--     f:SetMinMaxValues(0,1)

--     local backdrop = {
--         bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
--         insets = {left = -2, right = -2, top = -2, bottom = -2},
--     }
--     f:SetBackdrop(backdrop)
--     f:SetBackdropColor(0,0,0,0.65)
--     f:SetStatusBarTexture(tex)

--     local bg = f:CreateTexture(nil,"BACKGROUND")
--     bg:SetTexture(tex)
--     bg:SetAllPoints(f)
--     f.bg = bg

--     f.SetColor = function(self, r,g,b)
--         r,g,b = r+.3, g+.3, b+.3
--         self:SetStatusBarColor(r,g,b)
--         self.bg:SetVertexColor(r*.3,g*.3,b*.3)
--     end

--     f:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", "target")
--     f:RegisterEvent("PLAYER_TARGET_CHANGED")

--     local UnitExists = UnitExists
--     local IsInGroup = IsInGroup
--     f:SetScript("OnEvent", function(self, event)
--         if UnitExists("target") and (IsInGroup() or UnitExists("pet") ) then
--             local isTanking, state, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation("player", "target")
--             if isTanking and state > 1 then
--                 self:SetColor(GetThreatStatusColor(state))
--                 self:SetValue(1)
--                 self:Show()
--                 return
--             elseif scaledPercent then
--                 self:SetColor(GetPercentColor(1 - scaledPercent/100))
--                 self:SetValue(scaledPercent/100)
--                 self:Show()
--                 return
--             end
--         end
--         self:Hide()
--     end)

--     return f
-- end

local function CustomOnEnter(self, ...)
    self.Name:Show()
    -- self.Info:Show()
    -- self.hppp:Show()
    -- self.hpp:Show()
    return UnitFrame_OnEnter(self, ...)
end

local function CustomOnLeave(self, ...)
    self.Name:Hide()
    -- self.Info:Hide()
    -- self.hppp:Hide()
    -- self.hpp:Hide()
    return UnitFrame_OnLeave(self, ...)
end

function ns.oUF_NugTargetFrame(addCastbar)
    return function(self, unit)
        return ns.oUF_NugTargetFrame1(self, unit, addCastbar)
    end
end

function ns.oUF_NugTargetFrame1( self, unit, addCastbar)
    local width = 307
    local height = 104
    self:SetHeight(height-30)
    self:SetWidth(width)

	self.colors = colors

    self:SetScript("OnEnter", CustomOnEnter)
    self:SetScript("OnLeave", CustomOnLeave)

	self:RegisterForClicks"anyup"

    local port = CreateFrame("PlayerModel",nil,self)
    local portsize = 64
    port.type = "3D"
    port:SetWidth(portsize)
    port:SetHeight(portsize)
    port:SetFrameStrata("LOW")
    if not ns.isFlipped then
        port:SetPoint("TOPRIGHT",self,"TOPRIGHT",-25,-20)
    else
        port:SetPoint("TOPLEFT",self,"TOPLEFT", 25,-20)
    end

    local portbg = port:CreateTexture(nil, "BACKGROUND")
    portbg:SetTexture[[Interface\AddOns\oUF_NugTarget\target\portBG.tga]]
    portbg:SetPoint("TOPLEFT", port, "TOPLEFT", -1,0)
    portbg:SetPoint("BOTTOMRIGHT", port, "BOTTOMRIGHT", 0,0)

    local portIconFrame = CreateFrame("Frame", nil, self)
    local portIcon = portIconFrame:CreateTexture(nil,"ARTWORK", nil, 2)
    portIcon:SetAllPoints()
    portIcon:SetTexCoord(.1, .9, .1, .9)
    portIcon:SetAlpha(0.70)
    portIconFrame.tex = portIcon

    local portIconDS = portIconFrame:CreateTexture(nil,"ARTWORK")
    portIconDS:SetAllPoints()
    portIconDS:SetTexCoord(.1, .9, .1, .9)
    portIconFrame.tex0 = portIconDS
    portIconDS:SetDesaturated(true)

    port:SetFrameStrata("BACKGROUND")

    local picd = CreateFrame("Cooldown", "oUF_NugTargetPortraitCooldown", portIconFrame, "CooldownFrameTemplate")
    picd:SetEdgeTexture("Interface\\Cooldown\\edge");
    picd:SetSwipeColor(0, 0, 0);
    picd:SetDrawEdge(false);
    picd:SetHideCountdownNumbers(true);
    picd:SetReverse(true)
    picd:SetAllPoints(portIconFrame)
    -- picd:SetFrameLevel(4)
    portIconFrame.cd = picd

    portIconFrame:SetAllPoints(port)
    portIconFrame:SetFrameStrata("LOW")



    portIconFrame:RegisterUnitEvent("UNIT_AURA", "target")
    portIconFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    local filters = { "HARMFUL", "HELPFUL" }
    portIconFrame.Update = function(self)
        local unit = "target"
        if not UnitIsPlayer(unit) then
            self:Hide()
            return
        end
        local maxPrio = 0
        local maxPrioFilter
        local maxPrioIndex = 1
        for _, filter in ipairs(filters) do
            for i=1,100 do
                local name, icon, count, debuffType, duration, expirationTime, caster, _,_, spellID, canApplyAura, isBossAura = UnitAura(unit, i, filter)
                if not name then break end

                local rootSpellID, spellType, prio = LibAuraTypes.GetDebuffInfo(spellID)
                if prio and prio > maxPrio then
                    maxPrio = prio
                    maxPrioIndex = i
                    maxPrioFilter = filter
                end
            end
        end
        local isLocked = LibSpellLocks:GetSpellLockInfo(unit)
        local PRIO_SILENCE = LibAuraTypes.GetDebuffTypePriority("SILENCE")
        if isLocked and PRIO_SILENCE > maxPrio then
            maxPrio = PRIO_SILENCE
            maxPrioIndex = -1
        end
        if maxPrio >= PRIO_SILENCE then
            local name, icon, _, _, duration, expirationTime, _, _,_, spellID
            if maxPrioIndex == -1 then
                spellID, name, icon, duration, expirationTime = LibSpellLocks:GetSpellLockInfo(unit)
            else
                name, icon, _, _, duration, expirationTime, _, _,_, spellID = UnitAura(unit, maxPrioIndex, maxPrioFilter)
            end
            self.tex:SetTexture(icon)
            self.tex0:SetTexture(icon)
            self.cd:SetCooldown(expirationTime-duration, duration)
            self:Show()
        else
            self:Hide()
        end
    end

    portIconFrame:SetScript("OnEvent", function(self, event, unit)
        self:Update()
    end)
    LibSpellLocks.RegisterCallback(portIconFrame, "UPDATE_INTERRUPT", function(event, guid)
        -- if UnitGUID("target") == guid then
            portIconFrame:Update()
        -- end
    end)


    self.Portrait = port



    local height = 25
    local width = 183
    local sparkWidth = 50

    -- local texture = [[Interface\AddOns\NugRunning\statusbar.tga]]
    -- local texture = [[Interface\TargetingFrame\UI-StatusBar]]
    local texture = [[Interface\AddOns\oUF_NugTarget\statusbar1.tga]]

    local hp = CreateFrame("StatusBar",nil,self)
    hp:SetFrameStrata("MEDIUM")
    hp:SetStatusBarTexture(texture)
    hp:GetStatusBarTexture():SetDrawLayer("ARTWORK",1)
    hp:SetHeight(height)
    hp:SetWidth(width)
    if not ns.isFlipped then
        hp:SetPoint("TOPLEFT",self,"TOPLEFT",19,-20)
    else
        hp:SetPoint("TOPRIGHT",self,"TOPRIGHT", -19,-20)
    end

    hp.colorTapping = true
    hp.colorDisconnected = true
    hp.colorHealth = true
    hp.Smooth = true

    hp.bg = hp:CreateTexture(nil, "BORDER")
    hp.bg:SetAllPoints(hp)
    hp.bg:SetTexture(texture)
    hp.bg.multiplier = 0.4





    local sf = CreateFrame("ScrollFrame", nil, hp)

    sf._width = hp:GetWidth()
    sf.SetValue = ScrollFrameSetValue
    sf.SetMinMaxValues = ScrollFrameSetMinMaxValues
    sf.GetMinMaxValues = ScrollFrameGetMinMaxValues
    sf.GetValue = ScrollFrameGetValue
    sf.SetStatusBarTexture = ScrollFrameSetStatusBarTexture

    -- local health = MakeVial(sf, healthWidth, healthHeight, "HEALTH")
    sf:SetSize( hp:GetWidth(), hp:GetHeight())
    sf:SetPoint("LEFT", hp, "LEFT",0,0)

    -- [1249924] = "spells/7fx_ghost_red_state.m2"
    -- [165539] = "spells/acidburn_red.m2"

    local ambientSmoke
    if not isClassic then
        -- ambientSmoke = MakeModelRegion(sf, hp:GetWidth(), hp:GetHeight(), "spells/redghost_state.m2", 0, -0, 0 )
        -- ambientSmoke:SetFrameLevel(5)
        -- local ambientSmoke2 = MakeModelRegion(sf, hp:GetWidth(), hp:GetHeight(), "spells/redghost_state.m2", 0, 0.4, 0 )
        -- ambientSmoke:SetAllPoints(sf)
        -- ambientSmoke2:SetAllPoints(sf)
    -- else
        ambientSmoke = MakeModelRegion(sf, hp:GetWidth(), hp:GetHeight(), 165539, -20, 0, -4.6 )
        -- local ambientSmoke = MakeModelRegion(sf, hp:GetWidth(), hp:GetHeight(), 1249924,  3,0,1.2 )
        -- ambientSmoke:SetAlpha(0.7)
        ambientSmoke:SetAllPoints(sf)

        sf:SetScrollChild(ambientSmoke)
    end

    hp.model = sf


    local spark = hp:CreateTexture(nil, "ARTWORK", nil, 4)
    spark:SetBlendMode("ADD")
    spark:SetTexture([[Interface\AddOns\oUF_NugTarget\vialSparkH.tga]])
    spark:SetSize(sparkWidth, height)

    spark:SetPoint("CENTER", hp, "LEFT",0,0)
    spark:SetVertexColor(unpack(colors.health))
    hp.spark = spark

    local OriginalSetValue = hp.SetValue
    hp.SetValue = function(self, v)
        local min, max = self:GetMinMaxValues()
        local total = max-min
        local p
        if total == 0 then
            p = 0
        else
            p = (v-min)/(max-min)
        end
        local len = p*self:GetWidth()
        self.spark:SetPoint("CENTER", self, "LEFT", len, 0)
        self.model:SetValue(v)
        return OriginalSetValue(self, v)
    end

    local OriginalSetStatusBarColor = hp.SetStatusBarColor
    hp.SetStatusBarColor = function(self, r,g,b,a)
        self.spark:SetVertexColor(r,g,b,a)
        return OriginalSetStatusBarColor(self, r,g,b,a)
    end

    local OriginalSetMinMaxValues = hp.SetMinMaxValues
    hp.SetMinMaxValues = function(self, min, max)
        self.model:SetMinMaxValues(min,max)
        return OriginalSetMinMaxValues(self, min, max)
    end

    self.Health = hp
    self.Health.PostUpdate = PostUpdateHealth
    self.Health.UpdateColor = function(element, event, unit)
        local cur, max = UnitHealth(unit), UnitHealthMax(unit)
        element:PostUpdate(unit, cur, max)
    end

    local mp_height = 10

    local mp = CreateFrame("StatusBar",nil,self)
    mp:SetFrameStrata("MEDIUM")
    mp:SetStatusBarTexture(texture)
    mp:GetStatusBarTexture():SetDrawLayer("ARTWORK",1)
    mp:SetHeight(mp_height)
    mp:SetWidth(width)
    if not ns.isFlipped then
        mp:SetPoint("TOPLEFT",self,"TOPLEFT",19,-50)
    else
        mp:SetPoint("TOPRIGHT",self,"TOPRIGHT",-19,-50)
    end


    mp.colorPower = true
    mp.colorDisconnected = true
    mp.colorTapping = true
    mp.frequentUpdates = true

    mp.bg = mp:CreateTexture(nil, "BORDER")
    mp.bg:SetAllPoints(mp)
    mp.bg:SetTexture(texture)
    mp.bg.multiplier = 0.3


    local spark = mp:CreateTexture(nil, "ARTWORK", nil, 4)
    spark:SetBlendMode("ADD")
    spark:SetTexture([[Interface\AddOns\oUF_NugTarget\vialSparkH.tga]])
    spark:SetSize(sparkWidth, mp_height)

    spark:SetPoint("CENTER", mp, "LEFT",0,0)
    spark:SetVertexColor(unpack(colors.health))
    mp.spark = spark

    local OriginalSetValue = mp.SetValue
    mp.SetValue = function(self, v)
        local min, max = self:GetMinMaxValues()
        local total = max-min
        local p
        if total == 0 then
            p = 0
        else
            p = (v-min)/(max-min)
        end
        local len = p*self:GetWidth()
        self.spark:SetPoint("CENTER", self, "LEFT", len, 0)
        return OriginalSetValue(self, v)
    end

    local OriginalSetStatusBarColor = mp.SetStatusBarColor
    mp.SetStatusBarColor = function(self, r,g,b,a)
        self.spark:SetVertexColor(r,g,b,a)
        return OriginalSetStatusBarColor(self, r,g,b,a)
    end


    self.Power = mp


    local bg = hp:CreateTexture(nil,"ARTWORK", nil, 7)
    bg:SetPoint("TOPLEFT", self, "TOPLEFT",0,0)
    bg:SetWidth(307)
    bg:SetHeight(104)
    if ns.isFlipped then
        bg:SetTexture[[Interface\AddOns\oUF_NugTarget\target\targetBG_Flipped]]
    else
        bg:SetTexture[[Interface\AddOns\oUF_NugTarget\target\targetBG]]
    end
    bg:SetTexCoord(0,1,0,0.67)

--~ 	self.OverrideUpdateHealth = OverrideUpdateHealth



    --==< HEALTH BAR TEXT >==--


    local hppp = self.Portrait:CreateFontString(nil, "OVERLAY")
    hppp:SetFont(font1,font1size,"OUTLINE")
    hppp:SetJustifyH"LEFT"
    hppp:SetTextColor(0, 1, 0)
    hppp:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 1, -3)
    self:Tag(hppp, '[perhp]')

    self.hppp = hppp

    local hpp = self.Portrait:CreateFontString(nil, "OVERLAY")
    hpp:SetFont(font1,font1size,"OUTLINE")
    hpp:SetJustifyH"LEFT"
    hpp:SetTextColor(0, 1, 0)
    -- hpp:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 1, -3)
    hpp:SetPoint("TOPLEFT", hppp, "BOTTOMLEFT", 0, -2)
    self:Tag(hpp, '[shorthp]')
    -- hpp:Hide()

    self.hpp = hpp

	--==< LEVEL TEXT >==--
    local info = self.Portrait:CreateFontString(nil, "OVERLAY")
    info:SetFont(font1,font1size,"OUTLINE")
    info:SetJustifyH"RIGHT"
    info:SetTextColor(0, 1, 0)

    self:Tag(info, 'L[difficulty][level]')

    info:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMRIGHT", 1, 1)

    self.Info = info


    --==< THREAT BAR >==--
    if not isClassic and unit == "target" then
        local threatp = self.Portrait:CreateFontString(nil, "OVERLAY")
        threatp:SetFont(font1,font1size,"OUTLINE")
        threatp:SetJustifyH"LEFT"
        -- threatp:SetTextColor(0, 1, 0)
        -- threatp:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 1, -3)
        threatp:SetPoint("BOTTOMLEFT", self.Portrait, "BOTTOMLEFT", 1, 1)
        self:Tag(threatp, '[tankthreat]')

        -- local threatbar = CreateThreatBar(self)
        -- threatbar:SetFrameLevel(7)
        -- threatbar:SetWidth(5)
        -- threatbar:SetHeight(25)
        -- threatbar:SetPoint("TOPRIGHT",self,"TOPRIGHT",-95,-30)
        -- threatbar:SetColor( 0.3, 0, 0)

        -- local ThreatIndicator = self.Portrait:CreateTexture(nil, 'OVERLAY')
        -- ThreatIndicator.feedbackUnit = "player"
        -- ThreatIndicator:SetSize(16, 16)
        -- ThreatIndicator:SetPoint('TOPLEFT', self.Portrait, "TOPLEFT", 0, -20)

        -- -- Register it with oUF
        -- self.ThreatIndicator = ThreatIndicator
    end

    --==< NAME TEXT >==--
    local name = hp:CreateFontString(nil, "OVERLAY")
    name:SetFont(font2,font2size,"OUTLINE")
    name:SetJustifyH"LEFT"
    name:SetTextColor(0,1,0)
    self:Tag(name, '[raidcolor][name]')


    -- name:SetHeight(height)
    name:SetPoint("LEFT",self.Health,"LEFT",10,0)
    name:SetPoint("RIGHT",self.Health,"RIGHT",-10,0)
    name:Hide()

    self.Name = name

    --==< AURAS >==--
    -- Buffs
    local PostCreate = function (self, button, icons, index, debuff)
        button.cd:SetReverse(true)
        button.cd.noCooldownCount = true -- for OmniCC
        local overlay = button.overlay
        overlay:SetTexCoord(0,1,0,1)
        button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
        -- if not overlay then
        --     overlay = button:CreateTexture("$parentBorder", "OVERLAY")
        --     overlay:SetWidth(33); overlay:SetHeight(32);
        --     overlay:SetPoint("CENTER",0,0)
        -- end
        -- button.overlay = overlay
        overlay:SetTexture([[Interface\AddOns\oUF_NugTarget\buffBorder]])
        if not button.isDebuff then
            overlay:Show()
            overlay:SetVertexColor(0.6,0.6,0.6, 1)
            overlay.Hide = overlay.Show
        end
    end

    local buffs = CreateFrame("Frame", "$parentBuffs", self)
    buffs:SetHeight(24)
    buffs:SetWidth(72)
    buffs.PostCreateIcon = PostCreate
    buffs.num = 12

    buffs.size = 24
    if not ns.isFlipped then
        buffs:SetPoint("TOPLEFT", self, "TOPRIGHT",-5,-10)
        buffs.initialAnchor = "TOPLEFT"
        buffs["growth-x"] = "RIGHT"
        buffs["growth-y"] = "DOWN"
    else
        buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -8, -7)
        buffs.initialAnchor = "BOTTOMRIGHT"
        buffs["growth-x"] = "LEFT"
        buffs["growth-y"] = "UP"
        buffs:SetWidth(96)
    end

    self.Buffs = buffs

    -- Debuffs
    local debuffs = CreateFrame("Frame", "$parentDebuffs", self)
    debuffs:SetHeight(1)
    debuffs:SetWidth(150)
    debuffs.num = 16
    debuffs.PostCreateIcon = PostCreate

    debuffs.PostUpdateIcon = function(icons, unit, icon, index, offset)
        if icon.caster == "player" or icon.caster == "pet" or UnitIsFriend("player", unit) then
            icon:SetAlpha(1)
            -- icon.icon:SetDesaturated(0)
            -- icon:SetSize(36,36)
        else
            -- icon.icon:SetDesaturated(1)
            icon:SetAlpha(.5)
            -- icon:SetSize(28,28)
        end
    end

    debuffs.showDebuffType = true
    debuffs.size = 24--28

    if not ns.isFlipped then
        debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT",57,-1)
        debuffs.initialAnchor = "TOPLEFT"
        debuffs["growth-x"] = "RIGHT"
        debuffs["growth-y"] = "DOWN"
    else
        debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT",105,-1)
        debuffs.initialAnchor = "TOPLEFT"
        debuffs["growth-x"] = "RIGHT"
        debuffs["growth-y"] = "DOWN"
        debuffs:SetWidth(192)
    end

    self.Debuffs = debuffs

    if addCastbar then
        local cw,ch = 320, 27
        local castbar = ns:CreateCastbar(self, cw, ch, true)
        castbar:SetColor(0.6, 0, 1)

        castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT",40,-28)
        -- debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT",45,-4-ch)

        self.Castbar = castbar
    end



    --==< LEADER ICON >==--
    local leader = self:CreateFontString(nil, "OVERLAY")
    leader:SetFont(font1,font1size+1,"OUTLINE")
    leader:SetJustifyH"LEFT"
    leader:SetTextColor(0, 1, 0)
    leader:SetPoint("BOTTOMRIGHT",self.Info,"TOPRIGHT",0,3)
    leader:SetText("LDR")
    leader:Hide()
    self.Leader = leader

    --==< RAID ICON >==--
    local raidicon = self.Portrait:CreateTexture(nil, "OVERLAY")
    raidicon:SetHeight(20)
    raidicon:SetWidth(20)
    -- raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    raidicon:SetPoint("TOPRIGHT",self.Portrait, "TOPRIGHT",0,0)
    self.RaidTargetIndicator = raidicon


    self:EnableMouse(true)
    -- self:RegisterForDrag("LeftButton")
    -- self:SetMovable(true)
    -- self:SetScript("OnDragStart",function(self)
    --     if IsShiftKeyDown() then self:StartMoving() end
    -- end)
    -- self:SetScript("OnDragStop",function(self)
    --     self:StopMovingOrSizing();
    -- end)
end



function ns.oUF_NugTargetTargetFrame(self, unit)
    local width = 256 * 0.52
    local height = 88 * 0.52
    self:SetHeight(height)
    self:SetWidth(width)

    self.colors = colors


	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

 	self:RegisterForClicks"anyup"
    -- self:SetAttribute("*type2", "menu")



    self:SetFrameLevel(7)


    local width = 112
    local height = 15

    -- local texture = [[Interface\TargetingFrame\UI-StatusBar]]
    local texture = [[Interface\AddOns\oUF_NugTarget\statusbar1.tga]]

    local hp = CreateFrame("StatusBar",nil,self)
    hp:SetFrameStrata("MEDIUM")
    hp:SetStatusBarTexture(texture)
    hp:GetStatusBarTexture():SetDrawLayer("ARTWORK",1)
    hp:SetHeight(height)
    hp:SetWidth(width)
    hp:SetPoint("TOPLEFT",self,"TOPLEFT",11,-24)

    hp.colorTapping = true
    hp.colorDisconnected = true
    hp.colorHealth = true
    -- hp.Smooth = true

    hp.bg = hp:CreateTexture(nil, "BORDER")
    hp.bg:SetAllPoints(hp)
    hp.bg:SetTexture(texture)
    hp.bg.multiplier = 0.4

    -- hp.model = CreateFrame("Frame")

    self.Health = hp
    -- self.Health.PostUpdate = PostUpdateHealth


    local bg = hp:CreateTexture(nil,"ARTWORK")
    bg:SetDrawLayer("ARTWORK", 7)
    bg:SetAllPoints(self)
    bg:SetTexture[[Interface\AddOns\oUF_NugTarget\target\totBG]]
    bg:SetTexCoord(0,1,0,88/128)

     --==< NAME TEXT >==--
    local name = hp:CreateFontString(nil, "OVERLAY")
    name:SetFont(font2,font2size-2)
    name:SetNonSpaceWrap(false)
    name:SetJustifyH"LEFT"
    name:SetTextColor(1,1,1, 0.35)
    self:Tag(name, '[name]')

    name:SetPoint("TOPLEFT",self.Health,"TOPLEFT",7,0)
    name:SetPoint("BOTTOMRIGHT",self.Health,"BOTTOMRIGHT",-5,0)

    self.Name = name


end





-- function from LibCrayon
local function GetThresholdPercentage(quality, ...)
    local n = select('#', ...)
    if n <= 1 then
        return GetThresholdPercentage(quality, 0, ... or 1)
    end

    local worst = ...
    local best = select(n, ...)

    if worst == best and quality == worst then
        return 0.5
    end

    if worst <= best then
        if quality <= worst then
            return 0
        elseif quality >= best then
            return 1
        end
        local last = worst
        for i = 2, n-1 do
            local value = select(i, ...)
            if quality <= value then
                return ((i-2) + (quality - last) / (value - last)) / (n-1)
            end
            last = value
        end

        local value = select(n, ...)
        return ((n-2) + (quality - last) / (value - last)) / (n-1)
    else
        if quality >= worst then
            return 0
        elseif quality <= best then
            return 1
        end
        local last = worst
        for i = 2, n-1 do
            local value = select(i, ...)
            if quality >= value then
                return ((i-2) + (quality - last) / (value - last)) / (n-1)
            end
            last = value
        end

        local value = select(n, ...)
        return ((n-2) + (quality - last) / (value - last)) / (n-1)
    end
end

function ns:GetThresholdColor(quality, ...)
    if quality ~= quality then
        return 1, 1, 1
    end

    local percent = GetThresholdPercentage(quality, ...)

    if percent <= 0 then
        return 1, 0, 0
    elseif percent <= 0.5 then
        return 1, percent*2, 0
    elseif percent >= 1 then
        return 0, 1, 0
    else
        return 2 - percent*2, 1, 0
    end
end

function ns:GetThresholdHexColor(quality, ...)
    local r, g, b = self:GetThresholdColor(quality, ...)
    return string.format("%02x%02x%02x", r*255, g*255, b*255)
end


local MakeBorder = function(self, tex, left, right, top, bottom, level)
    local t = self:CreateTexture(nil,"BACKGROUND",nil,level)
    t:SetTexture(tex)
    t:SetPoint("TOPLEFT", self, "TOPLEFT", left, -top)
    t:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -right, bottom)
    return t
end



