--[[
---------------------------------------
HearthstoneCombatUI - Main
Author: Chiieflady
Version: 1.0

Test: Print a message on PLAYER_LOGIN with a variable for the suffix.
---------------------------------------
]]

-- Create event frame
local HearthstoneCombatUIFrame = CreateFrame("Frame", "HearthstoneCombatUIFrame")

-- Register PLAYER_LOGIN
HearthstoneCombatUIFrame:RegisterEvent("PLAYER_LOGIN")

-- Main manager object
HSCUI = {
    frames = {},   -- store references to UI components
    settings = {}, -- config & saved vars
}

-- Initialize addon frames
function HSCUI:Init()
  -- Store all main component frames
  self.frames.main = _G["HSCUI_MainFrame"]
  self.frames.trait = _G["HSCUI_TraitFrame"]
  self.frames.resource = _G["HSCUI_ResourceFrame"]
  self.frames.abilities = _G["HSCUI_AbilitiesFrame"]

  -- Debug checks
  if self.frames.main then
    --   DEFAULT_CHAT_FRAME:AddMessage("MainFrame loaded successfully.")
  else
    --   DEFAULT_CHAT_FRAME:AddMessage("MainFrame missing!")
  end

  if self.frames.trait then
    --   DEFAULT_CHAT_FRAME:AddMessage("TraitFrame loaded successfully.")
      self.frames.trait:Show()
  else
    --   DEFAULT_CHAT_FRAME:AddMessage("TraitFrame missing!")
  end

  if self.frames.resource then
    --   DEFAULT_CHAT_FRAME:AddMessage("ResourceFrame loaded successfully.")
      self.frames.resource:Show()
      self.frames.resource:SetScale(0.87)
  else
    --   DEFAULT_CHAT_FRAME:AddMessage("ResourceFrame missing!")
  end

  if self.frames.abilities then
    --   DEFAULT_CHAT_FRAME:AddMessage("AbilitiesFrame loaded successfully.")
      self.frames.abilities:Show()
      self.frames.abilities:SetScale(0.87)
  else
    --   DEFAULT_CHAT_FRAME:AddMessage("AbilitiesFrame missing!")
  end
end

-- Toggle main frame visibility
function HSCUI:SetVisible(state)
    local main = self.frames.main
    if not main then return end
    if state then main:Show() else main:Hide() end
end

-- Generate and print login message
function HSCUI:LoginMessage()
    local messages = {
      " is ready for battle!",
      "'s tea time is over - let's fight!",
      " at your service.",
      " picked your cards.",
      " is eating a cake."
    }

    local randomMessage = messages[math.random(1, table.getn(messages))]
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[HearthstoneCombatUI]|r" .. randomMessage)
end

-- Event handler
HearthstoneCombatUIFrame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        HSCUI:Init()
        HSCUI:SetVisible(true) -- change to false if it should only show in combat
        HSCUI:LoginMessage()
        HSCUI_InitWeaponSwing()
    end
end)


--[[
    XML Usage Functions
]] 

function HSCUI_SetAbilityTextures()
    local _, class = UnitClass("player")
    local basePath = "Interface\\AddOns\\HearthstoneCombatUI\\Media\\Abilities\\" .. class .. "\\"

    local textures = {
        Left   = "sliceanddice.tga",
        Center = "sinisterstrike.tga",
        Right  = "eviscerate.tga",
    }

    for key, fileName in pairs(textures) do
        local texture = _G["HSCUI_AbilityCard" .. key]
        if texture then
            texture:SetTexture(basePath .. fileName)
        else
            DEFAULT_CHAT_FRAME:AddMessage("HSCUI: Missing texture frame HSCUI_AbilityCard" .. key)
        end
    end
end

function HSCUI_SetTraitTextures()
    local _, class = UnitClass("player")
    local basePath = "Interface\\AddOns\\HearthstoneCombatUI\\Media\\Trait\\" .. class .. "\\"

    local textures = {
        On = "daggers.tga",
        Off = "daggers-off.tga",    
    }

    for key, fileName in pairs(textures) do
        local texture = _G["HSCUI_TraitIcon" .. key]
        if texture then
            texture:SetTexture(basePath .. fileName)
        else
            DEFAULT_CHAT_FRAME:AddMessage("HSCUI: Missing texture frame HSCUI_TraitIcon" .. key)
        end
    end
end

-------------------------------------------------
-- Weapon Swing Animation
-------------------------------------------------

-- Initializes swing tracking when addon loads
function HSCUI_InitWeaponSwing()
    DEFAULT_CHAT_FRAME:AddMessage("HSCUI: InitWeaponSwing")
    HSCUI.weaponSpeed = UnitAttackSpeed("player") or 1.0
    HSCUI.nextSwingTime = GetTime() + HSCUI.weaponSpeed

    -- Create hidden frame for event listening
    if not HSCUI.swingFrame then
        HSCUI.swingFrame = CreateFrame("Frame")
    end

    -- Register combat log events
    HSCUI.swingFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    HSCUI.swingFrame:SetScript("OnEvent", HSCUI_OnCombatLogEvent)
end

-- Triggered when a weapon swing occurs
function HSCUI_OnCombatLogEvent()
    DEFAULT_CHAT_FRAME:AddMessage("HSCUI: OnCombatLogEvent")
    local timestamp, eventType, _, sourceGUID, _, _, _, _, _, _, _, _, _ = CombatLogGetCurrentEventInfo()
    if sourceGUID == UnitGUID("player") then
        if eventType == "SWING_DAMAGE" or eventType == "SWING_MISSED" then
            HSCUI_TriggerWeaponSwing()
        end
    end
end

-- Handles swing timing + visual animation
function HSCUI_TriggerWeaponSwing()
    DEFAULT_CHAT_FRAME:AddMessage("HSCUI: TriggerWeaponSwing")
    local cooldownFrame = _G["HSCUI_TraitSwingCooldown"]
    local speed = UnitAttackSpeed("player") or 1.0
    HSCUI.weaponSpeed = speed
    HSCUI.nextSwingTime = GetTime() + speed

    if cooldownFrame then
        cooldownFrame:SetCooldown(GetTime(), speed)
    end
end

-- Optional helper for testing without combat
SLASH_HSCUISWING1 = "/swtest"
SlashCmdList["HSCUISWING"] = function()
    HSCUI_TriggerWeaponSwing()
    DEFAULT_CHAT_FRAME:AddMessage("HSCUI: Test swing animation triggered.")
end


-- Initialize on PLAYER_LOGIN
-- HearthstoneCombatUIFrame:HookScript("OnEvent", function(_, event)
--     if event == "PLAYER_LOGIN" then
--         HSCUI_InitWeaponSwing()
--     end
-- end)
