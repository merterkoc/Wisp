local Wisp = require("wisp")
local Hole = setmetatable({}, { __index = Wisp })
Hole.__index = Hole

function Hole:new(name, context, x, y, radius, color)
    local h = Wisp.new(self, name or "hole", context)
    local w = context and context.properties.width or 800
    local hgt = context and context.properties.height or 600
    h.properties = {
        x = x or math.random(50, w - 50),
        y = y or math.random(50, hgt - 50),
        r = radius or math.random(15, 35),
        color = color or {0, 0, 0}
    }

    h.autonomy = function() end

    h.appearance = function(self)
        love.graphics.setColor(self.properties.color)
        love.graphics.circle("fill", self.properties.x, self.properties.y, self.properties.r)
    end

    return h
end

return Hole
