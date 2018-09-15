local addonName, ns = ...

local createFocusTarget = true
local targetCastbar = false
local focusCastbar = true
local petCastbar = false


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



oUF:RegisterStyle("oUF_NugPetFrame", ns.oUF_NugGenericSmallFrame(petCastbar, false))
oUF:SetActiveStyle"oUF_NugPetFrame"

local pet = oUF:Spawn("pet","oUF_Pet")
pet:SetPoint("BOTTOMRIGHT", UIParent,"BOTTOMRIGHT",-150,100)


-- oUF:RegisterStyle("oUF_NugNameplates", ns.oUF_NugNameplates)
-- oUF:SetActiveStyle"oUF_NugNameplates"
-- oUF:SpawnNamePlates("oUF_Nameplate", ns.oUF_NugNameplatesOnTargetChanged)

oUF:RegisterStyle("oUF_NugBossFrame", ns.oUF_NugGenericSmallFrame(true, false, true))
oUF:SetActiveStyle"oUF_NugBossFrame"
for i=1,MAX_BOSS_FRAMES do
    local bossunit = "boss"..i
    oUF:Spawn(bossunit,"oUF_Boss"..i):SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -15, -220 - 90*(i-1) )
end

