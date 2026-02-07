-- ConfigWindow_Tabs.lua
-- Tab creation functions for HuskiesQOL config window
-- WoW 12.0 Compatible

local addon = HuskiesQOL

-- ========================================
-- HELPER FUNCTIONS - MODERN STYLE
-- ========================================

-- Modern Button (Tab-Style)
local function CreateModernButton(parent, text, width)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width, 35)
    
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
    
    btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.highlight:SetAllPoints()
    btn.highlight:SetColorTexture(0.3, 0.5, 0.7, 0.3)
    
    -- Border helper
    local function CreateBorder(parent)
        local borderSize = 1
        local color = {0.3, 0.3, 0.35, 1}
        
        local top = parent:CreateTexture(nil, "BORDER")
        top:SetColorTexture(unpack(color))
        top:SetHeight(borderSize)
        top:SetPoint("TOPLEFT")
        top:SetPoint("TOPRIGHT")
        
        local bottom = parent:CreateTexture(nil, "BORDER")
        bottom:SetColorTexture(unpack(color))
        bottom:SetHeight(borderSize)
        bottom:SetPoint("BOTTOMLEFT")
        bottom:SetPoint("BOTTOMRIGHT")
        
        local left = parent:CreateTexture(nil, "BORDER")
        left:SetColorTexture(unpack(color))
        left:SetWidth(borderSize)
        left:SetPoint("TOPLEFT")
        left:SetPoint("BOTTOMLEFT")
        
        local right = parent:CreateTexture(nil, "BORDER")
        right:SetColorTexture(unpack(color))
        right:SetWidth(borderSize)
        right:SetPoint("TOPRIGHT")
        right:SetPoint("BOTTOMRIGHT")
    end
    CreateBorder(btn)
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(text)
    btn.text:SetTextColor(0.9, 0.9, 0.9, 1)
    
    btn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.15, 0.15, 0.17, 0.9)
        self.text:SetTextColor(0.4, 0.7, 1, 1)
    end)
    
    btn:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
        self.text:SetTextColor(0.9, 0.9, 0.9, 1)
    end)
    
    return btn
end

local function CreateTitle(parent, text)
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetText(text)
    title:SetTextColor(0.4, 0.7, 1, 1) -- Hell-Blau, gut lesbar!
    return title
end

local function CreateDescription(parent, text)
    local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetText(text)
    desc:SetTextColor(0.7, 0.7, 0.8, 1)
    return desc
end

-- Modern Checkbox (Custom styled)
local function CreateCheckbox(parent, label, tooltipText)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(300, 32)
    
    -- The checkbox itself (custom styled)
    local check = CreateFrame("Button", nil, container)
    check:SetSize(24, 24)
    check:SetPoint("LEFT", 0, 0)
    
    -- Background
    check.bg = check:CreateTexture(nil, "BACKGROUND")
    check.bg:SetAllPoints()
    check.bg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
    
    -- Border
    local function CreateBorder(parent)
        local borderSize = 1
        local color = {0.3, 0.3, 0.35, 1}
        
        local top = parent:CreateTexture(nil, "BORDER")
        top:SetColorTexture(unpack(color))
        top:SetHeight(borderSize)
        top:SetPoint("TOPLEFT")
        top:SetPoint("TOPRIGHT")
        
        local bottom = parent:CreateTexture(nil, "BORDER")
        bottom:SetColorTexture(unpack(color))
        bottom:SetHeight(borderSize)
        bottom:SetPoint("BOTTOMLEFT")
        bottom:SetPoint("BOTTOMRIGHT")
        
        local left = parent:CreateTexture(nil, "BORDER")
        left:SetColorTexture(unpack(color))
        left:SetWidth(borderSize)
        left:SetPoint("TOPLEFT")
        left:SetPoint("BOTTOMLEFT")
        
        local right = parent:CreateTexture(nil, "BORDER")
        right:SetColorTexture(unpack(color))
        right:SetWidth(borderSize)
        right:SetPoint("TOPRIGHT")
        right:SetPoint("BOTTOMRIGHT")
    end
    CreateBorder(check)
    
    -- Check mark (blue when checked)
    check.checkmark = check:CreateTexture(nil, "OVERLAY")
    check.checkmark:SetSize(16, 16)
    check.checkmark:SetPoint("CENTER")
    check.checkmark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    check.checkmark:SetVertexColor(0.4, 0.7, 1, 1)  -- Hellblau!
    check.checkmark:Hide()
    
    -- Checked state
    check.checked = false
    
    -- Modern font for label
    check.text = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    check.text:SetPoint("LEFT", check, "RIGHT", 10, 0)
    check.text:SetText(label)
    check.text:SetTextColor(0.9, 0.9, 0.95, 1)
    
    -- Hover effect
    check:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.15, 0.15, 0.17, 0.9)
        if tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end)
    
    check:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
        GameTooltip:Hide()
    end)
    
    -- Click handler
    check:SetScript("OnClick", function(self)
        self.checked = not self.checked
        if self.checked then
            self.checkmark:Show()
        else
            self.checkmark:Hide()
        end
        
        -- Call the external OnClick if set
        if container.onClick then
            container.onClick(container)  -- Pass container (frame), not boolean!
        end
    end)
    
    -- Public API for container
    container.check = check
    
    function container:SetChecked(value)
        check.checked = value
        if value then
            check.checkmark:Show()
        else
            check.checkmark:Hide()
        end
    end
    
    function container:GetChecked()
        return check.checked
    end
    
    function container:SetScript(event, handler)
        if event == "OnClick" then
            container.onClick = handler
        end
    end
    
    return container
