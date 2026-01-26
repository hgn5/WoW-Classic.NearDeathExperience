local ADDON = ...

NDE = NDE or {}
NDE.helper = NDE.helper or {}
NDE.display = NDE.display or {}
NDE.options = NDE.options or {}
NDE.colors = NDE.colors or {}
NDE.animations = NDE.animations or {}
NDE.animations.icon = NDE.animations.icon or {}
NDE.gametooltip = NDE.gametooltip or {}
NDE.buffs = NDE.buffs or {}
NDE.topList = NDE.topList or {}

NearDeathExperienceSetup = NearDeathExperienceSetup or {}
NearDeathExperienceScores = NearDeathExperienceScores or {}
NearDeathExperienceSessionScores = NearDeathExperienceSessionScores or {}

NDE.isFloating = false

local test = NDE.helper:createEmptyEntry()
local toplistFontSize = 12
local testInCombat = nil

-- Icon display code for best score and tooltip --
local floatingIconContainer = CreateFrame("Frame", "NDE_FloatingIconContainer", UIParent)
floatingIconContainer:SetFrameStrata("LOW")
floatingIconContainer:EnableMouse(true)
floatingIconContainer:SetMovable(true)
floatingIconContainer:SetSize(32, 32)
floatingIconContainer:SetPoint("CENTER", 0, 0)
floatingIconContainer:Hide()

-- Create icon frame
local iconFrame = CreateFrame("Button", "NDE_IconFrame", UIParent, "BackdropTemplate")
iconFrame:SetFrameStrata("MEDIUM")
iconFrame:SetSize(32, 30)
iconFrame:SetPoint("CENTER", 0, 0)
iconFrame:SetFrameLevel(BuffFrame:GetFrameLevel())
iconFrame:EnableMouse(true)

-- Icon texture
iconFrame.icon = iconFrame:CreateTexture(nil, "BACKGROUND")
iconFrame.icon:SetAllPoints(iconFrame)
iconFrame.icon:SetTexture(136147) -- resurrection sickness icon

iconFrame.border = iconFrame:CreateTexture(nil, "BORDER")
iconFrame.border:ClearAllPoints()
iconFrame.border:SetAllPoints(iconFrame)
iconFrame.border:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", 0, 0)
iconFrame.border:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 0, 1)
iconFrame.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
iconFrame.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
iconFrame.border:SetVertexColor(1, 1, 1, 1)
iconFrame.border:SetBlendMode("ADD")

-- Title text in icon
iconFrame.title = iconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
iconFrame.title:SetPoint("BOTTOM", iconFrame, "BOTTOM",1, 2)
iconFrame.title:SetText("NDE")
local fontPath, _, flags = iconFrame.title:GetFont()
iconFrame.title:SetFont(fontPath, 10, flags)
iconFrame.title:SetTextColor(1, .8, .2, 1)

-- Percent text below
iconFrame.score = iconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
iconFrame.score:SetPoint("TOP", iconFrame, "BOTTOM", 0, -2)
iconFrame.score:SetText("--")
iconFrame.score:SetFont(fontPath, 10, flags)
iconFrame.score:SetTextColor(1, .8, .2, 1)
iconFrame.score:SetJustifyH("CENTER")

function NDE:updateIcon(score)
    iconFrame.score:SetText(NDE.helper:formatP100(score))
    local r, g, b, a = NDE.colors.p100:RGBA(score)
    iconFrame.score:SetTextColor(r, g, b, a)
    if iconFrame.border then 
        iconFrame.border:SetVertexColor(r, g, b, a)
    end
end

iconFrame:SetScript("OnEnter", function(self)
    NDE.gametooltip:setGameTooltip(self, 14)
end)

iconFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

local isDragging = false

iconFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and IsControlKeyDown() and iconFrame.isMovable == true then
        isDragging = true
        floatingIconContainer:StartMoving()
    end
end)

iconFrame:SetScript("OnMouseUp", function(self, button)
    if isDragging then
        floatingIconContainer:StopMovingOrSizing()
        isDragging = false
        return
    end

    if button == "LeftButton" then
        if NDE.topList.frame:IsShown() then
            NDE.topList.frame:Hide()
            return
        end
        NDE.topList:updateTopList()
        NDE.topList.frame:Show()

    elseif button == "RightButton" then
        local catID = NDE.options:updateOptionsScreen()
        Settings.OpenToCategory(catID)

    end
end)

