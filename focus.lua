local texture = [[Interface\AddOns\oUF_Suupa\statusbar]]

local mana = {.4, .4, 1}
local colors = setmetatable({
    health = { 1, .3, .3}, {__index = oUF.health},
	power = setmetatable({
		["MANA"] = mana,
		["RAGE"] = {0.9, 0, 0},
--~ 		["FOCUS"] = {0.71, 0.43, 0.27},
		["ENERGY"] = {1, 1, 0.4},
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

function oUF_supa_lousy_FOCUS(self, unit)
    local height = 40
    local width = 180
    self:SetHeight(height)
    self:SetWidth(width)

    self.menu = menu
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")
    
    self.colors = colors
    
    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
    
    self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 0.7)
	self:SetBackdropBorderColor(.3, .3, .3, 1)
    
    
    local hp = CreateFrame("StatusBar",nil,self)
    hp:SetStatusBarTexture(texture)
    hp:SetStatusBarColor(1, .3, .3)
    hp:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    hp:SetPoint("BOTTOMRIGHT",self,"RIGHT",0,1-8)
    
    hp.colorTapping = true
    hp.colorDisconnected = true
    hp.frequentUpdates = true
    
    local hpbg = hp:CreateTexture(nil,"BACKGROUND")
    hpbg:SetAllPoints(hp)
    hpbg:SetTexture(texture)
    hp.bg = hpbg
    hp.bg.multiplier = 0.5
    hp.colorHealth = true
    self.Health = hp
    
    
    local mb = CreateFrame("StatusBar",nil,self)
    mb:SetWidth(131)
    mb:SetHeight(19)
    
    mb:SetStatusBarTexture(texture)
    mb:SetStatusBarColor(.4, .4, 1)
    mb:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
    mb:SetPoint("TOPLEFT",self,"LEFT",0,-1-8)
    
    local mbbg = mb:CreateTexture(nil,"BACKGROUND")
    mbbg:SetAllPoints(mb)
    mbbg:SetTexture(texture)
    mb.bg = mbbg
    mb.bg.multiplier = 0.5
    mb.colorPower = true
    mb.colorDisconnected = true
    mb.colorTapping = true
    mb.frequentUpdates = true
    self.Power = mb
    
		-- Buffs
        local disableCC = function (self, button, icons, index, debuff)
            button.cd:SetReverse(true)
            button.cd.noCooldownCount = true -- for OmniCC
        end
        
		local buffs = CreateFrame("Frame", "oUF_Nuga_Buffs", self)
		buffs:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT",-5,0)
		buffs:SetHeight(24)
		buffs:SetWidth(72)
        buffs.PostCreateIcon = disableCC

		buffs.size = 24
        buffs.initialAnchor = "BOTTOMRIGHT"
        buffs["growth-x"] = "LEFT"
        buffs["growth-y"] = "UP"

		self.Buffs = buffs

		-- Debuffs
		local debuffs = CreateFrame("Frame", "oUF_Nuga_Debuffs", self)
		debuffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT",0,5)
		debuffs:SetHeight(1)
		debuffs:SetWidth(width)
        debuffs.PostCreateIcon = disableCC
        
        debuffs.showDebuffType = true
		debuffs.initialAnchor = "BOTTOMRIGHT"
        debuffs["growth-x"] = "LEFT"
        debuffs["growth-y"] = "UP"
		debuffs.size = 28

		self.Debuffs = debuffs

    
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:SetScript("OnDragStart",function(self)
        if IsShiftKeyDown() then self:StartMoving() end
    end)
    self:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
    end)

end


-- oUF:RegisterStyle("supafocus", oUF_supa_lousy_FOCUS)
-- oUF:SetActiveStyle"supafocus"
-- local focus = oUF:Spawn("focus","oUF_Focus")
-- focus:SetPoint("LEFT",UIParent,"LEFT", 165,2)

--~ oUF:RegisterStyle("FocusCast", oUF_Suupa_CastBar)
--~ oUF:SetActiveStyle"FocusCast"
--~ local focuscast = oUF:Spawn("focus","ouf_focus_cast")
--~ focuscast:SetWidth(focus:GetWidth())
--~ focuscast:SetPoint("TOPRIGHT",focus,"BOTTOMRIGHT", 0, -10)