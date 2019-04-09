local Grid = {}
local error = {r = 1, g = 0, b = 0}
Grid.__index = Grid

------------------------------------------------------------------------------------------------------------------
-- Use this to spawn scripting zones and iterate over them for objects or anything else you want.
-- All numbers unless otherwise specified.
-- Notes:
-- Each Grid script can only handle one Grid at a time.
-- Try not to use it onload() except for debugging purposes, scripting zones are hard to see.
--
-- Parameters:
--  Grid Width: How many columns
--  Grid Height: How many rows
--
--  y/x/z_offset: Offset from spawn l ocation
--
--  cell_width/height: How large the cell is
--  cell_padding: How much space in-between the cells
--
--  spawn_location: Where the grid spawns. (Table)
------------------------------------------------------------------------------------------------------------------
-- WORKING
function Grid:new()
  local grid = {}
  return setmetatable(grid, Grid)
end

function Grid:spawn(grid_width, grid_height, y_offset, x_offset, z_offset, cell_width, cell_height, cell_padding, spawn_location)
  local grid = {}
  local parameters = {grid_width, grid_height, y_offset, x_offset, z_offset, cell_width, cell_height, cell_padding}

  for i, parameter in pairs(parameters) do
    if not (type(parameter) == "number") then
      return nil, printToAll("Argument " .. i .. " (".. parameters[i].."): expected number, got " .. type(parameter), error)
    end
  end

  if type(spawn_location) == "table" then
    grid_global_pos = spawn_location
  else
    return nil, printToAll("Invalid spawn location, expected table, got ".. type(spawn_location), error)
  end

  for i = 1, grid_height do
    grid[i] = {}
  end

  local zone_params = {
    type = "ScriptingTrigger",
    position = grid_global_pos,
    scale = {x = 0, y = 2, z = 0},
    callback_function = function(obj) grid_add(obj) end
  }

  local baseX = grid_global_pos[1] + x_offset
  zone_params["scale"]["x"] = cell_width - cell_padding
  zone_params["scale"]["z"] = cell_height - cell_padding
  zone_params["position"]["y"] = y_offset
  zone_params["position"]["x"] = grid_global_pos[1] + x_offset
  zone_params["position"]["z"] = grid_global_pos[3] + z_offset
  local Xpos = 0
  local Ypos = 0

  for i, b in ipairs(grid) do
    Ypos = Ypos + 1
    Xpos = 0
    self[Ypos] = {}
    for i = 1, grid_width do

      zone_params["position"]["x"] = zone_params["position"]["x"] + cell_width

      Xpos = Xpos + 1
      local x, y = Xpos, Ypos -- doesn't work without this.
      zone_params.callback_function = function(obj)
        self[y][x] = obj
      end
      spawnObject(zone_params)
    end
    zone_params["position"]["x"] = baseX
    zone_params["position"]["z"] = zone_params["position"]["z"] + cell_height
  end
  return setmetatable(grid, Grid)
end

------------------------------------------------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------
-- Notes:
-- Iterates through all cells in a circle within a given radius.
-- Useful for AOE effects.
--
-- Parameters:
--  mode: (string)
--    line: inner edge of circle.
--    fill (default:) all within circle
--
-- x0/y0: (number) The starting (center) of the circle
--
-- Example:
-- for x, y, v in Grid:circle(parameters) do ...
-- - x = x position, y = y positon, v = actual reference
------------------------------------------------------------------------------------------------------------------

function Grid:circle(mode, x0, y0, radius, includeNil)
  mode = mode or "fill"
  local f = 1 - radius
  local dx = 1
  local dy = -2 * radius
  local x = 0
  local y = radius
  local points = {}

  local function mark(y, x1, x2)
    if not points[y] then points[y] = {} end
    if mode == "line" then
      points[y][x1] = true
      points[y][x2] = true
    else
      for x = x1, x2 do
        points[y][x] = true
      end
    end
  end

  mark(y0 + radius, x0, x0)
  mark(y0 - radius, x0, x0)
  mark(y0, x0 - radius, x0 + radius)
  while x < y do
    if f >= 0 then
      y = y - 1;
      dy = dy + 2;
      f = f + dy;
    end
    x = x + 1;
    dx = dx + 2;
    f = f + dx;
    mark(y0 + y, x0 - x, x0 + x)
    mark(y0 - y, x0 - x, x0 + x)
    mark(y0 + x, x0 - y, x0 + y)
    mark(y0 - x, x0 - y, x0 + y)
  end

  local row
  y, row = next(points)
  x = nil
  return function()
    while true do
      x = next(row, x)
      if not x then
        y, row = next(points, y)
        if not row then return nil end
        x = next(row)
      end
      if self[x] == nil then self[x] = {} end
      if self[x][y] then
        return x, y, self[x][y]
      end
    end
  end
end