-- Main display text frame for low scores --
local textDisplay = CreateFrame("Frame", "NearDeathExperience_Lowscore", UIParent, "BackdropTemplate")
textDisplay:SetFrameStrata("DIALOG")
textDisplay:SetWidth(400)
textDisplay:SetHeight(40)
textDisplay:SetPoint("TOP", 0, -72)
textDisplay:SetMovable(true)
textDisplay:EnableMouse(true)

textDisplay:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
})
textDisplay:SetBackdropColor(0, 0, 0, 0.5)
textDisplay:SetBackdropBorderColor(.25, .25, .25, .5)

local highscore = textDisplay:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
highscore:SetTextColor(1, 1, .5, 1)
highscore:SetPoint("CENTER", textDisplay, 0, 0)
highscore:SetJustifyH("CENTER")
local fontPath, _, flags = highscore:GetFont()
highscore:SetFont(fontPath, NearDeathExperienceSetup.textSize or 18, flags)

local topList = CreateFrame("Frame", "NearDeathExperience_TopList", UIParent, "BackdropTemplate")
topList:SetWidth(400)
topList:SetHeight(100)
topList:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
})

topList:SetBackdropColor(0, 0, 0, 0.7)
topList:SetBackdropBorderColor(1, 1, 1, 1)
topList:Hide()

topList.indexes = topList:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topList.indexes:SetTextColor(.7, .7, .7, 1)
topList.indexes:SetPoint("TOPRIGHT", topList, -10, -10)
topList.indexes:SetJustifyH("RIGHT")
local fontPath, _, flags = topList.indexes:GetFont()
topList.indexes:SetFont(fontPath, toplistFontSize, flags)

topList.HP = topList:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topList.HP:SetTextColor(1, 1, .5, 1)
topList.HP:SetPoint("TOPRIGHT", topList, -10, -10)
topList.HP:SetJustifyH("RIGHT")
local fontPath, _, flags = topList.HP:GetFont()
topList.HP:SetFont(fontPath, toplistFontSize, flags)

topList.Lvllabel = topList:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topList.Lvllabel:SetTextColor(1, 1, 1, 1)
topList.Lvllabel:SetPoint("TOPRIGHT", topList, -10, -10)
topList.Lvllabel:SetJustifyH("RIGHT")
local fontPath, _, flags = topList.Lvllabel:GetFont()
topList.Lvllabel:SetFont(fontPath, toplistFontSize, flags)

topList.Lvl = topList:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topList.Lvl:SetTextColor(1, 1, 1, 1)
topList.Lvl:SetPoint("TOPRIGHT", topList, -10, -10)
topList.Lvl:SetJustifyH("RIGHT")
local fontPath, _, flags = topList.Lvl:GetFont()
topList.Lvl:SetFont(fontPath, toplistFontSize, flags)

topList.times = topList:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
topList.times:SetTextColor(.7, .7, .7, 1)
topList.times:SetPoint("TOPRIGHT", topList, -10, -10)
topList.times:SetJustifyH("RIGHT")
local fontPath, _, flags = topList.times:GetFont()
topList.times:SetFont(fontPath, toplistFontSize, flags)

function NDE:setTextBgOpacity()
    local opacity = NearDeathExperienceSetup.textBgOpacity or 0.5
    textDisplay:SetBackdropColor(0, 0, 0, opacity)
    textDisplay:SetBackdropBorderColor(.25, .25, .25, opacity)
end

function NDE:updateDisplayText()
    if highscore == nil then
        return
    end
    local fontPath, _, flags = highscore:GetFont()
    highscore:SetFont(fontPath, NearDeathExperienceSetup.textSize, flags)
    textDisplay:SetWidth(highscore:GetStringWidth() + NearDeathExperienceSetup.textSize / 2)
    textDisplay:SetHeight(highscore:GetStringHeight() + NearDeathExperienceSetup.textSize / 2)
end

