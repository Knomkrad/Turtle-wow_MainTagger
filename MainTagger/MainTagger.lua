-- MainTagger Addon for Turtle WoW (v1.12 Client)
-- Created by Knomkrad

-- Saved Variables
MainTaggerDB = MainTaggerDB or {}

-- Class colors (hex codes)
local classColors = {
    WARRIOR = "C79C6E",
    MAGE = "69CCF0",
    ROGUE = "FFF569",
    DRUID = "FF7D0A",
    HUNTER = "ABD473",
    SHAMAN = "0070DE",
    PRIEST = "FFFFFF",
    WARLOCK = "9482C9",
    PALADIN = "F58CBA",
}

-- Save original SendChatMessage
local Original_SendChatMessage = SendChatMessage

-- Our hooked SendChatMessage
local function MainTagger_SendChatMessage(msg, chatType, language, channel)
    local playerName = UnitName("player")

    if (chatType == "GUILD" or chatType == "WHISPER") and msg and MainTaggerDB[playerName] then
        -- Skip tagging if the message is exactly "123"
        if msg == "123" then
            Original_SendChatMessage(msg, chatType, language, channel)
            return
        end	
		
        local data = MainTaggerDB[playerName]
        if data.mainName and data.mainName ~= "" then
            local color = classColors[string.upper(data.mainClass or "")] or "69CCF0"
            local coloredTag = "|cff" .. color .. "[" .. data.mainName .. "]|r"
            msg = coloredTag .. " " .. msg
        end
    end

    Original_SendChatMessage(msg, chatType, language, channel)
end

-- Hook it
SendChatMessage = MainTagger_SendChatMessage

-- Slash Commands
SLASH_MAINTAGGER1 = "/mainname"
SLASH_MAINTAGGERCLASS1 = "/mainclass"
SLASH_MAINTAGGERCONFIG1 = "/maintaggerconfig"
SLASH_MTC1 = "/mtc"

SlashCmdList["MAINTAGGER"] = function(msg)
    local playerName = UnitName("player")
    if msg and msg ~= "" then
        if not MainTaggerDB[playerName] then
            MainTaggerDB[playerName] = {}
        end
        MainTaggerDB[playerName].mainName = msg
        DEFAULT_CHAT_FRAME:AddMessage("|cff69CCF0MainTagger:|r Main character name set to '" .. msg .. "' for " .. playerName .. ".")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff69CCF0MainTagger Usage:|r /mainname YourMainCharacterName")
    end
end

SlashCmdList["MAINTAGGERCLASS"] = function(msg)
    local playerName = UnitName("player")
    if msg and msg ~= "" and msg ~= raidInv then
        if not MainTaggerDB[playerName] then
            MainTaggerDB[playerName] = {}
        end
        MainTaggerDB[playerName].mainClass = msg
        DEFAULT_CHAT_FRAME:AddMessage("|cff69CCF0MainTagger:|r Main character class set to '" .. msg .. "' for " .. playerName .. ".")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff69CCF0MainTagger Usage:|r /mainclass YourMainClassName")
    end
end

SlashCmdList["MAINTAGGERCONFIG"] = function()
    CreateMaintaggerConfigMenu()
end

SlashCmdList["MTC"] = function()
    CreateMaintaggerConfigMenu()
end

-- Config Menu
function CreateMaintaggerConfigMenu()
    if MaintaggerConfigMenuFrame then
        MaintaggerConfigMenuFrame:Show()
        return
    end

    local frame = CreateFrame("Frame", "MaintaggerConfigMenuFrame", UIParent)
    frame:SetWidth(300)
    frame:SetHeight(200)
    frame:SetPoint("CENTER", UIParent, "CENTER")

    -- Background
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetTexture(0, 0, 0, 0.8) -- Black with 80% opacity

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("MainTagger Config")

    -- Main Name Label
    local nameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -40)
    nameLabel:SetText("Main Character Name:")

    -- Main Name EditBox
    local nameEditBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    nameEditBox:SetWidth(160)
    nameEditBox:SetHeight(20)
    nameEditBox:SetPoint("LEFT", nameLabel, "RIGHT", 10, 0)
    nameEditBox:SetAutoFocus(false)

    -- Main Class Label
    local classLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -80)
    classLabel:SetText("Main Character Class:")

    -- Main Class EditBox
    local classEditBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    classEditBox:SetWidth(160)
    classEditBox:SetHeight(20)
    classEditBox:SetPoint("LEFT", classLabel, "RIGHT", 10, 0)
    classEditBox:SetAutoFocus(false)
	
	-- Raid invite Label
	local raidLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raidLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -100)
    raidLabel:SetText("Raid invite:")
	
	-- Raid invite Editbox
	local raidEditBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    raidEditBox:SetWidth(160)
    raidEditBox:SetHeight(20)
    raidEditBox:SetPoint("LEFT", raidLabel, "RIGHT", 20, 0)
    raidEditBox:SetAutoFocus(false)


    -- Save Button
    local saveButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    saveButton:SetWidth(80)
    saveButton:SetHeight(22)
    saveButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
    saveButton:SetText("Save")

    saveButton:SetScript("OnClick", function()
        local playerName = UnitName("player")
        if not MainTaggerDB[playerName] then
            MainTaggerDB[playerName] = {}
        end
        MainTaggerDB[playerName].mainName = nameEditBox:GetText()
        MainTaggerDB[playerName].mainClass = classEditBox:GetText()
		MainTaggerDB[playerName].raidInv = raidEditBox:GetText()
        DEFAULT_CHAT_FRAME:AddMessage("|cff69CCF0MainTagger:|r Saved settings for " .. playerName .. ".")
        frame:Hide()
    end)

    -- Pre-fill fields if data exists
    local playerName = UnitName("player")
    if MainTaggerDB[playerName] then
        if MainTaggerDB[playerName].mainName then
            nameEditBox:SetText(MainTaggerDB[playerName].mainName)
        end
        if MainTaggerDB[playerName].mainClass then
            classEditBox:SetText(MainTaggerDB[playerName].mainClass)
        end
		if MainTaggerDB[playerName].raidInv then
            raidEditBox:SetText(MainTaggerDB[playerName].raidInv)
        end
    end
end
