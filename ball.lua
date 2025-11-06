--========================================================--
--  BALL WISP
--  Simple visual entity drawn on screen.
--========================================================--

local Wisp = require("wisp")
local Ball = setmetatable({}, { __index = Wisp })
Ball.__index = Ball

------------------------------------------------------------
-- Constructor
------------------------------------------------------------
function Ball:new(name, context, x, y, radius, color)
    local b = Wisp.new(self, name or "ball", context)
    b.properties = {
        x = x or 200,
        y = y or 200,
        r = radius or 20,
        color = color or {1, 0, 0},
        speed = 5
    }

    -- movement controls (require attendance)
    b:add_control("keypressed", "up", "move_up", true)
    b:add_control("keypressed", "down", "move_down", true)
    b:add_control("keypressed", "left", "move_left", true)
    b:add_control("keypressed", "right", "move_right", true)

    --------------------------------------------------------
    -- METHODS
    --------------------------------------------------------
    function b:move_up()
        self.properties.y = self.properties.y - self.properties.speed
    end

    function b:move_down()
        self.properties.y = self.properties.y + self.properties.speed
    end

    function b:move_left()
        self.properties.x = self.properties.x - self.properties.speed
    end

    function b:move_right()
        self.properties.x = self.properties.x + self.properties.speed
    end

    --------------------------------------------------------
    -- AUTONOMY & APPEARANCE
    --------------------------------------------------------
    b.autonomy = function(self)
        -- color change based on attendance
        if self.attended then
            self.properties.color = {0, 0, 1}
        else
            self.properties.color = {1, 0, 0}
        end
    end

    b.appearance = function(self)
        love.graphics.setColor(self.properties.color)
        love.graphics.circle("fill", self.properties.x, self.properties.y, self.properties.r)
    end

    return b
end

return Ball
