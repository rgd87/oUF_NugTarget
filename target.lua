local texture = [[Interface\AddOns\oUF_Suupa\statusbar]]
local font = [[Interface\AddOns\oUF_Nuga\fonts\font.ttf]]

--~ local font1 = [[Interface\AddOns\oUF_Suupa\fonts\ConsoleSingle.TTF]]
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
    health = { 1, .3, .3}, {__index = oUF.health},
    execute = { 1, .3, .45 },
	power = setmetatable({
		["MANA"] = mana,
		["RAGE"] = {0.9, 0, 0},
--~ 		["FOCUS"] = {0.71, 0.43, 0.27},
		["ENERGY"] = {1, 1, 0.4},
--~ 		["HAPPINESS"] = {0.19, 0.58, 0.58},
--~ 		["RUNES"] = {0.55, 0.57, 0.61},
--~ 		["RUNIC_POWER"] = {0, 0.82, 1},
--~ 		["AMMOSLOT"] = {0.8, 0.6, 0},
--~ 		["FUEL"] = {0, 0.55, 0.5},
--~ 		["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
--~ 		["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	}, {__index = oUF.colors.power}),
--~ 	happiness = setmetatable({
--~ 		[1] = {.69,.31,.31},
--~ 		[2] = {.65,.63,.35},
--~ 		[3] = {.33,.59,.33},
--~ 	}, {__index = oUF.colors.happiness}),
--~ 	runes = setmetatable({
--~ 		[1] = {0.69, 0.31, 0.31},
--~ 		[2] = {0.33, 0.59, 0.33},
--~ 		[3] = {0.31, 0.45, 0.63},
--~ 		[4] = {0.84, 0.75, 0.65},
--~ 	}, {__index = oUF.colors.runes}),
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

local siValue = function(val)
	if(val >= 1e4) then
		return ("%.1f"):format(val / 1e3):gsub('%.', 'k')
    else
		return val
	end
end

local execute_range

local ranges = {
    WARLOCK1 = 0.2,
    WARLOCK2 = 0.25,
    WARLOCK3 = 0.2,

    WARRIOR1 = 0.2,
    WARRIOR2 = 0.2,
    WARRIOR3 = 0.2,

    ROGUE1 = 0.35,

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
    elseif(health.colorDisconnected and not UnitIsConnected(unit)) then
        t = self.colors.disconnected
    elseif(health.colorClass and UnitIsPlayer(unit)) or
        (health.colorClassNPC and not UnitIsPlayer(unit)) or
        (health.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
        local _, class = UnitClass(unit)
        t = self.colors.class[class]
    elseif(health.colorReaction and UnitReaction(unit, 'player')) then
        t = self.colors.reaction[UnitReaction(unit, "player")]
    elseif(health.colorSmooth) then
        r, g, b = self.ColorGradient(min, max, unpack(health.smoothGradient or self.colors.smooth))
    elseif execute_range and cur/max < execute_range then
        t = self.colors.execute
    elseif(health.colorHealth) then
        t = self.colors.health
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


local function CreateHBar(name, parent)
    local f = CreateFrame("Frame", name, parent)
    f.left = 0
    f.right = 1
    f.top =  0
    f.bottom =  1
    f.minvalue = 0
    f.maxvalue = 100    
    
    local t = f:CreateTexture(nil, "ARTWORK")
    
    t:SetPoint("TOPLEFT", f, "TOPLEFT",0,0)
    t:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",0,0)
    
    f.t = t
    
    f.SetCoord = function(self, left, right, top, bottom)
        self.left = left
        self.right = right
        self.top =  top
        self.bottom =  bottom
        self.t:SetTexCoord(left,right,top,bottom)
    end
    f.SetStatusBarTexture = function (self, texture)
        self.t:SetTexture(texture)
    end
    f.GetStatusBarTexture = function (self)
        return self.t:GetTexture()
    end
    f.SetStatusBarColor = function(self, r,g,b)
        self.t:SetVertexColor(r,g,b)
    end
    
    f.SetMinMaxValues = function(self, min, max)
        if max > min then
            self.minvalue = min
            self.maxvalue = max
        else
            self.minvalue = 0
            self.maxvalue = 1
        end
    end
    
    f.SetValue = function(self, val)
        if not val then return end
        
        local pos = (val-self.minvalue)/(self.maxvalue-self.minvalue)
        if pos == 0 then pos = 0.001 end
        local h = self:GetWidth()*pos
        self.t:SetWidth(h)
--~         print ("pos: "..pos)
--~         print (string.format("min:%s max:%s",self.minvalue,self.maxvalue))
--~         print((self.bottom-self.top)*pos)
--~         print(string.format("coords: %s %s %s %s",self.left,self.right, self.bottom - (self.bottom-self.top)*pos , self.bottom))
        self.t:SetTexCoord(self.left, self.right*pos, self.top , self.bottom)
    end
    
--~     f:SetValue(100)
    f:Show()
    
    return f
end


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
--~     BeenThere = "yes"
--~     local width = settings[unit.."-width"]
--~     local height = settings[unit.."-height"]
--~     local scale = settings[unit.."-scale"]
--~     local healthbarpart = 0.7
--~     local fontsize = 13
--~     local portsize = -2
--~     if (height) then    self:SetHeight(height); settings["initial-height"] = height; end
--~     if (width) then     self:SetWidth(width); settings["initial-width"] = width; end
--~     if (scale) then     self:SetScale(scale); settings["initial-scale"] = scale; end
    local width = 307
    local height = 104
    self:SetHeight(height)
    self:SetWidth(width)

	self.menu = menu
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")
    
    
    
    
    local bg = self:CreateTexture(nil,"BACKGROUND")
    bg:SetAllPoints(self)
    bg:SetTexture[[Interface\AddOns\oUF_Suupa\target\targetBG]]
    bg:SetTexCoord(0,1,0,0.67)

        local port = CreateFrame("PlayerModel",nil,self)
        local portsize = 60
        port.type = "3D"
--~         local port = CreateFrame("Frame",nil,self)
        port:SetWidth(portsize)
        port:SetHeight(portsize)
        port:SetPoint("TOPRIGHT",self,"TOPRIGHT",-27,-23)
        
--~         local pa = port:CreateTexture(nil,"OVERLAY")
--~         pa:SetPoint("BOTTOMLEFT",port,"BOTTOMLEFT",-10,-14)
--~         pa:SetPoint("TOPRIGHT",port,"TOPRIGHT",0,0)
--~         pa:SetTexture[[Interface\AddOns\Supa\targetPortAlpha.tga]]
--~         pa:SetBlendMode("BLEND")
--~         port:SetPoint("TOP", 0, 0)
--~         port:SetPoint("RIGHT", 0, 0)
        
        self.Portrait = port
    
    self.colors = colors
    
    
--~ 	local hp = CreateFrame("StatusBar",nil,self)
    local hp = CreateHBar(nil,self)
    hp:SetWidth(184)
    hp:SetHeight(40)
    hp:SetStatusBarTexture[[Interface\AddOns\oUF_Suupa\target\targetHealthBar.tga]]
    hp:SetStatusBarColor(1, .3, .3)
    hp:SetPoint("TOPLEFT",self,"TOPLEFT",19,-20)
    
--~     oUF.colors.health = { 1, .3, .3 }
--~     oUF.colors.health = { 0.5, 0.025,  0.05}
    
--~     Smooth Regen
    hp.colorTapping = true
    hp.colorDisconnected = true
    hp.frequentUpdates = true
    
    local hpbg = hp:CreateTexture(nil,"BACKGROUND")
    hpbg:SetAllPoints(hp)
    hpbg:SetTexture[[Interface\AddOns\oUF_Suupa\target\targetHealthBar.tga]]
--~     hpbg:SetVertexColor(0.5,.15,.15)
    
    hp.bg = hpbg
    hp.bg.multiplier = 0.5
    
    hp.colorHealth = true
    
    
        --==< HEALTH BAR TEXT >==--
        local hpp = hp:CreateFontString(nil, "OVERLAY", self.Portrait)
        hpp:SetFont(font1,font1size,"OUTLINE")
        hpp:SetJustifyH"LEFT"
        hpp:SetTextColor(0, 1, 0)
        hpp:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 0, 1)
--~         hpp.frequentUpdates = true
        self:Tag(hpp, '[shorthp]')
--~         hp.value = hpp
        
        local hppp = hp:CreateFontString(nil, "OVERLAY", self.Portrait)
        hppp:SetFont(font1,font1size,"OUTLINE")
        hppp:SetJustifyH"LEFT"
        hppp:SetTextColor(0, 1, 0)
        hppp:SetPoint("BOTTOMLEFT", self.Portrait, "BOTTOMLEFT", 0, 0)
        self:Tag(hppp, '[perhp]')
--~         hp.perc = hppp
    
    
    self.Health = hp
    
--~     return nil
    self.Health.PostUpdate = PostUpdateHealth
    

--~ 	self.OverrideUpdateHealth = OverrideUpdateHealth
    


	--==< POWER BAR >==--
--~     local mb = CreateFrame("StatusBar",nil,self)
    local mb = CreateHBar(nil,self)
    mb:SetWidth(131)
    mb:SetHeight(19)
    
    mb:SetStatusBarTexture[[Interface\AddOns\oUF_Suupa\target\targetPowerBar.tga]]
    mb:SetStatusBarColor(.4, .4, 1)
    mb:SetPoint("TOPRIGHT",hp,"BOTTOMRIGHT",0,-6.5)
    
    local mbbg = mb:CreateTexture(nil,"BACKGROUND")
    mbbg:SetAllPoints(mb)
    mbbg:SetTexture[[Interface\AddOns\oUF_Suupa\target\targetPowerBar.tga]]
    mb.bg = mbbg
    mb.bg.multiplier = 0.4
    
--~     mb.colorType = true --deprecated 1.1
    mb.colorPower = true
    mb.colorDisconnected = true
    mb.colorTapping = true
    mb.frequentUpdates = true
    
--~     oUF.colors.power["MANA"] = {.4, .4, 1}
--~     oUF.colors.power["RAGE"] = oUF.colors.power["MANA"]
--~     oUF.colors.power["RAGE"] = oUF.colors.power["MANA"]
--~     oUF.colors.power["FOCUS"] = oUF.colors.power["MANA"]
--~     oUF.colors.power["ENERGY"] = oUF.colors.power["MANA"]
    
--~     oUF.colors.power["MANA"] = { 0.2, 0.45, 0.75 }
--~     oUF.colors.power["RAGE"] = oUF.colors.power["MANA"]
--~     oUF.colors.power["RAGE"] = { 0.9, 0.17, 0.3 }
--~     oUF.colors.power["FOCUS"] = { 1, 0.8, 0 }
--~     oUF.colors.power["ENERGY"] = { 1, 0.9, 0.2 }
    self.Power = mb
--~     --==< POWER BAR TEXT>==--
        local mbp = mb:CreateFontString(nil, "OVERLAY", self.Portrait)
        mbp:SetFont(font1,font1size,"OUTLINE")
        mbp:SetJustifyH"RIGHT"
        mbp:SetTextColor(0, 1, 0)
        mbp:SetPoint("RIGHT", self.Power, "RIGHT", -10, 0)
        self.Power.value = mbp
        
        mbp:Hide()
        self.Power:EnableMouse(true)
        self.Power:SetScript("OnEnter", function(self) self.value:Show() end)
        self.Power:SetScript("OnLeave", function(self) self.value:Hide() end)


    
    self.PostUpdatePower = PostUpdatePower
	--==< LEVEL TEXT >==--
--~     if unit == "target" then
        local info = mb:CreateFontString(nil, "OVERLAY", self.Portrait)
        info:SetFont(font1,font1size,"OUTLINE")
        info:SetJustifyH"RIGHT"
        info:SetTextColor(0, 1, 0)
        
        self:Tag(info, 'L[difficulty][level]')
--~         self:Tag(info, 'L[difficulty][level] [raidcolor][smartclass]')
        
        info:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMRIGHT", 1, 1)

        self.Info = info


        local threatbar = CreateThreatBar(self)
        threatbar:SetWidth(4)
        threatbar:SetHeight(25)
        threatbar:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMLEFT", -9, 6)
        threatbar:SetColor( 0.3, 0, 0)
        --self.UNIT_LEVEL = updateInfoString
        --self:RegisterEvent"UNIT_LEVEL"
--~     end

    --==< NAME TEXT >==--
--~ 	if unit == "target" or unit == "targettarget" then
        local name = hp:CreateFontString(nil, "OVERLAY", self.Health)
        name:SetFont(font2,font2size,"OUTLINE")
        name:SetJustifyH"LEFT"
--~         name:SetTextColor(1, .5, .5)
        name:SetTextColor(0,1,0)
        self:Tag(name, '[raidcolor][name]')
        
        
        name:SetPoint("LEFT",self.Health,"LEFT",10,0)
        name:SetPoint("RIGHT",self.Health,"RIGHT",-10,0)
        
        self.Health.name = name
        name:Hide()
        self.Health:EnableMouse(true)
        self.Health:SetScript("OnEnter", function(self) self.name:Show() end)
        self.Health:SetScript("OnLeave", function(self) self.name:Hide() end)
        
--~         name:SetText("НевихтаНевихтаНевихтаНевихтаНевихтаНевихта")
        
        self.Name = name
--~     end


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
--~ 	else
--~ 		self:RegisterEvent"PLAYER_UPDATE_RESTING"
--~ 		self.PLAYER_UPDATE_RESTING = function(self)
--~ 			if(IsResting()) then
--~ 				self:SetBackdropBorderColor(.3, .3, .8)
--~ 			else
--~ 				local color = UnitReactionColor[UnitReaction(unit, 'player')]
--~ 				self:SetBackdropBorderColor(color.r, color.g, color.b)
--~ 			end
--~ 		end
	end
    
    --==< LEADER ICON >==--
--~ 	if unit == "target" then 
        local leader = hp:CreateFontString(nil, "OVERLAY", self.Portrait)
        leader:SetFont(font1,font1size+1,"OUTLINE")
        leader:SetJustifyH"LEFT"
        leader:SetTextColor(0, 1, 0)
        leader:SetPoint("BOTTOMRIGHT",self.Info,"TOPRIGHT",0,3)
        leader:SetText("LDR")
        self.Leader = leader
--~     end
    
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
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:SetScript("OnDragStart",function(self)
        if IsShiftKeyDown() then self:StartMoving() end
    end)
    self:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
    end)

	-- Range fading on party
--~ 	if(not unit) then
--~ 		self.Range = true
--~ 		self.inRangeAlpha = 1
--~ 		self.outsideRangeAlpha = .5
--~ 	end
end




--~ function oUF_Suupa_CastBar(self, unit)
--~         local height = 25
--~         local width = 200
--~         self:SetHeight(height)
--~         self:SetWidth(width)

--~         local cbbackdrop = {
--~             bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
--~             insets = {left = -2-height-2, right = -2, top = -2, bottom = -2},
--~         }
--~         
--~         local cb = CreateFrame"StatusBar"
--~         cb:SetWidth(width - height -2 )
--~         cb:SetHeight(height)
--~         cb:SetStatusBarTexture(texture)
--~         cb:SetStatusBarColor(1,0.35,0.3)
--~         cb:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
--~         
--~         local cbbg = cb:CreateTexture(nil, "BORDER")
--~         cbbg:SetAllPoints(cb)
--~         cbbg:SetTexture(texture)
--~         cb.bg = cbbg
--~         
--~         cb:SetParent(self)
--~         
--~         local sp = cb:CreateTexture(nil,"OVERLAY")
--~         sp:SetBlendMode("ADD")
--~         sp:SetHeight(height*3)
--~         sp:SetAlpha(0.8)
--~         cb.Spark = sp
--~         
--~         local ic = cb:CreateTexture(nil,"ARTWORK")
--~         ic:SetHeight(height)
--~         ic:SetWidth(height)
--~         ic:SetTexCoord(.07, .93, .07, .93)
--~         ic:SetPoint("RIGHT",cb,"LEFT",-2,0)
--~         cb.Icon = ic
--~         
--~         cb:SetBackdrop(cbbackdrop)
--~         cb:SetBackdropColor(0, 0, 0, 0.7)
--~         cb:SetBackdropBorderColor(.3, .3, .3, 1)
--~         
--~         self.Castbar = cb
--~     
--~         self.PostCastStart = function(self, event, unit, spellname, spellrank)  
--~             local color = { 1, 0.35, 0.3 }
--~             local multiplier = 0.3
--~             self.Castbar:SetStatusBarColor(unpack(color))
--~             self.Castbar.bg:SetVertexColor(color[1]*multiplier,color[2]*multiplier,color[3]*multiplier)
--~         end
--~         self.PostChannelStart = function(self, event, unit, spellname, spellrank)  
--~             local color = { 0.4, 0.8, 0.3 }
--~             local multiplier = 0.3
--~             self.Castbar:SetStatusBarColor(unpack(color))
--~             self.Castbar.bg:SetVertexColor(color[1]*multiplier,color[2]*multiplier,color[3]*multiplier)
--~         end
--~         
--~ end



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
    local bg = self:CreateTexture(nil,"BACKGROUND")
    bg:SetAllPoints(self)
    bg:SetTexture[[Interface\AddOns\oUF_Suupa\target\totBG]]
    bg:SetTexCoord(0,1,0,88/128)
    self:SetFrameLevel(3)

--~     local hp = CreateFrame("StatusBar",nil,self)
    local hp = CreateHBar(nil,self)
    hp:SetWidth(165 * 0.695)
    hp:SetHeight(46 * 0.7 - 2)
    hp:SetStatusBarTexture[[Interface\AddOns\oUF_Suupa\target\totHealthBar.tga]]
    hp:SetStatusBarColor(1, .3, .3)
    hp:SetPoint("TOPLEFT",self,"TOPLEFT",10,-10.5)
    
--~     Smooth Regen
    hp.colorTapping = true
    hp.colorDisconnected = true
    hp.frequentUpdates = true
    
    local hpbg = hp:CreateTexture(nil,"BACKGROUND")
    hpbg:SetAllPoints(hp)
    hpbg:SetTexture[[Interface\AddOns\oUF_Suupa\target\totHealthBar.tga]]
--~     hpbg:SetVertexColor(0.5,.15,.15)
    
    hp.bg = hpbg
    hp.bg.multiplier = 0.5
    
    hp.colorHealth = true
    
    
    self.Health = hp
    
    
    
    
     --==< NAME TEXT >==--
--~ 	if unit == "target" or unit == "targettarget" then
        local name = hp:CreateFontString(nil, "OVERLAY", self.Health)
--~         name:SetFont([[Interface\AddOns\oUF_Suupa\fonts\ConsoleSingle.ttf]],font2size)
        name:SetFont(font2,font2size-1)
--~         
        name:SetJustifyH"LEFT"
--~         name:SetTextColor(1, .5, .5)
        name:SetTextColor(0,1,0)
        self:Tag(name, '[name]')
--~         [raidcolor]
        
        
        name:SetPoint("LEFT",self.Health,"LEFT",10,0)
        name:SetPoint("RIGHT",self.Health,"RIGHT",-7,0)
        
--~         self.Health.name = name
--~         name:Hide()
--~         self.Health:EnableMouse(true)
--~         self.Health:SetScript("OnEnter", function(self) self.name:Show() end)
--~         self.Health:SetScript("OnLeave", function(self) self.name:Hide() end)
        
--~         name:SetText("НевихтаНевихтаНевихтаНевихтаНевихтаНевихта")
        
        self.Name = name
end








oUF:RegisterStyle("SuupaTarget", SuupaTarget)
oUF:SetActiveStyle"SuupaTarget"
local target = oUF:Spawn("target","oUF_Target")
--~ target:SetPoint("CENTER", 219, 1)
--~ target:SetPoint("CENTER", 470, 1)
--~ target:SetPoint("CENTER", 490, 0)
-- target:SetPoint("LEFT", UIParent, "CENTER", 230, 0)
target:SetPoint("LEFT", UIParent, "CENTER", 230, -70)
-- target:SetPoint("TOPLEFT", UIParent, "CENTER", 120, -100)
-- target:SetPoint("TOPLEFT", UIParent, "CENTER", 230, -100)


oUF:RegisterStyle("SuupaTOT", SuupaTOT)
oUF:SetActiveStyle"SuupaTOT"
local targettarget = oUF:Spawn("targettarget","oUF_TargetTarget")
targettarget:SetPoint("BOTTOM",target,"TOP",61,-15)
-- /nrun setpos point=CENTER parent=oUF_Target to=TOPLEFT x=-11 y=-21


--~ oUF:RegisterStyle("TargetCast", oUF_Suupa_CastBar)
--~ oUF:SetActiveStyle"TargetCast"
--~ local targetcast = oUF:Spawn("target","oUF_Target")
--~ targetcast:SetPoint("LEFT",UIParent,"LEFT", 200, 40)

--~ local focuscast = oUF:Spawn("focus","ouf_focus_cast",nil, false)
--~ focuscast:SetPoint("CENTER",UIParent,"CENTER", 0, -200)



--~ local targettarget = oUF:Spawn("targettarget","oUF_TargetTarget")
--~ targettarget:SetPoint('BOTTOMRIGHT', target, 'TOPRIGHT', 0, 4)