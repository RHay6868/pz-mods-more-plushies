--============================================================--
--                   MorePlushies_Loot.lua                   --
--============================================================--
-- Purpose:
--   Eligibility filtering and distribution controller for
--   More Plushies. Injects enabled items into procedural
--   loot distributions using the spawn rate engine.
--
-- Responsibilities:
--   Build enabled item tables from registry and sandbox state.
--   Inject items into ProceduralDistributions on the
--   OnPreDistributionMerge event.
--
-- Dependencies:
--   MorePlushies_Constants.lua
--   MorePlushies_SandboxUtils.lua
--
--============================================================--

require "Items/ProceduralDistributions"
require "Items/SuburbsDistributions"
require "Items/Distributions"
require "Vehicles/VehicleDistributions"
require "MorePlushies_Constants"
require "MorePlushies_SandboxUtils"

MorePlushies      = MorePlushies or {}
MorePlushies.Loot = MorePlushies.Loot or {}

MorePlushies.Loot.AddedItems = {}

---===========================================---
--           INJECTION HELPER                 --
---===========================================---

function MorePlushies.Loot:add(itemsAndChances, locations)
    local prefix = "Base."
    for item, chance in pairs(itemsAndChances) do
        for _, loc in ipairs(locations) do
            local dist = ProceduralDistributions.list[loc]
            if dist and dist.items then
                local fullName = prefix .. item
                if ScriptManager.instance:FindItem(fullName) then
                    table.insert(dist.items, item)
                    table.insert(dist.items, chance)
                    self.AddedItems[item] = true
                else
                    MorePlushies.debugLog("Item not found in ScriptManager: " .. fullName)
                end
            end
        end
    end
end

---===========================================---
--          ENABLED ITEM TABLES               --
---===========================================---

function MorePlushies.Loot.getEnabledItems(sv)
    local registry = MorePlushies.Constants.Registry

    local result = {
        common   = {},
        uncommon = {},
        rare     = {},
        veryRare  = {},
    }

    for _, entry in ipairs(registry) do
        if not entry.spawnInLoot then
        elseif entry.tier == "common" and sv.CommonPlushies then
            table.insert(result.common, entry.id)
        elseif entry.tier == "uncommon" and sv.UncommonPlushies then
            table.insert(result.uncommon, entry.id)
        elseif entry.tier == "rare" and sv.RarePlushies then
            table.insert(result.rare, entry.id)
        elseif entry.tier == "veryRare" and sv.VeryRarePlushies then
            table.insert(result.veryRare, entry.id)
        end
    end

    return result
end

---===========================================---
--          CATEGORY CONFIG                   --
---===========================================---

MorePlushies.Loot.CategoryConfig = {}

function MorePlushies.Loot.CategoryConfig.Common(enabledItems, sv)
    if #enabledItems.common == 0 then return end
    local engine = MorePlushies.Constants.spawnRateEngine
    local locations = {}
    if sv.LocationsToy        then for _, l in ipairs(MorePlushies.Constants.LootLocations.toy)        do table.insert(locations, l) end end
    if sv.LocationsGeneral    then for _, l in ipairs(MorePlushies.Constants.LootLocations.general)    do table.insert(locations, l) end end
    if sv.LocationsIncidental then for _, l in ipairs(MorePlushies.Constants.LootLocations.incidental) do table.insert(locations, l) end end
    if #locations == 0 then return end
    local rate = engine:calculateRate({
        baseRate        = 0.9,
        globalLoot      = sv.Loot,
        spawnRateSlider = sv.CommonPlushiesRates,
        rarity          = "common",
    })
    local rateMap = {}
    for _, id in ipairs(enabledItems.common) do rateMap[id] = rate end
    MorePlushies.Loot:add(rateMap, locations)
end

function MorePlushies.Loot.CategoryConfig.Uncommon(enabledItems, sv)
    if #enabledItems.uncommon == 0 then return end
    local engine = MorePlushies.Constants.spawnRateEngine
    local locations = {}
    if sv.LocationsToy        then for _, l in ipairs(MorePlushies.Constants.LootLocations.toy)        do table.insert(locations, l) end end
    if sv.LocationsGeneral    then for _, l in ipairs(MorePlushies.Constants.LootLocations.general)    do table.insert(locations, l) end end
    if #locations == 0 then return end
    local rate = engine:calculateRate({
        baseRate        = 0.65,
        globalLoot      = sv.Loot,
        spawnRateSlider = sv.UncommonPlushiesRates,
        rarity          = "uncommon",
    })
    local rateMap = {}
    for _, id in ipairs(enabledItems.uncommon) do rateMap[id] = rate end
    MorePlushies.Loot:add(rateMap, locations)
end

function MorePlushies.Loot.CategoryConfig.Rare(enabledItems, sv)
    if #enabledItems.rare == 0 then return end
    local engine = MorePlushies.Constants.spawnRateEngine
    local locations = {}
    if sv.LocationsToy     then for _, l in ipairs(MorePlushies.Constants.LootLocations.toy)     do table.insert(locations, l) end end
    if sv.LocationsGeneral then for _, l in ipairs(MorePlushies.Constants.LootLocations.general) do table.insert(locations, l) end end
    if #locations == 0 then return end
    local rate = engine:calculateRate({
        baseRate        = 0.4,
        globalLoot      = sv.Loot,
        spawnRateSlider = sv.RarePlushiesRates,
        rarity          = "rare",
    })
    local rateMap = {}
    for _, id in ipairs(enabledItems.rare) do rateMap[id] = rate end
    MorePlushies.Loot:add(rateMap, locations)
