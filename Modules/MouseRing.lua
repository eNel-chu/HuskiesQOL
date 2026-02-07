-- Mouse Ring Module
-- Shows a circle around the mouse cursor (optional: only in combat)

local AddonName, NS = ...
local addon = NS.addon
local MouseRing = CreateFrame("Frame", "HuskiesQOL_MouseRing", UIParent)
MouseRing:SetFrameStrata("TOOLTIP")
MouseRing:SetSize(200, 200)
MouseRing:Hide()

-- Circle segments (textures for smooth circle)
MouseRing.segments = {}

-- Animation for pulse effect
local pulseAnim = MouseRing:CreateAnimationGroup()
local scale1 = pulseAnim:CreateAnimation("Scale")
scale1:SetScale(1.2, 1.2)
scale1:SetDuration(0.2)
scale1:SetOrder(1)

local scale2 = pulseAnim:CreateAnimation("Scale")
scale2:SetScale(0.833, 0.833) -- Back to 1.0 (1/1.2)
scale2:SetDuration(0.3)
scale2:SetOrder(2)

-- Build circle from line segments
function MouseRing:BuildCircle()
    local db = addon.db.mouseRing
    local segments = db.segments
    local radius = db.radius
    local thickness = db.thickness
    local r, g, b, a = unpack(db.color)
    
    -- Clear old segments
    for _, seg in ipairs(self.segments) do
        seg:Hide()
    end
    wipe(self.segments)
    
    -- Create new segments
    local angleStep = (2 * math.pi) / segments
    
    for i = 1, segments do
        local angle = i * angleStep
        local nextAngle = (i + 1) * angleStep
        
        local x1 = math.cos(angle) * radius
        local y1 = math.sin(angle) * radius
        local x2 = math.cos(nextAngle) * radius
        local y2 = math.sin(nextAngle) * radius
        
        local line = self:CreateTexture(nil, "OVERLAY")
        line:SetColorTexture(r, g, b, a)
        
        -- Calculate line length and rotation
        local length = math.sqrt((x2-x1)^2 + (y2-y1)^2)
        local midX = (x1 + x2) / 2
        local midY = (y1 + y2) / 2
        
        line:SetSize(length, thickness)
        line:SetPoint("CENTER", self, "CENTER", midX, midY)
        
        -- Rotate texture
        local rotation = math.atan2(y2 - y1, x2 - x1)
        line:SetRotation(rotation)
        
        table.insert(self.segments, line)
    end
    
    self:SetSize(radius * 2 + 20, radius * 2 + 20)
end

-- Update position to follow mouse
function MouseRing:UpdatePosition()
    if not self:IsShown() then return end
    
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
end

-- Update visibility
function MouseRing:UpdateVisibility()
    local db = addon.db.mouseRing
    
    if not db.enabled then
        self:Hide()
        return
    end
    
    if db.onlyInCombat and not InCombatLockdown() then
        self:Hide()
        return
    end
    
    self:Show()
end

-- Update appearance
function MouseRing:UpdateAppearance()
    local db = addon.db.mouseRing
    if not db.enabled then return end
    
    self:BuildCircle()
    self:UpdateVisibility()
end

-- OnUpdate for smooth mouse following
MouseRing:SetScript("OnUpdate", function(self, elapsed)
    self:UpdatePosition()
end)

-- Event handling
MouseRing:RegisterEvent("PLAYER_LOGIN")
MouseRing:RegisterEvent("PLAYER_REGEN_DISABLED")
MouseRing:RegisterEvent("PLAYER_REGEN_ENABLED")

MouseRing:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:UpdateAppearance()
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        self:UpdateVisibility()
        if addon.db.mouseRing.pulseOnCombat and self:IsShown() then
            pulseAnim:Play()
        end
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UpdateVisibility()
    end
end)

-- Public API
function MouseRing:Enable()
    addon.db.mouseRing.enabled = true
    self:UpdateAppearance()
end

function MouseRing:Disable()
    addon.db.mouseRing.enabled = false
    self:Hide()
end

function MouseRing:Toggle()
    if addon.db.mouseRing.enabled then
        self:Disable()
    else
        self:Enable()
    end
end

-- Register module
addon:RegisterModule("MouseRing", MouseRing)
