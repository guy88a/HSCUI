--[[
---------------------------------------
HearthstoneCombatUI - Config
Author: Chiieflady
Version: 1.0

Handles the configuration window toggle via /hscui command.
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

-- Initialize default config values
local function HSCUI_Config_InitDefaults()
    local defaultScale = 1.0
    local defaultPosX = 0
    local defaultPosY = 0

    -- Scale Field
    if HSCUI_ConfigFrameBoardSectionPropertiesFrameScaleFieldValueBox and HSCUI_ConfigFrameBoardSectionPropertiesFrameScaleFieldSlider then
        local scaleSlider = HSCUI_ConfigFrameBoardSectionPropertiesFrameScaleFieldSlider
        local scaleBox = HSCUI_ConfigFrameBoardSectionPropertiesFrameScaleFieldValueBox
        
        scaleBox:SetText(string.format("%.1f", defaultScale))
        scaleSlider:SetValue(defaultScale)

        -- Slider → EditBox + Frame
        scaleSlider:SetScript("OnValueChanged", function()
            local v = this:GetValue()
            if v then
                scaleBox:SetText(string.format("%.1f", v))
                if HSCUI_MainFrame then
                    HSCUI_MainFrame:SetScale(v)
                end
            end
        end)

        -- EditBox → Slider + Frame
        scaleBox:SetScript("OnTextChanged", function()
            local v = tonumber(this:GetText())
            if v then
                if v < 0.5 then v = 0.5 elseif v > 2.0 then v = 2.0 end -- Safe range
                scaleSlider:SetValue(v)
                if HSCUI_MainFrame then
                    HSCUI_MainFrame:SetScale(v)
                end
            end
        end)
    end

    -- Position X Field
    if HSCUI_ConfigFrameBoardSectionPropertiesFramePositionXFieldValueBox and HSCUI_ConfigFrameBoardSectionPropertiesFramePositionXFieldSlider then
        local xSlider = HSCUI_ConfigFrameBoardSectionPropertiesFramePositionXFieldSlider
        local xBox = HSCUI_ConfigFrameBoardSectionPropertiesFramePositionXFieldValueBox

        xBox:SetText(tostring(defaultPosX))
        xSlider:SetValue(0)

        xSlider:SetScript("OnValueChanged", function()
            local v = this:GetValue()
            if v then
                xBox:SetText(string.format("%d", v))
            end
        end)
    end

    -- Position Y Field
    if HSCUI_ConfigFrameBoardSectionPropertiesFramePositionYFieldValueBox and HSCUI_ConfigFrameBoardSectionPropertiesFramePositionYFieldSlider then
        local ySlider = HSCUI_ConfigFrameBoardSectionPropertiesFramePositionYFieldSlider
        local yBox = HSCUI_ConfigFrameBoardSectionPropertiesFramePositionYFieldValueBox

        yBox:SetText(tostring(defaultPosY))
        ySlider:SetValue(0)

        ySlider:SetScript("OnValueChanged", function()
            local v = this:GetValue()
            if v then
                yBox:SetText(string.format("%d", v))
            end
        end)
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
DEFAULT_CHAT_FRAME:AddMessage("HSCUI: Config module loaded.")
