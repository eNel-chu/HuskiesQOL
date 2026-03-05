-- PreyProgressbar Module
-- Tracks and displays Prey hunt progress as a configurable progress bar
-- Uses C_QuestLog.GetActivePreyQuest() + UIWidget system (same approach as Preydator addon)

local AddonName, NS = ...
local addon = NS.addon

local PREY_WIDGET_TYPE = 31  -- Enum.UIWidgetVisualizationType.PreyHuntProgress fallback
local PREY_PROGRESS_FINAL = 3

local PreyBar = CreateFrame("Frame", "HuskiesQOL_PreyProgressbar", UIParent, "BackdropTemplate")
PreyBar:SetSize(300, 30)
PreyBar:SetPoint("CENTER", 0, 200)
PreyBar:SetMovable(true)
PreyBar:EnableMouse(false)
PreyBar:SetClampedToScreen(true)
PreyBar:SetFrameStrata("MEDIUM")
PreyBar:Hide()

-- Background / border
PreyBar:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
PreyBar:SetBackdropColor(0.05, 0.05, 0.08, 0.9)
PreyBar:SetBackdropBorderColor(0.5, 0.2, 0.05, 1)

-- Status bar (the fill)
local statusBar = CreateFrame("StatusBar", nil, PreyBar)
statusBar:SetPoint("TOPLEFT", 2, -2)
statusBar:SetPoint("BOTTOMRIGHT", -2, 2)
statusBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
statusBar:GetStatusBarTexture():SetAtlas("UI-CastingBar-Interrupted")
statusBar:SetMinMaxValues(0, 100)
statusBar:SetValue(0)

-- Dark background behind bar fill
local barBg = statusBar:CreateTexture(nil, "BACKGROUND")
barBg:SetAllPoints()
barBg:SetTexture("Interface\\Buttons\\WHITE8X8")
barBg:SetVertexColor(0.08, 0.04, 0.02, 0.9)

-- Label above bar (shows stage name)
local labelText = PreyBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
labelText:SetPoint("BOTTOM", PreyBar, "TOP", 0, 5)
labelText:SetText("Prey Progress - Stage 1")
labelText:SetTextColor(0.9, 0.2, 0.2, 1)
labelText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")

local STAGE_NAMES = { "Stage 1", "Stage 2", "Stage 3", "Stage 4" }


-- Shine effect on top half
local shine = statusBar:CreateTexture(nil, "OVERLAY")
shine:SetTexture("Interface\\Buttons\\WHITE8X8")
shine:SetPoint("TOPLEFT")
shine:SetPoint("BOTTOMRIGHT", statusBar, "CENTER", 0, 0)
shine:SetVertexColor(1, 1, 1, 0.06)

-- ========================================
-- DRAG SUPPORT
-- ========================================

PreyBar:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and addon.db.preyProgressbar.unlocked then
        self:StartMoving()
    end
end)

PreyBar:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        if addon.db.preyProgressbar then
            addon.db.preyProgressbar.point = point
            addon.db.preyProgressbar.relativePoint = relativePoint
            addon.db.preyProgressbar.xOffset = x
            addon.db.preyProgressbar.yOffset = y
        end
    end
end)

-- ========================================
-- PREY TRACKING (widget/quest based)
-- ========================================

local function GetWidgetTypePreyHuntProgress()
    if Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.PreyHuntProgress then
        return Enum.UIWidgetVisualizationType.PreyHuntProgress
    end
    return PREY_WIDGET_TYPE
end

local function GetShownStateShown()
    if Enum and Enum.WidgetShownState and Enum.WidgetShownState.Shown then
        return Enum.WidgetShownState.Shown
    end
    return 1
end

local function GetActivePreyQuest()
    if C_QuestLog and C_QuestLog.GetActivePreyQuest then
        return C_QuestLog.GetActivePreyQuest()
    end
    return nil
end

local function IsValidQuestID(questID)
    return type(questID) == "number" and questID > 0
end

local function ClampPercent(value)
    return math.max(0, math.min(100, value))
end

