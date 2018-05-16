local addonName, addon = ...

local colors = addon.colors
local menu = addon.menu

function oUF_NugPetFrame(self, unit)
    local m=0.45
    -- local height = 100*m
    -- local width = 255*m
    local width = 278*m
    local height = 120*m
    self:SetHeight(height)
    self:SetWidth(width)

    self.menu = menu
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")
    
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
    hp.frequentUpdates = true
    hp.colorHealth = true
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
    
end



oUF:RegisterStyle("playetpet", oUF_NugPetFrame)
oUF:SetActiveStyle"playetpet"
local pet = oUF:Spawn("pet","oUF_Pet")
-- pet:SetPoint("BOTTOMLEFT",oUF_Player,"BOTTOMRIGHT",-13,59)
pet:SetPoint("BOTTOMRIGHT", UIParent,"BOTTOMRIGHT",-150,100)