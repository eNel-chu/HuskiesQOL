-- Mouse Ring Module
-- Shows a circle around the mouse cursor (optional: only in combat)

local AddonName, NS = ...
local addon = NS.addon
local MouseRing = CreateFrame("Frame", "HuskiesQOL_MouseRing", UIParent)
MouseRing:SetFrameStrata("TOOLTIP")
MouseRing:SetSize(200, 200)
MouseRing:Hide()

-- State tracking
local isInCombat = false

-- Ring texture (single circle texture)
MouseRing.ring = MouseRing:CreateTexture(nil, "OVERLAY")
MouseRing.ring:SetTexture("Interface\\AddOns\\HuskiesQOL\\Media\\pixelring")
MouseRing.ring:SetPoint("CENTER")

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

-- Update ring appearance
function MouseRing:UpdateRing()
    local db = addon.db.mouseRing
    local radius = db.radius or 80
    local thickness = db.thickness or 1.0
    local size = radius * 2 * thickness  -- Apply thickness multiplier

    local r, g, b, a
    if db.useClassColor then
        -- Use class color
        local _, class = UnitClass("player")
        local classColor = RAID_CLASS_COLORS[class]
        if classColor then
            r, g, b = classColor.r, classColor.g, classColor.b
            a = db.color[4] or 1  -- Keep alpha from custom color
        else
            r, g, b, a = unpack(db.color)
        end
    else
        r, g, b, a = unpack(db.color)
    end
    a = a or 1  -- Ensure alpha is set

    -- Update ring appearance
    self.ring:SetVertexColor(r, g, b, a)
    self.ring:SetSize(size, size)
    self.ring:Show()  -- Make sure the texture is visible
    self:SetSize(size + 20, size + 20)
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

    -- Use state variable instead of InCombatLockdown() to avoid timing issues
    if db.onlyInCombat and not isInCombat then
        self:Hide()
        return
    end

    self:Show()
end

-- Update appearance
function MouseRing:UpdateAppearance()
    local db = addon.db.mouseRing
    if not db.enabled then return end

    self:UpdateRing()
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
        -- Initialize combat state
        isInCombat = InCombatLockdown()
        self:UpdateAppearance()

    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Entering combat - Set variable FIRST, then update visibility
        isInCombat = true
        self:UpdateVisibility()
        if addon.db.mouseRing.pulseOnCombat and self:IsShown() then
            pulseAnim:Play()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Leaving combat - Set variable FIRST, then update visibility
        isInCombat = false
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