function NDE:displayScore(score)
    if (score ~= nil and score.level ~= nil) then
        local displayFunction = NDE.display:getDisplayFunctionName()
        if NDE.display.textStyles[displayFunction] == nil then
            textDisplay:Hide()
            return
        end
        highscore:SetText(NDE.display.textStyles[displayFunction](score))
    else
        highscore:SetText(NDE.display.textStyles:noScoreYet())
    end
    NDE:updateDisplayText()
    textDisplay:Show()
end

function NDE:AnchorNDEIcon()

    if NearDeathExperienceSetup.displayFunction == "buff" 
        or NearDeathExperienceSetup.displayFunction == "debuff"
        or NearDeathExperienceSetup.displayFunction == "floating"
    then
        textDisplay:Hide()
        iconFrame:Show()
    else
        textDisplay:Show()
        iconFrame:Hide()
        return
    end

    local anchor = nil
    if NearDeathExperienceSetup.displayFunction == "buff" then
        anchor = NDE.buffs:getLastVisibleBuff()

    elseif NearDeathExperienceSetup.displayFunction == "debuff" then
        anchor = NDE.buffs:getLastVisibleDebuff()

    end

    iconFrame:ClearAllPoints()
    iconFrame.score:ClearAllPoints()
    iconFrame.score:SetPoint("TOP", iconFrame, "BOTTOM", 0, -2)

    if anchor then
        iconFrame:SetSize(anchor:GetWidth(), anchor:GetHeight())
        iconFrame:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -6, 0)
        floatingIconContainer:Hide()

    elseif NearDeathExperienceSetup.displayFunction == "buff" then
        iconFrame:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
        floatingIconContainer:Hide()

    elseif NearDeathExperienceSetup.displayFunction == "debuff" then
        iconFrame:SetPoint("TOPRIGHT", BuffFrame, "BOTTOMRIGHT", 0, -64)
        floatingIconContainer:Hide()

    elseif NearDeathExperienceSetup.displayFunction == "floating" then
        iconFrame:SetPoint("CENTER", floatingIconContainer, "CENTER", 0, 0)
        floatingIconContainer:Show()
        if NearDeathExperienceSetup.iconTextAbove == true then
            iconFrame.score:ClearAllPoints()
            iconFrame.score:SetPoint("BOTTOM", iconFrame, "TOP", 0, 2)
        end
    end

    iconFrame.isMovable = NearDeathExperienceSetup.displayFunction == "floating"
    NDE.isFloating = NearDeathExperienceSetup.displayFunction == "floating" or 
        NearDeathExperienceSetup.displayFunction == "full" or 
        NearDeathExperienceSetup.displayFunction == "mini" or 
        NearDeathExperienceSetup.displayFunction == "nano" or 
        NearDeathExperienceSetup.displayFunction == "small"

end

