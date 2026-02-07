-- Config Window - IMPROVED VERSION mit Resize & Scroll
-- Lern-Version mit detaillierten Kommentaren
-- WoW 12.0 Compatible

local AddonName, NS = ...
local addon = NS.addon

-- ========================================
-- KONZEPT: Frame-Erstellung
-- Ein "Frame" ist wie ein Container/Fenster in WoW
-- ========================================

local ConfigWindow = CreateFrame("Frame", "HuskiesQOL_ConfigWindow", UIParent)

-- WICHTIG: Setze eine START-Größe, aber nicht die finale!
-- Der User kann es später selbst vergrößern/verkleinern
ConfigWindow:SetSize(900, 650)
ConfigWindow:SetPoint("CENTER")
ConfigWindow:SetFrameStrata("DIALOG")  -- Erscheint über anderen Fenstern

-- ========================================
-- NEU: RESIZABLE MACHEN
-- ========================================

-- Schritt 1: Frame kann Größe ändern
ConfigWindow:SetResizable(true)

-- Schritt 2: Min/Max-Grenzen setzen
-- Syntax: SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
ConfigWindow:SetResizeBounds(
    600,   -- Minimum Breite (zu klein = unleserlich)
    400,   -- Minimum Höhe
    1400,  -- Maximum Breite (zu groß = unpraktisch)
    1000   -- Maximum Höhe
)

-- ========================================
-- HINTERGRUND & BORDER (wie vorher)
-- ========================================

local bg = ConfigWindow:CreateTexture(nil, "BACKGROUND", nil, -8)
bg:SetAllPoints()
bg:SetColorTexture(0.05, 0.05, 0.08, 0.95)

-- Border-Funktion (unverändert)
local function CreateBorder(parent, r, g, b)
    local borderSize = 2
    local color = {r, g, b, 1}
    
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

CreateBorder(ConfigWindow, 0.4, 0.7, 1)  -- Hellblau statt Lila

-- ========================================
-- BEWEGLICH MACHEN (wie vorher)
-- ========================================

ConfigWindow:SetMovable(true)
ConfigWindow:EnableMouse(true)
ConfigWindow:RegisterForDrag("LeftButton")
ConfigWindow:SetScript("OnDragStart", ConfigWindow.StartMoving)
ConfigWindow:SetScript("OnDragStop", ConfigWindow.StopMovingOrSizing)
ConfigWindow:SetClampedToScreen(true)
ConfigWindow:Hide()

-- ========================================
-- NEU: RESIZE-BUTTON (untere rechte Ecke)
-- Das ist der "Griff" zum Größe ändern!
-- ========================================

local resizeButton = CreateFrame("Button", nil, ConfigWindow)
resizeButton:SetSize(16, 16)  -- Kleine Größe für den Griff
resizeButton:SetPoint("BOTTOMRIGHT", -5, 5)

-- WICHTIG: Damit der Button Mauseingaben bekommt
resizeButton:EnableMouse(true)
resizeButton:RegisterForDrag("LeftButton")

-- Textur für den Griff (die drei schrägen Linien)
local resizeTexture = resizeButton:CreateTexture(nil, "OVERLAY")
resizeTexture:SetSize(16, 16)
resizeTexture:SetPoint("CENTER")
resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

-- HIGHLIGHT: Zeigt an, wenn Maus drüber ist
local resizeHighlight = resizeButton:CreateTexture(nil, "HIGHLIGHT")
resizeHighlight:SetSize(16, 16)
resizeHighlight:SetPoint("CENTER")
resizeHighlight:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")

-- WICHTIG: Die Resize-Logik!
-- OnDragStart = Wenn User beginnt zu ziehen
resizeButton:SetScript("OnDragStart", function(self)
    ConfigWindow:StartSizing("BOTTOMRIGHT")  -- Größe ändern von unten-rechts
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
end)

-- OnDragStop = Wenn User loslässt
resizeButton:SetScript("OnDragStop", function(self)
    ConfigWindow:StopMovingOrSizing()
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    
    -- WICHTIG: Nach Resize müssen wir den Content neu berechnen!
    ConfigWindow:UpdateContentSize()
end)

-- ========================================
-- HEADER (Logo + Titel) - unverändert
-- ========================================

