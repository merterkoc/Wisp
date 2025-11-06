--========================================================--
--  ROOT WISP
--  Top-level container of the entire Wisp hierarchy.
--  Holds and manages the App wisp as its primary child.
--========================================================--

local Wisp = require("wisp")
local App  = require("app")

------------------------------------------------------------
-- Class definition
------------------------------------------------------------
local Root = setmetatable({}, { __index = Wisp })
Root.__index = Root

------------------------------------------------------------
-- Constructor
------------------------------------------------------------
function Root:new()
    local r = Wisp.new(self, "root", nil)

    -- root itself has no visual logic
    r.appearance = function() end

    -- create and attach the App wisp
    local app = App:new("app", r)
    r:add_wisp(app)

    return r
end

return Root
