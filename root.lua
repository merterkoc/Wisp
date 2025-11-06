--========================================================--
--  ROOT WISP
--  Central container for all wisps.
--========================================================--

local Wisp = require("wisp")
local Root = setmetatable({}, { __index = Wisp })
Root.__index = Root
local App = require("app")

function Root:new()
    local r = Wisp.new(self, "root", nil)

    r.appearance = function(self)
        -- nothing; App handles visuals
    end

    -- create and add the App wisp
    local app = App:new("app", r)
    r:add_wisp(app)

    return r
end

return Root
