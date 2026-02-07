-- Combat Notifier Module
-- Shows on-screen messages when entering/leaving combat

local AddonName, NS = ...
local addon = NS.addon
local CombatNotifier = CreateFrame("Frame", "HuskiesQOL_CombatNotifier", UIParent)
CombatNotifier:SetSize(400, 100)
CombatNotifier:SetPoint("TOP", UIParent, "TOP", 0, -200)
CombatNotifier:SetFrameStrata("HIGH")
CombatNotifier:SetMovable(true)
CombatNotifier:EnableMouse(false)

-- Background (shown when unlocked)
CombatNotifier.bg = CombatNotifier:CreateTexture(nil, "BACKGROUND")
CombatNotifier.bg:SetAllPoints()
CombatNotifier.bg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
CombatNotifier.bg:Hide()

-- Borders
local function CreateBorder(parent)
    local borders = {}
    local borderSize = 2
    local color = {0.4, 0.7, 1, 1}
    
    local top = parent:CreateTexture(nil, "BORDER")
    top:SetColorTexture(unpack(color))
    top:SetHeight(borderSize)
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    table.insert(borders, top)
    
    local bottom = parent:CreateTexture(nil, "BORDER")
    bottom:SetColorTexture(unpack(color))
    bottom:SetHeight(borderSize)
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    table.insert(borders, bottom)
    
    local left = parent:CreateTexture(nil, "BORDER")
    left:SetColorTexture(unpack(color))
    left:SetWidth(borderSize)
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    table.insert(borders, left)
    
    local right = parent:CreateTexture(nil, "BORDER")
    right:SetColorTexture(unpack(color))
    right:SetWidth(borderSize)
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    table.insert(borders, right)
    
    return borders
end

CombatNotifier.borders = CreateBorder(CombatNotifier)
for _, border in ipairs(CombatNotifier.borders) do
    border:Hide()
end

-- Label
CombatNotifier.label = CombatNotifier:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
CombatNotifier.label:SetPoint("TOP", 0, -10)
CombatNotifier.label:SetText("Combat Notifier (Drag to move)")
CombatNotifier.label:SetTextColor(0.4, 0.7, 1, 1)
CombatNotifier.label:Hide()

-- Main text
CombatNotifier.text = CombatNotifier:CreateFontString(nil, "OVERLAY")
CombatNotifier.text:SetFont("Fonts\\FRIZQT__.TTF", 48, "THICKOUTLINE")  -- MUST BE FIRST!
CombatNotifier.text:SetPoint("CENTER", CombatNotifier, "CENTER", 0, 0)  -- Center in frame
CombatNotifier.text:SetJustifyH("CENTER")
CombatNotifier.text:SetTextColor(1, 1, 1, 1)
CombatNotifier.text:SetShadowOffset(2, -2)
CombatNotifier.text:SetShadowColor(0, 0, 0, 1)
CombatNotifier.text:SetText("")  -- Now we can set text

-- Text animation (NO SCALING - just fade)
local textAnim = CombatNotifier:CreateAnimationGroup()

-- Fade in
local fadeIn = textAnim:CreateAnimation("Alpha")
fadeIn:SetFromAlpha(0)
fadeIn:SetToAlpha(1)
fadeIn:SetDuration(0.2)
fadeIn:SetOrder(1)

-- Hold
local hold = textAnim:CreateAnimation("Alpha")
hold:SetFromAlpha(1)
hold:SetToAlpha(1)
hold:SetDuration(1.5)
hold:SetOrder(2)

-- Fade out
local fadeOut = textAnim:CreateAnimation("Alpha")
fadeOut:SetFromAlpha(1)
fadeOut:SetToAlpha(0)
fadeOut:SetDuration(0.5)
fadeOut:SetOrder(3)

textAnim:SetScript("OnPlay", function()
    CombatNotifier.text:SetAlpha(1)  -- Make sure it's visible
end)

textAnim:SetScript("OnFinished", function()
    CombatNotifier.text:SetText("")
    CombatNotifier.text:SetAlpha(0)
end)