------------------------------------------------------------------------------------------------------------------
-- Notes:
-- Iterates through all cells in a rectangle within a given size.
--
-- Parameters:
--  mode: (string)
--    line: inner edge of circle.
--    fill (default:) all within circle
--
-- startX, startY: Where the rectangle starts. Left to right, top to bottom order. Defaults to 0,0
------------------------------------------------------------------------------------------------------------------
function Grid:rectangle(mode, startX, startY, width, height, includeNil)
  local x, y = startX, startY
  local rx, ry, rv
  return function()
    while y < startY + height do
      while x < startX + width do
        if self[x] == nil then self[x] = {} end
        rx, ry, rv = x, y, self[x][y]
        if mode == "fill" or y == startY or y == startY + height - 1 then
          x = x + 1
        else
          x = x + width - 1
        end
        if rv ~= nil or includeNil then
          return rx, ry, rv
        end
      end
      x = startX
      y = y + 1
    end
    return nil
  end
end

function Grid:line(mode, startX, startY, endX, endY, includeNil)
    local dx = math.abs(endX - startX)
    local dy = math.abs(endY - startY)
    local x = startX
    local y = startY
    local incrX = endX > startX and 1 or -1
    local incrY = endY > startY and 1 or -1
    local err = dx - dy
    local err2 = err*2
    local i = 1+dx+dy
    local rx,ry,rv
    local checkX = false
    return function()
        while i>0 do
          if self[x] == nil then self[x] = {} end
            rx,ry,rv = x,y,self[x][y]
            err2 = err*2
            while true do
                checkX = not checkX
                if checkX == true or mode == "rigid" then
                    if err2 > -dy then
                        err = err - dy
                        x = x + incrX
                        i = i-1
                        if mode ~= "rigid" then break end
                    end
                end
                if checkX == false or mode == "rigid" then
                    if err2 < dx then
                        err = err + dx
                        y = y + incrY
                        i = i-1
                        if mode ~= "rigid" then break end
                    end
                end
                if mode == "rigid" then break end
            end
            if rx == endX and ry == endY then i = 0 end
            if rv ~= nil or includeNil then return rx,ry,rv end
        end
        return nil
    end
end

-- WORKING
-- for x, y, v in Grid:iterate() do ... end
function Grid:iterate()
  local x, row = next(self)
  if x == nil then return function() end end
  local y, val
  return function()
    repeat
      y, val = next(row, y)
      if y == nil then x, row = next(self, x) end
    until (val and x and y) or (not val and not x and not y)
    return x, y, val
  end
end

function Grid:clean()
  for key, row in pairs(self) do
    if not next(row) then self[key] = nil end
  end
end

-- Get the scripting zone of a cell
function Grid:get(x, y)
  return self[x] and self[x][y]
end

----------------------------------
-- DEBUGGING                    --
----------------------------------
function onChat(message, player)
  if player.host == true then
    local spawn = self.getPosition()
    -- spawns debug grid
    if message == "Grid_Debug_Init" then -- Initalize grid
      special_grid = Grid:new()
      special_grid:spawn(6, 3, 2.3, 0.1, 0.7, 2.6, 1.5, 0.5, spawn)
    end

    -- tests grid functionality by printing values
    if message == "Grid_Debug_Test" and special_grid ~= nil then
      zone = special_grid:get(1, 6)
      print("Coordinate 1,6 : ", zone)
      local objects = zone.getObjects()
      print("Object 1 at 1,6: ", objects[1])

      for x, y, v in special_grid:iterate() do print("Grid: ", x, ",", y, " ", v) end
      print("-----------")
      for x, y, v in special_grid:rectangle("fill", 1, 1, 2, 2) do print("Rectangle: ", x, ",", y, " ", v)end
      print("-----------")
      for x, y, v in special_grid:circle("fill", 2, 2, 1) do print("Circle: ", x, ",", y, " ", v) end
      print("-----------")
      for x, y, v in special_grid:line("rigid", 1, 1, 3, 6) do print("Line: ", x, ",", y, " ", v) end

      special_grid:clean()
    end

    if message == "Grid_Debug_Spawn" and special_grid ~= nil then
      -- for x, y, v in special_grid:rectangle("fill", 1, 1, 2, 3) do
      --   spawnObject({
      --     type = "Die_4",
      --     position = v.getPosition(),
      --     rotation = {x = 0, y = 90, z = 0},
      --     scale = {x = 1, y = 1, z = 1},
      --     sound = false,
      --   snap_to_grid = false})
      -- end
      -- for x, y, v in special_grid:circle("fill", 2, 5, 1) do
      --   spawnObject({
      --     type = "Die_6",
      --     position = v.getPosition(),
      --     rotation = {x = 0, y = 90, z = 0},
      --     scale = {x = 1, y = 1, z = 1},
      --     sound = false,
      --   snap_to_grid = false})
      -- end
        for x, y, v in special_grid:line("rigid", 1, 1, 3, 6) do
        spawnObject({
          type = "Die_8",
          position = v.getPosition(),
          rotation = {x = 0, y = 90, z = 0},
          scale = {x = 1, y = 1, z = 1},
          sound = false,
        snap_to_grid = false})
      end
    end

  end
end