local function ExtractProgressPercent(info)
    if type(info) ~= "table" then return nil end

    -- Direct percent fields
    local directFields = { "progressPercentage", "progressPercent", "fillPercentage", "percentage", "percent", "progress" }
    for _, field in ipairs(directFields) do
        local val = tonumber(info[field])
        if val then
            if val >= 0 and val <= 1 then return ClampPercent(val * 100) end
            return ClampPercent(val)
        end
    end

    -- Value/max ratio
    local valueFields = { "barValue", "value", "currentValue" }
    local maxFields = { "barMax", "maxValue", "total", "max" }
    for _, vf in ipairs(valueFields) do
        local cur = info[vf]
        if type(cur) == "number" then
            for _, mf in ipairs(maxFields) do
                local mx = info[mf]
                if type(mx) == "number" and mx > 0 then
                    return ClampPercent((cur / mx) * 100)
                end
            end
        end
    end

    -- Tooltip percent
    if type(info.tooltip) == "string" then
        local pct = tonumber(info.tooltip:match("(%d+)%s*%%"))
        if pct then return ClampPercent(pct) end
    end

    return nil
end

local function GetQuestObjectivePercent(questID)
    if not IsValidQuestID(questID) then return nil end

    local questBarPct = nil
    if GetQuestProgressBarPercent then
        local raw = tonumber(GetQuestProgressBarPercent(questID))
        if raw then questBarPct = ClampPercent(raw) end
    end

    if not (C_QuestLog and C_QuestLog.GetQuestObjectives) then return questBarPct end

    local objectives = C_QuestLog.GetQuestObjectives(questID)
    if type(objectives) ~= "table" or #objectives == 0 then return questBarPct end

    local totalFulfilled, totalRequired = 0, 0
    local anyNumeric = false

    for _, obj in ipairs(objectives) do
        if type(obj) == "table" then
            local fulfilled = tonumber(obj.numFulfilled)
            local required = tonumber(obj.numRequired)
            if fulfilled and required and required > 0 then
                anyNumeric = true
                totalFulfilled = totalFulfilled + math.max(0, fulfilled)
                totalRequired = totalRequired + math.max(0, required)
            end
        end
    end

    if anyNumeric and totalRequired > 0 then
        local objPct = ClampPercent((totalFulfilled / totalRequired) * 100)
        if questBarPct then return math.max(objPct, questBarPct) end
        return objPct
    end

    return questBarPct
end

