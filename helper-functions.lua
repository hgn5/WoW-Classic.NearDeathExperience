NDE = NDE or {}
NDE.helperFunctions = NDE.helperFunctions or {}

function NDE.helperFunctions:asDecPercent(currentXP, nextLevelXP)
    local roundPercent = math.floor(currentXP / nextLevelXP * 100 + .5)
    if roundPercent > 99 then
        roundPercent = 99
    end
    return string.format("%02d", roundPercent)
end

function NDE.helperFunctions:dotLevel(level, xp, lxp)
    if level == nil or level == 0 then
        return 0
    end
    if xp == nil then
        return 0
    end
    if lxp == nil or lxp == 0 then
        return 0
    end
    return level + xp / lxp
end

function NDE.helperFunctions:dotLevelFromEntry(entry)
    return NDE.helperFunctions:dotLevel(entry.level, entry.xp, entry.lxp)
end

function NDE.helperFunctions:createEmptyEntry()
    return {
        level = nil,
        xp = nil,
        lxp = nil,
        health = nil,
        maxhp = nil,
        timestamp = nil,
    }
end

function NDE.helperFunctions:getHighestDotLevel(scores)
    local highestDotLevel = 0
    for _, entry in ipairs(scores.entries) do
        local dotLevel = NDE.helperFunctions:dotLevelFromEntry(entry)
        if dotLevel ~= nil and dotLevel > highestDotLevel then
            highestDotLevel = dotLevel
        end
    end
    return highestDotLevel
end

function NDE.helperFunctions:repairScoresTable(scores)
    local scoreTemplate = NDE.helperFunctions:createEmptyEntry()

    if not scores then
        scores = {
            entries = {}, 
            maxEntries = 10
        }
        table.insert(scores.entries, scoreTemplate)
    end
    
    if not scores.entries then
        local tempEntry = scores
        scores = {
            entries = {}, 
            maxEntries = 10
        }
        if tempEntry.level ~= nil then
            NDE.helperFunctions:addEntry(scores, tempEntry)
        end
    end

    local validRootKeys = {
        maxEntries = true,
        entries = true,
        lastCombat = true,
    }
    for k, v in pairs(scores) do
        if not validRootKeys[k] then
            scores[k] = nil
        end
    end
    
    return NDE.helperFunctions:removeInvalidEntries(scores)
end

function NDE.helperFunctions:removeInvalidEntries(scores)
    local validEntries = {}
    for _, entry in ipairs(scores.entries) do
        if entry.level ~= nil and entry.health ~= nil and entry.maxhp ~= nil then
            table.insert(validEntries, entry)
        end
    end
    scores.entries = validEntries
    return scores
end

function NDE.helperFunctions:addEntry(scores, data)
    table.insert(scores.entries, {
        level = data.level,
        xp = data.xp,
        lxp = data.lxp,
        health = data.health,
        maxhp = data.maxhp,
        timestamp = time(),
    })

    -- sort by lowest health percentage
    table.sort(scores.entries, function(a, b)
        return (a.health / a.maxhp) < (b.health / b.maxhp)
    end)

    scores = NDE.helperFunctions:removeInvalidEntries(scores)

    -- trim to maxEntries
    while #scores.entries > scores.maxEntries do
        table.remove(scores.entries)
    end

    return scores
end

function NDE.helperFunctions:timestampToDateString(timestamp)
    return date("%Y-%m-%d %H:%M", timestamp)
end

function NDE.helperFunctions:getLowestEntry(scores)

    if scores.entries == nil or #scores.entries == 0 then
        return nil
    end

    local highestEntry = scores.entries[1]
    for _, entry in ipairs(scores.entries) do
        local entryHPPercent = entry.health / entry.maxhp
        local highestHPPercent = highestEntry.health / highestEntry.maxhp

        -- highscore: the lowest hp percent
        if entryHPPercent < highestHPPercent then
            highestEntry = entry

        -- tie breaker: higher dot level wins
        elseif entryHPPercent == highestHPPercent then
            local entryDotLevel = NDE.helperFunctions:dotLevelFromEntry(entry)
            local highestDotLevel = NDE.helperFunctions:dotLevelFromEntry(highestEntry)
            if entryDotLevel ~= nil and highestDotLevel ~= nil and entryDotLevel > highestDotLevel then
                highestEntry = entry
            end
        end

    end

    return highestEntry
end

function NDE.helperFunctions:sampleValues()
    local sampledData = {}

    sampledData.maxhp = UnitHealthMax("player")
    sampledData.health = UnitHealth("player")
    sampledData.level = UnitLevel("player")
    sampledData.xp = UnitXP("player")
    sampledData.lxp = UnitXPMax("player")

    return sampledData
end

function NDE.helperFunctions:printEntrie(entry)
    local entryLine = "|cffFF8888[NDE]|r |cffFFff00Entry:|r"
    for k, v in pairs(entry) do
        entryLine = entryLine .. "  " .. tostring(k) .. ": " .. tostring(v)
    end
    print( entryLine)
end

function NDE.helperFunctions:printEntries(scores)
    local typeOfScores = type(scores)

    if typeOfScores ~= "table" then
        print( " |cffFF8888[NDE]|r |cffFF0000Error: Scores is not a table|r")
        return
    end

    if scores.entries == nil then
        print( " |cffFF8888[NDE]|r |cffFF0000Error: Scores.entries is nil|r")
        return
    end

    if #scores.entries == 0 then
        print( "|cffFF8888[NDE]|r |cffFF0000No saved entries found.|r")
    end
end