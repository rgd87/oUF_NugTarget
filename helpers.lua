local addonName, ns = ...

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...)
	return self[event](self, event, ...)
end)
frame:RegisterEvent("SPELLS_CHANGED")

local isClassic = select(4,GetBuildInfo()) <= 19999
local GetSpecialization = isClassic and function() return 1 end or _G.GetSpecialization

local ranges

local function SimplePercentCheck(threshold)
    return function(p, unit, cur, max)
        return p < threshold
    end
end

local function CondemnExecute()
    local isMassacre = IsPlayerSpell(281001) or IsPlayerSpell(206315) -- arms, fury massacres
    local lowT = isMassacre and 0.35 or 0.2
    local isCondemn = IsPlayerSpell(317320) or IsPlayerSpell(317485) -- arms/prot, fury condemn
    local highT = isCondemn and 0.8 or 1
    return function(p, unit, cur, max)
        return p < lowT or p > highT
    end
end

local function TouchOfDeath()
    local pressurePoints = IsPlayerSpell(287599)
    return function(p, unit, cur, max)
        if pressurePoints and UnitIsPlayer(unit) then
            return p < 0.1
        else
            -- local playerMaxHealth = UnitHealthMax("player")
            -- local isWeak = max < playerMaxHealth
            -- if isWeak then
            --     return true
            -- else
                return p < 0.15
            -- end
        end
    end
end

local function Wrap(func)
    return function()
        return func
    end
end

if isClassic then
    local IsAnySpellKnown = function (...)
        for i=1, select("#", ...) do
            local spellID = select(i, ...)
            if not spellID then break end
            if IsPlayerSpell(spellID) then return spellID end
        end
    end

    ranges = {
        WARRIOR = {
            function() return IsAnySpellKnown(20662, 20661, 20660, 20658, 5308) and SimplePercentCheck(0.2) end,
        },
        PALADIN = {
            function() return IsAnySpellKnown(24275, 24274, 24239) and SimplePercentCheck(0.2) end,
        },
    }
else

ranges = {
    WARRIOR = {
        CondemnExecute, CondemnExecute, CondemnExecute,
    },
    ROGUE = {
        function() return IsPlayerSpell(328085) and SimplePercentCheck(0.35) end, -- blindside
    },
    WARLOCK = {
        function() return IsPlayerSpell(198590) and SimplePercentCheck(0.20) end, -- drain soul
    },
    PRIEST = {
        Wrap(SimplePercentCheck(0.20)), Wrap(SimplePercentCheck(0.20)), Wrap(SimplePercentCheck(0.20)),
    },
    PALADIN = {
        Wrap(SimplePercentCheck(0.20)), Wrap(SimplePercentCheck(0.20)), Wrap(SimplePercentCheck(0.20)),
    },
    HUNTER = {
        Wrap(SimplePercentCheck(0.20)), Wrap(SimplePercentCheck(0.20)), Wrap(SimplePercentCheck(0.20)),
    },
    MONK = {
        Wrap(SimplePercentCheck(0.15)), Wrap(SimplePercentCheck(0.15)), Wrap(SimplePercentCheck(0.15)),
    },
}
end


function frame:SPELLS_CHANGED()
    local class = select(2, UnitClass("player"))
    local spec = GetSpecialization()
    if not spec then ns.UpdateExecute(nil); return end
    local classopts = ranges[class]
    local range
    if classopts then
        range = classopts[spec]
        if range then
            range = range()
        end
    end
    ns.UpdateExecute(range)
end


-- local function SetupDefaults(t, defaults)
--     if not defaults then return end
--     for k,v in pairs(defaults) do
--         if type(v) == "table" then
--             if t[k] == nil then
--                 t[k] = CopyTable(v)
--             elseif t[k] == false then
--                 t[k] = false --pass
--             else
--                 SetupDefaults(t[k], v)
--             end
--         else
--             if t[k] == nil then t[k] = v end
--         end
--     end
-- end
-- local function RemoveDefaults(t, defaults)
--     if not defaults then return end
--     for k, v in pairs(defaults) do
--         if type(t[k]) == 'table' and type(v) == 'table' then
--             RemoveDefaults(t[k], v)
--             if next(t[k]) == nil then
--                 t[k] = nil
--             end
--         elseif t[k] == v then
--             t[k] = nil
--         end
--     end
--     return t
-- end

-- local defaults = {
-- }

-- function frame:PLAYER_LOGIN()
--     _G.oUF_NugAnchorsDB = _G.oUF_NugAnchorsDB or {}
--     oUF_NugAnchorsDB = _G.oUF_NugAnchorsDB
--     SetupDefaults(oUF_NugAnchorsDB, defaults)
-- end
-- function frame:PLAYER_LOGOUT()
--     RemoveDefaults(oUF_NugAnchorsDB, defaults)
-- end




-- function frame:CreateAnchor(db_tbl)
--     local f = CreateFrame("Frame", "NugStatsAnchor",UIParent)
--     f:SetHeight(20)
--     f:SetWidth(20)
--     f:EnableMouse(true)
--     f:SetMovable(true)
--     f:Hide()

--     local t = f:CreateTexture(nil,"BACKGROUND")
--     t:SetTexture("Interface\\Buttons\\UI-RadioButton")
--     t:SetTexCoord(0,0.25,0,1)
--     t:SetAllPoints(f)

--     t = f:CreateTexture(nil,"BACKGROUND")
--     t:SetTexture("Interface\\Buttons\\UI-RadioButton")
--     t:SetTexCoord(0.25,0.49,0,1)
--     t:SetVertexColor(1, 0, 0)
--     t:SetAllPoints(f)

--     f.db_tbl = db_tbl

--     f:SetScript("OnMouseDown",function(self)
--         self:StartMoving()
--     end)
--     f:SetScript("OnMouseUp",function(self)
--             local opts = self.db_tbl
--             self:StopMovingOrSizing();
--             local point,_,to,x,y = self:GetPoint(1)
--             opts.point = point
--             opts.parent = "UIParent"
--             opts.to = to
--             opts.x = x
--             opts.y = y
--     end)

--     local pos = f.db_tbl
--     f:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
--     return f
-- end
