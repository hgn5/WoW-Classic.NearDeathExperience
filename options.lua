NDE = NDE or {}
NDE.display = NDE.display or {}
NDE.colors = NDE.colors or {}
NDE.options = NDE.options or {}

NearDeathExperienceSetup = NearDeathExperienceSetup or {}

local minTextFontSize = 12
local maxTextFontSize = 32

local systemColors = NDE.colors.system
local healthColors = NDE.colors.health

local displayFunctions = {
    ["Icon Style"] = {
        {id = "buff", 
        text = systemColors.title.cff .. "Buff Icon|r + ".. healthColors.good.cff .. "Percent|r"},
        {id = "debuff", 
        text = systemColors.title.cff .. "Debuff Icon|r + ".. healthColors.good.cff .. "Percent|r"},
        {id = "floating", 
        text = systemColors.title.cff .. "Floating Icon|r + ".. healthColors.good.cff .. "Percent|r"},
    },
    ["Text Style"] = {
        {id="full", 
        text = "Full '".. 
            systemColors.title.cff .. "Near Death Experience|r ".. 
            healthColors.good.cff .. "(Percent %)|r "..
            systemColors.identity.cff .. "xx / xxx HP|r "..
            systemColors.subtitle.cff .. "@ [Level]|r'"},
        {id="small", 
        text = "Small '".. 
            healthColors.good.cff .. "(Percent %)|r "..
            systemColors.identity.cff .. "xx / xxx HP|r "..
            systemColors.subtitle.cff .. "@ [Level]|r'"},
        {id="mini", 
        text = "Mini '".. 
            healthColors.good.cff .. "(Percent %)|r "..
            systemColors.identity.cff .. "xx / xxx HP|r'"},
        {id="nano", 
        text = "Nano '".. 
            healthColors.good.cff .. "(Percent %)"},
    },
}

local function bar(parentFrame, rightAnchorFrame, rightAnchorPoint, rightAnchorOffset, leftAnchorFrame, leftAnchorPoint, leftAnchorOffset)
    local b = parentFrame:CreateTexture(nil, "BACKGROUND")
    b:SetHeight(8)
    b:SetPoint("RIGHT", rightAnchorFrame, rightAnchorPoint, rightAnchorOffset, 0)
    b:SetPoint("LEFT", leftAnchorFrame, leftAnchorPoint, leftAnchorOffset, 0)
    b:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
    b:SetTexCoord(0.81, 0.94, 0.5, 1)
    return b
end

local function createSeparator(parent, title)
    local sep = CreateFrame("Frame", nil, parent or UIParent)
    sep:SetPoint("TOPLEFT", parent or UIParent, "BOTTOMLEFT", 0, 0)
    sep:SetPoint("TOPRIGHT", parent or UIParent, "BOTTOMRIGHT", -16, 0)

    sep.label = sep:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sep.label:SetPoint("CENTER", sep, "CENTER", 0, 0)
    sep.label:SetJustifyH("CENTER")
    sep.label:SetParent(parent or UIParent)
    sep.label:SetText(title or "")

    sep:SetHeight(sep.label:GetHeight() + 10)

    sep.left = bar(sep, sep.label, "LEFT", -5, sep, "LEFT", 3)
    sep.right = bar(sep, sep.label, "RIGHT", 5, sep, "RIGHT", -3)

    return sep
end

