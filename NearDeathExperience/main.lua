local events = {}
local lowscore = {
    level = nil,
    xp = nil,
    lxp = nil,
    health = nil,
    maxhp = nil
}
local test = {
    level = nil,
    xp = nil,
    lxp = nil,
    health = nil,
    maxhp = nil
}
local testInCombat = nil
local displayTitleStatus = 0

if not NearDeathExperienceScores then
    NearDeathExperienceScores = {
        level = nil,
        xp = nil,
        lxp = nil,
        health = nil,
        maxhp = nil
    }
end

local frame = CreateFrame("Frame", "NearDeathExperience_Lowscore", UIParent)
local highscore = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
local testscore = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")

frame:SetFrameStrata("DIALOG")
frame:SetWidth(400)
frame:SetHeight(40)
frame:SetPoint("CENTER", 0, 100)
frame:SetMovable(true)

highscore:SetTextColor(1, 1, .5, 1)
highscore:SetPoint("CENTER", frame, 0, 10)
highscore:SetJustifyH("CENTER")
local fontPath, _, flags = highscore:GetFont()
highscore:SetFont(fontPath, 18, flags)

testscore:SetTextColor(1, 1, 1, 1)
testscore:SetPoint("CENTER", frame, 0, -10)
testscore:SetJustifyH("CENTER")
local fontPath, _, flags = testscore:GetFont()
testscore:SetFont(fontPath, 16, flags)

function asDecPercent(currentXP, nextLevelXP)
    local roundPercent = math.floor(currentXP / nextLevelXP * 100 + .5)
    if roundPercent > 99 then
        roundPercent = 99
    end
    return string.format("%02d", roundPercent)
end

function dotLevel(level, xp, lxp)
    if level == nil then
        return nil
    end
    if xp == nil then
        return nil
    end
    if lxp == nil then
        return nil
    end
    return level + xp / lxp
end

function displayScore()
    if testInCombat == true and test.level ~= nil then
        testscore:SetText(string.format("%.1f", math.floor(test.health / test.maxhp * 1000 + .5) / 10) .. "%")
    elseif testInCombat == false then
        testscore:SetText("")
    end
    if (lowscore.level ~= nil) then
        local scoreLine = ""
        if displayTitleStatus == 0 then
            scoreLine = scoreLine .. "|cffFF8888Near Death Experience|r "
        end
        scoreLine = scoreLine .. string.format("%.1f", math.floor(lowscore.health / lowscore.maxhp * 1000 + .5) / 10) ..
                        "%"
        if displayTitleStatus < 2 then
            scoreLine = scoreLine .. " HP |cffFFFFFF@ Lvl " ..
                            string.format("%.2f", dotLevel(lowscore.level, lowscore.xp, lowscore.lxp)) .. "|r"
        end
        highscore:SetText(scoreLine)
    else
        highscore:SetText("|cffff0000Near Death Experience|r ")
    end
end

function sampleValues()
    test.maxhp = UnitHealthMax("player")
    test.health = UnitHealth("player")
    test.level = UnitLevel("player")
    test.xp = UnitXP("player")
    test.lxp = UnitXPMax("player")
end

function events:PLAYER_REGEN_DISABLED()
    sampleValues()
    testInCombat = true
end

function events:PLAYER_REGEN_ENABLED()
    testInCombat = false
    if not UnitIsDead("player") and
        (lowscore.health == nil or ((test.health / test.maxhp) < (lowscore.health / lowscore.maxhp))) then
        lowscore.health = test.health
        lowscore.maxhp = test.maxhp
        lowscore.level = test.level
        lowscore.xp = test.xp
        lowscore.lxp = test.lxp
        NearDeathExperienceScores.health = lowscore.health
        NearDeathExperienceScores.maxhp = lowscore.maxhp
        NearDeathExperienceScores.level = lowscore.level
        NearDeathExperienceScores.xp = lowscore.xp
        NearDeathExperienceScores.lxp = lowscore.lxp
    end
    displayScore()
end

function events:UNIT_HEALTH(...)
    local unit = ...
    if testInCombat == true and unit == "player" then
        if test.health == nil or (UnitHealth("player") / UnitHealthMax("player")) < (test.health / test.maxhp) then
            sampleValues()
        end
        displayScore()
    end
end

function events:PLAYER_ENTERING_WORLD(...)
    displayScore()
end

function events:ADDON_LOADED(...)
    local addon = ...
    if addon == "NearDeathExperience" then
        local nde_dotlevel = dotLevel(NearDeathExperienceScores.level, NearDeathExperienceScores.xp,
            NearDeathExperienceScores.lxp)
        if nde_dotlevel ~= nil then
            local csv_dotlevel = dotLevel(UnitLevel("player"), UnitXP("player"), UnitXPMax("player"))
            if nde_dotlevel > csv_dotlevel then
                NearDeathExperienceScores = {
                    level = nil,
                    xp = nil,
                    lxp = nil,
                    health = nil,
                    maxhp = nil
                }
            end
        end
        lowscore.health = NearDeathExperienceScores.health
        lowscore.maxhp = NearDeathExperienceScores.maxhp
        lowscore.level = NearDeathExperienceScores.level
        lowscore.xp = NearDeathExperienceScores.xp
        lowscore.lxp = NearDeathExperienceScores.lxp
        displayScore()
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
            displayTitleStatus = (displayTitleStatus + 1) % 3
            displayScore()
        end
    end
end)

frame:SetScript("OnDragStop", function(self, button)
    self:StopMovingOrSizing()
end)

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end)

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end