-- Mouse-based movement (smoother than drag)
CombatNotifier:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and addon.db.combatNotifier.unlocked then
        self:StartMoving()
    end
end)

CombatNotifier:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        if addon.db.combatNotifier then
            addon.db.combatNotifier.point = point
            addon.db.combatNotifier.relativePoint = relativePoint
            addon.db.combatNotifier.xOffset = x
            addon.db.combatNotifier.yOffset = y
        end
    end
end)

-- Update font size
function CombatNotifier:UpdateFont()
    local fontSize = addon.db.combatNotifier.fontSize or 48
    self.text:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "THICKOUTLINE")
    
    -- Dynamically resize frame based on font size
    -- Width: enough for typical message text
    -- Height: font size + padding for label
    local width = math.max(400, fontSize * 8)  -- At least 400, or 8x font size
    local height = fontSize + 60  -- Font size + space for label + padding
    
    self:SetSize(width, height)
    
    -- If unlocked, show preview text
    if addon.db.combatNotifier.unlocked then
        self.text:SetText(">>> PREVIEW <<<")
        self.text:SetTextColor(0.7, 0.7, 0.7, 1)
    end
end

-- Lock/Unlock
function CombatNotifier:Lock()
    addon.db.combatNotifier.unlocked = false
    self:EnableMouse(false)
    self.bg:Hide()
    self.label:Hide()
    for _, border in ipairs(self.borders) do
        border:Hide()
    end
    -- Clear preview text
    self.text:SetText("")
end

function CombatNotifier:Unlock()
    addon.db.combatNotifier.unlocked = true
    self:EnableMouse(true)
    self.bg:Show()
    self.label:Show()
    for _, border in ipairs(self.borders) do
        border:Show()
    end
    -- Show preview text
    self:UpdateFont()  -- This will show preview
end

function CombatNotifier:ToggleLock()
    if addon.db.combatNotifier.unlocked then
        self:Lock()
    else
        self:Unlock()
    end
end

-- Show text
function CombatNotifier:ShowText(message, r, g, b)
    if not addon.db.combatNotifier.enabled then return end
    
    self.text:SetText(message)
    self.text:SetTextColor(r, g, b, 1)
    textAnim:Stop()
    textAnim:Play()
end

-- Combat enter
function CombatNotifier:OnCombatEnter()
    local db = addon.db.combatNotifier
    if not db.enabled then return end
    
    if db.enterMessage and db.enterMessage ~= "" then
        self:ShowText(db.enterMessage, 1, 0, 0)
    end
end

-- Combat leave
function CombatNotifier:OnCombatLeave()
    local db = addon.db.combatNotifier
    if not db.enabled then return end
    
    if db.leaveMessage and db.leaveMessage ~= "" then
        self:ShowText(db.leaveMessage, 0, 1, 0)
    end
end

-- Restore position
function CombatNotifier:RestorePosition()
    local db = addon.db.combatNotifier
    if db.point then
        self:ClearAllPoints()
        self:SetPoint(
            db.point or "TOP",
            UIParent,
            db.relativePoint or "TOP",
            db.xOffset or 0,
            db.yOffset or -200
        )
    end
end

-- Events
CombatNotifier:RegisterEvent("PLAYER_LOGIN")
CombatNotifier:RegisterEvent("PLAYER_REGEN_DISABLED")
CombatNotifier:RegisterEvent("PLAYER_REGEN_ENABLED")

CombatNotifier:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:RestorePosition()
        self:UpdateFont()
        
        if addon.db.combatNotifier.unlocked then
            self:Unlock()
        else
            self:Lock()
        end
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        self:OnCombatEnter()
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:OnCombatLeave()
    end
end)

-- Public API
function CombatNotifier:Enable()
    addon.db.combatNotifier.enabled = true
end

function CombatNotifier:Disable()
    addon.db.combatNotifier.enabled = false
end

function CombatNotifier:Toggle()
    if addon.db.combatNotifier.enabled then
        self:Disable()
    else
        self:Enable()
    end
end

-- Register module
addon:RegisterModule("CombatNotifier", CombatNotifier)
