NDE = NDE or {}
NDE.displayFunctions = NDE.displayFunctions or {}
NDE.helperFunctions = NDE.helperFunctions or {}

function NDE.displayFunctions:full(score)
    local scoreLine = ""
     scoreLine = scoreLine .. "|cffFF8888Near Death Experience|r "
     scoreLine = scoreLine .. string.format("%.1f", math.floor(score.health / score.maxhp * 1000 + .5) / 10) ..
                        "%"
    scoreLine = scoreLine .. " HP |cffFFFFFF@ Lvl " ..
                            string.format("%.2f", NDE.helperFunctions:dotLevel(score.level, score.xp, score.lxp)) .. "|r"
    return scoreLine
end

function NDE.displayFunctions:mini(score)
    local scoreLine = "|cffFF8888"
     scoreLine = scoreLine .. string.format("%.1f", math.floor(score.health / score.maxhp * 1000 + .5) / 10) ..
                        "%"
    scoreLine = scoreLine .. " HP|r |cffFFFFFF@ Lvl " ..
                            string.format("%.2f", NDE.helperFunctions:dotLevel(score.level, score.xp, score.lxp)) .. "|r"
    return scoreLine
end

function NDE.displayFunctions:nano(score)
    local scoreLine = "|cffFF8888"
        scoreLine = scoreLine .. string.format("%.1f", math.floor(score.health / score.maxhp * 1000 + .5) / 10) ..
                        "%|r"     
    return scoreLine
end

function NDE.displayFunctions:noScoreYet()
    local scoreLine = ""
        scoreLine = scoreLine .. "|cffFF8888Near Death Experience|r no score yet"
    return scoreLine
end
