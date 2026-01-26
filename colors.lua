NDE = NDE or {}
NDE.colors = NDE.colors or {}

NDE.colors.system = {
    title = {
        rgba = { r = 1, g = .8, b = .2, a = 1 },
        cff = "|cffFFCC33"
    },
    subtitle = {
        rgba = { r = 1, g = 1, b = 1, a = 1 },
        cff = "|cffFFFFFF"
    },
    identity = {
        rgba = { r = 1, g = 0.5, b = 0.5, a = 1 },
        cff = "|cffFF8888"
    },
    info = {
        rgba = { r = .2, g = 0.5, b = 1, a = 1 },
        cff = "|cff3399FF"
    },
    warning = {
        rgba = { r = 1, g = 0.65, b = 0, a = 1 },
        cff = "|cffFFAA33"
    },
    error = {
        rgba = { r = 1, g = .2, b = .2, a = 1 },
        cff = "|cffFF3333"
    }
}

NDE.colors.health = {
    good = {
        rgba = { r = .2, g = 1, b = .2, a = 1 },
        cff = "|cff33FF33"
    },
    moderate = { 
        rgba = { r = 1, g = 1, b = .2, a = 1 },
        cff = "|cffFFFF33"
    },
    low = { 
        rgba = { r = 1, g = .7, b = .2, a = 1 },
        cff = "|cffFFAA33"
    },
    critical = { 
        rgba = { r = 1, g = .2, b = .2, a = 1 },
        cff = "|cffFF3333"
    },
    unknown = { 
        rgba = { r = .8, g = .8, b = .8, a = 1 },
        cff = "|cffCCCCCC"
    }
}

local function p100_core(v100)
  if not v100 then return NDE.colors.health.unknown end
  if v100 <= 10 then return NDE.colors.health.critical end
  if v100 <= 25 then return NDE.colors.health.low end
  if v100 <= 50 then return NDE.colors.health.moderate end
  return NDE.colors.health.good
end

NDE.colors.p100 = {}

function NDE.colors.p100:RGBA(v100)
    local c = p100_core(v100).rgba
    return c.r, c.g, c.b, c.a
end

function NDE.colors.p100:CFF(v100)
    return p100_core(v100).cff
end

NDE.colors.pct = {}

function NDE.colors.pct:RGBA(v1)
    local c = p100_core(v1*100).rgba
    return c.r, c.g, c.b, c.a
end

function NDE.colors.pct:CFF(v1)
    return NDE.colors.p100:CFF(v1*100)
end