local function updateTopList()

    if NearDeathExperienceScores == nil or
        NearDeathExperienceScores.entries == nil or
        #NearDeathExperienceScores.entries == 0 then
        topList:Hide()
        return
    end

    local topListIndexes = "\n"
    local topListHP = "HP\n"
    local topListLvllabel = "\n"
    local topListLvl = "Level\n"
    local topListTime = "Date/Time\n"

    local widths = {}

    topList.contentArea = topList.contentArea or CreateFrame("Frame", nil, topList)
    topList.contentArea:ClearAllPoints()
    topList.contentArea:SetPoint("TOPLEFT", topList, "TOPLEFT", 10, -10)
    topList.contentArea:SetPoint("BOTTOMRIGHT", topList, "BOTTOMRIGHT", -10, 10)

    topList.title = topList:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    topList.title:SetTextColor(1, .8, .2, 1)
    topList.title:SetPoint("TOPLEFT", topList.contentArea, "TOPLEFT", 0, 0)
    topList.title:SetJustifyH("LEFT")
    local fontPath, _, flags = topList.title:GetFont()
    topList.title:SetFont(fontPath, toplistFontSize + 2, flags)
    topList.title:SetText("Near Death Experience")
    table.insert(widths, topList.title:GetStringWidth())

    topList.subtitle = topList:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    topList.subtitle:SetTextColor(1, 1, 1, 1)
    topList.subtitle:SetPoint("TOPLEFT", topList.title, "BOTTOMLEFT", 0, -5)
    topList.subtitle:SetJustifyH("LEFT")
    local fontPath, _, flags = topList.subtitle:GetFont()
    topList.subtitle:SetFont(fontPath, toplistFontSize, flags)
    topList.subtitle:SetText("Top " ..  math.min(#NearDeathExperienceScores.entries, NearDeathExperienceScores.maxEntries) .. " Low Scores")
    table.insert(widths, topList.subtitle:GetStringWidth())

    for i, entry in ipairs(NearDeathExperienceScores.entries) do
        topListIndexes = topListIndexes .. i .. ". \n"
        topListHP = topListHP ..
            NDE.helper:formatP100(entry.health / entry.maxhp * 100) .. "% HP\n"

        if NearDeathExperienceSetup.displayTitleStatus < 2 then
            topListLvllabel = topListLvllabel .. "@ Lvl\n"
            topListLvl = topListLvl ..
                string.format("%.2f", NDE.helper:dotLevel(entry.level, entry.xp, entry.lxp)) .. "\n"
        end

        if NearDeathExperienceSetup.displayTitleStatus == 0 then
            if entry.timestamp ~= nil then
                topListTime = topListTime .. " " .. date("%Y-%m-%d %H:%M", entry.timestamp) .. "\n"
            else
                topListTime = topListTime .. " some time ago\n"
            end
        end
    end

    topList.tableArea = CreateFrame("Frame", nil, topList)
    topList.tableArea:ClearAllPoints()
    topList.tableArea:SetPoint("TOPLEFT", topList.subtitle, "BOTTOMLEFT", 0, -10)
    topList.tableArea:SetPoint("BOTTOMRIGHT", topList.contentArea, "BOTTOMRIGHT", 0, 0)

    local offset = 10

    topList.times:SetText(topListTime)
    local timeWidth = topList.times:GetStringWidth()
    topList.times:SetPoint("TOPRIGHT", topList.tableArea, "TOPRIGHT", -10, 0)
    offset = offset + timeWidth

    topList.Lvl:SetText(topListLvl)
    local lvlWidth = topList.Lvl:GetStringWidth()
    topList.Lvl:SetPoint("TOPRIGHT", topList.tableArea, "TOPRIGHT", -offset, 0)
    offset = offset + lvlWidth

    topList.Lvllabel:SetText(topListLvllabel)
    local lvllabelWidth = topList.Lvllabel:GetStringWidth()
    topList.Lvllabel:SetPoint("TOPRIGHT", topList.tableArea, "TOPRIGHT", -offset, 0)
    offset = offset + lvllabelWidth

    topList.HP:SetText(topListHP)
    local hpWidth = topList.HP:GetStringWidth()
    topList.HP:SetPoint("TOPRIGHT", topList.tableArea, "TOPRIGHT", -offset, 0)
    offset = offset + hpWidth

    topList.indexes:SetText(topListIndexes)
    local indexesWidth = topList.indexes:GetStringWidth()
    topList.indexes:SetPoint("TOPRIGHT", topList.tableArea, "TOPRIGHT", -offset, 0)
    offset = offset + indexesWidth

    local totalWidth = offset - 10 + 10 + 10
    table.insert(widths, totalWidth)
    local totalheight = topList.indexes:GetStringHeight() + 30 + topList.title:GetHeight() + topList.subtitle:GetHeight()

    topList:ClearAllPoints()
    topList:SetWidth(math.max(unpack(widths)) + 20)
    topList:SetHeight(totalheight)
end

topList:SetMovable(true)
topList:EnableMouse(true)

topList:SetScript("OnDragStart", function(self, button)
    self:StartMoving()
end)

topList:SetScript("OnDragStop", function(self, button)
    self:StopMovingOrSizing()
end)

NDE.topList = NDE.topList or {}

textDisplay:SetScript("OnMouseDown", function(self, button)
    if IsControlKeyDown() then
        self:StartMoving()

    elseif button == "RightButton" then
        local catID = NDE.options:updateOptionsScreen()
        Settings.OpenToCategory(catID)

    elseif button == "LeftButton" then
        if NDE.topList.frame:IsShown() then
            NDE.topList.frame:Hide()
            return
        end
        NDE.topList:updateTopList()
        NDE.topList.frame:Show()
    end
end)

textDisplay:SetScript("OnMouseUp", function(self, button)
    self:StopMovingOrSizing()
end)

textDisplay:SetScript("OnEnter", function(self, button)
    NDE.gametooltip:setGameTooltip(self, 5)
end)

textDisplay:SetScript("OnLeave", function(self, button)
    GameTooltip:Hide()
end)

textDisplay:SetScript("OnDragStop", function(self, button)
    self:StopMovingOrSizing()
end)

local events = {}

function events:UNIT_AURA()
    NDE:AnchorNDEIcon()
end

function events:UNIT_INVENTORY_CHANGED()
    NDE:AnchorNDEIcon()
end

function events:BAG_UPDATE_DELAYED()
    NDE:AnchorNDEIcon()
end

function events:PLAYER_EQUIPMENT_CHANGED()
    NDE:AnchorNDEIcon()
end

function events:PLAYER_REGEN_DISABLED()
    test = NDE.helper:sampleValues()
    testInCombat = true
end

function events:PLAYER_REGEN_ENABLED()
    testInCombat = false
    if not UnitIsDead("player") and (test.health < test.maxhp) then
        test.timestamp = time()
        NDE.helper:addEntry(NearDeathExperienceSessionScores, test)
        local place = NDE.helper:addEntry(NearDeathExperienceScores, test)
        if place == 1 then
            NDE.helper:formattedChatEntry(test, "new Lowscore")
            NDE:updateIcon((test.health / test.maxhp) * 100)
            NDE.animations.icon:onNewRecord(iconFrame)
            NDE:displayScore(test)
        end
        NDE.topList:updateTopList()
    end
end

function events:PLAYER_DEAD()
    testInCombat = false
    test = NDE.helper:sampleValues()
    test.timestamp = time()
    NDE.helper:addEntry(NearDeathExperienceSessionScores, test)
    NDE.helper:addEntry(NearDeathExperienceScores, test)

    NearDeathExperienceScores = { entries = {}, maxEntries = NearDeathExperienceScores.maxEntries or 10 }
end

function events:UNIT_HEALTH(...)
    local unit = ...
    if testInCombat == true and unit == "player" then
        local liveSample = NDE.helper:sampleValues()
        if test.health == nil or (liveSample.health / liveSample.maxhp) < (test.health / test.maxhp) then
            test = liveSample
        end
    end
end

function events:PLAYER_ENTERING_WORLD(...)
    local isInitialLogin, isReloadingUI = ...

    if isInitialLogin == true then
        NearDeathExperienceSessionScores = { entries = {}, maxEntries = 3 }
        print("|cffFF8888[NDE]|r |cff00ff00session scores|r reset.")

    elseif isReloadingUI == true then
        print("|cffFF8888[NDE]|r |cff00ff00UI reloaded|r.")
    end

    NearDeathExperienceSetup.displayFunction = NearDeathExperienceSetup.displayFunction or "buff"
    NearDeathExperienceSetup.textSize = NearDeathExperienceSetup.textSize or 18
    NearDeathExperienceSetup.textBgOpacity = NearDeathExperienceSetup.textBgOpacity or 0.5
    NearDeathExperienceSetup.iconTextAbove = NearDeathExperienceSetup.iconTextAbove or false

    NearDeathExperienceScores = NDE.helper:repairScoresTable(NearDeathExperienceScores)
    NearDeathExperienceSessionScores = NDE.helper:repairScoresTable(NearDeathExperienceSessionScores, 3)

    NDE:updateDisplayText()
    NDE:setTextBgOpacity()

    local lowscore = NDE.helper:getLowestEntry(NearDeathExperienceScores)
    if lowscore ~= nil then
        NDE.helper:formattedChatEntry(lowscore, "Lowscore")
        NDE:displayScore(lowscore)
        NDE:updateIcon(lowscore and lowscore.health and lowscore.maxhp and (lowscore.health / lowscore.maxhp * 100) or nil)
    else
        NDE:displayScore(nil)
        NDE:updateIcon(nil)
    end

    NDE.options:updateOptionsScreen()
    NDE:AnchorNDEIcon()
    NDE.topList:updateTopList()
end

local eventFrame = CreateFrame("Frame")

for k, _ in pairs(events) do
    eventFrame:RegisterEvent(k)
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if events[event] then
        events[event](self, ...)
    end
end)
