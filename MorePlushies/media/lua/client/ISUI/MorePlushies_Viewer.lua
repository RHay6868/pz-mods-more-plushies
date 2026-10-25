--============================================================--
--                 MorePlushies_Viewer.lua                   --
--============================================================--
-- B41 VERSION
-- Base: ISCollapsableWindow (gives title bar, close btn,
--       resize, moveWithMouse, stencil clipping).
-- Icons drawn inline in render() via drawTextureScaled.
-- Scroll via setStencilRect/clearStencilRect.
--============================================================--

require "ISUI/ISCollapsableWindow"
require "MorePlushies_Constants"
require "MorePlushies_CollectionTracker"

MorePlushies        = MorePlushies or {}
MorePlushies.Viewer = MorePlushies.Viewer or {}

local PADDING      = 12
local ICON_SIZE    = 56
local ICON_PAD_T   = 10
local ENTRY_W      = 124
local ENTRY_GAP_X  = 8
local ENTRY_GAP_Y  = 8
local HEADER_H     = 28
local SCROLLBAR_W  = 12

-- Responsive font/entry helpers — all layout derives from live font height.
local ICON_GAP    = 6   -- px between icon bottom and text zone
local BOTTOM_PAD  = 8   -- px below last text line inside entry

local function getLH()
    return getTextManager():getFontHeight(UIFont.Small)
end

local function getEH()
    local lh = getLH()
    return ICON_PAD_T + ICON_SIZE + ICON_GAP + lh + lh + BOTTOM_PAD
end

local TIER_ORDER = { "vanilla", "common", "uncommon", "rare", "veryRare" }
local TIER_LABEL = {
    vanilla  = getText("IGUI_MP_Vanilla"),
    common   = getText("IGUI_MP_Common"),
    uncommon = getText("IGUI_MP_Uncommon"),
    rare     = getText("IGUI_MP_Rare"),
    veryRare = getText("IGUI_MP_VeryRare"),
}

local function calcCols(contentW)
    return math.max(1, math.floor((contentW + ENTRY_GAP_X) / (ENTRY_W + ENTRY_GAP_X)))
end

local PANEL_W = PADDING + 7 * (ENTRY_W + ENTRY_GAP_X) - ENTRY_GAP_X + PADDING + SCROLLBAR_W + 6
local PANEL_H = 620

local function cleanName(name)
    name = name:gsub("%s*[Pp]lushie%s*$", "")
    name = name:gsub("%s*[Pp]lush%s*$",   "")
    name = name:gsub("^[Pp]lushie%s*",    "")
    return name
end

local function splitName(name, maxW)
    if getTextManager():MeasureStringX(UIFont.Small, name) <= maxW then
        return name, nil
    end
    local words = {}
    for w in name:gmatch("%S+") do table.insert(words, w) end
    if #words >= 2 then
        local bestL1, bestL2, bestMax = nil, nil, math.huge
        for mid = 1, #words - 1 do
            local l1 = table.concat(words, " ", 1, mid)
            local l2 = table.concat(words, " ", mid + 1)
            local w1 = getTextManager():MeasureStringX(UIFont.Small, l1)
            local w2 = getTextManager():MeasureStringX(UIFont.Small, l2)
            local mx = math.max(w1, w2)
            if w1 <= maxW and w2 <= maxW and mx < bestMax then
                bestL1, bestL2, bestMax = l1, l2, mx
            end
        end
        if bestL1 then return bestL1, bestL2 end
    end
    local s = name
    while getTextManager():MeasureStringX(UIFont.Small, s .. "~") > maxW and #s > 1 do
        s = s:sub(1, -2)
    end
    return s .. "~", nil
end

MorePlushies_ViewerPanel = ISCollapsableWindow:derive("MorePlushies_ViewerPanel")

