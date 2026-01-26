NDE = NDE or {}
NDE.display = NDE.display or {}
NDE.helper = NDE.helper or {}
NDE.colors = NDE.colors or {}

local systemColors = NDE.colors.system
local healthColors = NDE.colors.health

NDE.display.textStyles = {}

function NDE.display.textStyles:noScoreYet()
    return systemColors.identity.cff .. "Near Death Experience|r " .. healthColors.unknown.cff .. "no score yet|r"
end

NDE.display.textStyles["full"] = function(score)
    if not score then
        return NDE.display.textStyles:noScoreYet()
    end
    local scoreValue = (score.health or 0) / (score.maxhp or 1) * 100
    local scoreLine = systemColors.title.cff .. "Near Death Experience|r "
    scoreLine = scoreLine .. NDE.colors.p100:CFF(scoreValue) .. "(" ..NDE:formatP100(scoreValue) .. " %)|r " 
    scoreLine = scoreLine .. systemColors.identity.cff .. score.health .." / " .. score.maxhp .." HP|r "
    scoreLine = scoreLine .. systemColors.subtitle.cff .. "@ [" .. string.format("%.2f", NDE.helper:dotLevel(score.level, score.xp, score.lxp)) .. "]|r"
    return scoreLine
end

NDE.display.textStyles["small"] = function(score)
    if not score then
        return NDE.display.textStyles:noScoreYet()
    end
    local scoreValue = (score.health or 0) / (score.maxhp or 1) * 100
    local scoreLine = NDE.colors.p100:CFF(scoreValue) .. "(" ..NDE:formatP100(scoreValue) .. " %)|r "
     scoreLine = scoreLine .. systemColors.identity.cff .. score.health .." / " .. score.maxhp .." HP|r "
     scoreLine = scoreLine .. systemColors.subtitle.cff .. "@ [" .. string.format("%.2f", NDE.helper:dotLevel(score.level, score.xp, score.lxp)) .. "]|r"
    return scoreLine
end

NDE.display.textStyles["mini"] = function(score)
    if not score then
        return NDE.display.textStyles:noScoreYet()
    end
    local scoreValue = score.health / score.maxhp * 100
    local scoreLine = NDE.colors.p100:CFF(scoreValue) .. "(" ..NDE:formatP100(scoreValue) .. " %)|r "
        scoreLine = scoreLine .. systemColors.identity.cff .. score.health .." / " .. score.maxhp .." HP|r"     
    return scoreLine
end

NDE.display.textStyles["nano"] = function(score)
    if not score then
        return NDE.display.textStyles:noScoreYet()
    end
    local scoreValue = score.health / score.maxhp * 100
    local scoreLine = NDE.colors.p100:CFF(scoreValue) .. NDE:formatP100(scoreValue) .. " %|r"
    return scoreLine
end

function NDE.display:setDisplayFunction(name)
    NearDeathExperienceSetup.displayFunction = name or "buff"
end

function NDE.display:getDisplayFunctionName()
    return NearDeathExperienceSetup.displayFunction or "buff"
end

function NDE.display:isTextStyle()
    local displayFunctionName = NDE.display:getDisplayFunctionName()
    for styleName, _ in pairs(NDE.display.textStyles) do
        if displayFunctionName == styleName then
            return true
        end
    end
    return false
end

function NDE.display:isIconStyle()
    return not NDE.display:isTextStyle()
end 
