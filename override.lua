-- settings
local foliage = vec(0.47, 0.67, 0.18)
local grass = vec(0.57, 0.74, 0.35)
local water = vec(0.25, 0.46, 0.9)
local waterFrames = 32

-- models
local sqrt05 = math.sqrt(0.5)

local crossModel = {
   {
      pos = vec(0.5 + sqrt05 * 0.5, 1, 0.5 - sqrt05 * 0.5),
      rot = vec(0, 45, 0),
      size = vec(1, 1), uvStart = vec(0, 0), uvEnd = vec(1, 1), side = "PARTICLE"
   },
   {
      pos = vec(0.5 - sqrt05 * 0.5, 1, 0.5 + sqrt05 * 0.5),
      rot = vec(0, 225, 0),
      size = vec(1, 1), uvStart = vec(0, 0), uvEnd = vec(1, 1), side = "PARTICLE"
   },
   {
      pos = vec(0.5 - sqrt05 * 0.5, 1, 0.5 - sqrt05 * 0.5),
      rot = vec(0, 135, 0),
      size = vec(1, 1), uvStart = vec(0, 0), uvEnd = vec(1, 1), side = "PARTICLE"
   },
   {
      pos = vec(0.5 + sqrt05 * 0.5, 1, 0.5 + sqrt05 * 0.5),
      rot = vec(0, 315, 0),
      size = vec(1, 1), uvStart = vec(0, 0), uvEnd = vec(1, 1), side = "PARTICLE"
   }
}

-- override table
return {
   ids = {
      ["minecraft:grass_block"] = {
         sideColors = {
         UP = {[1] = {color = grass}},
         WEST = {[2] = {color = grass}},
         EAST = {[2] = {color = grass}},
         SOUTH = {[2] = {color = grass}},
         NORTH = {[2] = {color = grass}},
         }
      },

      ["minecraft:grass"] = {color = grass, mesh = crossModel},
      ["minecraft:tall_grass"] = {color = grass, mesh = crossModel},
      ["minecraft:fern"] = {color = grass, mesh = crossModel},
      ["minecraft:large_fern"] = {color = grass, mesh = crossModel},
      ["minecraft:vine"] = {color = foliage},

      ["minecraft:sugar_cane"] = {color = foliage, mesh = crossModel},

      ["minecraft:oak_leaves"] = {color = foliage, noCull = true},
      ["minecraft:spruce_leaves"] = {color = vec(0.38, 0.6, 0.38)},
      ["minecraft:birch_leaves"] = {color = vec(0.5, 0.65, 0.33), noCull = true},
      ["minecraft:jungle_leaves"] = {color = foliage, noCull = true},
      ["minecraft:acacia_leaves"] = {color = foliage, noCull = true},
      ["minecraft:dark_oak_leaves"] = {color = foliage, noCull = true},
      ["minecraft:mangrove_leaves"] = {color = foliage, noCull = true},
      ["minecraft:cherry_leaves"] = {noCull = true},
      ["minecraft:azalea_leaves"] = {noCull = true},
      ["minecraft:flowering_azalea_leaves"] = {noCull = true},

      ["minecraft:pink_petals"] = {},
      ["minecraft:flowering_azalea"] = {},

      ["minecraft:dirt_path"] = {
         textures = {
            UP = {[1] = "minecraft:textures/block/dirt_path_top"}
         }
      },

      ["minecraft:lily_pad"] = {
         color = vec(0.13, 0.5, 0.19)
      },

      ["minecraft:water"] = {
         color = water,
         cull = 2,
         textures = {
            UP = {[1] = "minecraft:textures/block/water_still"}
         },
         mesh = {{
            pos = vec(1, 14 / 16, 1),
            rot = vec(90, 0, 0),
            size = vec(1, 1), uvStart = vec(0, 0), uvEnd = vec(1, 1 / waterFrames), side = "UP"
         },
         {
            pos = vec(1, 14 / 16, 0),
            rot = vec(-90, 0, 0),
            size = vec(1, 1), uvStart = vec(0, 0), uvEnd = vec(1, 1 / waterFrames), side = "UP"
         }}
      },

      ["minecraft:nether_portal"] = {mesh = {}}
   },
   tags = {
      ["minecraft:flowers"] = {
         mesh = crossModel
      }
   }
}