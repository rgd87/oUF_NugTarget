local addonName, ns = ...


function ns.CreateCastbar(self, parent, _width, _height, spark)

    local bar = CreateFrame("StatusBar",nil,parent)

    local width = _width or 150
    local height = _height or 20
    width = width - height -1

    bar:SetHeight(height)
    bar:SetWidth(width - height - 1)
    local texture = [[Interface\AddOns\oUF_NugTarget\castbar.tga]]
    bar:SetStatusBarTexture(texture)
    -- bar:GetStatusBarTexture():SetDrawLayer("ARTWORK")

    -- local backdrop = {
    --     bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
    --     insets = {left = -3-height, right = -2, top = -2, bottom = -2},
    -- }
    -- bar:SetBackdrop(backdrop)
    -- bar:SetBackdropColor(0, 0, 0, 0.7)

    local backdrop = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
    backdrop:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    backdrop:SetVertexColor(0,0,0,0.7)
    backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", -3-height, 2)
    backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)


    local ict = bar:CreateTexture(nil,"ARTWORK",nil,0)
    ict:SetPoint("TOPRIGHT",bar,"TOPLEFT", -1, 0)
    ict:SetWidth(height)
    ict:SetHeight(height)
    ict:SetTexCoord(.07, .93, .07, .93)
    bar.Icon = ict

    if spark then
        self:CastbarAddSpark(bar)
    end


    local m = 0.4
    bar.SetColor = function(self, r,g,b)
        self:SetStatusBarColor(r,g,b)
        self.bg:SetVertexColor(r*m,g*m,b*m)
    end

    bar.bg = bar:CreateTexture(nil, "BORDER")
	bar.bg:SetAllPoints(bar)
    bar.bg:SetTexture(texture)

    local font = [[Interface\AddOns\oUF_NugTarget\fonts\AlegreyaSans-Medium.ttf]]
    local textColor = {1,1,1, 0.6}
    local timeFont = font
    local timeFontSize = 10

    local timeText = bar:CreateFontString();
    timeText:SetFont(timeFont, timeFontSize)
    timeText:SetJustifyH("RIGHT")
    timeText:SetVertexColor(1,1,1)
    timeText:SetPoint("TOPRIGHT", bar, "TOPRIGHT",-6,0)
    timeText:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT",0,0)
    timeText:SetTextColor(unpack(textColor))
    bar.Time = timeText


    local spellFont = font
    local spellFontSize = 12

    local spellText = bar:CreateFontString();
    spellText:SetFont(spellFont, spellFontSize)
    spellText:SetWidth(width/4*3 -12)
    spellText:SetHeight(height/2+1)
    spellText:SetJustifyH("CENTER")
    spellText:SetTextColor(unpack(textColor))
    spellText:SetPoint("LEFT", bar, "LEFT",6,0)
    bar.Text = spellText

    local shield = bar:CreateTexture(nil,"ARTWORK",nil,2)
    shield:SetTexture([[Interface\AchievementFrame\UI-Achievement-IconFrame]])
    shield:SetTexCoord(0,0.5625,0,0.5625)
    shield:SetWidth(height*1.8)
    shield:SetHeight(height*1.8)
    shield:SetPoint("CENTER", ict,"CENTER",0,0)
    shield:Hide()
    bar.Shield = shield

    return bar
end

function ns.CastbarAddSpark(self, bar)
    local spark = bar:CreateTexture(nil, "ARTWORK", nil, 4)
    spark:SetBlendMode("ADD")
    spark:SetTexture([[Interface\AddOns\oUF_NugTarget\vialSparkH.tga]])
    spark:SetSize(bar:GetHeight()*2, bar:GetHeight())

    spark:SetPoint("CENTER", bar, "TOP",0,0)
    bar.spark = spark

    local OriginalSetValue = bar.SetValue
    bar.SetValue = function(self, v)
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

    local OriginalSetStatusBarColor = bar.SetStatusBarColor
    bar.SetStatusBarColor = function(self, r,g,b,a)
        self.spark:SetVertexColor(r,g,b,a)
        return OriginalSetStatusBarColor(self, r,g,b,a)
    end
end