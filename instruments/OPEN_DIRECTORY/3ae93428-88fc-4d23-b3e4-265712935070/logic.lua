--dbg = txt_add("None", "font:lcd.ttf; size:15; color:white; halign:left;", 0, 0, 100, 50)
NAV_PANEL_OFF = 1
NAV_PANEL_DIM = 0
NAV_PANEL_BRIGHT = 2

Instrument = {}

function Instrument:new (o)
  local empty = o == nil
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Instrument:sim_up() 
  self:phy_changed(hw_input_read(self.phy))
end

function Instrument:sim_down()
end

Toggle = Instrument:new()

function Toggle:phy_changed(state)
  r, w = self:translate(state)
  if not timer_running(self.timer) and r ~= self.sim_state then
    self.timer = timer_start(500, nil, self.timeout)
    fsx_variable_write(self.sim_var, "number", w)
  end
end

function Toggle:sim_update(state)
  self.sim_state = state
  switch = hw_input_read(self.phy)
  r, _ = self:translate(switch)
  if self.sim_state == r then
    if timer_running(self.timer) then
      timer_stop(self.timer)
    end
  else
    if not timer_running(self.timer) then
      self:phy_changed(switch)
    end
  end
end

function Toggle:translate(state)
  if state then return true, 1 end
  return false, 0
end

function Toggle:init(pin, sim_var)
  self.pin = pin
  self.sim_var = sim_var
  self.phy = hw_input_add(self.pin, function(state) self:phy_changed(state) end)
  self.timeout = function() self:phy_changed(hw_input_read(self.phy)) end
  self.timer = timer_start(500, nil, function() self:timeout() end)
  timer_stop(self.timer)
  fsx_variable_subscribe(self.sim_var, "Bool", function(state) self:sim_update(state) end)
end

function Toggle:new(pin, sim_var)
  local empty = pin == nil
  o = {}
  setmetatable(o, self)
  self.__index = self
  r, _ = o:translate(false)
  o.sim_state = r
  if not empty then
    o:init(pin, sim_var)
  end
  return o
end

EventToggle = Toggle:new()

function EventToggle:phy_changed(state)
  if not timer_running(self.timer) and state ~= self.sim_state then
    self.timer = timer_start(500, nil, self.timeout)
    fsx_event(self.event)
  end
end

function EventToggle:translate(state)
  if state then return true, true end
  return false, false
end

function EventToggle:new(pin, sim_var, event)
  local empty = pin == nil
  o = {}
  setmetatable(o, self)
  self.__index = self
  Toggle.init(o, pin, sim_var)
  o.event = event
  return o
end


SimMonitor = {}
function SimMonitor:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.instruments = {}
  o.sim_running = false
  o.last_watchdog_s = 0.0
  o.last_update_s = 0.0
  o.watchdog_timer = timer_start(1000, 5000, function() o:watchdog() end)
  fsx_variable_subscribe("L:InGameTime", "number", function(time) o:time_update(time) end)
  return o
end
 
function SimMonitor:add_instrument(instrument)
  table.insert(self.instruments, instrument)
end

function SimMonitor:watchdog()
  local currently_running = self.last_update_s > self.last_watchdog_s
  if self.sim_running ~= currently_running then
    self:notify(currently_running)
    self.sim_running = currently_running
  end
  self.last_watchdog_s = self.last_update_s
end

function SimMonitor:time_update(time)
  self.last_update_s = time
end

function SimMonitor:notify(is_up)
  for _, instrument in pairs(self.instruments) do
    if is_up then
      instrument:sim_up()
    else
      instrument:sim_down()
    end
  end
end

nav_controller = Toggle:new("ARDUINO_NANO_B_A0", "L:NavInstrLightSwitch")
function nav_controller:translate(state)
  if state then return 0, 0 end
  return 1, 1
end

master_controller = Toggle:new("ARDUINO_NANO_B_A1", "L:Battery1Switch")
alternator_controller = Toggle:new("ARDUINO_NANO_B_A2", "L:BreakerGeneratorField")
fuel_controller = EventToggle:new("ARDUINO_NANO_B_A3", "GENERAL ENG FUEL PUMP SWITCH:1", "TOGGLE_ELECT_FUEL_PUMP1")
landing_controller = Toggle:new("ARDUINO_NANO_B_A4", "L:LandingLightSwitch")
beacon_controller = Toggle:new("ARDUINO_NANO_B_A5", "L:BeaconLightSwitch")
pitot_controller = Toggle:new("ARDUINO_NANO_B_D3", "L:PitotHeatSwitch")
cabin_controller = Toggle:new("ARDUINO_NANO_B_D2", "L:CabinLightSwitch")

sim_monitor = SimMonitor:new()
sim_monitor:add_instrument(nav_controller)
sim_monitor:add_instrument(master_controller)
sim_monitor:add_instrument(alternator_controller)
sim_monitor:add_instrument(fuel_controller)
sim_monitor:add_instrument(landing_controller)
sim_monitor:add_instrument(beacon_controller)
sim_monitor:add_instrument(pitot_controller)
sim_monitor:add_instrument(cabin_controller)

