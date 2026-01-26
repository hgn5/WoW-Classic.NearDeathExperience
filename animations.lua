NDE = NDE or {}
NDE.colors = NDE.colors or {}
NDE.animations = NDE.animations or {}
NDE.animations.icon = NDE.animations.icon or {}

function NDE.animations.icon:onNewRecord(frame)

    local function SetupProcAnim(frame)
        if frame.procAnim then return end

        local ag = frame:CreateAnimationGroup()
        frame.procAnim = ag
        ag:SetLooping("NONE")

        local grow = ag:CreateAnimation("Scale")
        grow:SetOrder(1)
        grow:SetDuration(0.10)
        grow:SetScale(1.25, 1.25)
        grow:SetSmoothing("OUT")

        local shrink = ag:CreateAnimation("Scale")
        shrink:SetOrder(2)
        shrink:SetDuration(0.12)
        shrink:SetScale(0.80, 0.80)
        shrink:SetSmoothing("IN")

        local a1 = ag:CreateAnimation("Alpha")
        a1:SetOrder(1)
        a1:SetDuration(0.10)
        a1:SetFromAlpha(0.6)
        a1:SetToAlpha(1.0)
        a1:SetSmoothing("OUT")

        local a2 = ag:CreateAnimation("Alpha")
        a2:SetOrder(2)
        a2:SetDuration(0.12)
        a2:SetFromAlpha(1.0)
        a2:SetToAlpha(1.0)
        a2:SetSmoothing("IN")

        ag:SetScript("OnStop", function()
            frame:SetScale(1)
            frame:SetAlpha(1)
        end)

    end

    SetupProcAnim(frame)
    if frame.procAnim:IsPlaying() then
        frame.procAnim:Stop()
    end
    frame.procAnim:Play()
end