--========================================================--
--  WISP CLASS (Base Entity Framework)
--  Provides hierarchical entity management, process flow,
--  control binding, and rendering/update recursion.
--========================================================--

local Wisp = {}
Wisp.__index = Wisp

------------------------------------------------------------
-- Constructor: Create new Wisp instance
------------------------------------------------------------
function Wisp:new(name, context)
    local w = setmetatable({}, self)
    math.randomseed(os.clock() * 1e9)
    w.id = tostring(math.random(1e9))        -- unique random id
    w.name = name or ""                      -- name of the wisp
    w.context = context or nil               -- parent wisp (if any)
    w.content = {}                           -- contained wisps
    w.properties = {}                        -- static data of the wisp
    w.state = "idle"                         -- current state tag
    w.processes = {}                         -- list of active method names
    w.autonomy = function(self) end          -- always-active logic
    w.appearance = function(self) end        -- visualization function
    w.attended = false                       -- true if currently attended (focused)
    w.controls = {}                          -- key-event to function bindings

    -- context validation hook
    if not w:check_context() then
        error("Wisp '" .. (w.name or "?") .. "' initialization failed: invalid context.")
    end

    return w
end

------------------------------------------------------------
-- Default context validation
-- Override in subclasses when specific context properties are required
------------------------------------------------------------
function Wisp:check_context()
    return true
end
--[[
Example:
function StressWisp:check_context()
    return self.context
       and self.context.properties
       and self.context.properties.stress_level
end
]]--

------------------------------------------------------------
-- Returns the metatable (class type)
------------------------------------------------------------
function Wisp:type()
    return getmetatable(self)
end

------------------------------------------------------------
-- Lists only instance-level methods (not class-defined)
------------------------------------------------------------
function Wisp:list_instance_methods()
    local methods = {}
    local class = getmetatable(self)
    for k, v in pairs(self) do
        if type(v) == "function" and type(class[k]) ~= "function" then
            table.insert(methods, k)
        end
    end
    return methods
end

------------------------------------------------------------
-- Adds a sub-wisp to this wisp
------------------------------------------------------------
function Wisp:add_wisp(entity)
    if not entity.name or entity.name == "" then
        error("Unnamed wisp.")
    end
    if self.content[entity.name] then
        error("Duplicate wisp: " .. entity.name)
    end
    entity.context = self
    self.content[entity.name] = entity
end

------------------------------------------------------------
-- Adds a control binding (for LÖVE input events)
-- Example:
-- self:add_control("keypressed", "w", "move_up", true)
-- The last argument (requires_attend) determines if the control
-- should only trigger when the wisp is attended.
------------------------------------------------------------
function Wisp:add_control(event, key, action, requires_attend)
    table.insert(self.controls, {
        event = event,
        key = key,
        action = action,
        requires_attend = requires_attend or false
    })
end

------------------------------------------------------------
-- Returns a sub-wisp by name
------------------------------------------------------------
function Wisp:get_wisp(name)
    return self.content[name]
end

------------------------------------------------------------
-- Update routine
-- Runs autonomy, active processes, and sub-wisp updates
------------------------------------------------------------
function Wisp:update()
    self.autonomy(self)  -- always-active logic
    for _, name in ipairs(self.processes) do  -- run listed methods
        if type(self[name]) == "function" then
            self[name](self)
        end
    end
    for _, w in pairs(self.content) do        -- update contained wisps
        if type(w) == "table" and w.update then
            w:update()
        end
    end
end

------------------------------------------------------------
-- Draw routine
-- Calls appearance() and recursively draws sub-wisps
------------------------------------------------------------
function Wisp:draw()
    self.appearance(self)
    for _, w in pairs(self.content) do
        if type(w) == "table" and w.draw then
            w:draw()
        end
    end
end

------------------------------------------------------------
-- Attend / Unattend toggle
-- Call with true/false to set explicitly
-- Call with no argument to toggle
------------------------------------------------------------
function Wisp:attend(state)
    if state == nil then
        self.attended = not self.attended
    else
        self.attended = state and true or false
    end
end

------------------------------------------------------------
--  INPUT HANDLING (to be placed in main.lua)
--  Recursively propagates key events to all wisps
------------------------------------------------------------
--[[
local function handle_input(wisp, event, key)
    -- run attendance logic if defined
    if type(wisp.attendance) == "function" then
        wisp:attendance(event, key)
    end

    -- process control bindings
    for _, c in ipairs(wisp.controls) do
        if c.event == event and c.key == key then
            if (not c.requires_attend) or wisp.attended then
                local func = wisp[c.action]
                if type(func) == "function" then func(wisp) end
            end
        end
    end

    -- recurse into child wisps
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
]]

--========================================================--
--  RETURN CLASS
--========================================================--
return Wisp
