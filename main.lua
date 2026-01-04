NDE = NDE or {}
NDE.helperFunctions = NDE.helperFunctions or {}
NDE.displayFunctions = NDE.displayFunctions or {}

local events = {}
local lowscore = NDE.helperFunctions:createEmptyEntry()
local test = NDE.helperFunctions:createEmptyEntry()

local mainTextFontSize = 18
local toplistFontSize = 12

local testInCombat = nil
local displayTitleStatus = 0

local frame = CreateFrame("Frame", "NearDeathExperience_Lowscore", UIParent, "BackdropTemplate")
frame:SetFrameStrata("DIALOG")
frame:SetWidth(400)
frame:SetHeight(40)
frame:SetPoint("CENTER", 0, 100)
frame:SetMovable(true)
frame:EnableMouse(true)

frame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
})
frame:SetBackdropColor(0, 0, 0, 0.5)
frame:SetBackdropBorderColor(.25, .25, .25, .5)


local highscore = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
highscore:SetTextColor(1, 1, .5, 1)
highscore:SetPoint("CENTER", frame, 0, 0)
highscore:SetJustifyH("CENTER")
local fontPath, _, flags = highscore:GetFont()
highscore:SetFont(fontPath, mainTextFontSize, flags)

local topListFrame = CreateFrame("Frame", "NearDeathExperience_TopList", frame, "BackdropTemplate")
topListFrame:SetWidth(400)
topListFrame:SetHeight(1)
topListFrame:SetPoint("TOPRIGHT", 0, - highscore:GetHeight())

topListFrame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
})

topListFrame:SetBackdropColor(0, 0, 0, 0.7)
topListFrame:SetBackdropBorderColor(1, 1, 1, 1)
topListFrame:Hide()

local topListText_indexes = topListFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topListText_indexes:SetTextColor(.7, .7, .7, 1)
topListText_indexes:SetPoint("TOPRIGHT", topListFrame, -10, -10)
topListText_indexes:SetJustifyH("RIGHT")
local fontPath, _, flags = topListText_indexes:GetFont()
topListText_indexes:SetFont(fontPath, toplistFontSize, flags)

local topListText_HP = topListFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topListText_HP:SetTextColor(1, 1, .5, 1)
topListText_HP:SetPoint("TOPRIGHT", topListFrame, -10, -10)
topListText_HP:SetJustifyH("RIGHT")
local fontPath, _, flags = topListText_HP:GetFont()
topListText_HP:SetFont(fontPath, toplistFontSize, flags)

local topListText_Lvllabel = topListFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topListText_Lvllabel:SetTextColor(1, 1, 1, 1)
topListText_Lvllabel:SetPoint("TOPRIGHT", topListFrame, -10, -10)
topListText_Lvllabel:SetJustifyH("RIGHT")
local fontPath, _, flags = topListText_Lvllabel:GetFont()
topListText_Lvllabel:SetFont(fontPath, toplistFontSize, flags)

local topListText_Lvl = topListFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topListText_Lvl:SetTextColor(1, 1, 1, 1)
topListText_Lvl:SetPoint("TOPRIGHT", topListFrame, -10, -10)
topListText_Lvl:SetJustifyH("RIGHT")
local fontPath, _, flags = topListText_Lvl:GetFont()
topListText_Lvl:SetFont(fontPath, toplistFontSize, flags)

local topListText_time = topListFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topListText_time:SetTextColor(.7, .7, .7, 1)
topListText_time:SetPoint("TOPRIGHT", topListFrame, -10, -10)
topListText_time:SetJustifyH("RIGHT")
local fontPath, _, flags = topListText_time:GetFont()
topListText_time:SetFont(fontPath, toplistFontSize, flags)

NearDeathExperienceSetup = NearDeathExperienceSetup or {}
NearDeathExperienceSetup.displayTitleStatus = NearDeathExperienceSetup.displayTitleStatus or 0

