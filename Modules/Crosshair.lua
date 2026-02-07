-- Crosshair Module
-- Performance optimized with style options

local addon = HuskiesQOL
local Crosshair = CreateFrame("Frame", "HuskiesQOL_Crosshair", UIParent)
Crosshair:SetFrameStrata("HIGH")
Crosshair:Hide()

-- Texture elements
Crosshair.hLine = Crosshair:CreateTexture(nil, "OVERLAY")
Crosshair.vLine = Crosshair:CreateTexture(nil, "OVERLAY")
Crosshair.dot = Crosshair:CreateTexture(nil, "OVERLAY")
Crosshair.circle = Crosshair:CreateTexture(nil, "OVERLAY")

-- State tracking
local isInCombat = InCombatLockdown()  -- Initialize with current state
local isMounted = false
local isInVehicle = false
local isDragonriding = false
local combatEventsRegistered = false  -- Track if combat events are registered

-- Update appearance based on style
function Crosshair:UpdateAppearance()
    local db = addon.db.crosshair
    -- Don't check enabled here - we want live preview in config!
    -- if not db.enabled then return end
    
    local r, g, b, a = unpack(db.color)
    a = a or 1  -- Default alpha to 1 if nil
    
    local size = db.size
    local thickness = db.thickness
    local gap = db.gap
    
    -- FORCE REDRAW: Hide frame, update, then show again
    local wasShown = self:IsShown()
    if wasShown then
        self:Hide()
    end
    
    self:SetSize(size, size)
    
    -- Hide all elements first
    self.hLine:Hide()
    self.vLine:Hide()
    self.dot:Hide()
    self.circle:Hide()
    
    if db.style == "cross" then
        -- Horizontal line
        self.hLine:ClearAllPoints()
        self.hLine:SetColorTexture(r, g, b, a)
        self.hLine:SetSize(size, thickness)
        self.hLine:SetPoint("CENTER", 0, 0)
        self.hLine:Show()
        
        -- Vertical line
        self.vLine:ClearAllPoints()
        self.vLine:SetColorTexture(r, g, b, a)
        self.vLine:SetSize(thickness, size)
        self.vLine:SetPoint("CENTER", 0, 0)
        self.vLine:Show()
        
    elseif db.style == "dot" then
        self.dot:ClearAllPoints()
        self.dot:SetColorTexture(r, g, b, a)
        self.dot:SetSize(thickness * 2, thickness * 2)
        self.dot:SetPoint("CENTER", 0, 0)
        self.dot:Show()
        
    elseif db.style == "circle" then
        self.circle:ClearAllPoints()
        self.circle:SetTexture("Interface\\AddOns\\HuskiesQOL\\Media\\Circle")
        self.circle:SetVertexColor(r, g, b, a)
        self.circle:SetSize(size, size)
        self.circle:SetPoint("CENTER", 0, 0)
        self.circle:Show()
    end
    
    -- FORCE REDRAW: Show frame again
    if wasShown then
        self:Show()
    end
end

-- Update position based on Y offset
function Crosshair:UpdatePosition()
    local db = addon.db.crosshair
    local yOffset = db.yOffset or 0
    
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "CENTER", 0, yOffset)
end

-- Update visibility based on conditions
function Crosshair:UpdateVisibility()
    local db = addon.db.crosshair
    
    if not db.enabled then
        self:Hide()
        return
    end
    
    -- Check all hide conditions - WICHTIG: isInCombat Variable statt InCombatLockdown()!
    -- (InCombatLockdown hat Timing-Issues mit PLAYER_REGEN_DISABLED Event)
    if db.onlyInCombat and not isInCombat then
        self:Hide()
        return
    end
    
    if db.hideOnMount and isMounted then
        self:Hide()
        return
    end
    
    if db.hideInVehicle and isInVehicle then
        self:Hide()
        return
    end
    
    if db.hideOnDragonriding and isDragonriding then
        self:Hide()
        return
    end
    
    self:Show()
end

-- Sync combat state with current reality (called when checkbox is toggled)
function Crosshair:UpdateCombatStatus()
    isInCombat = InCombatLockdown()
end

-- Register combat events (only if not already registered)
function Crosshair:RegisterCombatEvents()
    if not combatEventsRegistered then
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        combatEventsRegistered = true
    end
end

-- Unregister combat events (only if currently registered)
function Crosshair:UnregisterCombatEvents()
    if combatEventsRegistered then
        self:UnregisterEvent("PLAYER_REGEN_DISABLED")
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        combatEventsRegistered = false
    end
end

-- Update mount/vehicle/dragonriding status
function Crosshair:UpdateMountStatus()
    isMounted = IsMounted()
    isInVehicle = UnitInVehicle("player")
    isDragonriding = false  -- Dragonriding detection disabled (causes errors in WoW 12.0)
    
    self:UpdateVisibility()
end

-- Event handlers (optimized - only register needed events)
Crosshair:RegisterEvent("PLAYER_LOGIN")
-- Combat events (PLAYER_REGEN_DISABLED/ENABLED) werden CONDITIONAL registriert:
--   - In PLAYER_LOGIN wenn onlyInCombat aktiv ist
--   - Dynamisch in ConfigWindow_Tabs.lua wenn die Checkbox geändert wird
Crosshair:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")  -- For mount detection (WoW 12.0)
Crosshair:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
Crosshair:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

Crosshair:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_LOGIN" then
        -- Initialize combat state
        isInCombat = InCombatLockdown()
        
        -- Initialize combat events conditionally
        local db = addon.db.crosshair
        if db and db.onlyInCombat then
            self:RegisterCombatEvents()
        end
        
        self:UpdateAppearance()
        self:UpdatePosition()
        self:UpdateMountStatus()
        self:UpdateVisibility()
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Entering combat - Set variable FIRST, then update visibility
        isInCombat = true
        self:UpdateVisibility()
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Leaving combat - Set variable FIRST, then update visibility
        isInCombat = false
        self:UpdateVisibility()
        
    elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        -- Mount status changed - update immediately
        self:UpdateMountStatus()
        
    elseif event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" then
        C_Timer.After(0.1, function() self:UpdateMountStatus() end)
    end
end)

-- Public API
function Crosshair:Enable()
    addon.db.crosshair.enabled = true
    self:UpdateAppearance()
    self:UpdateVisibility()
end

function Crosshair:Disable()
    addon.db.crosshair.enabled = false
    self:Hide()
end

function Crosshair:Toggle()
    if addon.db.crosshair.enabled then
        self:Disable()
    else
        self:Enable()
    end
end

-- Register module
addon:RegisterModule("Crosshair", Crosshair)
