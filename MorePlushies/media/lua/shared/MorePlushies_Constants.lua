--============================================================--
--                MorePlushies_Constants.lua                 --
--============================================================--
-- Purpose:
--   Single source of truth for all items, location groups,
--   rate constants, and curve profiles owned by More Plushies.
--
-- Responsibilities:
--   Item registry with tier and metadata fields.
--   Location group definitions for all spawn contexts.
--   Spawn rate engine curve pattern.
--   Debug logging utility.
--
-- Dependencies:
--   None. No requires. 
--
--============================================================--

MorePlushies           = MorePlushies or {}
MorePlushies.Constants = MorePlushies.Constants or {}

---===========================================---
--                DEBUG FLAG                  --
---===========================================---

local isDebugEnabled = false

function MorePlushies.debugLog(msg)
    if isDebugEnabled then
        print("[MorePlushies] " .. tostring(msg))
    end
end

---===========================================---
--              ITEM REGISTRY                 --
---===========================================---
-- Every item this mod distributes is declared here.
-- spawnInLoot = false means recipe-output only, never distributed.
-- enabledByDefault = false means requires explicit sandbox toggle.

MorePlushies.Constants.Registry = {
    { id = "PigPlushie",             tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "AxolotlPlushie",         tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "ChocobiPlushie",         tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "DaveMinionPlushie",      tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "DeathBeePlushie",        tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "UddersPlushie",          tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "GnomeAmericanPlushie",   tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "PinkKittenPlushie",      tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "FloppyPlushie",          tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "GoatPlushie",            tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "UnicornPlushie",         tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "TurtlePlushie",          tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "OtterPlushie",           tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "AlienSpiffoPlushie",     tier = "common",   enabledByDefault = true,  spawnInLoot = true  },
    { id = "CopSpiffoPlushie",       tier = "common",   enabledByDefault = true,  spawnInLoot = true  },

    { id = "RoyalePlushie",          tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "BioPlushie",             tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "BatmanPlushie",          tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "GroguPlushie",           tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "MiniMoosePlushie",       tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "CactuarPlushie",         tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "MogPlushie",             tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "GrebdiozPlushie",        tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "ReiPlushie",             tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "PochitaPlushie",         tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "LeonardoPlushie",        tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "RaphaelPlushie",         tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "DonatelloPlushie",       tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "MichelangeloPlushie",    tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "Porg1Plushie",           tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "Porg2Plushie",           tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "Ewok1Plushie",           tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "Ewok2Plushie",           tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "StitchPlushie",          tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "PuarPlushie",            tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "PiranhaPlushie",         tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "ScrapPlushie",           tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "BlahajPlushie",          tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "SpongebobPlushie",       tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "PatrickStarPlushie",     tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "SquidwardPlushie",       tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "MrKrabsPlushie",         tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "BedtimeBearPlushie",     tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "FunshineBearPlushie",    tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "GrumpyBearPlushie",      tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "TenderBearPlushie",      tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },
    { id = "CheerBearPlushie",       tier = "uncommon", enabledByDefault = true,  spawnInLoot = true  },

    { id = "StitchesPlushie",        tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "HexDollPlushie",         tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "MurderMonkeyPlushie",    tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "GIRPlushie",             tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "GIR2Plushie",            tier = "rare",     enabledByDefault = false, spawnInLoot = false },
    { id = "ShredderPlushie",        tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "SplinterPlushie",        tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "MikeWazowskiPlushie",    tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "SullyPlushie",           tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "LuckyCatPlushie",        tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "InspectorGadgetPlushie", tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "CthulhuPlushie",         tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "CannabisPlushie",        tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "MetalGearRayPlushie",    tier = "rare",     enabledByDefault = false, spawnInLoot = false },
    { id = "MarvMunchkinPlushie",    tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "DeadpoolPlushie",        tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "ZoeyPlushie",            tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "RumiPlushie",            tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "MiraPlushie",            tier = "rare",     enabledByDefault = false, spawnInLoot = false },
    { id = "CellPlushie",            tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "WolverinePlushie",       tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "RealBatmanPlushie",      tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    { id = "IronmanPlushie",         tier = "rare",     enabledByDefault = true,  spawnInLoot = true  },
    
    { id = "MishkaPlushie",          tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "LuckyCatGoldPlushie",    tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "BenderPlushie",          tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "LuffyPlushie",           tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "DarthVaderPlushie",      tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "SmokeyPlushie",          tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "CthulhuFullPlushie",     tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "OptimusPrimePlushie",    tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "MegatronPlushie",        tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "FrogbertPlushie",        tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "HammondPlushie",         tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
    { id = "BrainPlushie",           tier = "veryRare",  enabledByDefault = false, spawnInLoot = true  },
}

-- Vanilla plushies — tracked in the viewer but never spawned by this mod.
MorePlushies.Constants.VanillaRegistry = {
    { id = "Spiffo",              displayName = "Spiffo",                module = "Base" },
    { id = "SpiffoBig",           displayName = "Big Spiffo",            module = "Base" },
    { id = "BorisBadger",         displayName = "Boris The Badger",      module = "Base" },
    { id = "JacquesBeaver",       displayName = "Jacques The Beaver",    module = "Base" },
    { id = "FreddyFox",           displayName = "Freddy The Fox",        module = "Base" },
    { id = "PancakeHedgehog",     displayName = "Pancake The Hedgehog",  module = "Base" },
    { id = "MoleyMole",           displayName = "Moley The Mole",        module = "Base" },
    { id = "FluffyfootBunny",     displayName = "Fluffyfoot The Bunny",  module = "Base" },
    { id = "FurbertSquirrel",     displayName = "Furbert The Squirrel",  module = "Base" },
}

---===========================================---
--             LOCATION GROUPS                --
---===========================================---

MorePlushies.Constants.LootLocations = {
    toy = {
        "CrateToys",
        "GigamartToys",
        "PrisonCellRandom",
        "WardrobeChild",
    },
    general = {
        "ClassroomMisc",
        "CrateRandomJunk",
        "DaycareCounter",
        "DaycareShelves",
        "GigamartSchool",
    },
    incidental = {
        "KitchenRandom",
    },
}

---===========================================---
--           SPAWN RATE ENGINE                --
---===========================================---

MorePlushies.Constants.spawnRateEngine = {
    scalingFactor = 2.0,
    minMultiplier = 0.05,
    maxMultiplier = 20.0,

    curveProfiles = {
        common   = 0.85,
        uncommon = 1.0,
        rare     = 1.15,
        veryRare = 1.35,
    }
}

function MorePlushies.Constants.spawnRateEngine:getMultiplierFromSetting(lootSetting, curveName)
    lootSetting = lootSetting or 3
    lootSetting = math.max(1, math.min(lootSetting, 6))
    local curveModifier = self.curveProfiles[curveName] or self.curveProfiles.uncommon
    local normalizedSetting = (lootSetting - 1) / 5

    local range = self.maxMultiplier - self.minMultiplier
    local rawMultiplier = self.minMultiplier + (math.pow(normalizedSetting, curveModifier) * range)

    local baselineMultiplier = self:getBaselineMultiplier(3, curveName)
    return rawMultiplier / baselineMultiplier
end

function MorePlushies.Constants.spawnRateEngine:getBaselineMultiplier(lootSetting, curveName)
    lootSetting = lootSetting or 3
    lootSetting = math.max(1, math.min(lootSetting, 6))
    local curveModifier = self.curveProfiles[curveName] or self.curveProfiles.uncommon
    local normalizedSetting = (lootSetting - 1) / 5

    local range = self.maxMultiplier - self.minMultiplier
    return self.minMultiplier + (math.pow(normalizedSetting, curveModifier) * range)
end

function MorePlushies.Constants.spawnRateEngine:calculateRate(options)
    local baseRate          = options.baseRate or 1.0
    local globalLootSetting = options.globalLoot or 3
    local spawnRateSlider   = options.spawnRateSlider
    local rarity            = options.rarity or "uncommon"

    local globalMultiplier = self:getMultiplierFromSetting(globalLootSetting, rarity)

    local spawnRateMultiplier = 1.0
    if spawnRateSlider then
        spawnRateMultiplier = (spawnRateSlider / 50) ^ 1.25
    end

    return baseRate * globalMultiplier * spawnRateMultiplier
end