function MorePlushies_ViewerPanel:new(x, y, player)
    local o = ISCollapsableWindow.new(self, x, y, PANEL_W, PANEL_H)
    o.player           = player
    o.entries          = {}
    o.textures         = {}
    o.totalCount       = 0
    o.collectedCount   = 0
    o.scrollY          = 0
    o.contentH         = 0
    o.isDraggingScroll = false
    o.title            = getText("IGUI_MP_CollectionTitle")
    o.backgroundColor  = {r=0.07, g=0.12, b=0.12, a=0.97}
    o.borderColor      = {r=0.20, g=0.70, b=0.70, a=1.0}
    o:setResizable(true)
    o:setDrawFrame(true)
    return o
end

function MorePlushies_ViewerPanel:createChildren()
    ISCollapsableWindow.createChildren(self)
    if self.closeButton then
        self.closeButton.backgroundColor          = {r=0.08, g=0.18, b=0.18, a=1}
        self.closeButton.backgroundColorMouseOver = {r=0.20, g=0.50, b=0.50, a=1}
        self.closeButton.borderColor              = {r=0.20, g=0.70, b=0.70, a=1}
    end
    if self.pinButton      then self.pinButton:setVisible(false)      end
    if self.collapseButton then self.collapseButton:setVisible(false) end
    self.pin         = true
    self.isCollapsed = false
    -- Style the resize widget bar to match our theme
    if self.resizeWidget then
        self.resizeWidget.backgroundColor  = {r=0.07, g=0.12, b=0.12, a=1}
        self.resizeWidget.borderColor      = {r=0.20, g=0.70, b=0.70, a=1}
    end
    if self.resizeWidget2 then
        self.resizeWidget2.backgroundColor = {r=0.07, g=0.12, b=0.12, a=1}
        self.resizeWidget2.borderColor     = {r=0.20, g=0.70, b=0.70, a=1}
    end
end

function MorePlushies_ViewerPanel:onMouseMoveOutside(dx, dy)
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function MorePlushies_ViewerPanel:initialise()
    ISCollapsableWindow.initialise(self)
    self:buildEntries()
    self:calcContentHeight()
end

function MorePlushies_ViewerPanel:buildEntries()
    self.entries        = {}
    self.textures       = {}
    self.totalCount     = 0
    self.collectedCount = 0

    local collected = MorePlushies.Collection.getCollected(self.player)
    local byTier    = {}
    for _, t in ipairs(TIER_ORDER) do byTier[t] = {} end

    for _, entry in ipairs(MorePlushies.Constants.Registry) do
        local fullType   = "Base." .. entry.id
        local scriptItem = ScriptManager.instance:FindItem(fullType)
        local rawName    = scriptItem and scriptItem:getDisplayName() or entry.id
        local name       = cleanName(rawName)
        local tex        = nil
        local tmp        = InventoryItemFactory.CreateItem(fullType)
        if tmp then tex = tmp:getTex(); self.textures[fullType] = tex end
        local isCollected = collected[fullType] == true
        table.insert(byTier[entry.tier] or byTier["common"], {
            displayName = name,
            fullType    = fullType,
            tier        = entry.tier,
            collected   = isCollected,
        })
        self.totalCount = self.totalCount + 1
        if isCollected then self.collectedCount = self.collectedCount + 1 end
    end

    if MorePlushies.Constants.VanillaRegistry then
        for _, entry in ipairs(MorePlushies.Constants.VanillaRegistry) do
            local fullType = "Base." .. entry.id
            local tex      = nil
            local tmp      = InventoryItemFactory.CreateItem(fullType)
            if tmp then tex = tmp:getTex(); self.textures[fullType] = tex end
            local isCollected = collected[fullType] == true
            table.insert(byTier["vanilla"], {
                displayName = entry.displayName,
                fullType    = fullType,
                tier        = "vanilla",
                collected   = isCollected,
            })
            self.totalCount = self.totalCount + 1
            if isCollected then self.collectedCount = self.collectedCount + 1 end
        end
    end

    for _, t in ipairs(TIER_ORDER) do
        table.sort(byTier[t], function(a, b) return a.displayName < b.displayName end)
    end
    for _, t in ipairs(TIER_ORDER) do
        local group = byTier[t]
        if #group > 0 then
            table.insert(self.entries, {isHeader=true, label=TIER_LABEL[t]})
            for _, e in ipairs(group) do table.insert(self.entries, e) end
        end
    end