end

local function CreateSlider(parent, label, minVal, maxVal, step, tooltipText)
    -- Container frame
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(250, 70)
    
    -- Modern label (same font as title)
    local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    labelText:SetPoint("TOPLEFT", 0, 0)
    labelText:SetText(label)
    labelText:SetTextColor(0.9, 0.9, 0.95, 1)
    
    -- The slider itself with custom backdrop
    local slider = CreateFrame("Slider", nil, container, "BackdropTemplate")
    slider:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -8)
    slider:SetSize(220, 18)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetOrientation("HORIZONTAL")
    
    -- Modern slider track (background)
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    slider:SetBackdropColor(0.1, 0.1, 0.12, 0.8)
    slider:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)
    
    -- Modern thumb texture
    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(16, 16)
    thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
    thumb:SetVertexColor(0.4, 0.7, 1, 1)  -- Hellblau!
    slider:SetThumbTexture(thumb)
    
    -- Value display (bigger, modern font)
    slider.Value = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    slider.Value:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    slider.Value:SetTextColor(0.4, 0.7, 1, 1)  -- Hellblau
    
    -- Min/Max labels (smaller, subtle)
    slider.Low = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -3)
    slider.Low:SetText(minVal)
    slider.Low:SetTextColor(0.5, 0.5, 0.6, 1)
    
    slider.High = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -3)
    slider.High:SetText(maxVal)
    slider.High:SetTextColor(0.5, 0.5, 0.6, 1)
    
    if tooltipText then
        slider:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        slider:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end
    
    -- Store references
    container.slider = slider
    container.Value = slider.Value  -- Direct access to Value label
    container.Low = slider.Low
    container.High = slider.High
    container.SetValue = function(self, value) slider:SetValue(value) end
    container.GetValue = function(self) return slider:GetValue() end
    container.SetScript = function(self, event, handler) slider:SetScript(event, handler) end
    
    return container
end

local function CreateColorPicker(parent, label, tooltipText)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(200, 60)
    
    local labelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    labelText:SetPoint("TOPLEFT", 0, 0)
    labelText:SetText(label)
    labelText:SetTextColor(0.9, 0.9, 0.95, 1)  -- Heller, moderner Text
    
    -- Simple button with backdrop
    local colorBox = CreateFrame("Button", nil, frame, "BackdropTemplate")
    colorBox:SetSize(50, 25)
    colorBox:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -8)
    
    -- Backdrop for border
    colorBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    colorBox:SetBackdropColor(1, 1, 1, 1)  -- This will be overwritten
    colorBox:SetBackdropBorderColor(0, 0, 0, 1)
    
    if tooltipText then
        colorBox:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        colorBox:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end
    
    frame.colorBox = colorBox
    return frame
end

