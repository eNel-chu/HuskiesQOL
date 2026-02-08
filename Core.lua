-- HuskiesQOL Core
-- Optimized addon initialization and event handling

-- HuskiesQOL Core
-- Optimized addon initialization and event handling

local AddonName, NS = ...
local addon = {}
NS.addon = addon

-- Namespace for modules
NS.Modules = {}
addon.Modules = NS.Modules

-- Event frame
local eventFrame = CreateFrame("Frame")

-- Deep copy utility (for defaults)
local function DeepCopy(src, dst)
    dst = dst or {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = DeepCopy(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

-- Initialize database with defaults
local function Initialize()
    -- Load saved variables
    HuskiesQOL_DB = HuskiesQOL_DB or {}
    
    -- Apply defaults
    HuskiesQOL_DB = DeepCopy(addon.Defaults, HuskiesQOL_DB)
    
    -- Store DB reference
    addon.db = HuskiesQOL_DB

    -- Register slash commands
    SLASH_HUSKIESQOL1 = "/huskies"
    SLASH_HUSKIESQOL2 = "/hqol"
    SlashCmdList["HUSKIESQOL"] = function(msg)
        addon:SlashCommand(msg)
    end
    
    print("|cFF9D4EFFHUSKIES|r QOL loaded! Type |cFF00FF00/huskies|r to configure.")
end

-- Event handling
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        Initialize()
    end
end)

-- Slash command handler
function addon:SlashCommand(msg)
    msg = strtrim(msg:lower())
    
    if msg == "" or msg == "config" or msg == "settings" then
        if addon.ConfigWindow then
            addon.ConfigWindow:Toggle()
        else
            print("|cFFFF0000HuskiesQOL:|r ConfigWindow not found! Type /reload")
        end
    elseif msg == "reset" then
        StaticPopup_Show("HUSKIESQOL_RESET_CONFIRM")
    else
        print("|cFF9D4EFFHUSKIES|r QOL Commands:")
        print("  /huskies - Open settings")
        print("  /huskies reset - Reset all settings")
    end
end

-- Reset confirmation popup
StaticPopupDialogs["HUSKIESQOL_RESET_CONFIRM"] = {
    text = "Reset all HuskiesQOL settings to default?",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        HuskiesQOL_DB = DeepCopy(addon.Defaults, {})
        addon.db = HuskiesQOL_DB
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Module registration
function addon:RegisterModule(name, module)
    NS.Modules[name] = module
end

-- Get module
function addon:GetModule(name)
    return NS.Modules[name]
end
