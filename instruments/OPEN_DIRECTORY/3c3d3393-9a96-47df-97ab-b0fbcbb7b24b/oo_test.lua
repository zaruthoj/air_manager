Display = {}
function Display:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end
 
function Display:insert(before, after, other)
  self.before = before
  self.after = after
  self.other = other
end

function Display:step_next()
  self:exit()
  current = self.after
  self.after:start()
end

function Display:step_prev()
  self:exit()
  current = self.before
  self.before:start()
end

function Display:start()
  print("start "..self.text)
end

function Display:exit()
  print("exit "..self.text)
end

function Display:prog(side)
  if (self.other ~= nil) then
    self:exit()
    current = self.other
    self.other:start()
  end
end

function Display:prog_both()
  print "prog both"
end

flow_main = Display:new{text="flow"}
rem_main = Display:new{text="rem"}
used_main = Display:new{text="used"}

flow_alt = Display:new{text="hp"}
used_alt = Display:new{text="flight used"}

flow_main:insert(used_main, rem_main, flow_alt)
rem_main:insert(flow_main, used_main, nil)
used_main:insert(rem_main, flow_main, used_alt)

flow_alt:insert(used_main, rem_main, flow_main)
used_alt:insert(rem_main, flow_main, used_main)

current = flow_main

while true do
  command = io.read(1)
  if (command == "a") then
    current:prog(-1)
  elseif (command == "f") then
    current:prog(1)
  elseif (command == "s") then
    current:step_prev()
  elseif (command == "d") then
    current:step_next()
  elseif (command == "x") then
    current:prog_both()
  elseif (command == "q") then
    break
  end
end
