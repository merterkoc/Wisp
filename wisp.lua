--========================================================--
--  WISP CLASS
--  Base entity framework for hierarchical, autonomous units
--========================================================--

local Wisp = {}
Wisp.__index = Wisp

------------------------------------------------------------
-- Constructor
------------------------------------------------------------
function Wisp:new(name, context)
    local w = setmetatable({}, self)
    math.randomseed(os.clock() * 1e9)
    w.id = tostring(math.random(1e9))
    w.name = name or ""
    w.context = context
    w.content = {}
    w.properties = {}
    w.state = "idle"
    w.processes = {}
    w.autonomy = function() end
    w.appearance = function() end
    w.attended = false
    w.controls = {}
    if not w:check_context() then
        error("Invalid context for wisp '" .. (w.name or "?") .. "'")
    end
    return w
end

------------------------------------------------------------
-- Context validation (override in subclasses if needed)
------------------------------------------------------------
function Wisp:check_context()
    return true
end

------------------------------------------------------------
-- Get class type
------------------------------------------------------------
function Wisp:type()
    return getmetatable(self)
end

------------------------------------------------------------
-- List instance-only methods
------------------------------------------------------------
function Wisp:list_instance_methods()
    local methods, class = {}, getmetatable(self)
    for k, v in pairs(self) do
        if type(v) == "function" and type(class[k]) ~= "function" then
            methods[#methods + 1] = k
        end
    end
    return methods
end

------------------------------------------------------------
-- Add / Get sub-wisps
------------------------------------------------------------
function Wisp:add_wisp(entity)
    if not entity.name or entity.name == "" then error("Unnamed wisp.") end
    if self.content[entity.name] then error("Duplicate wisp: " .. entity.name) end
    entity.context = self
    self.content[entity.name] = entity
end

function Wisp:get_wisp(name)
    return self.content[name]
end

------------------------------------------------------------
-- Controls
------------------------------------------------------------
function Wisp:add_control(event, key, action, requires_attend)
    self.controls[#self.controls + 1] = {
        event = event,
        key = key,
        action = action,
        requires_attend = requires_attend or false
    }
end

------------------------------------------------------------
-- Update & Draw
------------------------------------------------------------
function Wisp:update()
    self:autonomy()
    for _, name in ipairs(self.processes) do
        if type(self[name]) == "function" then self[name](self) end
    end
    for _, w in pairs(self.content) do
        if w.update then w:update() end
    end
end

function Wisp:draw()
    self:appearance()
    for _, w in pairs(self.content) do
        if w.draw then w:draw() end
    end
end

------------------------------------------------------------
-- Attendance
------------------------------------------------------------
function Wisp:attend(state)
    self.attended = (state == nil) and not self.attended or not not state
end

------------------------------------------------------------
-- Recursive input handling
------------------------------------------------------------
function Wisp:handle_input(event, key)
    for _, c in ipairs(self.controls) do
        if c.event == event and c.key == key
           and ((not c.requires_attend) or self.attended) then
            local func = self[c.action]
            if type(func) == "function" then func(self) end
        end
    end
    for _, sub in pairs(self.content) do
        if sub.handle_input then sub:handle_input(event, key) end
    end
end

return Wisp