end

function MorePlushies_ViewerPanel:calcContentHeight(cols)
    local ENTRY_H = getEH()
    local TEXT_LINE_H = getLH()
    cols = cols or calcCols(self:getWidth() - PADDING * 2 - SCROLLBAR_W - 6)
    local y, col = PADDING, 0
    for _, e in ipairs(self.entries) do
        if e.isHeader then
            if col > 0 then y = y + ENTRY_H + ENTRY_GAP_Y; col = 0 end
            y = y + HEADER_H + 8
        else
            if col >= cols then col = 0; y = y + ENTRY_H + ENTRY_GAP_Y end
            col = col + 1
        end
    end
    if col > 0 then y = y + ENTRY_H + ENTRY_GAP_Y end
    self.contentH = y + PADDING
end

function MorePlushies_ViewerPanel:onResize()
    self:calcContentHeight()
    local th          = self:titleBarHeight()
    local rh          = self:resizeWidgetHeight()
    local scrollAreaH = self:getHeight() - th - rh
    local maxScroll   = math.max(0, self.contentH - scrollAreaH)
    self.scrollY      = math.min(self.scrollY, maxScroll)
end

function MorePlushies_ViewerPanel:refreshCollected()
    local collected     = MorePlushies.Collection.getCollected(self.player)
    self.collectedCount = 0
    for _, e in ipairs(self.entries) do
        if not e.isHeader then
            e.collected = collected[e.fullType] == true
            if e.collected then self.collectedCount = self.collectedCount + 1 end
        end
    end
end

function MorePlushies_ViewerPanel:prerender()
    ISCollapsableWindow.prerender(self)
    -- Paint over the resize bar strip so it matches our background
    local rh = self:resizeWidgetHeight()
    if rh > 0 then
        local barY = self:getHeight() - rh
        self:drawRect(0, barY, self:getWidth(), rh, 1, 0.07, 0.12, 0.12)
        -- Thin cyan top edge to match border colour
        self:drawRect(0, barY, self:getWidth(), 1, 1, 0.20, 0.70, 0.70)
    end
end

