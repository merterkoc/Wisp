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

function love.keypressed(key)
    root:handle_input("keypressed", key)
end

function love.keyreleased(key)
    root:handle_input("keyreleased", key)
end
