--[[
---------------------------------------
HearthstoneCombatUI - Config
Author: Chiieflady
Version: 1.1

Handles the configuration window toggle via /hscui command.
Adds per-character SavedVariables support (HSCUI_CharacterConfig).
---------------------------------------
]]

-- Slash command registration
SLASH_HSCUI1 = "/hscui"

SlashCmdList["HSCUI"] = function()
    local frame = HSCUI_ConfigFrame
    if not frame then
        DEFAULT_CHAT_FRAME:AddMessage("HSCUI: Config frame not found.")
        return
    end

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- Ensure SavedVariables table exists
local function HSCUI_EnsureCharacterConfig()
    if not HSCUI_CharacterConfig then
        HSCUI_CharacterConfig = {
            scale = 1.0,
            posX = 0,
            posY = 0,
        }
    else
        if HSCUI_CharacterConfig.scale == nil then HSCUI_CharacterConfig.scale = 1.0 end
        if HSCUI_CharacterConfig.posX == nil then HSCUI_CharacterConfig.posX = 0 end
        if HSCUI_CharacterConfig.posY == nil then HSCUI_CharacterConfig.posY = 0 end
    end
end

-- Initialize default config values
local function HSCUI_Config_InitDefaults()
    HSCUI_EnsureCharacterConfig()

    local p = HSCUI_CharacterConfig

    -- Retrieve UI elements dynamically
    local e = {
        scaleSlider = HSCUI_ConfigFrameBoardSectionPropertiesFrameScaleFieldSlider,
        scaleBox = HSCUI_ConfigFrameBoardSectionPropertiesFrameScaleFieldValueBox,
        posXSlider = HSCUI_ConfigFrameBoardSectionPropertiesFramePositionXFieldSlider,
        posXBox = HSCUI_ConfigFrameBoardSectionPropertiesFramePositionXFieldValueBox,
        posYSlider = HSCUI_ConfigFrameBoardSectionPropertiesFramePositionYFieldSlider,
        posYBox = HSCUI_ConfigFrameBoardSectionPropertiesFramePositionYFieldValueBox,
    }

    -- SCALE ----------------------------
    if e.scaleSlider and e.scaleBox then
        e.scaleBox:SetText(string.format("%.1f", p.scale))
        e.scaleSlider:SetValue(p.scale)

        e.scaleSlider:SetScript("OnValueChanged", function()
            local v = this:GetValue()
            if v then
                p.scale = v
                e.scaleBox:SetText(string.format("%.1f", v))
                if HSCUI_MainFrame then
                    HSCUI_MainFrame:SetScale(v)
                end
            end
        end)

        e.scaleBox:SetScript("OnTextChanged", function()
            local v = tonumber(this:GetText())
            if v then
                if v < 0.5 then v = 0.5 elseif v > 2.0 then v = 2.0 end
                p.scale = v
                e.scaleSlider:SetValue(v)
                if HSCUI_MainFrame then
                    HSCUI_MainFrame:SetScale(v)
                end
            end
        end)
    end

    -- POSITION X ----------------------------
    if e.posXSlider and e.posXBox then
        e.posXBox:SetText(tostring(p.posX))
        e.posXSlider:SetValue(p.posX)

        e.posXSlider:SetScript("OnValueChanged", function()
            local v = this:GetValue()
            if v then
                p.posX = v
                e.posXBox:SetText(string.format("%d", v))
                if HSCUI_MainFrame then
                    local _, _, _, _, y = HSCUI_MainFrame:GetPoint()
                    HSCUI_MainFrame:ClearAllPoints()
                    HSCUI_MainFrame:SetPoint("CENTER", UIParent, "CENTER", v, y or -100)
                end
            end
        end)

        e.posXBox:SetScript("OnTextChanged", function()
            local v = tonumber(this:GetText())
            if v then
                p.posX = v
                e.posXSlider:SetValue(v)
                if HSCUI_MainFrame then
                    local _, _, _, _, y = HSCUI_MainFrame:GetPoint()
                    HSCUI_MainFrame:ClearAllPoints()
                    HSCUI_MainFrame:SetPoint("CENTER", UIParent, "CENTER", v, y or -100)
                end
            end
        end)
    end

    -- POSITION Y ----------------------------
    if e.posYSlider and e.posYBox then
        e.posYBox:SetText(tostring(p.posY))
        e.posYSlider:SetValue(p.posY)

        e.posYSlider:SetScript("OnValueChanged", function()
            local v = this:GetValue()
            if v then
                p.posY = v
                e.posYBox:SetText(string.format("%d", v))
                if HSCUI_MainFrame then
                    local _, _, _, x, _ = HSCUI_MainFrame:GetPoint()
                    local adjustedY = v - 100
                    HSCUI_MainFrame:ClearAllPoints()
                    HSCUI_MainFrame:SetPoint("CENTER", UIParent, "CENTER", x or 0, adjustedY)
                end
            end
        end)

        e.posYBox:SetScript("OnTextChanged", function()
            local v = tonumber(this:GetText())
            if v then
                p.posY = v
                e.posYSlider:SetValue(v)
                if HSCUI_MainFrame then
                    local _, _, _, x, _ = HSCUI_MainFrame:GetPoint()
                    local adjustedY = v - 100
                    HSCUI_MainFrame:ClearAllPoints()
                    HSCUI_MainFrame:SetPoint("CENTER", UIParent, "CENTER", x or 0, adjustedY)
                end
            end
        end)
    end

    -- Apply saved scale/position on load
    if HSCUI_MainFrame then
        HSCUI_MainFrame:SetScale(p.scale or 1.0)
        HSCUI_MainFrame:ClearAllPoints()
        HSCUI_MainFrame:SetPoint("CENTER", UIParent, "CENTER", p.posX or 0, (p.posY or 0) - 100)
    end
end

-- Make frame movable when loaded
local function HSCUI_Config_OnLoad()
    local frame = HSCUI_ConfigFrame
    if not frame then return end

    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() this:StartMoving() end)
    frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

    HSCUI_Config_InitDefaults()
end

-- Run when UI is ready
if HSCUI_ConfigFrame then
    HSCUI_Config_OnLoad()
else
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", HSCUI_Config_OnLoad)
end

-- Initialization message
DEFAULT_CHAT_FRAME:AddMessage("HSCUI: Config module loaded with per-character data.")
