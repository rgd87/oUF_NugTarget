local font1 = [[Interface\AddOns\oUF_Suupa\fonts\iFlash 706.TTF]]
local font1size = 8
--~ local font2 = [[Interface\AddOns\oUF_Suupa\fonts\Unvers.TTF]]
--~ local font2 = [[Interface\AddOns\oUF_Suupa\fonts\iFlash 706.TTF]]
local font2 = [[Interface\AddOns\oUF_Suupa\fonts\ClearFontBold.ttf]]
local font2size = 13

oUF.Tags.Events["shorthp"] = "UNIT_HEALTH"
oUF.Tags.Methods["shorthp"] = [[
function(u)
    local floor = math.floor
    local v = UnitHealth(u)
    local ms = floor(v/1000000)
    if ms > 10 then
        return ms.."M"
    else
        local ks = floor(v/1000)
        if  ks > 10 then
            return ks.."K"
        else
            return v
        end
    end
end
]]

local mana = {.4, .4, 1}
local colors = setmetatable({
    health = { .8, 0.15, 0.15}, {__index = oUF.health},
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


local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end


local execute_range

local ranges = {
    WARRIOR1 = 0.2,
    WARRIOR2 = 0.2,
    WARRIOR3 = 0.2,

    PRIEST1 = 0.2,
    PRIEST2 = 0.2,
    PRIEST3 = 0.2,
}
local SPELLS_CHANGED = function()
    local class = select(2, UnitClass("player"))
    local spec = GetSpecialization()
    if not spec then execute_range = nil; return end
    execute_range = ranges[class..spec]
end
local f = CreateFrame("Frame")
f:RegisterEvent("SPELLS_CHANGED")
-- f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", SPELLS_CHANGED)


local UnitIsTapDenied = UnitIsTapDenied
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend 
local PostUpdateHealth = function(self, unit, cur, max)
    -- print(unit, cur, max, execute_range )
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
    elseif execute_range and cur/max < execute_range then
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

local PostUpdatePower = function(self, event, unit, bar, min, max)
	if(min == 0) then
		bar.value:SetText()
	elseif(UnitIsDead(unit) or UnitIsGhost(unit)) then
		bar:SetValue(0)
	elseif(not UnitIsConnected(unit)) then
		bar.value:SetText()
	else
		bar.value:SetFormattedText('%s', min)
	end
end

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
--~ 	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = -2, right = -2, top = -2, bottom = -2},
}


local Redraw = function(self)
    if not self.model_path then return end

    self:SetModelScale(1)
    self:SetPosition(0,0,0)

    if type(self.model_path) == "number" then
        self:SetDisplayInfo(self.model_path)
    else
        self:SetModel(self.model_path)
    end
    self:SetModelScale(self.model_scale)
    self:SetPosition(self.ox, self.oy, self.oz)
end

local ResetTransformations = function(self)
    -- print(self:GetName(), "hiding", self:GetCameraDistance(), self:GetCameraPosition())
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
    local v = (cur - min) / (max - min)
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

local function CreateThreatBar(parent)
    local f = CreateFrame("StatusBar", "$parent_ThreatBar", parent)
    local width, height= 3, 20
    local tex = [[Interface\AddOns\oUF_Suupa\vstatusbar]]
    f:SetOrientation("VERTICAL")
    f:SetWidth(width)
    f:SetHeight(height)
    f:SetMinMaxValues(0,1)
    
    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
    f:SetBackdrop(backdrop)
    f:SetBackdropColor(0,0,0,0.5)
    f:SetStatusBarTexture(tex)
    -- 
    
    local bg = f:CreateTexture(nil,"BACKGROUND")
    bg:SetTexture(tex)
    bg:SetAllPoints(f)
    f.bg = bg

    f.SetColor = function(self, r,g,b)
        r,g,b = r+.3, g+.3, b+.3
        self:SetStatusBarColor(r,g,b)
        self.bg:SetVertexColor(r*.3,g*.3,b*.3)
    end

    f:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", "target")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")

    local UnitExists = UnitExists
    local IsInGroup = IsInGroup
    f:SetScript("OnEvent", function(self, event)
        if UnitExists("target") and (IsInGroup() or UnitExists("pet") ) then
            local isTanking, state, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation("player", "target")
            if scaledPercent then
                self:SetColor(GetPercentColor(1 - scaledPercent/100))
                self:SetValue(scaledPercent/100)
                self:Show()
                return
            end
        end
        self:Hide() 
    end)

    return f
