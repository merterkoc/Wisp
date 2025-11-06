-- main.lua

local Root = require("root")

function love.load()
    love.window.setMode(800, 600)
    love.window.setTitle("Wisp Architecture")

    root = Root:new()
end

function love.update(dt)
    root:update()
end

function love.draw()
    root:draw()
end

-- input handler aynı kalır
local function handle_input(wisp, event, key)
    for _, c in ipairs(wisp.controls) do
        if c.event == event and c.key == key then
            if (not c.requires_attend) or wisp.attended then
                local func = wisp[c.action]
                if type(func) == "function" then func(wisp) end
            end
        end
    end
    for _, sub in pairs(wisp.content) do
        handle_input(sub, event, key)
    end
end

function love.keypressed(key)
    handle_input(root, "keypressed", key)
end

function love.keyreleased(key)
    handle_input(root, "keyreleased", key)
end