local headerFrame = CreateFrame("Frame", nil, ConfigWindow)
headerFrame:SetPoint("TOPLEFT", 20, -20)
headerFrame:SetPoint("TOPRIGHT", -20, -20)
headerFrame:SetHeight(130)  -- Höher für größere Logo-Box

local logoBox = CreateFrame("Frame", nil, headerFrame)
logoBox:SetSize(180, 100)  -- Gleiche Breite wie Sidebar!
logoBox:SetPoint("LEFT", 0, 0)

local logoBoxBg = logoBox:CreateTexture(nil, "BACKGROUND")
logoBoxBg:SetAllPoints()
logoBoxBg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
CreateBorder(logoBox, 0.3, 0.3, 0.35)

local logoText = logoBox:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
logoText:SetPoint("CENTER")
logoText:SetTextColor(0.6, 0.6, 0.65, 1)

local logo = logoBox:CreateTexture(nil, "ARTWORK")
logo:SetSize(160, 80)  -- Größer für 180px Box
logo:SetPoint("CENTER")
logo:SetTexture("Interface\\AddOns\\HuskiesQOL\\Media\\HuskiesLogo")

local titleFrame = CreateFrame("Frame", nil, headerFrame)
titleFrame:SetPoint("LEFT", logoBox, "RIGHT", 20, 0)
titleFrame:SetPoint("RIGHT", -150, 0)
titleFrame:SetHeight(90)

local title = titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge2")
title:SetPoint("TOPLEFT", 0, -10)
title:SetText("HuskiesQOL Settings")
title:SetTextColor(0.4, 0.7, 1, 1)  -- Hell-Blau, gut lesbar!

local version = titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
version:SetText("version 2.0.0 - Resizable!")
version:SetTextColor(0.5, 0.5, 0.6, 1)

-- Close button
local closeBtn = CreateFrame("Button", nil, ConfigWindow, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function() ConfigWindow:Hide() end)

-- ========================================
-- SIDEBAR (FEST - passt sich NICHT an!)
-- ========================================

local sidebarWidth = 180
local sidebarFrame = CreateFrame("Frame", nil, ConfigWindow)
sidebarFrame:SetPoint("TOPLEFT", 20, -150)
sidebarFrame:SetPoint("BOTTOMLEFT", 20, 50)
sidebarFrame:SetWidth(sidebarWidth)

local sidebarBg = sidebarFrame:CreateTexture(nil, "BACKGROUND")
sidebarBg:SetAllPoints()
sidebarBg:SetColorTexture(0.08, 0.08, 0.1, 0.6)
CreateBorder(sidebarFrame, 0.3, 0.3, 0.35)

-- ========================================
-- CONTENT AREA (PASST SICH AN!)
-- Hier passiert die Magie des Scrollens
-- ========================================

local contentFrame = CreateFrame("Frame", nil, ConfigWindow)
contentFrame:SetPoint("TOPLEFT", sidebarFrame, "TOPRIGHT", 15, 0)
contentFrame:SetPoint("BOTTOMRIGHT", -20, 50)

local contentBg = contentFrame:CreateTexture(nil, "BACKGROUND")
contentBg:SetAllPoints()
contentBg:SetColorTexture(0.03, 0.03, 0.05, 0.4)
CreateBorder(contentFrame, 0.3, 0.3, 0.35)

-- ========================================
-- NEU: VERBESSERTER SCROLL FRAME
-- ========================================

-- Schritt 1: ScrollFrame erstellen
local scrollFrame = CreateFrame("ScrollFrame", nil, contentFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)  -- -30 für Scrollbar-Platz

-- Schritt 2: ScrollChild (der scrollbare Inhalt)
local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(1, 1)  -- Wird dynamisch gesetzt
scrollFrame:SetScrollChild(scrollChild)

-- WICHTIG: Speichere Referenzen für später
ConfigWindow.scrollChild = scrollChild
ConfigWindow.contentFrame = contentFrame
ConfigWindow.scrollFrame = scrollFrame

-- ========================================
-- NEU: MAUSRAD-SCROLLING AKTIVIEREN
-- Macht das Scrollen viel angenehmer!
-- ========================================

-- Die Scrollbar (wird automatisch von UIPanelScrollFrameTemplate erstellt)
local scrollBar = scrollFrame.ScrollBar