function NDE.options:updateOptionsScreen()
    local f = NDE.options
    if f.category then
        return f.category:GetID()
    end
    f.canvas = CreateFrame("Frame", "NDEOptionsFrame")
    f.canvas.name = "Near Death Experience"

    -- Register the options panel
    f.category = Settings.RegisterCanvasLayoutCategory(f.canvas, f.canvas.name)
    Settings.RegisterAddOnCategory(f.category)

    f.title = f.canvas:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    f.title:SetPoint("TOPLEFT", f.canvas, "TOPLEFT", 0, 0)
    f.title:SetText("Near Death Experience")

    f.subtitle = f.canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    f.subtitle:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -8)
    f.subtitle:SetPoint("LEFT", f.canvas, "LEFT", 0, 0)  
    f.subtitle:SetText("Configure Near Death Experience addon settings below.")

    -- create Radiobuttons for display functions
    f.displayFunctionButtons = {}

    f.displayeparator = createSeparator(f.canvas, "Select Display Style")
    f.displayeparator:SetPoint("TOPLEFT", f.subtitle, "BOTTOMLEFT", 0, -8)

    local currentOptionsBlock = 1
    local offset = -8
    local lastGroupingFrame = f.displayeparator
    for group, styles in pairs(displayFunctions) do

        local cgf = CreateFrame("Frame", nil, f.canvas, "BackdropTemplate")

        cgf:SetPoint("TOPLEFT", lastGroupingFrame, "BOTTOMLEFT", 0, -8)
        cgf:SetPoint("RIGHT", f.canvas, "RIGHT", -16, 0)
        cgf:SetSize(400, 20)
        cgf:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        cgf:SetBackdropColor(0, 0, 0, .5)

        cgf.header = cgf:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        cgf.header:SetPoint("TOPLEFT", cgf, "TOPLEFT", 12,  -12)
        cgf.header:SetText(group)
        cgf.header:SetFontObject("GameFontNormalLarge")
        cgf.header:SetJustifyH("LEFT")
        cgf.header:SetSpacing(4)
        cgf.header:SetTextColor(1, 1, 1, 1)

        local i = 0
        for _, option in ipairs(styles) do
            local button = CreateFrame("CheckButton", "NDEOptionsDisplayFunction"..i, f.canvas, "UIRadioButtonTemplate")
            button:SetPoint("TOPLEFT", cgf.header, "BOTTOMLEFT", 0, -i * 20 - 8 )
            button.text:SetText(option.text)
            button.text:SetJustifyH("LEFT")
            button:SetChecked(NearDeathExperienceSetup.displayFunction == option.id)

            local updateButtons = function (self)
                for _, otherButton in ipairs(f.displayFunctionButtons) do
                    if otherButton ~= self then
                        otherButton:SetChecked(false)
                    end
                end
                self:SetChecked(true)
                NDE.display:setDisplayFunction(option.id)
                local lowscore = NDE.helper:getLowestEntry(NearDeathExperienceScores)
                NDE:displayScore(lowscore)
                NDE:AnchorNDEIcon()
            end

            button:SetScript("OnClick", updateButtons )

            table.insert(f.displayFunctionButtons, button)
            i = i + 1
            offset = offset - button.text:GetHeight() * 2
        end

        cgf:SetHeight(24 + i * 20 + 20)
        
        if group == "Text Style" then

            cgf.slider = CreateFrame("Frame", nil, f.canvas, "BackdropTemplate")
            cgf.slider:SetPoint("TOPLEFT", cgf.header, "BOTTOMLEFT", 0, -i * 20 - 16)
            cgf.slider:SetPoint("RIGHT", cgf, "RIGHT", -16, 0)
            cgf.slider:SetHeight(60)

            cgf.slider.title = cgf.slider:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            cgf.slider.title:SetPoint("TOPLEFT", cgf.slider, "TOPLEFT", 0, 0)
            cgf.slider.title:SetText("Text Size")
            cgf.slider.title:SetJustifyH("LEFT")
            cgf.slider.title:SetSpacing(4)
            cgf.slider.title:SetTextColor(1, 1, 1, 1)
            
            cgf.slider.slider = CreateFrame("Slider", "NDEOptionsTextSizeSlider", cgf.slider, "OptionsSliderTemplate")
            cgf.slider.slider:SetPoint("TOPLEFT", cgf.slider.title, "BOTTOMLEFT", 8, -8)
            cgf.slider.slider:SetMinMaxValues(minTextFontSize, maxTextFontSize)
            cgf.slider.slider:SetValueStep(1)
            cgf.slider.slider:SetObeyStepOnDrag(true)
            cgf.slider.slider:SetValue(NearDeathExperienceSetup.textSize or 18)
            cgf.slider.slider:SetWidth(200)
            cgf.slider.slider.Low:SetText(tostring(minTextFontSize))
            cgf.slider.slider.High:SetText(tostring(maxTextFontSize))

            cgf.slider.slider:SetScript("OnValueChanged", function(self, value)
                NearDeathExperienceSetup.textSize = value
                cgf.slider.value:SetText(string.format("%.0f", value))
                NDE:updateDisplayText()
            end)

            cgf.slider.value = cgf.slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            cgf.slider.value:SetPoint("LEFT", cgf.slider.slider, "RIGHT", 8, 0)
            cgf.slider.value:SetText(string.format("%.0f", cgf.slider.slider:GetValue()))
            cgf.slider.value:SetJustifyH("CENTER")
            cgf.slider.value:SetSpacing(4)
            cgf.slider.value:SetTextColor(1, .8, .2, 1)
            cgf.slider.value:SetWidth(20)

            cgf.slider.reset = CreateFrame("Button", "NDEOptionsTextSizeResetButton", cgf.slider, "UIPanelButtonTemplate")
            cgf.slider.reset:SetPoint("LEFT", cgf.slider.value, "RIGHT", 8, 0)
            cgf.slider.reset:SetText("Set Default (18)")
            cgf.slider.reset:SetSize(120, 22)
            cgf.slider.reset:SetScript("OnClick", function(self)
                cgf.slider.slider:SetValue(18)
            end)

            cgf.textBg = CreateFrame("Frame", nil, f.canvas, "BackdropTemplate")
            cgf.textBg:SetPoint("TOPLEFT", cgf.slider, "BOTTOMLEFT", 0, -4)
            cgf.textBg:SetPoint("RIGHT", cgf, "RIGHT", -16, 0)
            cgf.textBg:SetHeight(60)

            cgf.textBg.title = cgf.textBg:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            cgf.textBg.title:SetPoint("TOPLEFT", cgf.textBg, "TOPLEFT", 0, 0)
            cgf.textBg.title:SetText("Background Visibility")
            cgf.textBg.title:SetJustifyH("LEFT")
            cgf.textBg.title:SetSpacing(4)
            cgf.textBg.title:SetTextColor(1, 1, 1, 1)

            cgf.textBg.slider = CreateFrame("Slider", "NDEOptionsTextBackgroundOpacitySlider", cgf.textBg, "OptionsSliderTemplate")
            cgf.textBg.slider:SetPoint("TOPLEFT", cgf.textBg.title, "BOTTOMLEFT", 8, -8)
            cgf.textBg.slider:SetMinMaxValues(0, 1)
            cgf.textBg.slider:SetValueStep(0.1)
            cgf.textBg.slider:SetObeyStepOnDrag(true)
            cgf.textBg.slider:SetValue(NearDeathExperienceSetup.textBgOpacity or 0.5)
            cgf.textBg.slider:SetWidth(200)
            cgf.textBg.slider.Low:SetText("hidden")
            cgf.textBg.slider.High:SetText("max")
            cgf.textBg.slider:SetScript("OnValueChanged", function(self, value)
                NearDeathExperienceSetup.textBgOpacity = value
                cgf.textBg.value:SetText(string.format("%.1f", value))
                NDE:setTextBgOpacity()
            end)

            cgf.textBg.value = cgf.textBg:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            cgf.textBg.value:SetPoint("LEFT", cgf.textBg.slider, "RIGHT", 8, 0)
            cgf.textBg.value:SetText(string.format("%.1f", cgf.textBg.slider:GetValue()))
            cgf.textBg.value:SetJustifyH("CENTER")
            cgf.textBg.value:SetSpacing(4)
            cgf.textBg.value:SetTextColor(1, .8, .2, 1)
            cgf.textBg.value:SetWidth(20)

            cgf.textBg.reset = CreateFrame("Button", "NDEOptionsTextBackgroundOpacityResetButton", cgf.textBg, "UIPanelButtonTemplate")
            cgf.textBg.reset:SetPoint("LEFT", cgf.textBg.value, "RIGHT", 8, 0)
            cgf.textBg.reset:SetText("Set Default (0.5)")
            cgf.textBg.reset:SetSize(120, 22)
            cgf.textBg.reset:SetScript("OnClick", function(self)
                cgf.textBg.slider:SetValue(0.5)
            end)

            cgf:SetHeight(cgf:GetHeight() + 120)
        end
        if group == "Icon Style" then
            cgf.textAbove = CreateFrame("CheckButton", "NDEOptionsTextAboveIconCheckbox", f.canvas, "UICheckButtonTemplate")
            cgf.textAbove:SetPoint("TOPLEFT", cgf.header, "BOTTOMLEFT", 16, -i * 20 - 4 )
            cgf.textAbove.text:SetText("Display ".. healthColors.good.cff .."Percent|r above floating Icon")
            cgf.textAbove.text:SetJustifyH("LEFT")
            cgf.textAbove:SetChecked(NearDeathExperienceSetup.iconTextAbove == true)
            cgf.textAbove:SetScript("OnClick", function(self)
                NearDeathExperienceSetup.iconTextAbove = self:GetChecked()
                NDE:AnchorNDEIcon()
            end)
            cgf:SetHeight(cgf:GetHeight() + 28)
        end

        lastGroupingFrame = cgf
        currentOptionsBlock = currentOptionsBlock + 1
    end

    return f.category:GetID()
end
