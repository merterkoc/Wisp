--========================================================--
--  APP WISP
--  Dynamically loads all entity modules except excluded ones.
--========================================================--

local Wisp = require("wisp")

-- auto-require all .lua files except excluded
local exclude = { main = true, conf = true, wisp = true, app = true, root = true }
for _, file in ipairs(love.filesystem.getDirectoryItems("")) do
    if file:match("%.lua$") then
        local name = file:match("^(.-)%.lua$")
        if not exclude[name] then
            _G[name:gsub("^%l", string.upper)] = require(name)
        end
    end
end

-- define App class
local App = setmetatable({}, { __index = Wisp })
App.__index = App

function App:new(name, context)
    local a = Wisp.new(self, name or "app", context)

    a.properties = {
        width = 800,
        height = 600,
        title = "Wisp Application"
    }

    -- init window once
    a.autonomy = function(self)
        if not self.properties.initialized then
            love.window.setMode(self.properties.width, self.properties.height)
            love.window.setTitle(self.properties.title)
            self.properties.initialized = true
        end
    end

    -- background
    a.appearance = function(self)
        love.graphics.clear(0.1, 0.1, 0.1)
    end

    -- controls
    a:add_control("keypressed", "space", "spawn_ball", false)
    a:add_control("keypressed", "l", "spawn_hole", false)
    a:add_control("keypressed", "a", "attend_random", false)
    a:add_control("keypressed", "b", "attend_random_2", false)

    --------------------------------------------------------
    -- FUNCTIONS
    --------------------------------------------------------

    a.spawn_hole = function(self)
        self:add_wisp(Hole:new("hole_" .. tostring(os.clock()), self))
    end

    a.spawn_ball = function(self)
        self:add_wisp(Ball:new("ball_" .. tostring(os.clock()), self))
    end

    -- randomly attend 1 wisp of type Ball
    function a:attend_random()
        local balls = {}
        for _, w in pairs(self.content) do
            if w.type and w:type() == Ball then table.insert(balls, w) end
        end
        if #balls == 0 then return end
        local rand_index = math.random(1, #balls)
        for i, b in ipairs(balls) do
            b:attend(i == rand_index)
        end
    end

    -- randomly attend up to 2 wisps of type Ball
    function a:attend_random_2()
        local balls = {}
        for _, w in pairs(self.content) do
            if w.type and w:type() == Ball then table.insert(balls, w) end
        end
        local total = #balls
        if total == 0 then return end

        for _, b in ipairs(balls) do b:attend(false) end

        local first = math.random(1, total)
        local second = first
        if total > 1 then
            repeat second = math.random(1, total) until second ~= first
        end
        balls[first]:attend(true)
        if total > 1 then balls[second]:attend(true) end
    end

    return a
end

return App
