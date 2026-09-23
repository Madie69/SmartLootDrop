-- SmartLootDrop 0.1.2 Beta: read-only candidate preview for WoW Forever.
local addon = CreateFrame("Frame", "SmartLootDropEventFrame")
local panel = CreateFrame("Frame", "SmartLootDropFrame", UIParent)
panel:SetSize(410, 224)
panel:SetFrameStrata("DIALOG")
panel:SetClampedToScreen(true)
local background = panel:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(panel)
background:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
local function BorderEdge(first, second, width, height)
    local edge = panel:CreateTexture(nil, "BORDER")
    edge:SetTexture("Interface\\Buttons\\WHITE8X8")
    edge:SetVertexColor(0.85, 0.68, 0.25, 1)
    edge:SetPoint(first, panel, first, 0, 0)
    edge:SetPoint(second, panel, second, 0, 0)
    if width then edge:SetWidth(width) end
    if height then edge:SetHeight(height) end
end
BorderEdge("TOPLEFT", "TOPRIGHT", nil, 2)
BorderEdge("BOTTOMLEFT", "BOTTOMRIGHT", nil, 2)
BorderEdge("TOPLEFT", "BOTTOMLEFT", 2, nil)
BorderEdge("TOPRIGHT", "BOTTOMRIGHT", 2, nil)
panel:Hide()

local function EnlargeFont(fontString, fontObject)
    local font, size, flags = fontObject:GetFont()
    if font and size then fontString:SetFont(font, size + 4, flags) end
end

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
EnlargeFont(title, GameFontNormal)
title:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -15)
title:SetText("SmartLootDrop 0.1.2 Beta")

local message = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
EnlargeFont(message, GameFontHighlightSmall)
message:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
message:SetPoint("RIGHT", panel, "RIGHT", -15, 0)
message:SetJustifyH("LEFT")
message:SetText("Bags full. Lowest-cost candidates:")

local rows = {}
for index = 1, 2 do
    local row = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    EnlargeFont(row, GameFontHighlightSmall)
    row:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -65 - (index - 1) * 70)
    row:SetPoint("RIGHT", panel, "RIGHT", -15, 0)
    row:SetJustifyH("LEFT")
    row:SetText("")
    rows[index] = row
end

local note = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
EnlargeFont(note, GameFontDisableSmall)
note:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 15, 12)
note:SetText("Preview only: no items can be destroyed in this build.")

local function Money(amount)
    local gold = math.floor(amount / 10000)
    local silver = math.floor((amount % 10000) / 100)
    local copper = amount % 100
    if gold > 0 then return gold .. "g " .. silver .. "s " .. copper .. "c" end
    if silver > 0 then return silver .. "s " .. copper .. "c" end
    return copper .. "c"
end

local function GetCandidates()
    local container = C_Container
    local getSlots = container and container.GetContainerNumSlots or GetContainerNumSlots
    local getLink = container and container.GetContainerItemLink or GetContainerItemLink
    local getInfo = container and container.GetContainerItemInfo or GetContainerItemInfo
    if type(getSlots) ~= "function" or type(getLink) ~= "function"
        or type(getInfo) ~= "function" or type(GetItemInfo) ~= "function" then return {} end

    local candidates = {}
    for bag = 0, 4 do
        local slots = getSlots(bag) or 0
        for slot = 1, slots do
            local link = getLink(bag, slot)
            if link then
                local info, count, locked = getInfo(bag, slot)
                if type(info) == "table" then
                    count, locked = info.stackCount, info.isLocked
                    if info.isQuestItem then locked = true end
                end
                local name, _, quality, _, _, itemType, itemSubType, maxStack,
                    _, _, price, classID = GetItemInfo(link)
                local quest = type(GetContainerItemQuestInfo) == "function"
                    and GetContainerItemQuestInfo(bag, slot)
                if not quest and container and type(container.GetContainerItemQuestInfo) == "function" then
                    local questInfo = container.GetContainerItemQuestInfo(bag, slot)
                    quest = questInfo and (questInfo.isQuestItem or questInfo.questID)
                end
                if name and type(count) == "number" and count > 0 and not locked
                    and (quality == 0 or quality == 1)
                    and type(price) == "number" and price > 0
                    and not quest and itemType ~= "Quest" and itemType ~= "Key"
                    and classID ~= 12 and classID ~= 13 then
                    candidates[#candidates + 1] = {
                        name = name, count = count, maxStack = math.max(1, maxStack or 1),
                        current = price * count, potential = price * math.max(1, maxStack or 1),
                        quality = quality, bag = bag, slot = slot,
                    }
                end
            end
        end
    end
    table.sort(candidates, function(a, b)
        if a.current ~= b.current then return a.current < b.current end
        if a.quality ~= b.quality then return a.quality < b.quality end
        if a.potential ~= b.potential then return a.potential < b.potential end
        if a.bag ~= b.bag then return a.bag < b.bag end
        return a.slot < b.slot
    end)
    return candidates
end

local function RenderCandidates()
    local candidates = GetCandidates()
    for index = 1, 2 do
        local item = candidates[index]
        if item then
            rows[index]:SetText(item.name .. " x" .. item.count .. "/" .. item.maxStack
                .. "\nNow: " .. Money(item.current) .. "   Full stack: " .. Money(item.potential))
        elseif index == 1 then
            rows[index]:SetText("No safe, priced junk or common items found.")
        else
            rows[index]:SetText("")
        end
    end
end

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
        RenderCandidates()
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
