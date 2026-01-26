NDE = NDE or {}
NDE.topList = NDE.topList or {}
NearDeathExperienceScores = NearDeathExperienceScores or { entries = {} }
NearDeathExperienceSessionScores = NearDeathExperienceSessionScores or { entries = {} }

if math.sum == nil then
    function math.sum(...)
        local s = 0
        for i = 1, select("#", ...) do
            s = s + select(i, ...)
        end
        return s
    end
end

local padding = 8
local toplistFontSize = 12

function NDE.topList:createTopListFrame()
    if self.frame then return self.frame end

    local f = CreateFrame("Frame", "NDETopListFrame", UIParent, "BackdropTemplate")
    self.frame = f

    f:SetSize(200, 300)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 16,
        edgeSize = 12,
        insets   = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetMovable(true)
    f:EnableMouse(true)

    local contentWidths = {}
    local contentHeights = {}

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOPLEFT", f, "TOPLEFT", padding, -padding)
    f.title:SetPoint("RIGHT", f, "RIGHT", 0, -padding)
    f.title:SetText("Near Death Experience")
    f.title:SetJustifyH("LEFT")

    f.closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    f.closeButton:SetScript("OnClick", function()
        f:Hide()
    end)

    table.insert(contentWidths, f.title:GetStringWidth()+f.closeButton:GetWidth())
    table.insert(contentHeights, f.title:GetStringHeight())

    f.subtitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.subtitle:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -padding/2)
    f.subtitle:SetPoint("RIGHT", f, "RIGHT", -padding, 0) 
    f.subtitle:SetText("Top ".. #NearDeathExperienceScores.entries .." Lowscores")
    f.subtitle:SetJustifyH("LEFT")
    f.subtitle:SetTextColor(1, 1, 1, 1)

    if NearDeathExperienceScores == nil or #NearDeathExperienceScores.entries == 0 then
        f.subtitle:SetText("No score yet.")
    end

    table.insert(contentWidths, f.subtitle:GetStringWidth())
    table.insert(contentHeights, f.subtitle:GetStringHeight())

    f.table = CreateFrame("Frame", nil, f)
    f.table:SetPoint("TOPLEFT", f.subtitle, "BOTTOMLEFT", 0, -padding)
    f.table:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -padding, padding)

    f.table.indexes = f.table:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    f.table.indexes:SetTextColor(.7, .7, .7, 1)
    f.table.indexes:SetPoint("TOPLEFT", f.table, "TOPLEFT", 0, 0)
    f.table.indexes:SetJustifyH("RIGHT")
    local fontPath, _, flags = f.table.indexes:GetFont()
    f.table.indexes:SetFont(fontPath, toplistFontSize, flags)

    f.table.pct = f.table:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    f.table.pct:SetTextColor(.7, .7, .7, 1)
    f.table.pct:SetPoint("TOPLEFT", f.table.indexes, "TOPRIGHT", padding, 0)
    f.table.pct:SetJustifyH("RIGHT")
    f.table.pct:SetFont(fontPath, toplistFontSize, flags)

    f.table.HP = f.table:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    f.table.HP:SetTextColor(1, 1, .5, 1)
    f.table.HP:SetPoint("TOPLEFT", f.table.pct, "TOPRIGHT", padding, 0)
    f.table.HP:SetJustifyH("RIGHT")
    f.table.HP:SetFont(fontPath, toplistFontSize, flags)

    f.table.Lvl = f.table:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    f.table.Lvl:SetTextColor(1, 1, 1, 1)
    f.table.Lvl:SetPoint("TOPLEFT", f.table.HP, "TOPRIGHT", padding, 0)
    f.table.Lvl:SetJustifyH("RIGHT")
    f.table.Lvl:SetFont(fontPath, toplistFontSize, flags)

    f.table.times = f.table:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    f.table.times:SetTextColor(1, 1, .5, 1)
    f.table.times:SetPoint("TOPLEFT", f.table.Lvl, "TOPRIGHT", padding, 0)
    f.table.times:SetJustifyH("RIGHT")
    f.table.times:SetFont(fontPath, toplistFontSize, flags)

    table.insert(contentWidths, f.table:GetWidth())
    table.insert(contentHeights, f.table:GetHeight())

    local maxWidth = math.max(unpack(contentWidths))
    local totalHeight = math.sum(unpack(contentHeights))

    print("Calculated Top List Frame size: ", maxWidth, totalHeight)

    f:SetWidth( maxWidth + padding*2 )
    f:SetHeight( totalHeight + padding*#contentHeights )
    f:Hide()

    f:SetScript("OnMouseDown", function(self, button)
        f:StartMoving()
    end)

    f:SetScript("OnMouseUp", function(self, button)
        f:StopMovingOrSizing()
    end)

    return f
end

function NDE.topList:updateTopList()
    if not self.frame then 
        self.frame = self:createTopListFrame()
    end

    local f = self.frame
    local scores = NearDeathExperienceScores.entries

    if #scores == 0 then
        f.subtitle:SetText("No score yet.")
        f.table.indexes:SetText("")
        f.table.pct:SetText("")
        f.table.HP:SetText("")
        f.table.Lvl:SetText("")
        f.table.times:SetText("")

        f:SetWidth( math.max(f.title:GetStringWidth()+f.closeButton:GetWidth(), f.subtitle:GetStringWidth()) + padding * 2 )
        f:SetHeight( math.sum(
            f.title:GetStringHeight(),
            f.subtitle:GetStringHeight()
        ) + padding * 2.5 )

        return
    end

    f.subtitle:SetText("Top ".. #NearDeathExperienceScores.entries .." Lowscores")

    local indexesText = "\n"
    local pctText = "\n"
    local hpText = "|cffFFFFFFHP|r\n"
    local lvlText = "|cffFFFFFFLevel|r\n"
    local timesText = "|cffFFFFFFDate/Time|r\n"

    for i, score in ipairs(scores) do
        local scoreColor = NDE.colors.pct:CFF(score.health / score.maxhp)
        indexesText = indexesText .. string.format("%d.\n", i)
        pctText = pctText .. scoreColor .. NDE.helper:formatP100(score.health / score.maxhp * 100) .. " %|r\n"
        hpText = hpText .. string.format(scoreColor .. "%d|r / %d\n", score.health, score.maxhp)
        lvlText = lvlText .. string.format("%.2f\n", score.level + score.xp / score.lxp)
        local dateStr = date("%Y-%m-%d", score.timestamp)
        if dateStr == date("%Y-%m-%d", time()) then
            dateStr = "|cff999999Today|r"
        end
        if dateStr == date("%Y-%m-%d", time() - 24*60*60) then
            dateStr = "|cff999999Yesterday|r"
        end
        local time = date("%H:%M", score.timestamp)
        timesText = timesText .. dateStr .. " " .. time .. "\n"
    end

    f.table.indexes:SetText(indexesText)
    f.table.HP:SetText(hpText)
    f.table.pct:SetText(pctText)
    f.table.Lvl:SetText(lvlText)
    f.table.times:SetText(timesText)

    local height = math.sum(
        f.title:GetStringHeight(),
        f.subtitle:GetStringHeight(),
        f.table.indexes:GetStringHeight()
    ) + padding * 3.5

    f:SetHeight(height)
    f:SetWidth( math.max(
        f.title:GetStringWidth()+f.closeButton:GetWidth(),
        f.subtitle:GetStringWidth(),
        f.table.indexes:GetStringWidth() +
        f.table.pct:GetStringWidth() +
        f.table.HP:GetStringWidth() +
        f.table.Lvl:GetStringWidth() +
        f.table.times:GetStringWidth() +
        padding * 4
    ) + padding * 2 )
end

NDE.topList.frame = NDE.topList:createTopListFrame()