-- Modern Dropdown (Custom styled)
local function CreateDropdown(parent, label, tooltipText)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(250, 70)
    
    -- Label
    local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    labelText:SetPoint("TOPLEFT", 0, 0)
    labelText:SetText(label)
    labelText:SetTextColor(0.9, 0.9, 0.95, 1)
    
    -- Dropdown button (custom styled)
    local dropdown = CreateFrame("Button", nil, container)
    dropdown:SetSize(220, 35)
    dropdown:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -8)
    
    -- Background
    dropdown.bg = dropdown:CreateTexture(nil, "BACKGROUND")
    dropdown.bg:SetAllPoints()
    dropdown.bg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
    
    -- Border
    local function CreateBorder(parent)
        local borderSize = 1
        local color = {0.3, 0.3, 0.35, 1}
        
        local top = parent:CreateTexture(nil, "BORDER")
        top:SetColorTexture(unpack(color))
        top:SetHeight(borderSize)
        top:SetPoint("TOPLEFT")
        top:SetPoint("TOPRIGHT")
        
        local bottom = parent:CreateTexture(nil, "BORDER")
        bottom:SetColorTexture(unpack(color))
        bottom:SetHeight(borderSize)
        bottom:SetPoint("BOTTOMLEFT")
        bottom:SetPoint("BOTTOMRIGHT")
        
        local left = parent:CreateTexture(nil, "BORDER")
        left:SetColorTexture(unpack(color))
        left:SetWidth(borderSize)
        left:SetPoint("TOPLEFT")
        left:SetPoint("BOTTOMLEFT")
        
        local right = parent:CreateTexture(nil, "BORDER")
        right:SetColorTexture(unpack(color))
        right:SetWidth(borderSize)
        right:SetPoint("TOPRIGHT")
        right:SetPoint("BOTTOMRIGHT")
    end
    CreateBorder(dropdown)
    
    -- Dropdown text
    dropdown.text = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    dropdown.text:SetPoint("LEFT", 10, 0)
    dropdown.text:SetText("Select...")
    dropdown.text:SetTextColor(0.9, 0.9, 0.9, 1)
    
    -- Arrow icon
    dropdown.arrow = dropdown:CreateTexture(nil, "OVERLAY")
    dropdown.arrow:SetSize(16, 16)
    dropdown.arrow:SetPoint("RIGHT", -8, 0)
    dropdown.arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    dropdown.arrow:SetVertexColor(0.4, 0.7, 1, 1)  -- Hellblau
    
    -- Hover effect
    dropdown:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.15, 0.15, 0.17, 0.9)
        self.text:SetTextColor(0.4, 0.7, 1, 1)
        if tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end)
    
    dropdown:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
        self.text:SetTextColor(0.9, 0.9, 0.9, 1)
        GameTooltip:Hide()
    end)
    
    -- Store menu items
    dropdown.items = {}
    dropdown.selectedValue = nil
    
    -- Create menu frame (shown on click)
    local menu = CreateFrame("Frame", nil, dropdown, "BackdropTemplate")
    menu:SetFrameStrata("DIALOG")
    menu:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    menu:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    menu:SetBackdropBorderColor(0.4, 0.7, 1, 1)  -- Hellblauer Rand!
    menu:Hide()
    
    dropdown.menu = menu
    
    -- Function to add items
    function dropdown:AddItem(text, value, onClick)
        local itemBtn = CreateFrame("Button", nil, menu)
        itemBtn:SetSize(218, 30)
        
        itemBtn.bg = itemBtn:CreateTexture(nil, "BACKGROUND")
        itemBtn.bg:SetAllPoints()
        itemBtn.bg:SetColorTexture(0.08, 0.08, 0.1, 0.5)
        
        itemBtn.text = itemBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        itemBtn.text:SetPoint("LEFT", 10, 0)
        itemBtn.text:SetText(text)
        itemBtn.text:SetTextColor(0.9, 0.9, 0.9, 1)
        
        itemBtn:SetScript("OnEnter", function(self)
            self.bg:SetColorTexture(0.15, 0.15, 0.17, 0.9)
            self.text:SetTextColor(0.4, 0.7, 1, 1)
        end)
        
        itemBtn:SetScript("OnLeave", function(self)
            self.bg:SetColorTexture(0.08, 0.08, 0.1, 0.5)
            self.text:SetTextColor(0.9, 0.9, 0.9, 1)
        end)
        
        itemBtn:SetScript("OnClick", function(self)
            dropdown.text:SetText(text)
            dropdown.selectedValue = value
            menu:Hide()
            if onClick then
                onClick(value)
            end
        end)
        
        table.insert(self.items, {button = itemBtn, text = text, value = value})
    end
    
    -- Function to show menu
    function dropdown:ShowMenu()
        if #self.items == 0 then return end
        
        local height = #self.items * 30 + 4
        menu:SetSize(220, height)
        menu:SetPoint("TOP", self, "BOTTOM", 0, -2)
        
        for i, item in ipairs(self.items) do
            item.button:SetPoint("TOPLEFT", 1, -1 - ((i-1) * 30))
        end
        
        menu:Show()
    end
    
    dropdown:SetScript("OnClick", function(self)
        if menu:IsShown() then
            menu:Hide()
        else
            self:ShowMenu()
        end
    end)
    
    container.dropdown = dropdown
    container.SetText = function(self, text) dropdown.text:SetText(text) end
    container.AddItem = function(self, ...) dropdown:AddItem(...) end
    
    return container
end

-- ========================================
-- TAB 1: GENERAL
-- ========================================

function addon:CreateGeneralTab(parent)
    local tab = CreateFrame("Frame", nil, parent)
    tab:SetSize(parent:GetWidth(), 1500) -- Tall enough for scrolling
    tab:SetPoint("TOPLEFT", 20, -20)
    
    local yOffset = 0
    
    local title = CreateTitle(tab, "General Settings")
    title:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 40
    
    local desc = CreateDescription(tab, "Global addon settings and information.")
    desc:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 40
    
    -- Version info
    local versionLabel = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    versionLabel:SetPoint("TOPLEFT", 0, yOffset)
    versionLabel:SetText("HuskiesQOL Version 2.0.0")
    versionLabel:SetTextColor(0.5, 0.8, 1, 1)
    yOffset = yOffset - 40
    
    -- Info text
    local infoText = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("TOPLEFT", 0, yOffset)
    infoText:SetWidth(500)
    infoText:SetJustifyH("LEFT")
    infoText:SetText([[
Welcome to HuskiesQOL!

This addon provides various quality-of-life improvements for World of Warcraft.

Features:
• Customizable crosshair overlay
• Mouse cursor ring
• GCD/Ability tracker with history
• Combat notifications
• And more to come!

Use the tabs on the left to configure each feature.
Changes take effect immediately.

For support, visit: github.com/yourrepo
    ]])
    
    tab:Hide()
    return tab
