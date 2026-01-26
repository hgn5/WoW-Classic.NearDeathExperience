NDE = NDE or {}
NDE.helper = NDE.helper or {}

function NDE.helper:asDecPercent(currentXP, nextLevelXP)
    local roundPercent = math.floor(currentXP / nextLevelXP * 100 + .5)
    if roundPercent > 99 then
        roundPercent = 99
    end
    return string.format("%02d", roundPercent)
end

function NDE.helper:dotLevel(level, xp, lxp)
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

function NDE.helper:dotLevelFromEntry(entry)
    if entry.level == nil or entry.level == 0 then
        return nil
    end
    if entry.xp == nil then
        return nil
    end
    if entry.lxp == nil or entry.lxp == 0 then
        return nil
    end
    return NDE.helper:dotLevel(entry.level, entry.xp, entry.lxp)
end

function NDE.helper:createEmptyEntry()
    return {
        level = nil,
        xp = nil,
        lxp = nil,
        health = nil,
        maxhp = nil,
        timestamp = nil,
    }
end

function NDE.helper:getHighestDotLevel(scores)
    local highestDotLevel = 0
    for _, entry in ipairs(scores.entries) do
        local dotLevel = NDE.helper:dotLevelFromEntry(entry)
        if dotLevel ~= nil and dotLevel > highestDotLevel then
            highestDotLevel = dotLevel
        end
    end
    return highestDotLevel
end

function NDE.helper:repairScoresTable(scores, maxEntries)
    if maxEntries == nil then
        maxEntries = 10
    end
    local scoreTemplate = NDE.helper:createEmptyEntry()

    if not scores then
        scores = {
            entries = {}, 
            maxEntries = maxEntries
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
            NDE.helper:addEntry(scores, tempEntry)
        end
    end

    local validRootKeys = {
        maxEntries = true,
        entries = true
    }
    for k, v in pairs(scores) do
        if not validRootKeys[k] then
            scores[k] = nil
        end
    end
    
    return NDE.helper:removeInvalidEntries(scores)
end

function NDE.helper:removeInvalidEntries(scores)
    local validEntries = {}
    local playerDotLevel = NDE.helper:dotLevel(UnitLevel("player"),  UnitXP("player"), UnitXPMax("player"))
    for _, entry in ipairs(scores.entries) do
        local entryDotlevel = NDE.helper:dotLevelFromEntry(entry)
        if entryDotlevel ~= nil and entryDotlevel <= playerDotLevel then
            table.insert(validEntries, entry)
        end
    end
    scores.entries = validEntries
    return scores
end

function NDE.helper:addEntry(scores, data)
    table.insert(scores.entries, {
        level = data.level,
        xp = data.xp,
        lxp = data.lxp,
        health = data.health,
        maxhp = data.maxhp,
        timestamp = data.timestamp or nil,
    })

    -- sort by lowest health percentage
    table.sort(scores.entries, function(a, b)
        return (a.health / a.maxhp) < (b.health / b.maxhp)
    end)

    scores = NDE.helper:removeInvalidEntries(scores)

    -- trim to maxEntries
    scores.maxEntries = scores.maxEntries or 10
    scores.entries = scores.entries or {}
    while #scores.entries > scores.maxEntries do
        table.remove(scores.entries)
    end

    for i, entry in ipairs(scores.entries) do
        if entry.timestamp == data.timestamp then
            return i
        end
    end
    return nil
end

function NDE.helper:timestampToDateString(timestamp)
    return date("%Y-%m-%d %H:%M", timestamp)
end

function NDE.helper:getLowestEntry(scores)

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
            local entryDotLevel = NDE.helper:dotLevelFromEntry(entry)
            local highestDotLevel = NDE.helper:dotLevelFromEntry(highestEntry)
            if entryDotLevel ~= nil and highestDotLevel ~= nil and entryDotLevel > highestDotLevel then
                highestEntry = entry
            end
        end

    end

    return highestEntry
end

function NDE.helper:sampleValues()
    local sampledData = {}

    sampledData.maxhp = UnitHealthMax("player")
    sampledData.health = UnitHealth("player")
    sampledData.level = UnitLevel("player")
    sampledData.xp = UnitXP("player")
    sampledData.lxp = UnitXPMax("player")

    return sampledData
end

function NDE.helper:printEntrie(entry)
    local entryLine = "|cffFF8888[NDE]|r |cffFFff00Entry:|r"
    for k, v in pairs(entry) do
        entryLine = entryLine .. "  " .. tostring(k) .. ": " .. tostring(v)
    end
    print( entryLine)
end

function NDE.helper:printEntries(scores)
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

function NDE.helper:formattedChatEntry(score, name)

    if name == nil then
        name = "Entry"
    end

    if score == nil then
        print("|cffFF8888[NDE]|r |cffFFff00" .. name .. ":|r no score data")
        return
    end

    local timeString = "some time ago"
    if score.timestamp ~= nil then
        timeString = date("%Y-%m-%d %H:%M", score.timestamp) .. ""
    end

    print("|cffFF8888[NDE]|r |cffFFff00" .. name .. ":|r " ..
        NDE.helper:formatP100(score.health / score.maxhp * 100) .. "%" ..
        " HP @ [" ..
        string.format("%.2f", NDE.helper:dotLevel(score.level, score.xp, score.lxp)) .. "]|r |cffcccccc@ " ..
        timeString .. "|r")
end

function NDE.helper:formatP100(v)
  if not v then v = 100 end
  if v >= 100 then
    return "nsy."
  end
  if v < 10 then
    return string.format("%.2f", v)
  end
  return string.format("%.1f", v)
end