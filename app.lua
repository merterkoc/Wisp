--========================================================--
--  APP WISP
--  Dynamically loads all entity modules except excluded ones.
--========================================================--

local Wisp = require("wisp")

------------------------------------------------------------
--  Auto-require all entity modules except excluded ones
------------------------------------------------------------
local exclude = { main = true, conf = true, wisp = true, app = true, root = true }
for _, file in ipairs(love.filesystem.getDirectoryItems("")) do
    if file:match("%.lua$") then
        local name = file:match("^(.-)%.lua$")
        if not exclude[name] then
            _G[name:gsub("^%l", string.upper)] = require(name)
        end
    end
end

------------------------------------------------------------
--  Define App class
------------------------------------------------------------
local App = setmetatable({}, { __index = Wisp })
App.__index = App

------------------------------------------------------------
--  Constructor
------------------------------------------------------------
function App:new(name, context)
    local a = Wisp.new(self, name or "app", context)

    a.properties = {
        width  = 800,
        height = 600,
        title  = "Wisp Application"
    }

    --------------------------------------------------------
    --  Autonomy: Initialize window once
    --------------------------------------------------------
    a.autonomy = function(self)
        if not self.properties.initialized then
            love.window.setMode(self.properties.width, self.properties.height)
            love.window.setTitle(self.properties.title)
            self.properties.initialized = true
        end
    end

    --------------------------------------------------------
    --  Appearance: Background color
    --------------------------------------------------------
    a.appearance = function()
        love.graphics.clear(0.1, 0.1, 0.1)
    end

    --------------------------------------------------------
    --  Controls
    --------------------------------------------------------
    a:add_control("spawn_ball",    "keypressed", "space", false)
    a:add_control("spawn_hole",    "keypressed", "l",     false)
    a:add_control("attend_random", "keypressed", "a",     false)
    a:add_control("attend_random_2","keypressed","b",     false)

    --------------------------------------------------------
    --  METHODS
    --------------------------------------------------------
    function a:spawn_hole()
        self:add_wisp(Hole:new("hole_" .. tostring(os.clock()), self))
    end

    function a:spawn_ball()
        self:add_wisp(Ball:new("ball_" .. tostring(os.clock()), self))
    end

    --  Picks N random wisps of a given class type
    function a:pick_random(wisp_type, n)
        local list = {}
        local class = _G[wisp_type]
        if not class then return {} end

        for _, w in pairs(self.content) do
            if w:type() == class then table.insert(list, w) end
        end
        if #list == 0 then return {} end

        local selected, picked = {}, {}
        n = math.min(n, #list)

        while #selected < n do
            local idx = math.random(1, #list)
            if not picked[idx] then
                picked[idx] = true
                table.insert(selected, list[idx])
            end
        end

        return selected
    end


    function a:attend_random()
        for _, w in pairs(self.content) do w:attend(false) end
        for _, b in ipairs(self:pick_random("Ball", 1)) do b:attend(true) end
    end

    function a:attend_random_2()
        for _, w in pairs(self.content) do w:attend(false) end
        for _, b in ipairs(self:pick_random("Ball", 2)) do b:attend(true) end
    end

    return a
end

return App
