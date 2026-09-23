-- SmartLootDrop 0.1.0 Beta: visibility foundation for WoW Forever.
local addon = CreateFrame("Frame", "SmartLootDropEventFrame")
local panel = CreateFrame("Frame", "SmartLootDropFrame", UIParent)
panel:SetSize(230, 82)
panel:SetFrameStrata("DIALOG")
panel:SetClampedToScreen(true)
local background = panel:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(panel)
background:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
panel:Hide()

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", panel, "TOPLEFT", 13, -11)
title:SetText("SmartLootDrop 0.1.0 Beta")

local message = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
message:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -9)
message:SetPoint("RIGHT", panel, "RIGHT", -13, 0)
message:SetJustifyH("LEFT")
message:SetText("Bags full. Candidate selection comes in the next build.")

local function FreeGeneralSlots()
    local api = C_Container
    local getFree = api and api.GetContainerNumFreeSlots or GetContainerNumFreeSlots
    if type(getFree) ~= "function" then return nil end

    local total = 0
    for bag = 0, 4 do
        local free, bagType = getFree(bag)
        if type(free) ~= "number" then return nil end
        -- A profession-only bag cannot accept arbitrary loot.
        if bagType == nil or bagType == 0 then
            total = total + free
        end
    end
    return total
end

local function PositionPanel()
    if not LootFrame or not LootFrame.GetLeft then return end
    local left, right = LootFrame:GetLeft(), LootFrame:GetRight()
    local top = LootFrame:GetTop()
    local scale = panel:GetEffectiveScale()
    local screenWidth = UIParent:GetWidth() * UIParent:GetEffectiveScale() / scale
    local screenHeight = UIParent:GetHeight() * UIParent:GetEffectiveScale() / scale
    if not left or not right or not top or not screenWidth or not screenHeight then return end

    -- Coordinates returned by a frame are in its effective scale.
    local lootScale = LootFrame:GetEffectiveScale()
    left, right, top = left * lootScale / scale, right * lootScale / scale, top * lootScale / scale
    local x = right + 8
    if x + panel:GetWidth() > screenWidth then x = left - panel:GetWidth() - 8 end
    if x < 0 or x + panel:GetWidth() > screenWidth then
        x = math.max(0, math.min(screenWidth - panel:GetWidth(), right - panel:GetWidth()))
    end
    local y = math.max(panel:GetHeight(), math.min(screenHeight, top))
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end

local function Refresh()
    local lootOpen = LootFrame and LootFrame.IsShown and LootFrame:IsShown()
    local free = lootOpen and FreeGeneralSlots()
    if lootOpen and free == 0 then
        PositionPanel()
        panel:Show()
    else
        panel:Hide()
    end
end

addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("LOOT_OPENED")
addon:RegisterEvent("LOOT_CLOSED")
addon:RegisterEvent("BAG_UPDATE")
addon:SetScript("OnEvent", Refresh)

-- The frame's actual visibility is authoritative, including when another UI closes it.
if LootFrame and LootFrame.HookScript then
    LootFrame:HookScript("OnShow", Refresh)
    LootFrame:HookScript("OnHide", Refresh)
end
