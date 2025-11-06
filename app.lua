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
        title = "Wisp Application",
        balls = {}
    }

    -- init window
    a.autonomy = function(self)
        if not self.properties.initialized then
            love.window.setMode(self.properties.width, self.properties.height)
            love.window.setTitle(self.properties.title)
            self.properties.initialized = true
        end

--[[
        -- update attended colors
        for _, ball in pairs(self.content) do
            if ball.attended then
                ball.properties.color = {0, 0, 1}
            else
                ball.properties.color = {1, 0, 0}
            end
        end
         ]]--
    end
    
    -- background
    a.appearance = function(self)
        love.graphics.clear(0.1, 0.1, 0.1)
    end

    -- controls
    a:add_control("keypressed", "space", "spawn_ball", false)
    a:add_control("keypressed", "l", "spawn_hole", false)
    a:add_control("keypressed", "a", "attend_random", false)
    a:add_control("keypressed", "b" , "attend_random_2" , false )

    --------------------------------------------------------
    -- FUNCTIONS
    --------------------------------------------------------

    function a:spawn_hole()
        local x = math.random(50, self.properties.width - 50)
        local y = math.random(50, self.properties.height - 50)
        local r = math.random(15, 35)
        local hole = Hole:new("hole_" .. tostring(os.clock()), self, x, y, r, {1, 0, 0})
        self:add_wisp(hole)
        table.insert(self.properties.balls, hole)
    end
    
    function a:spawn_ball()
        local x = math.random(50, self.properties.width - 50)
        local y = math.random(50, self.properties.height - 50)
        local r = math.random(15, 35)
        local ball = Ball:new("ball_" .. tostring(os.clock()), self, x, y, r, {1, 0, 0})
        self:add_wisp(ball)
        table.insert(self.properties.balls, ball)
    end

    function a:attend_random()
        if #self.properties.balls == 0 then return end
        local rand_index = math.random(1, #self.properties.balls)
        for i, b in ipairs(self.properties.balls) do
            b:attend(i == rand_index)
        end
    end
    
    function a:attend_random_2()
    local total = #self.properties.balls
    if total == 0 then return end

    -- reset all
    for _, b in ipairs(self.properties.balls) do
        b:attend(false)
    end

    -- choose up to two distinct random balls
    local first = math.random(1, total)
    local second = first
    if total > 1 then
        repeat
            second = math.random(1, total)
        until second ~= first
    end

    self.properties.balls[first]:attend(true)
    if total > 1 then
        self.properties.balls[second]:attend(true)
    end
end


    return a
end

return App
