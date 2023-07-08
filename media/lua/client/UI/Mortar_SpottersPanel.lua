require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"


--**************--
-- Various utilities
local function FetchPlayers()
    local players
    if isClient() then
        players = getOnlinePlayers()
    else
        players = ArrayList.new()
        players:add(getPlayer())
    end

    return players
end

--*****************

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local ENTRY_HGT = FONT_HGT_MEDIUM + 2 * 2

local SpottersViewerPanel = ISCollapsableWindow:derive("SpottersViewerPanel")

local isOpen = false

function SpottersViewerPanel.Open(x, y, instance)
    if isOpen then
        SpottersViewerPanel.instance:close()
        return
    end

    local modal = SpottersViewerPanel:new(x, y, 350, 500)
    modal:initialise()
    modal:addToUIManager()
    modal:setMortarInstance(instance)
    modal.instance:setKeyboardFocus()
    isOpen = true


    return modal
end

function SpottersViewerPanel:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
    o.width = width
    o.height = height
    o.resizable = false
    o.moveWithMouse = false
    SpottersViewerPanel.instance = o

    return o
end


function SpottersViewerPanel:setMortarInstance(instance)
    self.mortarInstance = instance
end

function SpottersViewerPanel:initialise()
    local top = 50

    self.panel = ISTabPanel:new(10, top, self.width - 10 * 2, self.height + top - 10)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.target = self
    self.panel.equalTabWidth = false
    self.panel.tabTransparency = 0
    self.panel.tabHeight = 0
    self:addChild(self.panel)


    self.mainCategory = SpottersScrollingTable:new(0, 0, self.panel.width, self.panel.height, self)
    self.mainCategory:initialise()
    self.panel:addView("Players", self.mainCategory)
    self.panel:activateView("Players")

    local players = FetchPlayers()
    self.mainCategory:initList(players)
end

function SpottersViewerPanel:prerender()
    local z = 20
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    local title = "TEST"
    self:drawText(title, self.width / 2 - (getTextManager():MeasureStringX(UIFont.Medium, title) / 2), z, 1, 1, 1, 1,
        UIFont.Medium)
end

function SpottersViewerPanel:onClick(button)
    -- todo use double click
end

function SpottersViewerPanel:setKeyboardFocus()
    local view = self.panel:getActiveView()
    if not view then return end
    Core.UnfocusActiveTextEntryBox()
    --view.filterWidgetMap.Type:focus()
end

function SpottersViewerPanel:update()
    ISCollapsableWindow.update(self)
    local selection = self.mainCategory.datas.selected
end

function SpottersViewerPanel:close()
    isOpen = false
    self:setVisible(false)
    self:removeFromUIManager()
end

--************************************************************************--


SpottersScrollingTable = ISPanel:derive("SpottersScrollingTable")

function SpottersScrollingTable:new(x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)

    o.listHeaderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.3 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.totalResult = 0
    o.viewer = viewer
    SpottersScrollingTable.instance = o
    return o
end

function SpottersScrollingTable:createChildren()
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local bottomHgt = 5 + FONT_HGT_SMALL * 2 + 5 + btnHgt + 20 + FONT_HGT_LARGE + HEADER_HGT + ENTRY_HGT

    self.datas = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - bottomHgt + 10)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas:setOnMouseDoubleClick(self, SpottersScrollingTable.selectSpotter)
    self.datas.drawBorder = true
    self.datas:addColumn("", 0)
    self:addChild(self.datas)
end

function SpottersScrollingTable:initList(module)
    self.datas:clear()
    local currPlayer = getPlayer()
    for i = 0, module:size() - 1 do
        local pl = module:get(i)
        local username = pl:getUsername()
        if pl ~= currPlayer and MortarCommon.ArePlayersInSameFaction(currPlayer, pl) then
            self.datas:addItem(username, pl)
        end
    end
end

function SpottersScrollingTable:selectSpotter(pl)
    self.viewer.mortarInstance:setSpotter(pl:getOnlineID())
end

function SpottersScrollingTable:update()
    self.datas.doDrawItem = self.drawDatas
end

function SpottersScrollingTable:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    local a = 0.9

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5)
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    local xOffset = 10
    self:drawText(item.text, xOffset, y + 4, 1, 1, 1, a, self.font)
    return y + self.itemheight
end

return SpottersViewerPanel
