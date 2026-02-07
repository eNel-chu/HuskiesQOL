-- GCD Tracker Module - IMPROVED VERSION
-- Shows ability history with customizable direction and stack counts
-- WoW 12.0 Compatible

local addon = HuskiesQOL

-- Spell blacklist (auto-attacks, passive effects, etc.)
local SPELL_BLACKLIST = {
    [75] = true, -- Auto Shot
    [6603] = true, -- Auto Attack
    [5374] = true, -- Mutilate
    [27576] = true, -- Mutilate
    [32175] = true, -- Stormstrike
    [32176] = true, -- Stormstrike (Off-Hand)
    [50622] = true, -- Bladestorm
    [61391] = true, -- Typhoon
    [84721] = true, -- Frozen Orb
    [85384] = true, -- Raging Blow
    [96103] = true, -- Raging Blow
    [107270] = true, -- Spinning Crane Kick
    [114089] = true, -- Windlash
    [114093] = true, -- Windlash Off-Hand
    [115357] = true, -- Windstrike
    [115360] = true, -- Windstrike Off-Hand
    [121473] = true, -- Shadow Blade
    [121474] = true, -- Shadow Blade Off-hand
    [132951] = true, -- Flare
    [148187] = true, -- Jade Wind
    [184707] = true, -- Rampage
    [184709] = true, -- Rampage
    [198928] = true, -- Cinderstorm
    [199672] = true, -- Rupture
    [201363] = true, -- Rampage
    [201364] = true, -- Rampage
    [213241] = true, -- Felblade
    [213243] = true, -- Felblade
    [218617] = true, -- Rampage
    [225919] = true, -- Fracture
    [225921] = true, -- Fracture
    [228354] = true, -- Flurry
    [228597] = true, -- Frostbolt
    [272790] = true, -- Frenzy; BM hunter buff
    [337819] = true, -- Screaming Brutality
    [346665] = true, -- Throw Glaive
    [385060] = true, -- Odyn's Fury
    [385061] = true, -- Odyn's Fury
    [385062] = true, -- Odyn's Fury
    [393035] = true, -- Throw Glaive
}

-- Module state
local currentlyCasting = nil
local currentlyChanneling = nil
local prevSpellID = nil
local prevSpellTime = 0

-- Spell info cache (for performance)
local spellInfoCache = {}

-- History of abilities (stores iconID and count)
local abilityHistory = {}

-- Main container frame
local GCDTracker = CreateFrame("Frame", "HuskiesQOL_GCDTracker", UIParent)
GCDTracker:SetFrameStrata("MEDIUM")
GCDTracker:SetSize(300, 60) -- Default size, will be adjusted
GCDTracker:SetPoint("CENTER", UIParent, "CENTER", 0, -200)

-- Background (visible when unlocked)
GCDTracker.bg = GCDTracker:CreateTexture(nil, "BACKGROUND")
GCDTracker.bg:SetAllPoints()
GCDTracker.bg:SetColorTexture(0, 0, 0, 0.3)
GCDTracker.bg:Hide() -- Hidden by default

-- Border for unlocked mode
GCDTracker.border = {}
for i = 1, 4 do
    GCDTracker.border[i] = GCDTracker:CreateTexture(nil, "BORDER")
    GCDTracker.border[i]:SetColorTexture(0.5, 0.3, 0.7, 0.8)
    GCDTracker.border[i]:Hide()
end
-- Top
GCDTracker.border[1]:SetHeight(2)
GCDTracker.border[1]:SetPoint("TOPLEFT")
GCDTracker.border[1]:SetPoint("TOPRIGHT")
-- Bottom
GCDTracker.border[2]:SetHeight(2)
GCDTracker.border[2]:SetPoint("BOTTOMLEFT")
GCDTracker.border[2]:SetPoint("BOTTOMRIGHT")
-- Left
GCDTracker.border[3]:SetWidth(2)
GCDTracker.border[3]:SetPoint("TOPLEFT")
GCDTracker.border[3]:SetPoint("BOTTOMLEFT")
-- Right
GCDTracker.border[4]:SetWidth(2)
GCDTracker.border[4]:SetPoint("TOPRIGHT")
GCDTracker.border[4]:SetPoint("BOTTOMRIGHT")

-- Pool of icon frames (reusable)
local iconPool = {}

-- Cleanup timer variables (handler will be set later)
local timeSinceLastCleanup = 0
local CLEANUP_INTERVAL = 0.5 -- Check every 0.5 seconds

---Create a new icon frame
---@return Frame
local function CreateIconFrame()
    local frame = CreateFrame("Frame", nil, GCDTracker)
    frame:SetSize(48, 48) -- Default size
    
    -- Border (black background)
    frame.border = frame:CreateTexture(nil, "BACKGROUND")
    frame.border:SetPoint("TOPLEFT", -2, 2)
    frame.border:SetPoint("BOTTOMRIGHT", 2, -2)
    frame.border:SetColorTexture(0, 0, 0, 1)
    
    -- Icon texture
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Count text (hidden, kept for potential future use)
    frame.count = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge")
    frame.count:SetPoint("BOTTOMRIGHT", 4, 0)
    frame.count:SetTextColor(1, 1, 1, 1)
    frame.count:SetShadowOffset(1, -1)
    frame.count:SetShadowColor(0, 0, 0, 1)
    frame.count:Hide()
    
    frame:Hide()
    return frame