end

-- ========================================
-- TAB 2: CROSSHAIR
-- ========================================

function addon:CreateCrosshairTab(parent)
    local tab = CreateFrame("Frame", nil, parent)
    tab:SetSize(parent:GetWidth(), 1500)
    tab:SetPoint("TOPLEFT", 20, -20)
    
    local yOffset = 0
    
    local title = CreateTitle(tab, "Crosshair Settings")
    title:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 40
    
    local desc = CreateDescription(tab, "Customize the center screen crosshair overlay.")
    desc:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 60
    
    -- Enable checkbox
    local enableCheck = CreateCheckbox(tab, "Enable Crosshair", "Show a crosshair in the center of your screen")
    enableCheck:SetPoint("TOPLEFT", 0, yOffset)
    enableCheck:SetChecked(addon.db.crosshair.enabled)
    enableCheck:SetScript("OnClick", function(self)
        addon.db.crosshair.enabled = self:GetChecked()
        local module = addon:GetModule("Crosshair")
        if module then
            if addon.db.crosshair.enabled then
                module:Enable()
            else
                module:Disable()
            end
        end
    end)
    yOffset = yOffset - 50
    
    -- Size slider
    local sizeSlider = CreateSlider(tab, "Crosshair Size", 32, 128, 4, "Size of the crosshair overlay")
    sizeSlider:SetPoint("TOPLEFT", 0, yOffset)
    sizeSlider:SetValue(addon.db.crosshair.size)
    sizeSlider.Value:SetText(addon.db.crosshair.size)
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.Value:SetText(value)
        addon.db.crosshair.size = value
        local module = addon:GetModule("Crosshair")
        if module and module.UpdateAppearance then
            module:UpdateAppearance()
        end
    end)
    yOffset = yOffset - 80
    
    -- Thickness slider
    local thicknessSlider = CreateSlider(tab, "Line Thickness", 1, 10, 1, "Thickness of crosshair lines")
    thicknessSlider:SetPoint("TOPLEFT", 0, yOffset)
    thicknessSlider:SetValue(addon.db.crosshair.thickness or 3)
    thicknessSlider.Value:SetText(addon.db.crosshair.thickness or 3)
    thicknessSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.Value:SetText(value)
        addon.db.crosshair.thickness = value
        local module = addon:GetModule("Crosshair")
        if module and module.UpdateAppearance then
            module:UpdateAppearance()
        end
    end)
    yOffset = yOffset - 80
    
    -- Y Offset slider
    local yOffsetSlider = CreateSlider(tab, "Vertical Position", -200, 200, 5, "Move crosshair up (negative) or down (positive)")
    yOffsetSlider:SetPoint("TOPLEFT", 0, yOffset)
    yOffsetSlider:SetValue(addon.db.crosshair.yOffset or 0)
    yOffsetSlider.Value:SetText(addon.db.crosshair.yOffset or 0)
    yOffsetSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.Value:SetText(value)
        addon.db.crosshair.yOffset = value
        local module = addon:GetModule("Crosshair")
        if module and module.UpdateAppearance then
            module:UpdateAppearance()
        end
    end)
    yOffset = yOffset - 100
    
    -- Color picker
    local colorFrame = CreateColorPicker(tab, "Crosshair Color", "Click to change color")
    colorFrame:SetPoint("TOPLEFT", 0, yOffset)
    
    -- Update the color box display
    local function UpdateColorBox()
        if not addon.db or not addon.db.crosshair then
            C_Timer.After(0.1, UpdateColorBox)
            return
        end
        local r, g, b, a = unpack(addon.db.crosshair.color or {1, 0, 0, 0.9})
        a = a or 1
        colorFrame.colorBox:SetBackdropColor(r, g, b, a)
    end
    UpdateColorBox()
    
    colorFrame.colorBox:SetScript("OnClick", function(self)
        -- Get CURRENT color values from DB (not cached!)
        local currentR, currentG, currentB, currentA = unpack(addon.db.crosshair.color or {1, 0, 0, 0.9})
        currentA = currentA or 1
        
        -- Store original values for cancel
        local originalColor = {currentR, currentG, currentB, currentA}
        
        local function OnColorSelect(restore)
            local newR, newG, newB, newA
            if restore then
                newR, newG, newB, newA = unpack(restore)
            else
                newR, newG, newB = ColorPickerFrame:GetColorRGB()
                newA = ColorPickerFrame:GetColorAlpha()
            end
            
            newA = newA or 1
            addon.db.crosshair.color = {newR, newG, newB, newA}
            
            -- Update color box display
            self:SetBackdropColor(newR, newG, newB, newA)
            
            -- Update crosshair appearance
            local module = addon:GetModule("Crosshair")
            if module and module.UpdateAppearance then
                module:UpdateAppearance()
            end
        end
        
        -- Open color picker with CURRENT values
        ColorPickerFrame:SetupColorPickerAndShow({
            r = currentR,
            g = currentG,
            b = currentB,
            opacity = currentA,
            hasOpacity = true,
            swatchFunc = OnColorSelect,
            opacityFunc = OnColorSelect,
            cancelFunc = function()
                OnColorSelect(originalColor)
            end,
        })
    end)
    yOffset = yOffset - 80
    
    -- Visibility options
    local visHeader = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    visHeader:SetPoint("TOPLEFT", 0, yOffset)
    visHeader:SetText("Visibility")
    visHeader:SetTextColor(0.4, 0.7, 1, 1)
    yOffset = yOffset - 40
    
    local combatCheck = CreateCheckbox(tab, "Only Show in Combat", "Hide crosshair when not in combat")
    combatCheck:SetPoint("TOPLEFT", 0, yOffset)
    combatCheck:SetChecked(addon.db.crosshair.onlyInCombat or false)
    combatCheck:SetScript("OnClick", function(self)
        addon.db.crosshair.onlyInCombat = self:GetChecked()
        local module = addon:GetModule("Crosshair")
        if module then
            -- Sync combat state when toggling checkbox
            module:UpdateCombatStatus()
            
            -- Register/unregister combat events based on setting
            if addon.db.crosshair.onlyInCombat then
                module:RegisterCombatEvents()
            else
                module:UnregisterCombatEvents()
            end
            
            if module.UpdateVisibility then
                module:UpdateVisibility()
            end
        end
    end)
    yOffset = yOffset - 50
    
    local mountCheck = CreateCheckbox(tab, "Hide on Mount", "Hide crosshair when mounted")
    mountCheck:SetPoint("TOPLEFT", 0, yOffset)
    mountCheck:SetChecked(addon.db.crosshair.hideOnMount ~= false)
    mountCheck:SetScript("OnClick", function(self)
        addon.db.crosshair.hideOnMount = self:GetChecked()
        local module = addon:GetModule("Crosshair")
        if module and module.UpdateVisibility then
            module:UpdateVisibility()
        end
    end)
    yOffset = yOffset - 50
    
    local vehicleCheck = CreateCheckbox(tab, "Hide in Vehicle", "Hide crosshair in vehicles")
    vehicleCheck:SetPoint("TOPLEFT", 0, yOffset)
    vehicleCheck:SetChecked(addon.db.crosshair.hideInVehicle ~= false)
    vehicleCheck:SetScript("OnClick", function(self)
        addon.db.crosshair.hideInVehicle = self:GetChecked()
        local module = addon:GetModule("Crosshair")
        if module and module.UpdateVisibility then
            module:UpdateVisibility()
        end
    end)
    
    tab:Hide()
    return tab
