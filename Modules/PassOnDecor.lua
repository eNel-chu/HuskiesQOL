-- PassOnDecor Module
-- Automatically passes on Decor (housing decoration) items in loot rolls

local AddonName, NS = ...
local addon = NS.addon

-- Item class ID for housing decorations (Decor) added in The War Within
local DECOR_CLASS_ID = 20

local PassOnDecor = CreateFrame("Frame")

local function IsDecorItem(itemLink)
    if not itemLink then return false end
    local _, _, _, _, _, classID = GetItemInfoInstant(itemLink)
    return classID == DECOR_CLASS_ID
end

PassOnDecor:RegisterEvent("START_LOOT_ROLL")

PassOnDecor:SetScript("OnEvent", function(self, event, rollID)
    if event == "START_LOOT_ROLL" then
        if not addon.db.passOnDecor.enabled then return end

        local itemLink = GetLootRollItemLink(rollID)
        if IsDecorItem(itemLink) then
            RollOnLoot(rollID, 0) -- 0 = Pass
            print("|cFF9D4EFFHUSKIES|r PassOnDecor: Passed on " .. (itemLink or "unknown item"))
        end
    end
end)

-- Public API
function PassOnDecor:Enable()
    addon.db.passOnDecor.enabled = true
end

function PassOnDecor:Disable()
    addon.db.passOnDecor.enabled = false
end

function PassOnDecor:Toggle()
    if addon.db.passOnDecor.enabled then
        self:Disable()
    else
        self:Enable()
    end
end

-- Register module
addon:RegisterModule("PassOnDecor", PassOnDecor)