-- Mausrad-Handler
scrollFrame:EnableMouseWheel(true)
scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    -- delta ist positiv bei Scroll nach oben, negativ bei Scroll nach unten
    local current = scrollBar:GetValue()
    local minVal, maxVal = scrollBar:GetMinMaxValues()
    
    -- Scroll-Geschwindigkeit: 20 Pixel pro Tick
    local scrollSpeed = 20
    local newValue = current - (delta * scrollSpeed)
    
    -- Begrenze den Wert
    if newValue < minVal then
        newValue = minVal
    elseif newValue > maxVal then
        newValue = maxVal
    end
    
    scrollBar:SetValue(newValue)
end)

-- ========================================
-- WICHTIGE FUNKTION: Content-Größe updaten
-- Wird nach jedem Resize aufgerufen!
-- ========================================

function ConfigWindow:UpdateContentSize()
    -- Hole die aktuelle Größe des Content-Bereichs
    local width = contentFrame:GetWidth() - 40  -- -40 für Padding + Scrollbar
    
    -- WICHTIG: Setze die Breite des scrollbaren Inhalts
    scrollChild:SetWidth(width > 0 and width or 600)
    
    -- Die Höhe bleibt groß genug für alle Tabs
    -- (wird nicht verkleinert, sonst würde man nicht scrollen können!)
    scrollChild:SetHeight(2000)
    
    -- Debug-Ausgabe (kannst du später entfernen)
    -- print("Content updated: width=" .. (width or "nil"))
end

-- Initial die Größe setzen
C_Timer.After(0.1, function()
    ConfigWindow:UpdateContentSize()
end)

-- ========================================
-- TAB SYSTEM (wie vorher)
-- ========================================

local tabs = {}
local tabButtons = {}
local currentTab = 1

local tabNames = {
    {name = "General"},
    {name = "Crosshair"},
    {name = "Cursor Ring"},
    {name = "GCD Tracker"},
    {name = "Combat"},
}

-- Tab Button erstellen (unverändert)
local function CreateTabButton(index, data)
    local btn = CreateFrame("Button", nil, sidebarFrame)
    btn:SetSize(sidebarWidth - 20, 45)
    btn:SetPoint("TOPLEFT", 10, -10 - ((index - 1) * 50))
    
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(0.1, 0.1, 0.12, 0.5)
    
    btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.highlight:SetAllPoints()
    btn.highlight:SetColorTexture(0.3, 0.5, 0.7, 0.3)  -- Bläulicher Highlight
    
    btn.selected = btn:CreateTexture(nil, "BORDER")
    btn.selected:SetAllPoints()
    btn.selected:SetColorTexture(0.4, 0.7, 1, 0.4)  -- Hellblau statt Lila
    btn.selected:Hide()
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    btn.text:SetPoint("LEFT", 15, 0)
    btn.text:SetText(data.name)
    btn.text:SetTextColor(0.9, 0.9, 0.9, 1)
    
    btn:SetScript("OnClick", function()
        ConfigWindow:ShowTab(index)
    end)
    
    btn:SetScript("OnEnter", function(self)
        if index ~= currentTab then
            self.bg:SetColorTexture(0.15, 0.15, 0.17, 0.7)
        end
    end)
    
    btn:SetScript("OnLeave", function(self)
        if index ~= currentTab then
            self.bg:SetColorTexture(0.1, 0.1, 0.12, 0.5)
        end
    end)
    
    return btn
end

-- Tab Buttons erstellen
for i, data in ipairs(tabNames) do
    tabButtons[i] = CreateTabButton(i, data)
end

-- Tab anzeigen (unverändert)
function ConfigWindow:ShowTab(index)
    if #tabs == 0 then
        self:InitializeTabs()
    end
    
    for i, tab in ipairs(tabs) do
        if i == index then
            tab:Show()
            tabButtons[i].selected:Show()
            tabButtons[i].bg:SetColorTexture(0.1, 0.15, 0.25, 0.8)  -- Bläulicher Hintergrund
            tabButtons[i].text:SetTextColor(0.7, 0.9, 1, 1)  -- Hellblauer Text
        else
            tab:Hide()
            tabButtons[i].selected:Hide()
            tabButtons[i].bg:SetColorTexture(0.1, 0.1, 0.12, 0.5)
            tabButtons[i].text:SetTextColor(0.9, 0.9, 0.9, 1)
        end
    end
    currentTab = index
    
    -- WICHTIG: Scroll zurück nach oben beim Tab-Wechsel
    scrollFrame.ScrollBar:SetValue(0)
