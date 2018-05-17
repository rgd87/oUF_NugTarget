local addonName, ns = ...

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...)
	return self[event](self, event, ...)
end)
frame:RegisterEvent("SPELLS_CHANGED")

local ranges = {
    WARRIOR1 = 0.2,
    WARRIOR2 = 0.2,
    WARRIOR3 = 0.2,

    PRIEST1 = 0.2,
    PRIEST2 = 0.2,
    PRIEST3 = 0.2,
}
function frame:SPELLS_CHANGED()
    local class = select(2, UnitClass("player"))
    local spec = GetSpecialization()
    if not spec then execute_range = nil; return end
    local execute_range = ranges[class..spec]
    ns.UpdateExecute(execute_range)
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