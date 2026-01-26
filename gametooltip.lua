NDE = NDE or {}
NDE.gametooltip = NDE.gametooltip or {}
NDE.helper = NDE.helper or {}
NDE.colors = NDE.colors or {}

local function showInteractions(tt)
    tt:AddLine(" ")
    if NDE.isFloating == true then
        tt:AddDoubleLine("CTRL+Drag:", "Move", .75,.75,.75, 1,0.8,0.2)
    end
    tt:AddDoubleLine("Left-Click:", "Top Scores", .75,.75,.75, 1,0.8,0.2)
    tt:AddDoubleLine("Right-Click:", "Options", .75,.75,.75, 1,0.8,0.2)
    tt:Show()
end

local function score2best(score)
    return {pct=(score.health/score.maxhp)*100, lvl = score.level+ score.xp/score.lxp, hp = score.health, date = score.timestamp}
end

function NDE.gametooltip:setGameTooltip(self, offset)
    local tt = GameTooltip

    tt:SetOwner(self, "ANCHOR_NONE")
    tt:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -offset or 0)
    tt:ClearLines()
    tt:AddLine("Near Death Experience", 1, .8, .2)

    local lowscore = NDE.helper:getLowestEntry(NearDeathExperienceScores)
    if lowscore == nil or lowscore.level == nil then
        tt:AddLine("No score yet.", 1, 1, 1)
        showInteractions(tt)
        return
    end

    local today = date("%Y-%m-%d", time())
    local yesterday = date("%Y-%m-%d", time() - 24*60*60)

    local best = score2best(lowscore)
    local r,g,b,a = NDE.colors.p100:RGBA(best.pct)
    local cff = NDE.colors.p100:CFF(best.pct)

    tt:AddDoubleLine("Lowscore", string.format("%s%%", NDE.helper:formatP100(best.pct  or 100)), 1,1,1, r, g, b)
    tt:AddDoubleLine(" ", string.format(cff.."%s|r / %s", best.hp or 0, lowscore.maxhp or 0).." HP", 1,1,1, 1,1,0)
    tt:AddDoubleLine("Level", string.format("%.2f", best.lvl or 0), 1,1,1, 1,1,0)
    local dateString = date("%Y-%m-%d", best.date) or "some time ago"
    if dateString == today then
        dateString = "|cff999999Today|r"
    end
    if dateString == yesterday then
        dateString = "|cff999999Yesterday|r"
    end
    tt:AddDoubleLine("Date", dateString, 1,1,1, 1,1,0)
    tt:AddDoubleLine("Time ", date("%H:%M", best.date) or "--", 1,1,1, 1,1,0)
    tt:AddLine(" ")

    local sessionlowscore = NDE.helper:getLowestEntry(NearDeathExperienceSessionScores)
    if sessionlowscore == nil or sessionlowscore.level == nil then
        tt:AddLine("No session score yet.", 1, 1, 1)
    else
        local best = score2best(sessionlowscore)
        local r,g,b,a = NDE.colors.p100:RGBA(best.pct)
        local cff = NDE.colors.p100:CFF(best.pct)
        tt:AddDoubleLine("Session Low", string.format("%s%%", NDE.helper:formatP100(best.pct  or 100)), 1,1,1, r, g, b)
        tt:AddDoubleLine(" ", string.format(cff.."%s|r / %s", best.hp or 0, sessionlowscore.maxhp or 0).." HP", 1,1,1, 1,1,0)
        tt:AddDoubleLine("Level", string.format("%.2f", best.lvl or 0), 1,1,1, 1,1,0)
        local dateString = date("%Y-%m-%d", best.date) or "some time ago"
        if dateString == today then
            dateString = "|cff999999Today|r"
        end
        if dateString == yesterday then
            dateString = "|cff999999Yesterday|r"
        end
        tt:AddDoubleLine("Date", dateString, 1,1,1, 1,1,0)
        tt:AddDoubleLine("Time ", date("%H:%M", best.date) or "--", 1,1,1, 1,1,0)
    end

    showInteractions(tt)
end