function displayScore(score)
    if (score ~= nil and score.level ~= nil) then
        local scoreLine = ""
        if NearDeathExperienceSetup.displayTitleStatus == 0 then
            highscore:SetText(NDE.displayFunctions:full(score))
        end
        if NearDeathExperienceSetup.displayTitleStatus == 1 then
            highscore:SetText(NDE.displayFunctions:mini(score))
        end
        if NearDeathExperienceSetup.displayTitleStatus == 2 then
            highscore:SetText(NDE.displayFunctions:nano(score))
        end
    else
        highscore:SetText(NDE.displayFunctions:noScoreYet())
    end
    frame:SetWidth(highscore:GetStringWidth() + 20)
    frame:SetHeight(highscore:GetStringHeight() + 10)
end

function events:PLAYER_REGEN_DISABLED()
    test = NDE.helperFunctions:sampleValues()
    testInCombat = true
end

function events:PLAYER_REGEN_ENABLED()
    testInCombat = false
    if not UnitIsDead("player") then
        test.timestamp = time()
        NDE.helperFunctions:addEntry(NearDeathExperienceScores, test)

        NearDeathExperienceScores.lastCombat = test
        -- formatedChatEntry(test, "Last Combat")

        local lowscore = NDE.helperFunctions:getLowestEntry(NearDeathExperienceScores)
        if (lowscore.health / lowscore.maxhp) > (test.health / test.maxhp) then
            formatedChatEntry(test, "new Lowscore")
        end
        displayScore(lowscore)
    end
end

function events:UNIT_HEALTH(...)
    local unit = ...
    if testInCombat == true and unit == "player" then
        if test.health == nil or (UnitHealth("player") / UnitHealthMax("player")) < (test.health / test.maxhp) then
           test = NDE.helperFunctions:sampleValues()
        end
    end
end

local function formatedChatEntry(score, name)
    if name == nil then
        name = "Entry"
    end
    if score == nil then
        print("|cffFF8888[NDE]|r |cffFFff00"..name..":|r no score data")
        return
    end

    local timeString = ""
    if score.timestamp ~= nil then
        timeString = date("%Y-%m-%d %H:%M", score.timestamp)
    else
        timeString = "some time ago"
    end

    print("|cffFF8888[NDE]|r |cffFFff00"..name..":|r " ..
              string.format("%.1f", math.floor(score.health / score.maxhp * 1000 + .5) / 10) .. "%" ..
              " HP @ Lvl " ..
              string.format("%.2f", NDE.helperFunctions:dotLevel(score.level, score.xp, score.lxp)) .."|r |cffcccccc@ " ..    
              timeString .."|r")
end

function events:PLAYER_ENTERING_WORLD(...)
    validateNDE()

    print("|cffFF8888[NDE]|r |cff00ff00hover|r to display the top 10 low scores.")
    print("|cffFF8888[NDE]|r Hold |cff00ff00CTRL|r and |cff00ff00drag|r to move the display.")
    print("|cffFF8888[NDE]|r Hold |cff00ff00ALT|r and |cff00ff00click|r the display to change info shown.")

    local lowscore = NDE.helperFunctions:getLowestEntry(NearDeathExperienceScores)
    formatedChatEntry(lowscore, "Lowscore")
    displayScore(lowscore)
end

function validateNDE()
    NearDeathExperienceScores = NDE.helperFunctions:repairScoresTable(NearDeathExperienceScores)
    NDE.helperFunctions:printEntries(NearDeathExperienceScores)

    if NearDeathExperienceScores.lastCombat == nil then
        return
    end

    local savedDotlevel = NDE.helperFunctions:dotLevel(
        NearDeathExperienceScores.lastCombat.level,
        NearDeathExperienceScores.lastCombat.xp,
        NearDeathExperienceScores.lastCombat.lxp)

    if savedDotlevel ~= nil then
        local currentDotlevel = NDE.helperFunctions:dotLevel(UnitLevel("player"), UnitXP("player"), UnitXPMax("player"))
        if currentDotlevel ~= nil and savedDotlevel > currentDotlevel then
            NearDeathExperienceScores = {
                entries = {},
                maxEntries = 10
            }
        end
    end

end

