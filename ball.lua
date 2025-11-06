local Wisp = require("wisp")
local Ball = setmetatable({}, { __index = Wisp })
Ball.__index = Ball

function Ball:new(name, context, x, y, radius, color)
    local b = Wisp.new(self, name or "ball", context)
    local w = context and context.properties.width or 800
    local h = context and context.properties.height or 600
    b.properties = {
        x = x or math.random(50, w - 50),
        y = y or math.random(50, h - 50),
        r = radius or math.random(15, 35),
        color = color or {math.random(), math.random(), math.random()},
        speed = 5
    }

    function b:move_up()    self.properties.y = self.properties.y - self.properties.speed end
    b:add_control("move_up", "keypressed", "up", true)

    function b:move_down()  self.properties.y = self.properties.y + self.properties.speed end
    b:add_control("move_down", "keypressed", "down", true)

    function b:move_left()  self.properties.x = self.properties.x - self.properties.speed end
    b:add_control("move_left", "keypressed", "left", true)

    function b:move_right() self.properties.x = self.properties.x + self.properties.speed end
    b:add_control("move_right", "keypressed", "right", true)


    b.autonomy = function(self)
        if self.attended then
            self.properties.color = {0, 0, 1}
        elseif self.properties.color[1] ~= 1 or self.properties.color[2] ~= 0 or self.properties.color[3] ~= 0 then
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