end

---Get or create an icon frame from pool
---@param index number
---@return Frame
local function GetIconFrame(index)
    if not iconPool[index] then
        iconPool[index] = CreateIconFrame()
    end
    return iconPool[index]
end

---Get spell info using the modern API (with caching)
---@param spellID number
---@return string|nil name, number|nil iconID
local function GetSpellInfo(spellID)
    if not spellID then
        return nil, nil
    end

    -- Check cache first
    local cached = spellInfoCache[spellID]
    if cached then
        return cached.name, cached.iconID
    end

    -- Use WoW 12.0 API
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if spellInfo then
        spellInfoCache[spellID] = {
            name = spellInfo.name,
            iconID = spellInfo.iconID,
        }
        return spellInfo.name, spellInfo.iconID
    end
    return nil, nil
end

---Add spell to history
---@param spellID number
local function AddToHistory(spellID)
    local db = addon.db.gcdTracker
    if not db or not db.enabled then return end
    
    local name, iconID = GetSpellInfo(spellID)
    if not iconID then return end
    
    -- ALWAYS add as new entry - no more stacking!
    -- Each cast creates a new icon, even if it's the same spell
    table.insert(abilityHistory, 1, {
        spellID = spellID,
        iconID = iconID,
        count = 1, -- Always 1 since we don't stack anymore
        time = GetTime()
    })
    
    -- Limit history size
    local maxIcons = db.maxIcons or 5
    while #abilityHistory > maxIcons do
        table.remove(abilityHistory)
    end
    
    -- Update display
    GCDTracker:UpdateDisplay()
end

---Remove expired entries (only out of combat)
local function CleanupHistory()
    -- Only cleanup when OUT of combat
    if InCombatLockdown() then
        return -- In combat = keep everything!
    end
    
    local currentTime = GetTime()
    local fadeTime = 5 -- 5 seconds (only out of combat)
    
    -- Remove from the END (oldest entries)
    for i = #abilityHistory, 1, -1 do
        if currentTime - abilityHistory[i].time > fadeTime then
            table.remove(abilityHistory, i)
        end
    end
    
    -- Update display if anything was removed
    GCDTracker:UpdateDisplay()
end

-- NOW set the OnUpdate handler (after CleanupHistory is defined)
GCDTracker:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastCleanup = timeSinceLastCleanup + elapsed
    
    if timeSinceLastCleanup >= CLEANUP_INTERVAL then
        CleanupHistory()
        timeSinceLastCleanup = 0
    end
end)

