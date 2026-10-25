--============================================================--
--            MorePlushies_CollectionTracker.lua             --
--============================================================--
-- B41 VERSION
-- Hooks ISInventoryTransferAction.perform to detect when
-- any tracked plushie (mod or vanilla) enters player inventory.
--============================================================--

require "MorePlushies_Constants"
require "TimedActions/ISInventoryTransferAction"

MorePlushies            = MorePlushies or {}
MorePlushies.Collection = MorePlushies.Collection or {}

local plushieLookup = nil
local MODDATA_KEY   = "MorePlushies_Collected"

local function buildLookup()
    plushieLookup = {}
    -- Mod plushies
    for _, entry in ipairs(MorePlushies.Constants.Registry) do
        plushieLookup["Base." .. entry.id] = true
    end
    -- Vanilla plushies
    if MorePlushies.Constants.VanillaRegistry then
        for _, entry in ipairs(MorePlushies.Constants.VanillaRegistry) do
            plushieLookup["Base." .. entry.id] = true
        end
    end
    local count = 0
    for _ in pairs(plushieLookup) do count = count + 1 end
end

function MorePlushies.Collection.getCollected(player)
    local md = player:getModData()
    if not md[MODDATA_KEY] then md[MODDATA_KEY] = {} end
    return md[MODDATA_KEY]
end

function MorePlushies.Collection.isCollected(player, itemType)
    return MorePlushies.Collection.getCollected(player)[itemType] == true
end

local function init()
    buildLookup()

    local original = ISInventoryTransferAction.perform
    function ISInventoryTransferAction:perform()
        original(self)

        if not plushieLookup then return end

        local item = self.item
        local dest = self.destContainer
        local chr  = self.character

        if not item or not dest or not chr then return end
        if not instanceof(chr, "IsoPlayer") then return end

        local playerNum = chr:getPlayerNum()
        if not playerNum or playerNum < 0 then return end
        local player = getSpecificPlayer(playerNum)
        if not player then return end
        if dest ~= player:getInventory() then return end

        local fullType = item:getFullType()
        if not plushieLookup[fullType] then return end

        local collected = MorePlushies.Collection.getCollected(player)
        if collected[fullType] then return end

        collected[fullType] = true
    end
end

Events.OnGameStart.Add(init)