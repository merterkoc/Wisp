--========================================================--
--  HOLE WISP
--  Static circular target entity.
--========================================================--

local Wisp = require("wisp")
local Hole = setmetatable({}, { __index = Wisp })
Hole.__index = Hole

------------------------------------------------------------
-- Constructor
------------------------------------------------------------
function Hole:new(name, context, x, y, radius, color)
    local h = Wisp.new(self, name or "hole", context)
    h.properties = {
        x = x or 400,
        y = y or 300,
        r = radius or 30,
        color = color or {0, 0, 0}, -- default black
    }

    h.autonomy = function(self)
        -- holes are static; no autonomy
    end

    h.appearance = function(self)
        love.graphics.setColor(self.properties.color)
        love.graphics.circle("line", self.properties.x, self.properties.y, self.properties.r)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", self.properties.x, self.properties.y, self.properties.r - 2)
    end

    return h
end

return Hole