end

-- Tabs initialisieren
function ConfigWindow:InitializeTabs()
    if #tabs > 0 then return end
    
    print("|cFF00FF00HuskiesQOL:|r Initializing tabs...")
    
    if addon.CreateGeneralTab then
        print("|cFF00FF00HuskiesQOL:|r Creating tabs...")
        
        local success, err
        
        success, tabs[1] = pcall(addon.CreateGeneralTab, addon, scrollChild)
        if not success then print("|cFFFF0000Error creating General tab:|r " .. tostring(tabs[1])) end
        
        success, tabs[2] = pcall(addon.CreateCrosshairTab, addon, scrollChild)
        if not success then print("|cFFFF0000Error creating Crosshair tab:|r " .. tostring(tabs[2])) end
        
        success, tabs[3] = pcall(addon.CreateMouseRingTab, addon, scrollChild)
        if not success then print("|cFFFF0000Error creating MouseRing tab:|r " .. tostring(tabs[3])) end
        
        success, tabs[4] = pcall(addon.CreateGCDTrackerTab, addon, scrollChild)
        if not success then print("|cFFFF0000Error creating GCDTracker tab:|r " .. tostring(tabs[4])) end
        
        success, tabs[5] = pcall(addon.CreateCombatNotifierTab, addon, scrollChild)
        if not success then print("|cFFFF0000Error creating CombatNotifier tab:|r " .. tostring(tabs[5])) end
        
        print("|cFF00FF00HuskiesQOL:|r Created " .. #tabs .. " tabs")
    else
        print("|cFFFF0000HuskiesQOL:|r Tab functions not found!")
    end
end

-- Fenster öffnen/schließen
function ConfigWindow:Toggle()
    if self:IsShown() then
        self:Hide()
    else
        self:Show()
        self:InitializeTabs()
        self:ShowTab(currentTab)
        self:UpdateContentSize()  -- NEU: Update bei jedem Öffnen
    end
end

-- ========================================
-- BOTTOM BUTTONS (NEU - Tab-Style!)
-- ========================================

-- Helper function for modern tab-style buttons
local function CreateModernButton(parent, text, width)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width, 35)
    
    -- Background
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
    
    -- Highlight
    btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.highlight:SetAllPoints()
    btn.highlight:SetColorTexture(0.3, 0.5, 0.7, 0.3)
    
    -- Border
    local function CreateButtonBorder(parent)
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
    CreateButtonBorder(btn)
    
    -- Text
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(text)
    btn.text:SetTextColor(0.9, 0.9, 0.9, 1)
    
    -- Hover effects
    btn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.15, 0.15, 0.17, 0.9)
        self.text:SetTextColor(0.4, 0.7, 1, 1)  -- Hellblau beim Hover
    end)
    
    btn:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
        self.text:SetTextColor(0.9, 0.9, 0.9, 1)
    end)
    
    return btn
end

-- Reset All (links)
local resetBtn = CreateModernButton(ConfigWindow, "Reset All", 110)
resetBtn:SetPoint("BOTTOMLEFT", 20, 10)
resetBtn:SetScript("OnClick", function()
    StaticPopup_Show("HUSKIESQOL_RESET_CONFIRM")
end)

-- Reload UI (links, neben Reset All)
local reloadBtn = CreateModernButton(ConfigWindow, "Reload UI", 110)
reloadBtn:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)
reloadBtn:SetScript("OnClick", function()
    ReloadUI()
end)

-- Close (rechts)
local closeBottomBtn = CreateModernButton(ConfigWindow, "Close", 110)
closeBottomBtn:SetPoint("BOTTOMRIGHT", -20, 10)
closeBottomBtn:SetScript("OnClick", function()
    ConfigWindow:Hide()
end)

-- ========================================
-- SPEICHERN
-- ========================================

addon.ConfigWindow = ConfigWindow

print("|cFF9D4EFFFHuskies|r ConfigWindow created (RESIZABLE & SCROLLABLE)!")
