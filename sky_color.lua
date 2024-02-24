local lib = {}

local skyColor = vec(0.72, 0.82, 1)
local skyColor2 = vec(0.71, 0.31, 0.24)

function lib.getLight(time)
   time = time or world.getTimeOfDay()

   time = time % 24000
   local sky = 0
   if time >= 0 and time < 12000 then
      sky = 15
   elseif time > 14000 and time < 22000 then
      sky = 4
   elseif time >= 12000 and time <= 14000 then
      sky = math.lerp(15, 4, (time - 12000) / 2000)
   elseif time >= 22000 and time <= 24000 then
      sky = math.lerp(4, 15, (time - 22000) / 2000)
   end

   return sky
end

function lib.getColor(time)
   local level = lib.getLight(time) / 15
   local color = math.lerp(skyColor, skyColor2, math.max(0.75 - math.abs(0.63 - level) * 2.2, 0))
   return color * level
end

return lib