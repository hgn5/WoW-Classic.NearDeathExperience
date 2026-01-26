NDE = NDE or {}
NDE.buffs = NDE.buffs or {}

function NDE.buffs:countTempEnchants()
    local hasMainHandEnchant, _, _, _, hasOffHandEnchant, _, _, _, hasRangedEnchant = GetWeaponEnchantInfo()
    local num = 0
    if hasMainHandEnchant then num = num + 1 end
    if hasOffHandEnchant then num = num + 1 end
    if hasRangedEnchant then num = num + 1 end
    return num
end

function NDE.buffs:getLastVisibleBuff()
    local last

    local enchants = NDE.buffs:countTempEnchants()
    if enchants > 0 then
        last = _G["TempEnchant"..enchants]
    end

  for i = 1, 32 do
    local btn = _G["BuffButton"..i]
    if btn and btn:IsShown() then
      last = btn
    else
      break
    end
  end

  return last
end

function NDE.buffs:getLastVisibleDebuff()
  local last
  for i = 1, 32 do
    local btn = _G["DebuffButton"..i]
    if btn and btn:IsShown() then
      last = btn
    else
      break
    end
  end
  return last
end