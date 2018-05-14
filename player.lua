local rem1 = {
    color = { 0.7,0,0 },
    shinecolor = { 0.9,0.4,0.4 },
}
local rem2 = {
    color = { 0.3,0.4,0.8 },
    shinecolor = { 0.5,0.5,0.9 },
}



local WeaponEnchFunc = function(id)
            local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
            if id == 1 and hasMainHandEnchant then return "player" end
            if id == 2 and hasOffHandEnchant then return "player" end
        end
local BuffFunc = function(spellID)
--~     name, rank, icon, count, debuffType, duration, expirationTime, caster
    return select(8,UnitAura("player",GetSpellInfo(spellID),nil,"HELPFUL"))
end

local function BuffGroup(ids, r,g,b)
    local buffs = {}
    for _,id in ipairs(ids) do
        buffs[id] = GetSpellInfo(id)
    end
    return function()
        for spellID, spellName in pairs(buffs) do
            local name, _,_, count, _, duration, expirationTime, caster, _,_, aura_spellID = UnitAura("player", spellName, nil, "HELPFUL")
            if name then return true, caster, r,g,b end
        end
        return false, nil, r,g,b
    end
end
--~ local WarrFunc = function(spellID)

    local _, playerClass = UnitClass("player")
    if playerClass == "PRIEST" then
        -- rem1.func = BuffGroup{588, 73413} -- Inner Fire, Inner Will
        -- rem2.func = BuffGroup{21562, 109773} -- Fort, Dark Intent
    end
    if playerClass == "WARLOCK" then
        -- rem1.func = BuffGroup{1459, 109773, 61316} -- Arcane Brilliance, Dark Intent, Dalaran Brilliance
        -- rem2.buffs = { 0 } -- 25228 is the actual buff
        -- rem2.func = SoulLink
    end
    if playerClass == "WARRIOR" then
        -- local battle = BuffGroup({6673, 19506, 57330}, .7,0,.7) -- battle shout, trueshot, horn of winter
        -- local commanding = BuffGroup({469, 6307, 21562, 109773}, 0,.7,0.5) -- commanding, blood pact, pwf, intent
        -- local GetSpecialization = GetSpecialization
        -- local GetShapeshiftFormID = GetShapeshiftFormID
        -- Battle Stance - 17
        -- Defensive Stance - 18
        -- Berserker Stance - 19
        -- rem1.func = function()
        --     local present, caster,r,g,b = battle()
        --     if present and caster ~= "player" then
        --         return commanding()
        --     else return present, caster,r,g,b end
        -- end

        -- rem2.func = function()
            -- if      GetSpecialization() == 1 then return GetShapeshiftFormID() == 17
            -- elseif  GetSpecialization() == 2 then return GetShapeshiftFormID() == 17
            -- elseif  GetSpecialization() == 3 then return GetShapeshiftFormID() == 18
            -- end
            -- return true
        -- end
    end
    if playerClass == "DEATHKNIGHT" then
        -- rem1.func = BuffGroup{6673, 19506, 57330} -- battle shout, trueshot, horn of winter
    end
    if playerClass == "ROGUE" then
        -- rem1.func = BuffGroup{2823, 8679}
        -- rem2.func = BuffGroup{3408, 5761, 108211, 108215}
    end


