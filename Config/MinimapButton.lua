--[[
---------------------------------------
HearthstoneCombatUI - Minimap Button
Author: Chiieflady
Version: 1.0

Vanilla 1.12-safe logic for the minimap button.
Handles initialization, tooltip, and dragging logic.
---------------------------------------
]]

-- Helper for colored messages
local function HSCUI_Print(msg, r, g, b)
    DEFAULT_CHAT_FRAME:AddMessage(msg, r or 1, g or 1, b or 1)
end

-- Color definitions
local ERROR_COLOR = { r = 1.0, g = 0.3, b = 0.1 }
local ENTER_COLOR = { r = 0.2, g = 0.6, b = 1.0 } -- Blue
local SUCCESS_COLOR = { r = 0.2, g = 1.0, b = 0.2 } -- Green

-- Initialize and wire up the minimap button after the UI is ready
local function HSCUI_MinimapButton_Init()
    HSCUI_Print("HSCUI: Entering HSCUI_MinimapButton_Init()", ENTER_COLOR.r, ENTER_COLOR.g, ENTER_COLOR.b)

    local btn = getglobal("HSCUI_MinimapButton")
    if not btn then
        HSCUI_Print("HSCUI: |cffff4c20Minimap button not found (XML not loaded yet).|r", ERROR_COLOR.r, ERROR_COLOR.g, ERROR_COLOR.b)
        return
    end

    -- Enable button interactions
    btn:EnableMouse(true)
    btn:RegisterForClicks("LeftButtonUp")
    btn:RegisterForDrag("LeftButton")

    -- Dragging logic (Ctrl + Drag to move)
    btn:SetScript("OnDragStart", function()
        if IsControlKeyDown() then
            btn:StartMoving()
        end
    end)

    btn:SetScript("OnDragStop", function()
        btn:StopMovingOrSizing()
    end)

    -- Click handler (toggle config frame)
    btn:SetScript("OnClick", function()
        if IsControlKeyDown() then return end -- prevent accidental click while dragging
        if HSCUI_ConfigFrame and HSCUI_ConfigFrame:IsShown() then
            HSCUI_ConfigFrame:Hide()
        elseif HSCUI_ConfigFrame then
            HSCUI_ConfigFrame:Show()
        else
            HSCUI_Print("HSCUI: |cffff4c20Config frame not found.|r", ERROR_COLOR.r, ERROR_COLOR.g, ERROR_COLOR.b)
        end
    end)

    -- Tooltip
    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(btn, "ANCHOR_TOPLEFT")
        GameTooltip:SetText("HSCUI Config", 1, 0.82, 0)
        GameTooltip:AddLine("Left-Click: Toggle Config", 1, 1, 1)
        GameTooltip:AddLine("Ctrl + Drag: Move button", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    HSCUI_Print("HSCUI: Minimap button initialized successfully.", SUCCESS_COLOR.r, SUCCESS_COLOR.g, SUCCESS_COLOR.b)
end

-- Run after the player fully logs in (all XML frames created)
local HSCUI_MinimapButton_InitFrame = CreateFrame("Frame")
HSCUI_MinimapButton_InitFrame:RegisterEvent("PLAYER_LOGIN")
HSCUI_MinimapButton_InitFrame:SetScript("OnEvent", function()
    HSCUI_MinimapButton_Init()
end)