function MorePlushies_ViewerPanel:render()
    local ENTRY_H = getEH()
    local TEXT_LINE_H = getLH()
    self:refreshCollected()

    local th          = self:titleBarHeight()
    local rh          = self:resizeWidgetHeight()
    local scrollAreaH = self:getHeight() - th - rh
    local sbX         = self:getWidth() - SCROLLBAR_W - 2
    local contentX    = PADDING
    local cols        = calcCols(sbX - PADDING * 2)
    local maxScroll   = math.max(0, self.contentH - scrollAreaH)

    -- Reflow if cols changed
    local newH = 0
    do
        local y2, col2 = PADDING, 0
        for _, e in ipairs(self.entries) do
            if e.isHeader then
                if col2 > 0 then y2 = y2 + ENTRY_H + ENTRY_GAP_Y; col2 = 0 end
                y2 = y2 + HEADER_H + 8
            else
                if col2 >= cols then col2 = 0; y2 = y2 + ENTRY_H + ENTRY_GAP_Y end
                col2 = col2 + 1
            end
        end
        if col2 > 0 then y2 = y2 + ENTRY_H + ENTRY_GAP_Y end
        newH = y2 + PADDING
    end
    if newH ~= self.contentH then
        self.contentH = newH
        maxScroll     = math.max(0, self.contentH - scrollAreaH)
        self.scrollY  = math.min(self.scrollY, maxScroll)
    end

    -- Count label — true vertical centre in title bar
    local countStr = tostring(self.collectedCount) .. " / " .. tostring(self.totalCount)
    local countW   = getTextManager():MeasureStringX(UIFont.Small, countStr)
    local countH   = getTextManager():getFontHeight(UIFont.Small)
    local countY   = math.floor((th - countH) / 2)
    self:drawText(countStr, self:getWidth() - countW - SCROLLBAR_W - 16, countY,
        0.20, 0.85, 0.85, 1, UIFont.Small)

    -- Clip content to scroll area
    self:setStencilRect(0, th, sbX, scrollAreaH)

    local y, col = PADDING, 0
    for _, e in ipairs(self.entries) do
        if e.isHeader then
            if col > 0 then y = y + ENTRY_H + ENTRY_GAP_Y; col = 0 end
            local drawY = th + y - self.scrollY
            if drawY + HEADER_H > th and drawY < th + scrollAreaH then
                self:drawRect(0, drawY, sbX, HEADER_H, 0.85, 0.08, 0.14, 0.14)
                self:drawText(e.label, contentX + 2, drawY + 3, 0.20, 0.85, 0.85, 1, UIFont.Small)
            end
            y = y + HEADER_H + 8
        else
            if col >= cols then col = 0; y = y + ENTRY_H + ENTRY_GAP_Y end
            local drawX = contentX + col * (ENTRY_W + ENTRY_GAP_X)
            local drawY = th + y - self.scrollY
            if drawY + ENTRY_H > th and drawY < th + scrollAreaH then
                if e.collected then
                    self:drawRect(drawX, drawY, ENTRY_W, ENTRY_H, 0.90, 0.06, 0.20, 0.20)
                    self:drawRectBorder(drawX, drawY, ENTRY_W, ENTRY_H, 0.85, 0.20, 0.70, 0.70)
                else
                    self:drawRect(drawX, drawY, ENTRY_W, ENTRY_H, 0.75, 0.10, 0.10, 0.10)
                    self:drawRectBorder(drawX, drawY, ENTRY_W, ENTRY_H, 0.40, 0.25, 0.25, 0.25)
                end
                local iconX = drawX + math.floor((ENTRY_W - ICON_SIZE) / 2)
                local iconY = drawY + ICON_PAD_T
                local tex   = self.textures[e.fullType]
                if tex then
                    self:drawTextureScaled(tex, iconX, iconY, ICON_SIZE, ICON_SIZE,
                        e.collected and 1.0 or 0.35, 1, 1, 1)
                else
                    self:drawRect(iconX, iconY, ICON_SIZE, ICON_SIZE, 0.3, 0.15, 0.15, 0.15)
                end
                local maxW      = ENTRY_W - 6
                local l1, l2    = splitName(e.displayName, maxW)

                local textAreaY = iconY + ICON_SIZE + ICON_GAP
                local textAreaH = ENTRY_H - ICON_PAD_T - ICON_SIZE - ICON_GAP

                local tr, tg, tb = e.collected and 0.20 or 0.75,
                                e.collected and 0.85 or 0.75,
                                e.collected and 0.85 or 0.75

                local lineOffset = l2 and 2 or math.floor((textAreaH - TEXT_LINE_H) / 2)

                local l1W = getTextManager():MeasureStringX(UIFont.Small, l1)
                self:drawText(l1,
                    drawX + math.floor((ENTRY_W - l1W) / 2),
                    textAreaY + lineOffset,
                    tr, tg, tb, 1, UIFont.Small)

                if l2 then
                    local l2W = getTextManager():MeasureStringX(UIFont.Small, l2)
                    self:drawText(l2,
                        drawX + math.floor((ENTRY_W - l2W) / 2),
                        textAreaY + lineOffset + TEXT_LINE_H + 2,
                        tr, tg, tb, 0.85, UIFont.Small)
                end
            end
            col = col + 1
        end
    end

    self:clearStencilRect()

    -- Scrollbar track
    self:drawRect(sbX, th, SCROLLBAR_W, scrollAreaH, 0.8, 0.05, 0.10, 0.10)
    self:drawRectBorder(sbX, th, SCROLLBAR_W, scrollAreaH, 0.6, 0.20, 0.60, 0.60)

    -- Scrollbar thumb
    if maxScroll > 0 then
        local ratio  = scrollAreaH / self.contentH
        local thumbH = math.max(20, math.floor(scrollAreaH * ratio))
        local thumbY = th + math.floor((scrollAreaH - thumbH) * (self.scrollY / maxScroll))
        local mx, my = self:getMouseX(), self:getMouseY()
        local hov    = mx >= sbX and mx <= sbX + SCROLLBAR_W and my >= th and my <= th + scrollAreaH
        self:drawRect(sbX + 1, thumbY, SCROLLBAR_W - 2, thumbH,
            0.9, hov and 0.30 or 0.20, hov and 0.85 or 0.70, hov and 0.85 or 0.70)
    end

    ISCollapsableWindow.render(self)