local function updateTopList()

    if NearDeathExperienceScores == nil or
       NearDeathExperienceScores.entries == nil or
       #NearDeathExperienceScores.entries == 0 then
        topListFrame:Hide()
        return
    end

    local topListIndexes = ""
    local topListHP = ""
    local topListLvllabel = ""
    local topListLvl = ""
    local topListTime = ""

    for i, entry in ipairs(NearDeathExperienceScores.entries) do
        topListIndexes = topListIndexes ..  i .. ". \n"
        topListHP = topListHP .. string.format("%.1f", math.floor(entry.health / entry.maxhp * 1000 + .5) / 10) .. "% HP\n"

        if NearDeathExperienceSetup.displayTitleStatus < 2 then
            topListLvllabel = topListLvllabel .. "@ Lvl\n"
            topListLvl = topListLvl .. string.format("%.2f", NDE.helperFunctions:dotLevel(entry.level, entry.xp, entry.lxp)) .."\n"
        end

        if NearDeathExperienceSetup.displayTitleStatus == 0 then
            if entry.timestamp ~= nil then
                topListTime = topListTime .. " ".. date("%Y-%m-%d %H:%M", entry.timestamp) .."\n"
            else
                topListTime = topListTime .. " some time ago\n"
            end
        end
    end

    local offset = 10

    topListText_time:SetText(topListTime)
    local timeWidth = topListText_time:GetStringWidth()
    topListText_time:SetPoint("TOPRIGHT", topListFrame, -offset, -10)
    offset = offset + timeWidth

    topListText_Lvl:SetText(topListLvl)
    local lvlWidth = topListText_Lvl:GetStringWidth()
    topListText_Lvl:SetPoint("TOPRIGHT", topListFrame, -offset, -10)
    offset = offset + lvlWidth

    topListText_Lvllabel:SetText(topListLvllabel)
    local lvllabelWidth = topListText_Lvllabel:GetStringWidth()
    topListText_Lvllabel:SetPoint("TOPRIGHT", topListFrame, -offset, -10)
    offset = offset + lvllabelWidth

    topListText_HP:SetText(topListHP)
    local hpWidth = topListText_HP:GetStringWidth()
    topListText_HP:SetPoint("TOPRIGHT", topListFrame, -offset, -10)
    offset = offset + hpWidth

    topListText_indexes:SetText(topListIndexes)
    local indexesWidth = topListText_indexes:GetStringWidth()
    topListText_indexes:SetPoint("TOPRIGHT", topListFrame, -offset, -10)
    offset = offset + indexesWidth

    local totalWidth = offset-10 + 10 + 10
    local totalheight = topListText_indexes:GetStringHeight() + 20
    
    topListFrame:ClearAllPoints()
    topListFrame:SetWidth(totalWidth)
    topListFrame:SetHeight(totalheight)

    local position_y = frame:GetTop()
    local y_offset = 5

    topListFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -y_offset)

    local bottomY = position_y + y_offset - totalheight
    local borderClearance = 10

    if bottomY < borderClearance then    
        topListFrame:ClearAllPoints()
        topListFrame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, y_offset)
        topListFrame:SetWidth(totalWidth)
        topListFrame:SetHeight(totalheight)
    end

end

local mouseStart = {
    x = 0,
    y = 0
}
local clickDistanceTreshold = 5

frame:SetScript("OnMouseDown", function(self, button)
    if IsControlKeyDown() then
        self:StartMoving()
    end
    if IsAltKeyDown() then
        mouseStart.x, mouseStart.y = self:GetCenter()
    end
end)

frame:SetScript("OnMouseUp", function(self, button)
    self:StopMovingOrSizing()
    if IsAltKeyDown() then
        local mouseEnd = {
            x = 0,
            y = 0
        }
        mouseEnd.x, mouseEnd.y = self:GetCenter()
        local delta_x = mouseStart.x - mouseEnd.x
        local delta_y = mouseStart.y - mouseEnd.y
        if (delta_x * delta_x + delta_y * delta_y) < clickDistanceTreshold * clickDistanceTreshold then
            NearDeathExperienceSetup.displayTitleStatus = (NearDeathExperienceSetup.displayTitleStatus + 1) % 3
            local lowscore = NDE.helperFunctions:getLowestEntry(NearDeathExperienceScores)
            displayScore(lowscore)
        end
    end
    updateTopList()
end)

frame:SetScript("OnEnter", function(self, button)
    topListFrame:Show()
    updateTopList()
end)

frame:SetScript("OnLeave", function(self, button)
    topListFrame:Hide()
end)

frame:SetScript("OnDragStop", function(self, button)
    self:StopMovingOrSizing()
    updateTopList()
end)

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end)

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end