end

function MorePlushies.Loot.CategoryConfig.VeryRare(enabledItems, sv)
    if #enabledItems.veryRare == 0 then return end
    local engine = MorePlushies.Constants.spawnRateEngine
    local locations = {}
    if sv.LocationsToy     then for _, l in ipairs(MorePlushies.Constants.LootLocations.toy)     do table.insert(locations, l) end end
    if sv.LocationsGeneral then for _, l in ipairs(MorePlushies.Constants.LootLocations.general) do table.insert(locations, l) end end
    if #locations == 0 then return end
    local rate = engine:calculateRate({
        baseRate        = 0.2,
        globalLoot      = sv.Loot,
        spawnRateSlider = sv.VeryRarePlushiesRates,
        rarity          = "veryRare",
    })
    local rateMap = {}
    for _, id in ipairs(enabledItems.veryRare) do rateMap[id] = rate end
    MorePlushies.Loot:add(rateMap, locations)
end

-- Binder: fixed low rate across all plushie locations, not gated by any plushie toggle.
function MorePlushies.Loot.CategoryConfig.Binder(sv)
    local locations = {}
    if sv.LocationsToy        then for _, l in ipairs(MorePlushies.Constants.LootLocations.toy)        do table.insert(locations, l) end end
    if sv.LocationsGeneral    then for _, l in ipairs(MorePlushies.Constants.LootLocations.general)    do table.insert(locations, l) end end
    if sv.LocationsIncidental then for _, l in ipairs(MorePlushies.Constants.LootLocations.incidental) do table.insert(locations, l) end end
    if #locations == 0 then return end
    MorePlushies.Loot:add({ ["PlushieCollectionBinder"] = 0.06 }, locations)
end

---===========================================---
--           ORPHAN DETECTION                 --
---===========================================---
-- Returns a set of all item short names the mod knows about
-- that are NOT in the currently enabled pool.
-- Used by the post-merge cleanup to strip disabled items
-- from distribution tables regardless of how they got there.

function MorePlushies.Loot.getOrphanedItems()
    local sv           = MorePlushies.SandboxUtils.get()
    local enabledItems = MorePlushies.Loot.getEnabledItems(sv)

    local enabledSet = {}
    for _, categoryList in pairs(enabledItems) do
        for _, id in ipairs(categoryList) do
            enabledSet[id] = true
        end
    end

    local orphaned = {}
    for _, entry in ipairs(MorePlushies.Constants.Registry) do
        if not enabledSet[entry.id] then
            orphaned[entry.id] = true
        end
    end

    return orphaned
end

---===========================================---
--         DISTRIBUTION CLEANUP               --
---===========================================---
-- Strips orphaned items from a single distribution table.

local function cleanupItemsInTable(distTable, orphanedItems)
    if not distTable or not distTable.items then return end
    local i = 1
    while i <= #distTable.items do
        local item = distTable.items[i]
        if type(item) == "string" and orphanedItems[item] then
            table.remove(distTable.items, i)
            table.remove(distTable.items, i)
        else
            i = i + 2
        end
    end
end

-- Recursively walks a distribution root table and cleans all subtables.
local function cleanupDistributionTable(rootTable, orphanedItems)
    if not rootTable or type(rootTable) ~= "table" then return end
    for _, v in pairs(rootTable) do
        if type(v) == "table" then
            if v.items and type(v.items) == "table" then
                cleanupItemsInTable(v, orphanedItems)
            else
                cleanupDistributionTable(v, orphanedItems)
            end
        end
    end
end

function MorePlushies.Loot.cleanup()
    local orphaned = MorePlushies.Loot.getOrphanedItems()
    cleanupDistributionTable(ProceduralDistributions.list, orphaned)
    cleanupDistributionTable(SuburbsDistributions, orphaned)
    cleanupDistributionTable(VehicleDistributions, orphaned)
    if Distributions and Distributions[1] then
        cleanupDistributionTable(Distributions[1], orphaned)
    end
    MorePlushies.debugLog("Post-merge cleanup complete.")
end

---===========================================---
--     INITIALIZE ON PRE DISTRIBUTION MERGE   --
---===========================================---

Events.OnPreDistributionMerge.Add(function()
    MorePlushies.Loot.AddedItems = {}

    local sv = MorePlushies.SandboxUtils.get()

    if sv.Loot == 1 then
        MorePlushies.debugLog("Loot = None. Skipping all injection.")
        return
    end

    local enabledItems = MorePlushies.Loot.getEnabledItems(sv)

    MorePlushies.Loot.CategoryConfig.Common(enabledItems, sv)
    MorePlushies.Loot.CategoryConfig.Uncommon(enabledItems, sv)
    MorePlushies.Loot.CategoryConfig.Rare(enabledItems, sv)
    MorePlushies.Loot.CategoryConfig.VeryRare(enabledItems, sv)
    MorePlushies.Loot.CategoryConfig.Binder(sv)

    MorePlushies.debugLog("Injection complete.")
end)

---===========================================---
--     CLEANUP ON POST DISTRIBUTION MERGE     --
---===========================================---
-- Strips any disabled mod items that survived the pre-merge pass.
-- This catches items populated by the engine before our hook fired
-- and clears them before players ever load in.

Events.OnPostDistributionMerge.Add(function()
    if MorePlushies.Loot and MorePlushies.Loot.cleanup then
        MorePlushies.Loot.cleanup()
    end
end)