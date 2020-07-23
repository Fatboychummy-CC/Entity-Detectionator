local bresen = require("BresenhamAPI") -- https://pastebin.com/Km4Z1W1D
local writer = require("writer")       -- https://pastebin.com/rWPVArBW
local canvas3d = peripheral.call("back", "canvas3d")
local c3 = peripheral.call("back", "canvas")
local sense = function() return peripheral.call("back", "sense") end
local pName = "fatmanchummy"
c3.clear()
canvas3d.clear()
local c = canvas3d.create()
local c2 = canvas3d.create()
local range = 16

-- add circles to show the range of detection.
-- default detection range is 16
bresen(range, 0, 0, function(x, y)
  local x = c2.addBox(x - 0.125, -0.125, y - 0.125, 0.25, 0.25, 0.25)
  x.setColor(150, 150, 150)
  x.setAlpha(25)
end)
bresen(range, 0, 0, function(x, y)
  local x = c2.addBox(x - 0.125, y - 0.125, -0.125, 0.25, 0.25, 0.25)
  x.setColor(150, 150, 150)
  x.setAlpha(25)
end)
bresen(range, 0, 0, function(x, y)
  local x = c2.addBox(-0.125, x - 0.125, y - 0.125, 0.25, 0.25, 0.25)
  x.setColor(150, 150, 150)
  x.setAlpha(25)
end)

local eInfo = {
  ["Witch"]               = {colors.blue,   0.5 },
  ["Enderman"]            = {colors.blue,   1   },
  ["Creeper"]             = {colors.lime,   0.5 },
  ["XPOrb"]               = {colors.lime,   0.2 },
  ["Zombie"]              = {colors.green,  0.5 },
  ["PigZombie"]           = {colors.pink,   0.5 },
  ["Skeleton"]            = {colors.lightGray,  0.5 },
  ["Ghast"]               = {colors.white,  2   },
  ["Item"]                = {colors.white,  0.2 },
  ["Indestructible Item"] = {colors.white,  0.2 },
  ["Spider"]              = {colors.black,  0.5 },
  ["Wither"]              = {colors.black,  2   },
  ["Bat"]                 = {colors.black,  0.25},
  ["Squid"]               = {colors.purple, 0.6 },
  ["Blaze"]               = {colors.yellow, 0.75},
  ["quark:foxhound"]      = {colors.orange, 0.5 },
  ["Guardian"]            = {colors.green,  1   },
  ["Boat"]                = {colors.yellow, 0.2 },
  ["Villager"]            = {colors.brown,  0.5 },
  ["CaveSpider"]          = {colors.black,  0.25},
  ["Battletower Golem"]   = {colors.gray,   2   },
  ["heatscarspider"]      = {colors.red,    2   },
  ["babyheatscarspider"]  = {colors.red,    0.5 }
}
local colorConvert = {
  [colors.white]     = {240, 240, 240},
  [colors.orange]    = {242, 178, 51 },
  [colors.magenta]   = {229, 127, 216},
  [colors.lightBlue] = {153, 178, 242},
  [colors.yellow]    = {222, 222, 108},
  [colors.lime]      = {127, 204, 25 },
  [colors.pink]      = {242, 178, 204},
  [colors.gray]      = {76 , 76 , 76 },
  [colors.lightGray] = {153, 153, 153},
  [colors.cyan]      = {76 , 153, 178},
  [colors.purple]    = {178, 102, 229},
  [colors.blue]      = {51 , 102, 204},
  [colors.brown]     = {127, 102, 76 },
  [colors.green]     = {87 , 166, 78 },
  [colors.red]       = {204, 76 , 76 },
  [colors.black]     = {17 , 17 , 17 }
}

local function drawInfo(scanned)
  c3.clear()
  writer(
    string.format("Entities detected: %d", #scanned - 1), -- remove self
    0,
    0,
    colors.white,
    colors.black
  )

  -- combine similar entries
  local tmp = {}
  for i, v in ipairs(scanned) do
    local insertionFlag = true
    for o = 1, #tmp do
      if tmp[o].name == v.name then
        insertionFlag = false
        tmp[o].count = tmp[o].count + 1
        break
      end
    end

    if insertionFlag then
      tmp[#tmp + 1] = {
        name = v.name,
        displayName = v.displayName,
        count = 1
      }
    end
  end
  scanned = tmp

  local written = 1
  local function writeEntity(entity, bg)
    local name = ""
    if entity.name == "Item" or entity.name == "Indestructible Item" then
      name = entity.name
    else
      name = entity.displayName
    end
    if string.len(name) > 30 then
      name = string.sub(name, 1, 27) .. "..."
    end
    if entity.count > 1 then
      name = string.format("%s (x%d)", name, entity.count)
    end
    writer(
      " ",
      0,
      9 * written,
      eInfo[entity.name] and eInfo[entity.name][1] or colors.white,
      eInfo[entity.name] and eInfo[entity.name][1] or colors.white
    )
    writer(
      name,
      6,
      9 * written,
      colors.white,
      bg
    )
    written = written + 1
  end

  for i = 1, #scanned do
    local entity = scanned[i]
    if entity.name ~= pName then
      if eInfo[entity.name] then
        writeEntity(entity, colors.black)
      end
    end
  end
  for i = 1, #scanned do
    local entity = scanned[i]
    if entity.name ~= pName then
      if not eInfo[entity.name] then
        writeEntity(entity, colors.black)
      end
    end
  end
end

local function recenterDetector()
  while true do
    c2.recenter()
    os.sleep()
  end
end

local function scanEntities()
  while true do
    c.clear()
    local entities = sense()
    c.recenter()
    for i = 1, #entities do
      local entity = entities[i]
      if entity.name ~= pName then
        local size = 0.5
        local offset = 0.25
        local color = {255, 255, 255}
        if eInfo[entity.name] then
          local tmp = eInfo[entity.name]
          color = colorConvert[tmp[1]]
          size = tmp[2]
          offset = size / 2
        end
        local tmp = c.addBox(entity.x - offset, entity.y - offset, entity.z - offset, size, size, size)
        tmp.setAlpha(100)
        tmp.setColor(table.unpack(color, 1, 3))
        tmp.setDepthTested(false)
      end
    end
    drawInfo(entities)
    os.sleep(1)
  end
end

parallel.waitForAny(recenterDetector, scanEntities)