local candidateWidgetSetIDs = {}
local function GetCandidateWidgetSetIDs()
    for i = #candidateWidgetSetIDs, 1, -1 do candidateWidgetSetIDs[i] = nil end
    if C_UIWidgetManager then
        if C_UIWidgetManager.GetTopCenterWidgetSetID then
            candidateWidgetSetIDs[#candidateWidgetSetIDs + 1] = C_UIWidgetManager.GetTopCenterWidgetSetID()
        end
        if C_UIWidgetManager.GetObjectiveTrackerWidgetSetID then
            candidateWidgetSetIDs[#candidateWidgetSetIDs + 1] = C_UIWidgetManager.GetObjectiveTrackerWidgetSetID()
        end
        if C_UIWidgetManager.GetBelowMinimapWidgetSetID then
            candidateWidgetSetIDs[#candidateWidgetSetIDs + 1] = C_UIWidgetManager.GetBelowMinimapWidgetSetID()
        end
        if C_UIWidgetManager.GetPowerBarWidgetSetID then
            candidateWidgetSetIDs[#candidateWidgetSetIDs + 1] = C_UIWidgetManager.GetPowerBarWidgetSetID()
        end
    end
    return candidateWidgetSetIDs
end

local STAGE_PCT = { [1] = 25, [2] = 50, [3] = 75, [4] = 100 }

local function GetStageFromState(progressState)
    if progressState == 0 then return 1 end
    if progressState == 1 then return 2 end
    if progressState == 2 then return 3 end
    if progressState == PREY_PROGRESS_FINAL then return 4 end
    return 1
end

local function FindPreyWidgetProgress()
    if not (C_UIWidgetManager
        and C_UIWidgetManager.GetAllWidgetsBySetID
        and C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo) then
        return nil, nil
    end

    local preyWidgetType = GetWidgetTypePreyHuntProgress()
    local shownStateShown = GetShownStateShown()

    for _, setID in ipairs(GetCandidateWidgetSetIDs()) do
        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(setID)
        if widgets then
            for _, widget in ipairs(widgets) do
                if widget and widget.widgetType == preyWidgetType then
                    local info = C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo(widget.widgetID)
                    if info and info.shownState == shownStateShown then
                        return info.progressState, ExtractProgressPercent(info)
                    end
                end
            end
        end
    end

    return nil, nil
end

-- ========================================
-- CORE LOGIC
-- ========================================

local function UpdateBar(pct, stage)
    local db = addon.db.preyProgressbar
    pct = pct or 0
    local stageName = STAGE_NAMES[stage] or STAGE_NAMES[1]
    statusBar:SetMinMaxValues(0, 100)
    statusBar:SetValue(pct)
    if db.showLabel ~= false then
        labelText:SetText("Prey Progress - " .. stageName)
    end
end

local function CheckPrey()
    local db = addon.db.preyProgressbar
    if not db.enabled then
        PreyBar:Hide()
        return
    end

    -- Preview when unlocked
    if db.unlocked then
        PreyBar:Show()
        UpdateBar(65, 1)
        return
    end

    local questID = GetActivePreyQuest()
    if not IsValidQuestID(questID) then
        PreyBar:Hide()
        return
    end

    -- Try widget first
    local progressState, pct = FindPreyWidgetProgress()

    -- Final stage = 100%
    if progressState == PREY_PROGRESS_FINAL then
        pct = 100
    end

    -- Fallback to quest objectives
    if pct == nil then
        pct = GetQuestObjectivePercent(questID)
    end

    local stage = 1
    if progressState ~= nil then
        stage = GetStageFromState(progressState)
        -- Stage-based fallback: if we know what stage we're on but have no percent,
        -- derive a minimum percent from the stage (same approach as Preydator)
        if pct == nil or pct <= 0 then
            pct = STAGE_PCT[stage] or 0
        end
    end

    UpdateBar(pct or 0, stage)
    PreyBar:Show()
end

-- ========================================
-- PUBLIC API
-- ========================================

function PreyBar:UpdateAppearance()
    local db = addon.db.preyProgressbar
    self:SetSize(db.width or 300, db.height or 30)
    labelText:SetShown(db.showLabel ~= false)
end

function PreyBar:RestorePosition()
    local db = addon.db.preyProgressbar
    if db.point then
        self:ClearAllPoints()
        self:SetPoint(
            db.point or "CENTER",
            UIParent,
            db.relativePoint or "CENTER",
            db.xOffset or 0,
            db.yOffset or 200
        )
    end
end

function PreyBar:Lock()
    addon.db.preyProgressbar.unlocked = false
    self:EnableMouse(false)
    CheckPrey()
end

function PreyBar:Unlock()
    addon.db.preyProgressbar.unlocked = true
    self:EnableMouse(true)
    self:Show()
    UpdateBar(65, 1)
end

function PreyBar:ToggleLock()
    if addon.db.preyProgressbar.unlocked then
        self:Lock()
    else
        self:Unlock()
    end
end

function PreyBar:Refresh()
    CheckPrey()
end

function PreyBar:Enable()
    addon.db.preyProgressbar.enabled = true
    CheckPrey()
end

function PreyBar:Disable()
    addon.db.preyProgressbar.enabled = false
    self:Hide()
end

function PreyBar:Toggle()
    if addon.db.preyProgressbar.enabled then
        self:Disable()
    else
        self:Enable()
    end
end

-- ========================================
-- EVENTS
-- ========================================

PreyBar:RegisterEvent("PLAYER_LOGIN")
PreyBar:RegisterEvent("QUEST_LOG_UPDATE")
PreyBar:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
PreyBar:RegisterEvent("UPDATE_UI_WIDGET")
PreyBar:RegisterEvent("QUEST_TURNED_IN")

PreyBar:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:RestorePosition()
        self:UpdateAppearance()
        if addon.db.preyProgressbar.unlocked then
            self:Unlock()
        end
        CheckPrey()
    elseif event == "QUEST_TURNED_IN" then
        C_Timer.After(3, function() CheckPrey() end)
    else
        CheckPrey()
    end
end)

-- Register module
addon:RegisterModule("PreyProgressbar", PreyBar)
