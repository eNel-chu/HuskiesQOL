-- Minimap Button for HuskiesQOL
-- Simple, reliable approach with free movement

local AddonName, NS = ...
local addon = NS.addon

-- ========================================
-- CREATE BUTTON - SIMPLE APPROACH
-- ========================================

local button = CreateFrame("Button", "HuskiesQOL_MinimapButton", Minimap)
button:SetSize(31, 31)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)

-- ========================================
-- TEXTURES - ALL ANCHORED TO BUTTON!
-- ========================================

-- Background
button.background = button:CreateTexture(nil, "BACKGROUND")
button.background:SetSize(20, 20)
button.background:SetPoint("CENTER", button, "CENTER", 0, 1)
button.background:SetColorTexture(0, 0, 0, 0.5)

-- ICON - THIS IS THE CRITICAL PART!
button.icon = button:CreateTexture(nil, "BORDER")
button.icon:SetSize(20, 20)
button.icon:SetPoint("CENTER", button, "CENTER", 0, 1)
button.icon:SetTexture("Interface\\AddOns\\HuskiesQOL\\Media\\HuskiesMinimap")

-- Border overlay
button.overlay = button:CreateTexture(nil, "OVERLAY")
button.overlay:SetSize(53, 53)
button.overlay:SetPoint("TOPLEFT", button, "TOPLEFT")
button.overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

-- Highlight
button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
button.highlight:SetSize(31, 31)
button.highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
button.highlight:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
button.highlight:SetBlendMode("ADD")
button.highlight:SetAlpha(0.5)

-- ========================================
-- POSITIONING SYSTEM - NO RADIUS LIMIT!
-- ========================================

local function PositionButton()
    button:ClearAllPoints()
    
    if not addon.db or not addon.db.minimap then
        -- Default position
        button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -15, 15)
        return
    end
    
    local x = addon.db.minimap.x or -15
    local y = addon.db.minimap.y or 15
    
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- ========================================
-- DRAGGING - COMPLETELY FREE!
-- ========================================

button:SetMovable(true)
button:EnableMouse(true)
button:RegisterForDrag("LeftButton")

local function OnDragStart(self)
    self:LockHighlight()
    self.isMoving = true
    
    -- Get starting positions
    local cursorX, cursorY = GetCursorPosition()
    local scale = self:GetEffectiveScale()
    cursorX = cursorX / scale
    cursorY = cursorY / scale
    
    self.startX = cursorX
    self.startY = cursorY
    self.startOffsetX = (addon.db.minimap.x or -15)
    self.startOffsetY = (addon.db.minimap.y or 15)
    
    self:SetScript("OnUpdate", function(self)
        if not self.isMoving then 
            self:SetScript("OnUpdate", nil)
            return 
        end
        
        local cursorX, cursorY = GetCursorPosition()
        local scale = self:GetEffectiveScale()
        cursorX = cursorX / scale
        cursorY = cursorY / scale
        
        local deltaX = cursorX - self.startX
        local deltaY = cursorY - self.startY
        
        local newX = self.startOffsetX + deltaX
        local newY = self.startOffsetY + deltaY
        
        -- NO CLAMPING - FREE MOVEMENT!
        -- If you want to keep it near minimap, uncomment this:
        -- local maxDist = 150
        -- local dist = math.sqrt(newX*newX + newY*newY)
        -- if dist > maxDist then
        --     newX = newX * (maxDist / dist)
        --     newY = newY * (maxDist / dist)
        -- end
        
        -- Update position
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "CENTER", newX, newY)
        
        -- Save to DB
        if addon.db and addon.db.minimap then
            addon.db.minimap.x = newX
            addon.db.minimap.y = newY
        end
    end)
end

local function OnDragStop(self)
    self:UnlockHighlight()
    self.isMoving = false
    self:SetScript("OnUpdate", nil)
end

button:SetScript("OnDragStart", OnDragStart)
button:SetScript("OnDragStop", OnDragStop)

-- ========================================
-- CLICKS
-- ========================================

button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
button:SetScript("OnClick", function(self, btn)
    if self.isMoving then return end
    
    if btn == "LeftButton" then
        if addon.ConfigWindow then
            addon.ConfigWindow:Toggle()
        end
    elseif btn == "RightButton" then
        print("|cFF9D4EFFHUSKIES|r QOL: Right-click menu coming soon!")
    end
end)

-- ========================================
-- TOOLTIP
-- ========================================

button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:ClearLines()
    GameTooltip:SetText("|cFF9D4EFFHUSKIES|r QOL", 1, 1, 1)
    GameTooltip:AddLine("Left-click: Open Settings", 0.7, 0.7, 0.8)
    GameTooltip:AddLine("Drag: Reposition", 0.7, 0.7, 0.8)
    GameTooltip:Show()
end)

button:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- ========================================
-- INITIALIZE
-- ========================================

local function Initialize()
    if not addon.db then
        C_Timer.After(0.5, Initialize)
        return
    end
    
    addon.db.minimap = addon.db.minimap or {}
    addon.db.minimap.x = addon.db.minimap.x or -15
    addon.db.minimap.y = addon.db.minimap.y or 15
    
    PositionButton()
    
    if addon.db.minimap.hide then
        button:Hide()
    else
        button:Show()
    end
    
    print("|cFF9D4EFFHUSKIES|r Minimap button loaded - drag to move anywhere!")
end

-- Event handler
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    C_Timer.After(1, Initialize)
end)

-- Public API
addon.MinimapButton = button

function button:Toggle()
    if self:IsShown() then
        self:Hide()
        if addon.db and addon.db.minimap then
            addon.db.minimap.hide = true
        end
    else
        self:Show()
        if addon.db and addon.db.minimap then
            addon.db.minimap.hide = false
        end
    end
end

function button:UpdatePosition()
    PositionButton()
end
