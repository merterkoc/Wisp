local Wisp = require("system.wisp")
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
        speed = 0.4
    }

    function b:move_up() self.properties.y = self.properties.y - self.properties.speed end
    b:add_control{ action = "move_up", mode = "activate", event = "keypressed", key = "up", requires_attend = true }
    b:add_control{ action = "move_up", mode = "deactivate", event = "keyreleased", key = "up", requires_attend = true }

    function b:move_down() self.properties.y = self.properties.y + self.properties.speed end
    b:add_control{ action = "move_down", mode = "activate", event = "keypressed", key = "down", requires_attend = true }
    b:add_control{ action = "move_down", mode = "deactivate", event = "keyreleased", key = "down", requires_attend = true }

    function b:move_left() self.properties.x = self.properties.x - self.properties.speed end
    b:add_control{ action = "move_left", mode = "activate", event = "keypressed", key = "left", requires_attend = true }
    b:add_control{ action = "move_left", mode = "deactivate", event = "keyreleased", key = "left", requires_attend = true }

    function b:move_right() self.properties.x = self.properties.x + self.properties.speed end
    b:add_control{ action = "move_right", mode = "activate", event = "keypressed", key = "right", requires_attend = true }
    b:add_control{ action = "move_right", mode = "deactivate", event = "keyreleased", key = "right", requires_attend = true }

    b.autonomy = function(self)
        if self.attended then
            self.properties.color = {0, 0, 1}
        elseif self.properties.color[1] ~= 1 or self.properties.color[2] ~= 0 or self.properties.color[3] ~= 0 then
            self.properties.color = {1, 0, 0}
        end
    end
    b:activate("autonomy")
    
    -- breath
    b.properties.oxy = 13
    function b:inhale()
        self.properties.oxy = (self.properties.oxy or 0) + 0.01
    end

    function b:exhale()
        self.properties.oxy = (self.properties.oxy or 0) - 0.01
    end

    function b:breath() -- autonomy 
        if (self.properties.oxy or 0) >= 12 then
            self:activate("exhale")
            self.processes["inhale"] = nil
        elseif (self.properties.oxy or 0) <= 8 then
            self:activate("inhale")
            self.processes["exhale"] = nil
        end

    end
    b:activate("breath")
    
    function b:scale_radius(scale)
        local oxy = self.properties.oxy
        self.properties.r = self.properties.r + (oxy-10) /100
    end
    b:activate("scale_radius")
    
    b.appearance = function(self)
        love.graphics.setColor(self.properties.color)
        love.graphics.circle("fill", self.properties.x, self.properties.y, self.properties.r)
    end

    return b
end

return Ball
