local addonName, ns = ...

local createFocusTarget = true
local targetCastbar = false
local focusCastbar = true


oUF:RegisterStyle("oUF_NugTargetFrame", ns.oUF_NugTargetFrame(targetCastbar))
oUF:SetActiveStyle("oUF_NugTargetFrame")
local target = oUF:Spawn("target","oUF_Target")
target:SetPoint("LEFT", UIParent, "CENTER", 230, -70)


oUF:RegisterStyle("oUF_NugFocusFrame", ns.oUF_NugTargetFrame(focusCastbar))
oUF:SetActiveStyle("oUF_NugFocusFrame")
local focus = oUF:Spawn("focus","oUF_Focus")
focus:SetPoint("LEFT", UIParent, "CENTER", 230, 140)



oUF:RegisterStyle("oUF_NugTargetTargetFrame", ns.oUF_NugTargetTargetFrame)
oUF:SetActiveStyle("oUF_NugTargetTargetFrame")
local targettarget = oUF:Spawn("targettarget","oUF_TargetTarget")
targettarget:SetPoint("BOTTOM",target,"TOP",61,-15)

if createFocusTarget then
    local focustarget = oUF:Spawn("focustarget","oUF_FocusTarget")
    focustarget:SetPoint("BOTTOM",focus,"TOP",61,-15)
end



oUF:RegisterStyle("oUF_NugGenericSmallFrame", ns.oUF_NugGenericSmallFrame)
oUF:SetActiveStyle"oUF_NugGenericSmallFrame"

local pet = oUF:Spawn("pet","oUF_Pet")
pet:SetPoint("BOTTOMRIGHT", UIParent,"BOTTOMRIGHT",-150,100)