end

-- ========================================
-- TAB 3: MOUSE RING
-- ========================================

function addon:CreateMouseRingTab(parent)
    local tab = CreateFrame("Frame", nil, parent)
    tab:SetSize(parent:GetWidth(), 1500)
    tab:SetPoint("TOPLEFT", 20, -20)
    
    local yOffset = 0
    
    local title = CreateTitle(tab, "Cursor Ring Settings")
    title:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 40
    
    local desc = CreateDescription(tab, "Customize the ring around your mouse cursor.")
    desc:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 60
    
    -- Enable checkbox
    local enableCheck = CreateCheckbox(tab, "Enable Cursor Ring", "Show a ring around your mouse cursor")
    enableCheck:SetPoint("TOPLEFT", 0, yOffset)
    enableCheck:SetChecked(addon.db.mouseRing.enabled)
    enableCheck:SetScript("OnClick", function(self)
        addon.db.mouseRing.enabled = self:GetChecked()
        local module = addon:GetModule("MouseRing")
        if module then
            if addon.db.mouseRing.enabled then
                module:Enable()
            else
                module:Disable()
            end
        end
    end)
    yOffset = yOffset - 50
    
    -- Radius slider
    local radiusSlider = CreateSlider(tab, "Ring Radius", 40, 150, 5, "Size of the ring around cursor")
    radiusSlider:SetPoint("TOPLEFT", 0, yOffset)
    radiusSlider:SetValue(addon.db.mouseRing.radius or 80)
    radiusSlider.Value:SetText(addon.db.mouseRing.radius or 80)
    radiusSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.Value:SetText(value)
        addon.db.mouseRing.radius = value
        local module = addon:GetModule("MouseRing")
        if module and module.UpdateAppearance then
            module:UpdateAppearance()
        end
    end)
    yOffset = yOffset - 80
    
    -- Thickness slider
    local thicknessSlider = CreateSlider(tab, "Line Thickness", 1, 10, 1, "Thickness of the ring line")
    thicknessSlider:SetPoint("TOPLEFT", 0, yOffset)
    thicknessSlider:SetValue(addon.db.mouseRing.thickness or 3)
    thicknessSlider.Value:SetText(addon.db.mouseRing.thickness or 3)
    thicknessSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.Value:SetText(value)
        addon.db.mouseRing.thickness = value
        local module = addon:GetModule("MouseRing")
        if module and module.UpdateAppearance then
            module:UpdateAppearance()
        end
    end)
    yOffset = yOffset - 80
    
    -- Color picker
    local colorFrame = CreateColorPicker(tab, "Ring Color", "Click to change ring color")
    colorFrame:SetPoint("TOPLEFT", 0, yOffset)
    
    -- Update the color box display
    local function UpdateColorBox()
        if not addon.db or not addon.db.mouseRing then
            C_Timer.After(0.1, UpdateColorBox)
            return
        end
        local r, g, b, a = unpack(addon.db.mouseRing.color or {0.4, 0.8, 1, 0.8})
        a = a or 1
        colorFrame.colorBox:SetBackdropColor(r, g, b, a)
    end
    UpdateColorBox()
    
    colorFrame.colorBox:SetScript("OnClick", function(self)
        -- Get CURRENT color values from DB (not cached!)
        local currentR, currentG, currentB, currentA = unpack(addon.db.mouseRing.color or {0.4, 0.8, 1, 0.8})
        currentA = currentA or 1
        
        -- Store original values for cancel
        local originalColor = {currentR, currentG, currentB, currentA}
        
        local function OnColorSelect(restore)
            local newR, newG, newB, newA
            if restore then
                newR, newG, newB, newA = unpack(restore)
            else
                newR, newG, newB = ColorPickerFrame:GetColorRGB()
                newA = ColorPickerFrame:GetColorAlpha()
            end
            
            newA = newA or 1
            addon.db.mouseRing.color = {newR, newG, newB, newA}
            
            -- Update color box display
            self:SetBackdropColor(newR, newG, newB, newA)
            
            -- Update ring appearance
            local module = addon:GetModule("MouseRing")
            if module and module.UpdateAppearance then
                module:UpdateAppearance()
            end
        end
        
        -- Open color picker with CURRENT values
        ColorPickerFrame:SetupColorPickerAndShow({
            r = currentR,
            g = currentG,
            b = currentB,
            opacity = currentA,
            hasOpacity = true,
            swatchFunc = OnColorSelect,
            opacityFunc = OnColorSelect,
            cancelFunc = function()
                OnColorSelect(originalColor)
            end,
        })
    end)
    yOffset = yOffset - 80
    
    -- Visibility options
    local visHeader = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    visHeader:SetPoint("TOPLEFT", 0, yOffset)
    visHeader:SetText("Visibility")
    visHeader:SetTextColor(0.4, 0.7, 1, 1)
    yOffset = yOffset - 40
    
    local combatCheck = CreateCheckbox(tab, "Only Show in Combat", "Only show ring when in combat")
    combatCheck:SetPoint("TOPLEFT", 0, yOffset)
    combatCheck:SetChecked(addon.db.mouseRing.onlyInCombat ~= false)
    combatCheck:SetScript("OnClick", function(self)
        addon.db.mouseRing.onlyInCombat = self:GetChecked()
        local module = addon:GetModule("MouseRing")
        if module and module.UpdateVisibility then
            module:UpdateVisibility()
        end
    end)
    
    tab:Hide()
    return tab