end

function MorePlushies_ViewerPanel:onMouseWheel(delta)
    local th          = self:titleBarHeight()
    local rh          = self:resizeWidgetHeight()
    local scrollAreaH = self:getHeight() - th - rh
    local maxScroll   = math.max(0, self.contentH - scrollAreaH)
    self.scrollY = math.max(0, math.min(self.scrollY + delta * 30, maxScroll))
    return true
end

function MorePlushies_ViewerPanel:onMouseDown(x, y)
    local th          = self:titleBarHeight()
    local rh          = self:resizeWidgetHeight()
    local scrollAreaH = self:getHeight() - th - rh
    local sbX         = self:getWidth() - SCROLLBAR_W - 2
    if x >= sbX and x <= sbX + SCROLLBAR_W and y >= th and y <= th + scrollAreaH then
        self.isDraggingScroll = true
        self:scrollFromMouse(y, th, scrollAreaH)
        return
    end
    ISCollapsableWindow.onMouseDown(self, x, y)
end

function MorePlushies_ViewerPanel:onMouseMove(dx, dy)
    if self.isDraggingScroll then
        local th          = self:titleBarHeight()
        local rh          = self:resizeWidgetHeight()
        local scrollAreaH = self:getHeight() - th - rh
        self:scrollFromMouse(self:getMouseY(), th, scrollAreaH)
        return
    end
    ISCollapsableWindow.onMouseMove(self, dx, dy)
end

function MorePlushies_ViewerPanel:onMouseUp(x, y)
    self.isDraggingScroll = false
    ISCollapsableWindow.onMouseUp(self, x, y)
end

function MorePlushies_ViewerPanel:onMouseMoveOutside(dx, dy)
    if self.isDraggingScroll then
        local th          = self:titleBarHeight()
        local rh          = self:resizeWidgetHeight()
        local scrollAreaH = self:getHeight() - th - rh
        self:scrollFromMouse(self:getMouseY(), th, scrollAreaH)
        return
    end
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function MorePlushies_ViewerPanel:scrollFromMouse(mouseY, th, scrollAreaH)
    local maxScroll = math.max(0, self.contentH - scrollAreaH)
    if maxScroll <= 0 then return end
    local thumbH = math.max(20, math.floor(scrollAreaH * (scrollAreaH / self.contentH)))
    local ratio  = math.max(0, math.min(1, (mouseY - th - thumbH / 2) / math.max(1, scrollAreaH - thumbH)))
    self.scrollY = math.floor(ratio * maxScroll)
end

function MorePlushies_ViewerPanel:onKeyPressed(key)
    if key == Keyboard.KEY_ESCAPE then self:close() end
end

function MorePlushies_ViewerPanel:close()
    ISCollapsableWindow.close(self)
    self:removeFromUIManager()
    MorePlushies.Viewer._panel = nil
end

function MorePlushies.Viewer.open(player)
    if MorePlushies.Viewer._panel then
        MorePlushies.Viewer._panel:close()
    end
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local panel   = MorePlushies_ViewerPanel:new(
        math.floor((screenW - PANEL_W) / 2),
        math.floor((screenH - PANEL_H) / 2),
        player
    )
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    MorePlushies.Viewer._panel = panel
end