---Update the visual display of all icons
function GCDTracker:UpdateDisplay()
    local db = addon.db.gcdTracker
    if not db or not db.enabled then return end
    
    local size = db.size or 48
    local spacing = db.spacing or 4
    local direction = db.direction or "right"
    local maxIcons = db.maxIcons or 5
    
    -- Update frame size based on direction and number of icons
    if direction == "right" or direction == "left" then
        -- Horizontal
        self:SetSize((size + spacing) * maxIcons - spacing, size)
    else
        -- Vertical
        self:SetSize(size, (size + spacing) * maxIcons - spacing)
    end
    
    -- Hide all icons first
    for i = 1, maxIcons do
        local frame = GetIconFrame(i)
        frame:Hide()
    end
    
    -- Now show and position only the ones we have
    for i = 1, math.min(#abilityHistory, maxIcons) do
        local frame = GetIconFrame(i)
        local entry = abilityHistory[i]
        
        -- Set icon
        frame.icon:SetTexture(entry.iconID)
        
        -- Hide count (we don't use stacking anymore)
        frame.count:Hide()
        
        -- Set size
        frame:SetSize(size, size)
        
        -- Position based on direction AND INDEX
        -- CRITICAL: Each icon gets a different position based on its index!
        frame:ClearAllPoints()
        
        if direction == "right" then
            -- Left to right: First icon at LEFT, second icon further RIGHT
            frame:SetPoint("LEFT", self, "LEFT", (i - 1) * (size + spacing), 0)
            
        elseif direction == "left" then
            -- Right to left: First icon at RIGHT, second icon further LEFT
            frame:SetPoint("RIGHT", self, "RIGHT", -(i - 1) * (size + spacing), 0)
            
        elseif direction == "down" then
            -- Top to bottom: First icon at TOP, second icon further DOWN
            frame:SetPoint("TOP", self, "TOP", 0, -(i - 1) * (size + spacing))
            
        elseif direction == "up" then
            -- Bottom to top: First icon at BOTTOM, second icon further UP
            frame:SetPoint("BOTTOM", self, "BOTTOM", 0, (i - 1) * (size + spacing))
        end
        
        frame:Show()
    end
end

---Update position from saved settings
function GCDTracker:UpdatePosition()
    local db = addon.db.gcdTracker
    if not db then return end
    
    -- If we have saved position, use it
    if db.point then
        self:ClearAllPoints()
        self:SetPoint(db.point, UIParent, db.relativePoint or db.point, db.xOffset or 0, db.yOffset or 0)
    else
        -- Use default position
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
    end
    
    self:UpdateDisplay()
end

---Save current position to DB
function GCDTracker:SavePosition()
    local db = addon.db.gcdTracker
    if not db then return end
    
    local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
    db.point = point
    db.relativePoint = relativePoint
    db.xOffset = xOffset
    db.yOffset = yOffset
end

---Lock the frame (disable dragging)
function GCDTracker:Lock()
    self:EnableMouse(false)
    self:SetMovable(false)
    self.bg:Hide()
    for i = 1, 4 do
        self.border[i]:Hide()
    end
    
    if addon.db and addon.db.gcdTracker then
        addon.db.gcdTracker.unlocked = false
    end
end

---Unlock the frame (enable dragging)
function GCDTracker:Unlock()
    self:EnableMouse(true)
    self:SetMovable(true)
    self:RegisterForDrag("LeftButton")
    self.bg:Show()
    for i = 1, 4 do
        self.border[i]:Show()
    end
    
    if addon.db and addon.db.gcdTracker then
        addon.db.gcdTracker.unlocked = true
    end
    
    print("|cFF9D4EFFFHUSKIES|r GCD Tracker unlocked! Drag to reposition.")
end

---Toggle lock/unlock
function GCDTracker:ToggleLock()
    if addon.db and addon.db.gcdTracker and addon.db.gcdTracker.unlocked then
        self:Lock()
    else
        self:Unlock()
    end
end

-- Drag handlers
GCDTracker:SetScript("OnDragStart", function(self)
    if addon.db and addon.db.gcdTracker and addon.db.gcdTracker.unlocked then
        self:StartMoving()
    end
end)

GCDTracker:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    self:SavePosition()
end)

---Record a spell cast
---@param spellID number
local function RecordSpell(spellID)
    local db = addon.db.gcdTracker
    if not db or not db.enabled then return end
    
    -- Skip blacklisted spells
    if SPELL_BLACKLIST[spellID] then
        return
    end
    
    -- Prevent duplicate rapid-fire (< 0.1s apart)
    local currentTime = GetTime()
    if prevSpellID == spellID and (currentTime - prevSpellTime) < 0.1 then
        return
    end
    
    prevSpellID = spellID
    prevSpellTime = currentTime
    
    -- Add to history
    AddToHistory(spellID)
end

---Handle spell cast events
local function OnSpellEvent(self, event, unit, castGUID, spellID)
    if not addon.db or not addon.db.gcdTracker or not addon.db.gcdTracker.enabled then
        return
    end

    -- Only track player
    if unit ~= "player" then return end

    if event == "UNIT_SPELLCAST_START" then
        -- Regular cast started
        currentlyCasting = spellID

    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        -- Channel started
        currentlyChanneling = spellID

    elseif event == "UNIT_SPELLCAST_STOP" then
        -- Regular cast stopped (finished or interrupted)
        if currentlyCasting == spellID then
            currentlyCasting = nil
        end

    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        -- Channel finished
        if currentlyChanneling == spellID then
            RecordSpell(spellID)
            currentlyChanneling = nil
        end

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- Spell successfully cast
        -- Skip if it's a channel starting (channels fire SUCCEEDED at start)
        if currentlyChanneling == spellID then
            return
        end
        
        RecordSpell(spellID)
        
        -- Clear casting state
        if currentlyCasting == spellID then
            currentlyCasting = nil
        end

    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        -- Cast interrupted - clear state
        if currentlyCasting == spellID then
            currentlyCasting = nil
        end
        if currentlyChanneling == spellID then
            currentlyChanneling = nil
        end
    end
end

-- Event registration
GCDTracker:RegisterEvent("PLAYER_LOGIN")
GCDTracker:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
GCDTracker:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
GCDTracker:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
GCDTracker:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
GCDTracker:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
GCDTracker:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")

GCDTracker:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:UpdatePosition()
        
        -- Set initial lock state
        if addon.db and addon.db.gcdTracker and addon.db.gcdTracker.unlocked then
            self:Unlock()
        else
            self:Lock()
        end
    else
        OnSpellEvent(self, event, ...)
    end
end)

-- Public API
function GCDTracker:Enable()
    if addon.db and addon.db.gcdTracker then
        addon.db.gcdTracker.enabled = true
        self:UpdatePosition()
        self:Show()
    end
end

function GCDTracker:Disable()
    if addon.db and addon.db.gcdTracker then
        addon.db.gcdTracker.enabled = false
        self:Hide()
    end
end

function GCDTracker:Toggle()
    if addon.db and addon.db.gcdTracker then
        if addon.db.gcdTracker.enabled then
            self:Disable()
        else
            self:Enable()
        end
    end
end

function GCDTracker:ClearHistory()
    abilityHistory = {}
    self:UpdateDisplay()
end

-- Register module
addon:RegisterModule("GCDTracker", GCDTracker)

print("|cFF9D4EFFFHUSKIES|r GCD Tracker (History) loaded!")