end

-- ========================================
-- TAB 4: GCD TRACKER (NEW IMPROVED VERSION)
-- ========================================

function addon:CreateGCDTrackerTab(parent)
    local tab = CreateFrame("Frame", nil, parent)
    tab:SetSize(parent:GetWidth(), 1500)
    tab:SetPoint("TOPLEFT", 20, -20)
    
    local yOffset = 0
    
    -- Title
    local title = CreateTitle(tab, "GCD Tracker / Ability History")
    title:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 40
    
    -- Description
    local desc = CreateDescription(tab, "Shows your recently used abilities with stack counts.")
    desc:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 60
    
    -- Enable checkbox
    local enableCheck = CreateCheckbox(tab, "Enable GCD Tracker", "Show your ability history on screen")
    enableCheck:SetPoint("TOPLEFT", 0, yOffset)
    enableCheck:SetChecked(addon.db.gcdTracker.enabled)
    enableCheck:SetScript("OnClick", function(self)
        addon.db.gcdTracker.enabled = self:GetChecked()
        local module = addon:GetModule("GCDTracker")
        if module then
            if addon.db.gcdTracker.enabled then
                module:Enable()
            else
                module:Disable()
            end
        end
    end)
    yOffset = yOffset - 50
    
    -- Unlock/Lock button (MODERN STYLE)
    local unlockBtn = CreateModernButton(tab, addon.db.gcdTracker.unlocked and "Lock Position" or "Unlock Position", 150)
    unlockBtn:SetPoint("TOPLEFT", 0, yOffset)
    unlockBtn:SetScript("OnClick", function(self)
        local module = addon:GetModule("GCDTracker")
        if module then
            module:ToggleLock()
            self.text:SetText(addon.db.gcdTracker.unlocked and "Lock Position" or "Unlock Position")
        end
    end)
    yOffset = yOffset - 60
    
    -- Separator
    local sep1 = tab:CreateTexture(nil, "ARTWORK")
    sep1:SetHeight(2)
    sep1:SetPoint("TOPLEFT", 0, yOffset)
    sep1:SetPoint("TOPRIGHT", -20, yOffset)
    sep1:SetColorTexture(0.3, 0.3, 0.35, 0.8)
    yOffset = yOffset - 20
    
    -- APPEARANCE SECTION
    local appearanceHeader = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    appearanceHeader:SetPoint("TOPLEFT", 0, yOffset)
    appearanceHeader:SetText("Appearance")
    appearanceHeader:SetTextColor(0.4, 0.7, 1, 1) -- Hell-Blau, gut lesbar!
    yOffset = yOffset - 40
    
    -- Icon size slider
    local sizeSlider = CreateSlider(tab, "Icon Size", 32, 96, 4, "Size of each ability icon")
    sizeSlider:SetPoint("TOPLEFT", 0, yOffset)
    sizeSlider:SetValue(addon.db.gcdTracker.size)
    sizeSlider.Value:SetText(addon.db.gcdTracker.size)
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.Value:SetText(value)
        addon.db.gcdTracker.size = value
        local module = addon:GetModule("GCDTracker")
        if module and module.UpdateDisplay then
            module:UpdateDisplay()
        end
    end)
    yOffset = yOffset - 80
    
    -- Spacing slider
    local spacingSlider = CreateSlider(tab, "Icon Spacing", 0, 20, 1, "Space between icons")
    spacingSlider:SetPoint("TOPLEFT", 0, yOffset)
    spacingSlider:SetValue(addon.db.gcdTracker.spacing or 4)
    spacingSlider.Value:SetText(addon.db.gcdTracker.spacing or 4)
    spacingSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.Value:SetText(value)
        addon.db.gcdTracker.spacing = value
        local module = addon:GetModule("GCDTracker")
        if module and module.UpdateDisplay then
            module:UpdateDisplay()
        end
    end)
    yOffset = yOffset - 80
    
    -- Max icons slider
    local maxIconsSlider = CreateSlider(tab, "Number of Icons", 2, 10, 1, "Maximum number of abilities to show")
    maxIconsSlider:SetPoint("TOPLEFT", 0, yOffset)
    maxIconsSlider:SetValue(addon.db.gcdTracker.maxIcons or 5)
    maxIconsSlider.Value:SetText(addon.db.gcdTracker.maxIcons or 5)
    maxIconsSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.Value:SetText(value)
        addon.db.gcdTracker.maxIcons = value
        local module = addon:GetModule("GCDTracker")
        if module and module.UpdateDisplay then
            module:UpdateDisplay()
        end
    end)
    yOffset = yOffset - 100
    
    -- Direction dropdown (MODERN STYLE)
    local directionFrame = CreateDropdown(tab, "Growth Direction", "Direction abilities move when new ones are cast")
    directionFrame:SetPoint("TOPLEFT", 0, yOffset)
    
    local directions = {
        {text = "Left to Right", value = "right"},
        {text = "Right to Left", value = "left"},
        {text = "Top to Bottom", value = "down"},
        {text = "Bottom to Top", value = "up"},
    }
    
    -- Add items to dropdown
    for _, dir in ipairs(directions) do
        directionFrame:AddItem(dir.text, dir.value, function(value)
            addon.db.gcdTracker.direction = value
            local module = addon:GetModule("GCDTracker")
            if module and module.UpdateDisplay then
                module:UpdateDisplay()
            end
        end)
    end
    
    -- Set initial text
    for _, dir in ipairs(directions) do
        if dir.value == addon.db.gcdTracker.direction then
            directionFrame:SetText(dir.text)
            break
        end
    end
    
    yOffset = yOffset - 90
    
    -- Info box
    local infoBox = CreateFrame("Frame", nil, tab)
    infoBox:SetSize(500, 100)
    infoBox:SetPoint("TOPLEFT", 0, yOffset)
    
    local infoBg = infoBox:CreateTexture(nil, "BACKGROUND")
    infoBg:SetAllPoints()
    infoBg:SetColorTexture(0.1, 0.15, 0.2, 0.5)
    
    local infoText = infoBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("TOPLEFT", 10, -10)
    infoText:SetPoint("BOTTOMRIGHT", -10, 10)
    infoText:SetJustifyH("LEFT")
    infoText:SetJustifyV("TOP")
    infoText:SetText([[
|cFF00FF00How it works:|r
• Every ability you use appears as a new icon
• If you use the same ability multiple times, each cast shows as a separate icon
• Use "Unlock Position" to drag the bar anywhere on screen
• Icons scroll in the chosen direction as you cast new abilities
• |cFFFFFF00In combat:|r Icons stay visible (full history)
• |cFFFFFF00Out of combat:|r Icons fade after 5 seconds
    ]])
    
    tab:Hide()
    return tab
