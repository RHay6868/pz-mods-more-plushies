--============================================================--
--              MorePlushies_OpenBinder.lua                  --
--============================================================--
-- B41 VERSION
--============================================================--

require "MorePlushies_Constants"

local BINDER_TYPE = "Base.PlushieCollectionBinder"

local function onFillInventoryObjectContextMenu(playerIndex, context, items)
    local binder = nil
    for _, v in ipairs(items) do
        local item = v.items and v.items[1] or v
        if item and item:getFullType() == BINDER_TYPE then
            binder = item
            break
        end
    end
    if not binder then return end

    local player = getSpecificPlayer(playerIndex)
    if not player then return end

    -- Only show option when binder is in player inventory, not on the ground
    if not player:getInventory():contains(binder) then return end

    context:addOption(
        getText("IGUI_MP_BrowseCollection"),
        player,
        function(chr)
            ISTimedActionQueue.add(ISOpenPlushieBinder:new(chr, binder))
        end
    )
end

local function init()
    ISOpenPlushieBinder = ISBaseTimedAction:derive("ISOpenPlushieBinder")

    function ISOpenPlushieBinder:new(character, item)
        local o = ISBaseTimedAction.new(self, character)
        o.item           = item
        o.character      = character
        o.maxTime        = 50   -- short, just a page flip or two
        o.stopOnWalk     = true
        o.stopOnRun      = true
        o.useProgressBar = false
        o.forceProgressBar = false
        return o
    end

    function ISOpenPlushieBinder:isValid()
        return self.character:getInventory():contains(self.item)
    end

    function ISOpenPlushieBinder:start()
        -- Exact pattern from ISReadABook.start()
        self:setAnimVariable("ReadType", "book")
        self:setActionAnim(CharacterActionAnims.Read)
        self:setOverrideHandModels(nil, self.item)
        self.character:setReading(true)
        self.character:playSound("OpenBook")
    end

    function ISOpenPlushieBinder:stop()
        self.character:setReading(false)
        self.character:playSound("CloseBook")
        ISBaseTimedAction.stop(self)
    end

    function ISOpenPlushieBinder:perform()
        self.character:setReading(false)
        self.character:playSound("CloseBook")
        MorePlushies.Viewer.open(self.character)
        ISBaseTimedAction.perform(self)
    end

    Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)
end

Events.OnGameStart.Add(init)