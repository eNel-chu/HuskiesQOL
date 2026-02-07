-- Settings Panel Integration
-- Integrates addon into WoW's settings interface

local addon = HuskiesQOL

-- Create main panel
local panel = CreateFrame("Frame")
panel.name = "HuskiesQOL"

-- Logo
local logo = panel:CreateTexture(nil, "ARTWORK")
logo:SetSize(200, 100)
logo:SetPoint("TOP", 0, -30)
logo:SetTexture("Interface\\AddOns\\HuskiesQOL\\Media\\HuskiesLogo")

-- Title
local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
title:SetPoint("TOP", logo, "BOTTOM", 0, -10)
title:SetText("HuskiesQOL")
title:SetTextColor(0.8, 0.5, 1, 1)

-- Version
local version = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
version:SetPoint("TOP", title, "BOTTOM", 0, -5)
version:SetText("Version 2.0.0")
version:SetTextColor(0.6, 0.6, 0.7, 1)

-- Description
local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
desc:SetPoint("TOP", version, "BOTTOM", 0, -20)
desc:SetWidth(500)
desc:SetJustifyH("CENTER")
desc:SetText("Quality of Life improvements for World of Warcraft\n\nClick the button below to open the full configuration window.")

-- Open config button
local openBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
openBtn:SetSize(200, 30)
openBtn:SetPoint("TOP", desc, "BOTTOM", 0, -30)
openBtn:SetText("Open Settings")
openBtn:SetScript("OnClick", function()
    if addon.ConfigWindow then
        addon.ConfigWindow:Show()
    else
        print("|cFFFF0000HuskiesQOL:|r Config window not ready yet. Try /huskies command.")
    end
end)

-- Features list
local featuresHeader = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
featuresHeader:SetPoint("TOP", openBtn, "BOTTOM", 0, -30)
featuresHeader:SetText("Features")
featuresHeader:SetTextColor(0.7, 0.4, 1, 1)

local features = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
features:SetPoint("TOP", featuresHeader, "BOTTOM", 0, -10)
features:SetWidth(500)
features:SetJustifyH("LEFT")
features:SetText([[
• Crosshair - Customizable center screen crosshair
• Mouse Ring - Circle around your mouse cursor
• GCD Tracker - Shows your last used ability
• Combat Notifier - Alerts when entering/leaving combat
• Auto Key Insert - Automatically use mythic keys (coming soon)
]])

-- Command info
local cmdInfo = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cmdInfo:SetPoint("BOTTOM", 0, 20)
cmdInfo:SetText("Slash Commands: |cFF00FF00/huskies|r or |cFF00FF00/hqol|r")
cmdInfo:SetTextColor(0.8, 0.8, 0.8, 1)

-- Register in new settings system (Dragonflight+)
if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    
    -- Store category for later use
    addon.SettingsCategory = category
else
    -- Fallback for older versions
    InterfaceOptions_AddCategory(panel)
end