end

-- ========================================
-- TAB 5: COMBAT NOTIFIER
-- ========================================

function addon:CreateCombatNotifierTab(parent)
    local tab = CreateFrame("Frame", nil, parent)
    tab:SetSize(parent:GetWidth(), 1500)
    tab:SetPoint("TOPLEFT", 20, -20)
    
    local yOffset = 0
    
    local title = CreateTitle(tab, "Combat Notifier Settings")
    title:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 40
    
    local desc = CreateDescription(tab, "Get on-screen notifications when entering or leaving combat.")
    desc:SetPoint("TOPLEFT", 0, yOffset)
    yOffset = yOffset - 60
    
    -- Enable checkbox
    local enableCheck = CreateCheckbox(tab, "Enable Combat Notifier", "Show on-screen notifications for combat state changes")
    enableCheck:SetPoint("TOPLEFT", 0, yOffset)
    enableCheck:SetChecked(addon.db.combatNotifier.enabled)
    enableCheck:SetScript("OnClick", function(self)
        addon.db.combatNotifier.enabled = self:GetChecked()
        local module = addon:GetModule("CombatNotifier")
        if module then
            if addon.db.combatNotifier.enabled then
                module:Enable()
            else
                module:Disable()
            end
        end
    end)
    yOffset = yOffset - 50
    
    -- Unlock/Lock button (MODERN STYLE)
    local unlockBtn = CreateModernButton(tab, addon.db.combatNotifier.unlocked and "Lock Position" or "Unlock Position", 150)
    unlockBtn:SetPoint("TOPLEFT", 0, yOffset)
    unlockBtn:SetScript("OnClick", function(self)
        local module = addon:GetModule("CombatNotifier")
        if module then
            module:ToggleLock()
            self.text:SetText(addon.db.combatNotifier.unlocked and "Lock Position" or "Unlock Position")
        end
    end)
    yOffset = yOffset - 60
    
    -- Separator
    local sep1 = tab:CreateTexture(nil, "ARTWORK")
    sep1:SetHeight(2)
    sep1:SetPoint("TOPLEFT", 0, yOffset)
    sep1:SetPoint("TOPRIGHT", -20, yOffset)
    sep1:SetColorTexture(0.3, 0.3, 0.35, 0.8)
    yOffset = yOffset - 20
    
    -- APPEARANCE SECTION
    local appearanceHeader = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    appearanceHeader:SetPoint("TOPLEFT", 0, yOffset)
    appearanceHeader:SetText("Appearance")
    appearanceHeader:SetTextColor(0.4, 0.7, 1, 1)
    yOffset = yOffset - 40
    
    -- Font Size slider
    local fontSizeSlider = CreateSlider(tab, "Font Size", 10, 96, 2, "Size of the combat notification text")
    fontSizeSlider:SetPoint("TOPLEFT", 0, yOffset)
    fontSizeSlider:SetValue(addon.db.combatNotifier.fontSize or 48)
    fontSizeSlider.Value:SetText(addon.db.combatNotifier.fontSize or 48)
    fontSizeSlider.slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        fontSizeSlider.Value:SetText(value)
        addon.db.combatNotifier.fontSize = value
        local module = addon:GetModule("CombatNotifier")
        if module and module.UpdateFont then
            module:UpdateFont()
        end
    end)
    yOffset = yOffset - 80
    
    -- Separator
    local sep2 = tab:CreateTexture(nil, "ARTWORK")
    sep2:SetHeight(2)
    sep2:SetPoint("TOPLEFT", 0, yOffset)
    sep2:SetPoint("TOPRIGHT", -20, yOffset)
    sep2:SetColorTexture(0.3, 0.3, 0.35, 0.8)
    yOffset = yOffset - 20
    
    -- Info box
    local infoBox = CreateFrame("Frame", nil, tab)
    infoBox:SetSize(500, 100)
    infoBox:SetPoint("TOPLEFT", 0, yOffset)
    
    local infoBg = infoBox:CreateTexture(nil, "BACKGROUND")
    infoBg:SetAllPoints()
    infoBg:SetColorTexture(0.1, 0.15, 0.2, 0.5)
    
    local infoText = infoBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("TOPLEFT", 10, -10)
    infoText:SetPoint("BOTTOMRIGHT", -10, 10)
    infoText:SetJustifyH("LEFT")
    infoText:SetJustifyV("TOP")
    infoText:SetText([[
|cFF00FF00How it works:|r
• Messages appear in the CENTER of your screen
• |cFFFF0000Entering combat:|r Shows red text message
• |cFF00FF00Leaving combat:|r Shows green text message
• Use "Unlock Position" to drag the notification frame
• Adjust font size (10-96) to your preference
• Frame automatically resizes with font size
• Preview text shows exactly how it will look
• Customize messages in Config.lua (enterMessage/leaveMessage)
    ]])
    
    tab:Hide()
    return tab
end

print("|cFF9D4EFFFHUSKIES|r ConfigWindow Tabs loaded!")
