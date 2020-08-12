local addonName, ns = ...

local colors = ns.colors

function ns.oUF_NugGenericSmallFrame(addCastbar, colorClass, addAltPower)
    return function(self, unit)
        return ns.oUF_NugGenericSmallFrame1(self, unit, addCastbar, colorClass, addAltPower)
    end
end

function ns.oUF_NugGenericSmallFrame1(self, unit, addCastbar, colorClass, addAltPower)
    local m=0.45
    -- local height = 100*m
    -- local width = 255*m
    local width = 278*m
    local height = 120*m
    self:SetHeight(height)
    self:SetWidth(width)

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	-- self:SetAttribute("*type2", nil) -- disable right click

    self.colors = colors

    local hpw = 97
    local hph = 17

    local texture = [[Interface\AddOns\oUF_NugTarget\statusbar1.tga]]

    local hp = CreateFrame("StatusBar",nil,self)
    hp:SetFrameStrata("LOW")
    hp:SetStatusBarTexture(texture)
    hp:GetStatusBarTexture():SetDrawLayer("ARTWORK",1)
    hp:SetHeight(hph)
    hp:SetWidth(hpw)
    hp:SetPoint("TOPLEFT",self,"TOPLEFT",14,-11)

    hp.colorTapping = true
    hp.colorDisconnected = true
    hp.colorHealth = true
    hp.colorClass = colorClass
    -- hp.frequentUpdates = true
    -- hp.Smooth = true

    hp.bg = hp:CreateTexture(nil, "BORDER")
    hp.bg:SetAllPoints(hp)
    hp.bg:SetTexture(texture)
    hp.bg.multiplier = 0.4

    -- hp.model = CreateFrame("Frame")

    self.Health = hp

    local mph = 9

    local mp = CreateFrame("StatusBar",nil,self)
    mp:SetFrameStrata("LOW")
    mp:SetStatusBarTexture(texture)
    mp:GetStatusBarTexture():SetDrawLayer("ARTWORK",1)
    mp:SetHeight(mph)
    mp:SetWidth(hpw)
    mp:SetPoint("TOPLEFT",self,"TOPLEFT",14,-31)


    mp.colorPower = true
    mp.colorDisconnected = true
    mp.colorTapping = true
    mp.frequentUpdates = true

    mp.bg = mp:CreateTexture(nil, "BORDER")
    mp.bg:SetAllPoints(mp)
    mp.bg:SetTexture(texture)
    mp.bg.multiplier = 0.3

    self.Power = mp

    -- local bgw = 278*m
    -- local bgh = 120*m

    local bg = hp:CreateTexture(nil,"ARTWORK")
    bg:SetDrawLayer("ARTWORK", 7)
    bg:SetAllPoints(self)
    bg:SetTexture[[Interface\AddOns\oUF_NugTarget\target\petBG]]
    bg:SetTexCoord(0, 278/512, 0, 0.95)

    if addCastbar then
        local cw,ch = 155, 18
        local castbar = ns:CreateCastbar(self, cw, ch, true)
        castbar:SetColor(0.6, 0, 1)

        castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT",10,1)

        self.Castbar = castbar
    end


    if addAltPower then
        -- Position and size
        local AlternativePower = CreateFrame('StatusBar', nil, self, BackdropTemplateMixin and "BackdropTemplate")
        AlternativePower:SetHeight(10)
        AlternativePower:SetWidth(90)

        AlternativePower:EnableMouse(true)
        local texture = [[Interface\AddOns\oUF_NugTarget\castbar.tga]]
        -- local texture = "Interface\\BUTTONS\\WHITE8X8"
        AlternativePower:SetStatusBarTexture(texture)
        local color = {1,0.6,0.2}
        local mul = 0.4
        AlternativePower:SetStatusBarColor(unpack(color))

        local bg = AlternativePower:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture(texture)
        bg:SetVertexColor(color[1]*mul, color[2]*mul, color[3]*mul)
        bg:SetAllPoints(AlternativePower)

        local backdrop = {
            bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 0,
            insets = {left = -2, right = -2, top = -2, bottom = -2},
        }
        AlternativePower:SetBackdrop(backdrop)
        AlternativePower:SetBackdropColor(0, 0, 0, 0.5)

        AlternativePower:SetPoint('TOPRIGHT', self, "LEFT",-5, 5)
        -- Register with oUF
        self.AlternativePower = AlternativePower
    end

end