local mana = {.4, .4, 1}
local colors = setmetatable({
    health = { 1, .4, .4}, {__index = oUF.health},
	power = setmetatable({
		["MANA"] = mana,
		["RAGE"] = mana,
		["ENERGY"] = mana,
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




local SHINE_FADE_IN = 0.15;
local SHINE_FADE_OUT = 0.15;
local TICK_PERIOD = 0.35;

local ShineFadeOut = function(frame)
    local fadeInfo = {};
        fadeInfo.mode = "OUT";
        fadeInfo.timeToFade = SHINE_FADE_OUT;
        fadeInfo.finishedFunc = function(self) self.animating = false end;
        fadeInfo.finishedArg1 = frame;
    UIFrameFade(frame, fadeInfo);
end
local ShineFadeIn = function(frame)
    if not frame.animating then
        local fadeInfo = {};
        fadeInfo.mode = "IN";
        fadeInfo.timeToFade = SHINE_FADE_IN;
        fadeInfo.finishedFunc = function(arg1) ShineFadeOut(arg1); end;
        fadeInfo.finishedArg1 = frame;
        frame.animating = true
        UIFrameFade(frame, fadeInfo);
    end
end

local function CreateIndicator(name, parent, opts)
    local f = CreateFrame("Frame",name,parent)
    local size = 13

    f.opts = opts

    f:SetHeight(size)
    f:SetWidth(size)

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture([[Interface\AddOns\oUF_Suupa\indicator\Indicator]])
    t:SetAllPoints(f)
    t:SetVertexColor(unpack(f.opts.color))
    f.tex = t

    t = f:CreateTexture(nil,"OVERLAY")
    t:SetTexture([[Interface\AddOns\oUF_Suupa\indicator\Shine]])
    t:SetWidth(size*5)
    t:SetHeight(size*5)
    t:SetPoint("CENTER",f,"CENTER",0,0)
    t:SetVertexColor(unpack(f.opts.shinecolor))
    t:SetAlpha(0)
    f.shinetex = t

    f.color = color
    f.color_shine = color_shine

    f.Shine = function(self)
        ShineFadeIn(self.shinetex)
    end

    f.OnUpdate = function (self, time)
        self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
        if self.OnUpdateCounter < TICK_PERIOD then return end
        self.OnUpdateCounter = 0

        local found, caster, r,g,b = self.opts.func()
        if b then
            self.tex:SetVertexColor(r,g,b)
            self.shinetex:SetVertexColor(r+.3, g+.3, b+.3)
        end
        if not found then self:Shine() end
    end
    if f.opts.func then
        f:SetScript("OnUpdate", f.OnUpdate)
    end


    return f
end



local function CreateVBar(name, parent)
--~     original resolution of both 63 : 300
    local f = CreateFrame("Frame", name, parent)
    f.left = 0
    f.right = 1
    f.top =  0
    f.bottom =  1
    f.minvalue = 0
    f.maxvalue = 100

--~     local tbg = bar:CreateTexture(nil,"BACKGROUND")
--~     tbg:SetAllPoints(bar)
--~     tbg:SetTexture(texture)
--~     tbg:SetTexCoord(0,1, 0, texbtm)
--~     tbg:SetVertexColor(color[1]/2,color[2]/2,color[3]/2)

--~     bar.bg = tbg


    local t = f:CreateTexture(nil, "ARTWORK")
--~     t:SetTexture(texture)


--~     t:SetVertexColor(color[1],color[2],color[3])
    t:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",0,0)
    t:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",0,0)

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
        local h = self:GetHeight()*pos
        self.t:SetHeight(h)
--~         print ("pos: "..pos)
--~         print (string.format("min:%s max:%s",self.minvalue,self.maxvalue))
--~         print((self.bottom-self.top)*pos)
--~         print(string.format("coords: %s %s %s %s",self.left,self.right, self.bottom - (self.bottom-self.top)*pos , self.bottom))
        self.t:SetTexCoord(self.left,self.right, self.bottom - (self.bottom-self.top)*pos , self.bottom)
    end

--~     f:SetValue(100)
    f:Show()

    return f
end



local SuupaPlayer = function( self, unit)
    local width = 157
    local height = 217
--~     self:SetAttribute('initial-height', height)
--~     self:SetAttribute('initial-width', width)
    self:SetHeight(height)
    self:SetWidth(width)

	self.menu = menu

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")


    self.colors = colors

    local bg = self:CreateTexture(nil,"BACKGROUND")
    bg:SetAllPoints(self)
    bg:SetTexture[[Interface\AddOns\oUF_Suupa\player\playerBG.tga]]

	local hp = CreateVBar(nil,self)
    hp:SetCoord(0,1,0,0.58)
    hp:SetWidth(38)
    hp:SetHeight(180)
    hp:SetStatusBarTexture[[Interface\AddOns\oUF_Suupa\player\playerLeftBar.tga]]
    hp:SetStatusBarColor(1, .3, .3)
    hp:SetPoint("CENTER",self,"CENTER",-39,0)


    local function GetGradientColor(c1, c2, v)
        if v > 1 then v = 1 end
        local r = c1[1] + v*(c2[1]-c1[1])
        local g = c1[2] + v*(c2[2]-c1[2])
        local b = c1[3] + v*(c2[3]-c1[3])
        return r,g,b
    end

    local c1 = {1,0,0}
    local c2 = {1,.4,.4}

    hp.SetValueDefault = hp.SetValue
    hp.SetValue = function(self, v)
        local max = self.maxvalue - self.minvalue
        local v2 = v - self.minvalue
        local vp = v2/max
        local r,g,b = GetGradientColor(c1,c2,vp)
        self:SetStatusBarColor(r,g,b)
        self.bg:SetVertexColor(r*.5,g*.5,b*.5)
        -- if vp < 0.15 then
            -- self.glowanim:SetDuration(0.1)
            -- if not self.glow:IsPlaying() then
                -- self.glow:Play()
            -- end
        if vp < 0.2 then
            self.glowanim:SetDuration(0.2)
            if not self.glow:IsPlaying() then
                self.glow:Play()
            end
        elseif vp < 0.35 then
            self.glowanim:SetDuration(0.4)
            if not self.glow:IsPlaying() then
                self.glow:Play()
            end
        else
            if self.glow:IsPlaying() then
                self.glow:Stop()
            end
        end
        self:SetValueDefault(v)
    end

    local sag = hp.t:CreateAnimationGroup()
    sag:SetLooping("BOUNCE")
    local sa1 = sag:CreateAnimation("Alpha")
    sa1:SetFromAlpha(1)
    sa1:SetToAlpha(0.3)
    sa1:SetDuration(0.3)
    sa1:SetOrder(1)

    hp.glow = sag
    hp.glowanim = sa1


    -- local hpglow = hp:CreateTexture(nil,"ARTWORK",3)
    -- hpglow:SetTexture[[Interface\AddOns\oUF_Suupa\player\playerLeftBarGlow.tga]]
    -- hpglow:SetTexCoord(0,1,0,0.50)
    -- hpglow:SetWidth(60)
    -- hpglow:SetHeight(196)
    -- hpglow:SetVertexColor(1, .3, .3)
    -- hpglow:SetPoint("CENTER",self,"CENTER",-40,0)
    -- hpglow:SetAlpha(.7)

    -- local hpglow = CreateVBar(nil,self)
    -- hpglow:SetCoord(0,1,0,0.50)
    -- hpglow:SetWidth(60)
    -- hpglow:SetHeight(196)
    -- hpglow:SetStatusBarTexture[[Interface\AddOns\oUF_Suupa\player\playerLeftBarGlow.tga]]
    -- hpglow:SetStatusBarColor(1, .3, .3)
    -- hpglow:SetPoint("CENTER",self,"CENTER",-40,0)
    -- hpglow.t:SetDrawLayer("ARTWORK", 3)
    -- hpglow:SetAlpha(.7)

    -- hp.glow = hpglow

    -- hp.SetValue1 = hp.SetValue
    -- hp.SetValue = function(self, v)
    --     self:SetValue1(v)
    --     self.glow:SetValue(v)
    -- end

    -- hp.SetMinMaxValues1 = hp.SetMinMaxValues
    -- hp.SetMinMaxValues = function(self, min, max)
    --     self:SetMinMaxValues1(min, max)
    --     self.glow:SetMinMaxValues(min, max)
    -- end


--~     Smooth Regen
    -- hp.colorTapping = true
    -- hp.colorDisconnected = true
    hp.frequentUpdates = true

    local hpbg = hp:CreateTexture(nil,"BACKGROUND")
    hpbg:SetAllPoints(hp)
    hpbg:SetTexture[[Interface\AddOns\oUF_Suupa\player\playerLeftBar.tga]]
    hpbg:SetTexCoord(0,1,0,0.58)
--~     hpbg:SetVertexColor(0.5,.15,.15)

    hp.bg = hpbg
    hp.bg.multiplier = 0.5

    -- hp.colorHealth = true

    self.Health = hp

	--==< POWER BAR >==--
    local mb = CreateVBar(nil,self)
    mb:SetCoord(0,1,0,0.58)
    mb:SetWidth(38)
    mb:SetHeight(180)

    mb:SetStatusBarTexture[[Interface\AddOns\oUF_Suupa\player\playerRightBar.tga]]
    mb:SetStatusBarColor(.4, .4, 1)
    mb:SetPoint("CENTER",self,"CENTER",-1,-1)

    local mbbg = mb:CreateTexture(nil,"BACKGROUND")
    mbbg:SetAllPoints(mb)
    mbbg:SetTexture[[Interface\AddOns\oUF_Suupa\player\playerRightBar.tga]]
    mbbg:SetTexCoord(0,1,0,0.58)

    mb.bg = mbbg
    mb.bg.multiplier = 0.5

    mb.colorPower = true
    mb.colorDisconnected = true
    mb.colorTapping = true
    mb.frequentUpdates = true

    self.Power = mb




    --INDICATORS

    local ind1 = CreateIndicator(nil,self, rem1 )
    ind1:SetPoint("CENTER",self,"CENTER",51,-62)
--~     ind1.tex:SetVertexColor(0.7,0,0)*
    self.ind1 = ind1

    local ind2 = CreateIndicator(nil,self, rem2 )
    ind2:SetPoint("CENTER",self,"CENTER",41,-84)
--~     ind2.tex:SetVertexColor
    self.ind2 = ind2

end

local func2 = function (self, unit)
    if unit == "player" or unit == "target" then
--~     if unit == "player" or unit == "target" then
        local cbh = unit == "player" and 25 or 25
        local cbw = unit == "player" and 200 or 200

        local cbbackdrop = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
            insets = {left = -2-cbh-2, right = -2, top = -2, bottom = -2},
        }

--~         CAST BAR
        local cb = CreateFrame"StatusBar"
        cb:SetWidth(cbw - cbh -2 )
        cb:SetHeight(cbh)
        cb:SetStatusBarTexture([[Interface\AddOns\oUF_Suupa\statusbar]])
        cb:SetStatusBarColor(0.8,0,0)

--~         CASTBAR BG
        local cbbg = cb:CreateTexture(nil, "BORDER")
        cbbg:SetAllPoints(cb)
        cbbg:SetTexture([[Interface\AddOns\oUF_Suupa\statusbar]])
        cb.bg = cbbg

        cb:SetParent(self)
        if unit == "player" then
            cb:SetPoint("BOTTOMRIGHT",UIParent,"BOTTOM", -10, 140)
        elseif unit == "target" then
            cb:SetPoint("CENTER",UIParent,"TOPLEFT", -300, 100)
        end

--~         SAFE ZONE
        local lag = cb:CreateTexture(nil, "OVERLAY")
        lag:SetAlpha(0.3)
        lag:SetVertexColor(0,0,0)
        cb.SafeZone = lag

--~         SPARK
        local sp = cb:CreateTexture(nil,"OVERLAY")
        sp:SetBlendMode("ADD")
        sp:SetHeight(cbh*3)
        sp:SetAlpha(0.8)
        cb.Spark = sp

--~         SPELL ICON
        local ic = cb:CreateTexture(nil,"ARTWORK")
        ic:SetHeight(cbh)
        ic:SetWidth(cbh)
        ic:SetTexCoord(.07, .93, .07, .93)
        ic:SetPoint("RIGHT",cb,"LEFT",-2,0)
        cb.Icon = ic

        cb:SetBackdrop(cbbackdrop)
        cb:SetBackdropColor(0, 0, 0, 0.7)
        cb:SetBackdropBorderColor(.3, .3, .3, 1)

        self.Castbar = cb
--~         COLORING
        self.PostCastStart = function(self, event, unit, spellname, spellrank)
            local color = { 0.8,0,0 }
            local multiplier = 0.3
            self.Castbar:SetStatusBarColor(unpack(color))
            self.Castbar.bg:SetVertexColor(color[1]*multiplier,color[2]*multiplier,color[3]*multiplier)
        end
        self.PostChannelStart = function(self, event, unit, spellname, spellrank)
            local color = { 0.4, 0.8, 0.3 }
            local multiplier = 0.3
            self.Castbar:SetStatusBarColor(unpack(color))
            self.Castbar.bg:SetVertexColor(color[1]*multiplier,color[2]*multiplier,color[3]*multiplier)
        end

    end
end

-- oUF:RegisterStyle("SuupaPlayer", SuupaPlayer)
-- oUF:SetActiveStyle"SuupaPlayer"

-- local player = oUF:Spawn("player","oUF_Player")
-- player:SetScale(0.85)
-- player:SetFrameLevel(8)
-- player:SetPoint("LEFT","ActionButton12","RIGHT",3)
-- player:SetPoint("BOTTOM",UIParent,"BOTTOM",0,-3)

