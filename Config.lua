-- HuskiesQOL Configuration Defaults

local AddonName, NS = ...
local addon = NS.addon

addon.Defaults = {
    -- Crosshair Settings
    crosshair = {
        enabled = true,
        size = 64,
        thickness = 3,
        gap = 4,
        color = {1, 0, 0, 0.9}, -- R, G, B, A
        useClassColor = false, -- Auto-use class color (different per character)
        yOffset = 0, -- Y Position (negative = up, positive = down)
        onlyInCombat = false,
        hideOnMount = true,
        hideInVehicle = true,
        hideOnDragonriding = true,
        style = "cross", -- "cross", "dot", "circle"
    },
    
    -- Mouse Ring Settings
    mouseRing = {
        enabled = true,
        radius = 80,
        thickness = 1.0, -- Ring size multiplier (0.5 - 2.0)
        color = {0.4, 0.8, 1, 0.8},
        useClassColor = false, -- Auto-use class color (different per character)
        onlyInCombat = true,
        pulseOnCombat = true,
    },
    
    -- GCD Tracker Settings (UPDATED for History Bar)
    gcdTracker = {
        enabled = true,
        size = 48, -- Size of each icon
        spacing = 4, -- Space between icons
        maxIcons = 5, -- Number of abilities to show (2-10)
        direction = "right", -- "right", "left", "up", "down"
        unlocked = false, -- Draggable mode
        -- Position (saved automatically)
        point = "CENTER",
        relativePoint = "CENTER",
        xOffset = 0,
        yOffset = -200,
    },
    
    -- Combat Notifier Settings
    combatNotifier = {
        enabled = true,
        enterMessage = ">>> IN COMBAT <<<",
        leaveMessage = ">>> OUT OF COMBAT <<<",
        playSound = true,
        enterSound = "PVPTHROUGHQUEUE",
        leaveSound = "AuctionWindowClose",
        screenFlash = true,
        flashColor = {1, 0, 0, 0.3},
        fontSize = 48,  -- Font size (10-96)
        unlocked = false,  -- Draggable mode
        -- Position (saved automatically)
        point = "TOP",
        relativePoint = "TOP",
        xOffset = 0,
        yOffset = -200,
    },
    
    -- Auto Key Insert (für später)
    autoKey = {
        enabled = false,
        keyName = "Schlüsselstein", -- Item name to auto-insert
    },
    
    -- Minimap Button
    minimap = {
        hide = false,
        angle = 225, -- Position around minimap (degrees)
    },

    -- Pass On Decor
    passOnDecor = {
        enabled = true,
    },

    -- Prey Progressbar
    preyProgressbar = {
        enabled = true,
        width = 300,
        height = 30,
        showLabel = true,
        unlocked = false,
        point = "CENTER",
        relativePoint = "CENTER",
        xOffset = 0,
        yOffset = 200,
    },
}
