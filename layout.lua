local addonName, ns = ...

local createFocusTarget = true
local targetCastbar = false
local focusCastbar = false
local petCastbar = false


local isClassic = select(4,GetBuildInfo()) <= 19999

ns.isFlipped = true
oUF:RegisterStyle("oUF_NugTargetFrame", ns.oUF_NugTargetFrame(targetCastbar))
oUF:RegisterStyle("oUF_NugTargetTargetFrame", ns.oUF_NugTargetTargetFrame)
oUF:RegisterStyle("oUF_NugFocusFrame", ns.oUF_NugTargetFrame(focusCastbar))

oUF:SetActiveStyle("oUF_NugTargetFrame")
local target = oUF:Spawn("target","oUF_Target")
-- target:SetPoint("LEFT", UIParent, "CENTER", 230, -70)
-- target:SetPoint("LEFT", UIParent, "CENTER", 332, -81) -- 0.8
target:SetPoint("LEFT", UIParent, "CENTER", 305, -81) -- 0.85
target:SetScale(0.85)
target.Name:SetScale(1.15)
if ns.isFlipped then
    target:SetPoint("LEFT", UIParent, "CENTER", 400, -100) -- 0.85
end


if not isClassic then
    oUF:SetActiveStyle("oUF_NugFocusFrame")
    local focus = oUF:Spawn("focus","oUF_Focus")
    focus:SetPoint("CENTER", UIParent, "CENTER", 250, 550)
    if createFocusTarget then
        oUF:SetActiveStyle("oUF_NugTargetTargetFrame")
        local focustarget = oUF:Spawn("focustarget","oUF_FocusTarget")
        focustarget:SetPoint("BOTTOM",focus,"TOP",61,-15)

        if ns.isFlipped then
            focustarget:SetPoint("BOTTOM",target,"TOP",-25,-15)
        else
            focustarget:SetPoint("BOTTOM",target,"TOP",55,-15)
        end
        focustarget:SetScale(0.8)
    end

    focus:SetScale(0.7)
end


oUF:SetActiveStyle("oUF_NugTargetTargetFrame")
local targettarget = oUF:Spawn("targettarget","oUF_TargetTarget")
-- targettarget:SetPoint("BOTTOM",target,"TOP",61,-15)
if ns.isFlipped then
    targettarget:SetPoint("BOTTOM",target,"TOP",-25,-15)
else
    targettarget:SetPoint("BOTTOM",target,"TOP",55,-15)
end
targettarget:SetScale(0.9)



oUF:RegisterStyle("oUF_NugPetFrame", ns.oUF_NugGenericSmallFrame(petCastbar, false))
oUF:SetActiveStyle"oUF_NugPetFrame"

local pet = oUF:Spawn("pet","oUF_Pet")
pet:SetPoint("BOTTOMRIGHT", UIParent,"BOTTOMRIGHT",-150,100)


if not isClassic then

oUF:RegisterStyle("oUF_NugBossFrame", ns.oUF_NugGenericSmallFrame(true, false, true))
oUF:SetActiveStyle"oUF_NugBossFrame"
for i=1,MAX_BOSS_FRAMES do
    local bossunit = "boss"..i
    oUF:Spawn(bossunit,"oUF_Boss"..i):SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -15, -220 - 90*(i-1) )
end

end
