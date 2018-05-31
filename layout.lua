local addonName, ns = ...

oUF:RegisterStyle("oUF_NugTargetFrame", ns.oUF_NugTargetFrame)
oUF:SetActiveStyle("oUF_NugTargetFrame")
local target = oUF:Spawn("target","oUF_Target")
target:SetPoint("LEFT", UIParent, "CENTER", 230, -70)

local focus = oUF:Spawn("focus","oUF_Focus")
focus:SetPoint("LEFT", UIParent, "CENTER", 230, 140)



oUF:RegisterStyle("oUF_NugTargetTargetFrame", ns.oUF_NugTargetTargetFrame)
oUF:SetActiveStyle("oUF_NugTargetTargetFrame")
local targettarget = oUF:Spawn("targettarget","oUF_TargetTarget")
targettarget:SetPoint("BOTTOM",target,"TOP",61,-15)



oUF:RegisterStyle("oUF_NugGenericSmallFrame", ns.oUF_NugGenericSmallFrame)
oUF:SetActiveStyle"oUF_NugGenericSmallFrame"

local pet = oUF:Spawn("pet","oUF_Pet")
pet:SetPoint("BOTTOMRIGHT", UIParent,"BOTTOMRIGHT",-150,100)


oUF:RegisterStyle("oUF_SuupaPlayer", ns.oUF_SuupaPlayer)
oUF:SetActiveStyle"oUF_SuupaPlayer"

local player = oUF:Spawn("player","oUF_Player")
player:SetScale(0.85)
player:SetFrameLevel(7)
player:SetPoint("LEFT","ActionButton12","RIGHT",3)
player:SetPoint("BOTTOM",UIParent,"BOTTOM",0,-3)