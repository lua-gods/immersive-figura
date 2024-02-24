local portals = {} -- dimension, chunk x, chunk z
local loadedChunks = {}
local chunkSize = 16
local screens = require('screens')

local function box(p, l)
   p = p:copy():floor()
   for _ = 1, 64 do
      particles.end_rod:pos(
         p + vec(math.random(), math.random(), math.random())
      ):velocity(0, 0, 0):gravity(0):size(0.5):lifetime(l or 1000):spawn()
   end
end

local portalToSave = nil
local previousBlock, currentBlock = world.newBlock('minecraft:air'), world.newBlock('minecraft:air')

local function axisToOffset(a)
   return a == 'x' and vec(1, 0, 0) or vec(0, 0, 1)
end

local function findPortal(pos)
   local block = world.getBlockState(pos)
   local rotOffset = axisToOffset(block.properties.axis)
   -- find portal
   local size = vec(1, 1)
   -- x
   local a, b = 0, 0
   for i = 1, 32 do
      if world.getBlockState(pos - rotOffset * i).id ~= 'minecraft:nether_portal' then break end
      a = i
   end
   for i = 1, 32 do
      if world.getBlockState(pos + rotOffset * i).id ~= 'minecraft:nether_portal' then break end
      b = i
   end
   pos = pos - rotOffset * a
   size.x = a + b + 1
   -- y
   a, b = 0, 0
   for i = 1, 32 do
      if world.getBlockState(pos - vec(0, i, 0)).id ~= 'minecraft:nether_portal' then break end
      a = i
   end
   for i = 1, 32 do
      if world.getBlockState(pos + vec(0, i, 0)).id ~= 'minecraft:nether_portal' then break end
      b = i
   end
   pos.y = pos.y - a
   size.y = a + b + 1
   -- -- debug bug
   -- for x = 0, size.x - 1 do
   --    for y = 0, size.y - 1 do
   --       box(pos + rotOffset * x + vec(0, y, 0), 2000)
   --    end
   -- end
   return pos, size, block.properties.axis
end

local function getBlocksAround(pos, size, axis)
   pos = (pos + size.x * axisToOffset(axis) * 0.5 + size._y_ * 0.5):floor()
   local blocks = {}
   local s = 8
   for x = pos.x - s, pos.x + s do
      blocks[x] = {}
      for y = pos.y - s, pos.y + s do
         blocks[x][y] = {}
         for z = pos.z - s, pos.z + s do
            blocks[x][y][z] = world.getBlockState(x, y, z).id
         end
      end
   end
   return blocks
end

local function getScreenPosRot(pos, size, axis, backwards)
   if axis == 'x' then
      if backwards then
         return pos + size._y_ + vec(0, 0, 1), vec(0, 180, 0)
      else
         return pos + size.xy_, vec(0, 0, 0)
      end
   else
      if backwards then
         return pos + size._yx + vec(1, 0, 0), vec(0, -90, 0)
      else
         return pos + size._y_, vec(0, 90, 0)
      end
   end
end

local function loadPortal(chunk, portal, id)
   -- unload old screens
   for _, v in ipairs(chunk.portals[id] or {}) do
      v:remove()
   end
   -- create new screens
   local portalList = {pos = portal.pos, time = 20}
   chunk.portals[id] = portalList
   local size = portal.size
   for i = 1, 2 do
      local pos1, rot1 = getScreenPosRot(portal.pos, size, portal.axis, i == 2)
      local pos2, rot2 = getScreenPosRot(portal.targetPos, size, portal.targetAxis, i == 2)
      portalList[i] = screens.newScreen(
         size, pos1, rot1,
         pos2, rot2,
         false, portal.blocks, 0
      )
   end
end

local function addPortal(dimension, portal)
   local pos = portal.pos
   local x = math.floor(pos.x / chunkSize)
   local z = math.floor(pos.z / chunkSize)
   local id = tostring(pos)
   if not portals[dimension] then portals[dimension] = {} end
   if not portals[dimension][x] then portals[dimension][x] = {} end
   if not portals[dimension][x][z] then portals[dimension][x][z] = {} end
   portals[dimension][x][z][id] = portal
   local chunkId = x..'_'..z
   if loadedChunks[chunkId] then
      loadPortal(loadedChunks[chunkId], portal, id)
   end
end

function events.tick()
   -- basic variables
   local playerPos = player:getPos():floor()
   previousBlock = currentBlock
   currentBlock = world.getBlockState(playerPos)
   local dimension = world.getDimension()
   -- unload chunks
   for i, v in pairs(loadedChunks) do
      v.time = v.time - 1
      if v.time < 0 or v.dimension ~= dimension then
         for _, screenList in pairs(v.portals) do
            for _, screen in ipairs(screenList) do
               screen:remove()
            end
         end
         loadedChunks[i] = nil
      end
   end
   -- load chunks
   local portalList = portals[dimension] or {}
   local chunkPos = (playerPos.xz / chunkSize):floor()
   for x = chunkPos.x - 1, chunkPos.x + 1 do
      for z = chunkPos.y - 1, chunkPos.y + 1 do
         local id = x..'_'..z
         local chunk = loadedChunks[id]
         if not chunk then
            chunk = {portals = {}, dimension = dimension}
            loadedChunks[id] = chunk
            for portalId, portal in pairs(portalList[x] and portalList[x][z] or {}) do
               loadPortal(loadedChunks[id], portal, portalId)
            end
         end
         for portalId, portal in pairs(chunk.portals) do
            local shouldBeLoaded = not world.isChunkLoaded(portal.pos) or world.getBlockState(portal.pos).id == 'minecraft:nether_portal'
            if not portal.time then print(portal) end
            portal.time = shouldBeLoaded and 40 or portal.time - 1
            if portal.time < 0 then
               for _, v in ipairs(chunk.portals[portalId]) do
                  v:remove()
               end
               chunk.portals[portalId] = nil
            end
         end
         chunk.time = 20
      end
   end
   -- cache portals
   if portalToSave then
      if portalToSave.dimension ~= dimension then
         portalToSave.time = portalToSave.time - 1
         if portalToSave.saveDelay and portalToSave.saveDelay < 0 then
            local pos, size, axis = findPortal(portalToSave.portalPos)
            local blocks = getBlocksAround(pos, size, offset)
            addPortal(
               dimension,
               {
                  pos = pos,
                  size = size,
                  axis = axis,
                  targetPos = portalToSave.pos,
                  targetSize = portalToSave.size,
                  targetAxis = portalToSave.axis,
                  blocks = portalToSave.blocks
               }
            )
            addPortal(
               portalToSave.dimension,
               {
                  pos = portalToSave.pos,
                  size = portalToSave.size,
                  axis = portalToSave.axis,
                  targetPos = pos,
                  targetSize = size,
                  targetAxis = axis,
                  blocks = blocks
               }
            )
            portalToSave = nil
         elseif portalToSave.saveDelay then
            portalToSave.saveDelay = portalToSave.saveDelay - 1
         elseif currentBlock.id == 'minecraft:nether_portal' then
            portalToSave.portalPos = playerPos
            portalToSave.saveDelay = 20
         elseif portalToSave.time < 0 then
            portalToSave = nil
         end
      elseif currentBlock.id ~= 'minecraft:nether_portal' then
         portalToSave = nil
      end
   elseif currentBlock.id == 'minecraft:nether_portal' and currentBlock ~= previousBlock then
      local pos, size, axis = findPortal(playerPos)
      portalToSave = {
         time = 100,
         pos = pos,
         size = size,
         axis = axis,
         blocks = getBlocksAround(pos, size, offset),
         dimension = dimension,
      }
   end
end