end


local SuupaTarget = function( self, unit)
    local width = 307
    local height = 104
    self:SetHeight(height)
    self:SetWidth(width)

	self.menu = menu
	self.colors = colors

    local CustomOnEnter = function(self, ...)
        self.Name:Show()
        -- self.Info:Show()
        -- self.hppp:Show()
        -- self.hpp:Show()
        return UnitFrame_OnEnter(self, ...)
    end

    local CustomOnLeave = function(self, ...)
        self.Name:Hide()
        -- self.Info:Hide()
        -- self.hppp:Hide()
        -- self.hpp:Hide()
        return UnitFrame_OnLeave(self, ...)
    end

    self:SetScript("OnEnter", CustomOnEnter)
    self:SetScript("OnLeave", CustomOnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")
    
    
    
    
    

    local port = CreateFrame("PlayerModel",nil,self)
    local portsize = 60
    port.type = "3D"
    port:SetWidth(portsize)
    port:SetHeight(portsize)
    port:SetPoint("TOPRIGHT",self,"TOPRIGHT",-27,-23)
    
    self.Portrait = port
    
    

    local height = 25
    local width = 183
    local sparkWidth = 50

    -- local texture = [[Interface\AddOns\NugRunning\statusbar.tga]]
    -- local texture = [[Interface\TargetingFrame\UI-StatusBar]]
    local texture = [[Interface\AddOns\oUF_Suupa\statusbar1.tga]]

    local hp = CreateFrame("StatusBar",nil,self)
    hp:SetFrameStrata("LOW")
    hp:SetStatusBarTexture(texture)
    hp:GetStatusBarTexture():SetDrawLayer("ARTWORK",1)
    hp:SetHeight(height)
    hp:SetWidth(width)
    hp:SetPoint("TOPLEFT",self,"TOPLEFT",19,-20)

    -- local m = 0.35
    -- hp.SetColor = function(self, r,g,b)
    --     self:SetStatusBarColor(r,g,b)
    --     self.bg:SetVertexColor(r*m,g*m,b*m)
    -- end

    hp.colorTapping = true
    hp.colorDisconnected = true
    hp.frequentUpdates = true
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

    local ambientSmoke = MakeModelRegion(sf, hp:GetWidth(), hp:GetHeight(), "spells/acidburn_red.m2", -20, 0, -4.6 )
    -- ambientSmoke:SetAlpha(0.7)
    ambientSmoke:SetAllPoints(sf)

    sf:SetScrollChild(ambientSmoke)
    
    hp.model = sf


    local spark = hp:CreateTexture(nil, "OVERLAY", 7)
    spark:SetBlendMode("ADD")
    spark:SetTexture([[Interface\AddOns\oUF_Suupa\vialSparkH.tga]])
    spark:SetSize(sparkWidth, height)

    spark:SetPoint("CENTER", f, "TOP",0,0)
    spark:SetVertexColor(unpack(colors.health))
    hp.spark = spark

    local OriginalSetValue = hp.SetValue
    hp.SetValue = function(self, v)
        local min, max = self:GetMinMaxValues()
        local p = (v-min)/(max-min)
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

    local mp = CreateFrame("StatusBar",nil,self)
    mp:SetFrameStrata("LOW")
    mp:SetStatusBarTexture(texture)
    mp:GetStatusBarTexture():SetDrawLayer("ARTWORK",1)
    mp:SetHeight(9)
    mp:SetWidth(width)
    mp:SetPoint("TOPLEFT",self,"TOPLEFT",19,-50)


    mp.colorPower = true
    mp.colorDisconnected = true
    mp.colorTapping = true
    mp.frequentUpdates = true

    mp.bg = mp:CreateTexture(nil, "BORDER")
    mp.bg:SetAllPoints(mp)
    mp.bg:SetTexture(texture)
    mp.bg.multiplier = 0.3


    local spark = mp:CreateTexture(nil, "OVERLAY", 7)
    spark:SetBlendMode("ADD")
    spark:SetTexture([[Interface\AddOns\oUF_Suupa\vialSparkH.tga]])
    spark:SetSize(sparkWidth, 9)

    spark:SetPoint("CENTER", f, "TOP",0,0)
    spark:SetVertexColor(unpack(colors.health))
    mp.spark = spark

    local OriginalSetValue = mp.SetValue
    mp.SetValue = function(self, v)
        local min, max = self:GetMinMaxValues()
        local p = (v-min)/(max-min)
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



    local bg = self:CreateTexture(nil,"ARTWORK")
    -- bg:SetDrawLayer("ARTWORK",7)
    bg:SetAllPoints(self)
    bg:SetTexture[[Interface\AddOns\oUF_Suupa\target\targetBG]]
    bg:SetTexCoord(0,1,0,0.67)
    

--~ 	self.OverrideUpdateHealth = OverrideUpdateHealth



    --==< HEALTH BAR TEXT >==--
    local hpp = port:CreateFontString(nil, "OVERLAY", self.Portrait)
    hpp:SetFont(font1,font1size,"OUTLINE")
    hpp:SetJustifyH"LEFT"
    hpp:SetTextColor(0, 1, 0)
    hpp:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 0, 1)
    self:Tag(hpp, '[shorthp]')
    -- hpp:Hide()

    self.hpp = hpp
    
    local hppp = port:CreateFontString(nil, "OVERLAY", self.Portrait)
    hppp:SetFont(font1,font1size,"OUTLINE")
    hppp:SetJustifyH"LEFT"
    hppp:SetTextColor(0, 1, 0)
    hppp:SetPoint("BOTTOMLEFT", self.Portrait, "BOTTOMLEFT", 0, 0)
    self:Tag(hppp, '[perhp]')

    self.hppp = hppp


	--==< LEVEL TEXT >==--
    local info = self.Portrait:CreateFontString(nil, "OVERLAY", self.Portrait)
    info:SetFont(font1,font1size,"OUTLINE")
    info:SetJustifyH"RIGHT"
    info:SetTextColor(0, 1, 0)
    
    self:Tag(info, 'L[difficulty][level]')
    
    info:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMRIGHT", 1, 1)

    self.Info = info


    local threatbar = CreateThreatBar(self)
    threatbar:SetWidth(4)
    threatbar:SetHeight(25)
    threatbar:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMLEFT", -9, 28)
    threatbar:SetColor( 0.3, 0, 0)

    --==< NAME TEXT >==--
    local name = hp:CreateFontString(nil, "OVERLAY", self.Health)
    name:SetFont(font2,font2size,"OUTLINE")
    name:SetJustifyH"LEFT"
    name:SetTextColor(0,1,0)
    self:Tag(name, '[raidcolor][name]')
    
    
    name:SetPoint("LEFT",self.Health,"LEFT",10,0)
    name:SetPoint("RIGHT",self.Health,"RIGHT",-10,0)
    name:Hide()
                
    self.Name = name

    --==< AURAS >==--
	if(unit == 'target') then
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
            overlay:SetTexture([[Interface\AddOns\oUF_Suupa\buffBorder]])
            if not button.isDebuff then
                overlay:Show()
                overlay:SetVertexColor(0.6,0.6,0.6, 1)
                overlay.Hide = overlay.Show
            end
        end
        
		local buffs = CreateFrame("Frame", "oUF_Nuga_Buffs", self)
		buffs:SetPoint("TOPLEFT", self, "TOPRIGHT",-5,-10)
		buffs:SetHeight(24)
		buffs:SetWidth(72)
        buffs.PostCreateIcon = PostCreate

		buffs.size = 24
        buffs.initialAnchor = "TOPLEFT"
        buffs["growth-x"] = "RIGHT"
        buffs["growth-y"] = "DOWN"

		self.Buffs = buffs

		-- Debuffs
		local debuffs = CreateFrame("Frame", "oUF_Nuga_Debuffs", self)
		debuffs:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT",-27,5)
		debuffs:SetHeight(1)
		debuffs:SetWidth(width-120)
        debuffs.num = 16
        debuffs.PostCreateIcon = PostCreate

        -- debuffs.CustomFilter = function (   self, unit, icon, name, rank, texture, count, dtype,
                                            -- duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)
            -- if 
        -- end
        debuffs.PostUpdateIcon = function(icons, unit, icon, index, offset)
            -- icon.icon:SetScale(
            -- if icon.o
            -- print(unit)
            if icon.owner == "player" or icon.owner == "pet" or UnitIsFriend("player", unit) then
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
		debuffs.initialAnchor = "TOPLEFT"
        debuffs["growth-x"] = "RIGHT"
        debuffs["growth-y"] = "DOWN"
		debuffs.size = 24--28

		self.Debuffs = debuffs
	end
    
    --==< LEADER ICON >==--
    local leader = self.Portrait:CreateFontString(nil, "OVERLAY", self.Portrait)
    leader:SetFont(font1,font1size+1,"OUTLINE")
    leader:SetJustifyH"LEFT"
    leader:SetTextColor(0, 1, 0)
    leader:SetPoint("BOTTOMRIGHT",self.Info,"TOPRIGHT",0,3)
    leader:SetText("LDR")
    self.Leader = leader
    
    --==< RAID ICON >==--
    -- if unit == "target" then
        local raidicon = self.Portrait:CreateTexture(nil, "OVERLAY")
        raidicon:SetHeight(20)
        raidicon:SetWidth(20)
        -- raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        raidicon:SetPoint("TOPRIGHT",self.Portrait, "TOPRIGHT",0,0)
        self.RaidIcon = raidicon
    -- end
    
    
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



local SuupaTOT = function( self, unit)
    local width = 256 * 0.52
    local height = 88 * 0.52
    self:SetHeight(height)
    self:SetWidth(width)
    
    self.colors = colors


	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
    
--~ 	self.menu = menu
--~ 	self:RegisterForClicks"anyup"
--~ 	self:SetAttribute("*type2", "menu")


    
    self:SetFrameLevel(7)
    
    
    local width = 112
    local height = 15

    -- local texture = [[Interface\TargetingFrame\UI-StatusBar]]
    local texture = [[Interface\AddOns\oUF_Suupa\statusbar1.tga]]

    local hp = CreateFrame("StatusBar",nil,self)
    -- hp:SetFrameStrata("LOW")
    hp:SetStatusBarTexture(texture)
    hp:GetStatusBarTexture():SetDrawLayer("ARTWORK",1)
    hp:SetHeight(height)
    hp:SetWidth(width)
    hp:SetPoint("TOPLEFT",self,"TOPLEFT",11,-24)

    hp.colorTapping = true
    hp.colorDisconnected = true
    hp.frequentUpdates = true
    hp.colorHealth = true
    -- hp.Smooth = true

    hp.bg = hp:CreateTexture(nil, "BORDER")
    hp.bg:SetAllPoints(hp)
    hp.bg:SetTexture(texture)
    hp.bg.multiplier = 0.4

    hp.model = CreateFrame("Frame")
    
    self.Health = hp
    self.Health.PostUpdate = PostUpdateHealth
    
    
    local bg = hp:CreateTexture(nil,"ARTWORK")
    bg:SetDrawLayer("ARTWORK", 7)
    bg:SetAllPoints(self)
    bg:SetTexture[[Interface\AddOns\oUF_Suupa\target\totBG]]
    bg:SetTexCoord(0,1,0,88/128)
    
     --==< NAME TEXT >==--
    local name = hp:CreateFontString(nil, "OVERLAY", self.Health)
    name:SetFont(font2,font2size-2)
    name:SetJustifyH"LEFT"
    name:SetTextColor(1,1,1, 0.35)
    self:Tag(name, '[name]')
    
    name:SetPoint("LEFT",self.Health,"LEFT",10,0)
    name:SetPoint("RIGHT",self.Health,"RIGHT",-7,0)
    
    self.Name = name


end








oUF:RegisterStyle("SuupaTarget", SuupaTarget)
oUF:SetActiveStyle"SuupaTarget"
local target = oUF:Spawn("target","oUF_Target")

target:SetPoint("LEFT", UIParent, "CENTER", 230, -70)


oUF:RegisterStyle("SuupaTOT", SuupaTOT)
oUF:SetActiveStyle"SuupaTOT"
local targettarget = oUF:Spawn("targettarget","oUF_TargetTarget")
targettarget:SetPoint("BOTTOM",target,"TOP",61,-15)
