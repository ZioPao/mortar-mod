local MODES = { 'SOLO', 'SPOT' }


--local MortarClientHandler = require("Mortar_ClientHandler")
local MortarData = require("Mortar_ClientData")

-- TODO Make it local

MortarUI = ISCollapsableWindow:derive("MortarUI")
MortarUI.instance = nil

function MortarUI.Open(coords)
    -------------------------
    -- MortarUI.Open({x=getPlayer():getX(), y = getPlayer():getY(), z = getPlayer():getZ()})

    ---------------
    if MortarUI.instance then
        MortarUI.instance:close()
    end

    -- TODO Should be in the middle of the screen
    local pnl = MortarUI:new(50, 200, 400, 500, coords)
    pnl:initialise()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end

function MortarUI:new(x, y, width, height, coords)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.resizable = false

    o.width = width
    o.height = height

    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.moveWithMouse = true


    -- TODO Instead of a UUID or crap like that, fetch it from the synced table with a combination of the coordinates.
    -- X .. Y .. Z or something like this.
    o.coords = coords
    o.mode = 'SPOT'
    o.mortarInstance = MortarData.GetOrCreateInstance(coords)

    MortarUI.instance = o
    return o
end

function MortarUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.panelInfo = ISRichTextPanel:new(0, 20, self:getWidth(), self:getHeight() / 4)
    self.panelInfo.autosetheight = false
    self.panelInfo.background = true
    self.panelInfo.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.panelInfo.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.panelInfo.marginTop = self.panelInfo:getHeight() / 2
    self.panelInfo:initialise()
    self.panelInfo:paginate()
    self:addChild(self.panelInfo)

    -----------------------

    local xPadding = 10
    local yOffset = self.panelInfo:getBottom() + 10

    local btnWidth = self:getWidth() - xPadding * 2
    local btnHeight = 25

    self.btnShoot = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, 'Shoot', self, self.onClick)
    self.btnShoot.internal = "SHOOT"
    self.btnShoot:initialise()
    self.btnShoot:setEnable(false)
    self:addChild(self.btnShoot)

    yOffset = yOffset + self.btnShoot:getHeight() + 10

    self.btnReload = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, 'Reload', self, self.onClick)
    self.btnReload.internal = "RELOAD"
    self.btnReload:initialise()
    self.btnReload:setEnable(false)
    self:addChild(self.btnReload)

    yOffset = yOffset + self.btnReload:getHeight() + 10

    self.btnSetSpotter = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, 'Set spotter', self, self.onClick)
    self.btnSetSpotter.internal = "SET_SPOTTER"
    self.btnSetSpotter:initialise()
    self.btnSetSpotter:setEnable(true)
    self:addChild(self.btnSetSpotter)

    yOffset = yOffset + self.btnSetSpotter:getHeight() + 10

    self.btnSwitchMode = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, 'Switch Mode', self, self.onClick)
    self.btnSwitchMode.internal = "SWITCH_MODE"
    self.btnSwitchMode:initialise()
    self.btnSwitchMode:setTooltip("Spot Mode")
    self.btnSwitchMode:setEnable(true)
    self:addChild(self.btnSwitchMode)


    self.btnClose = ISButton:new(xPadding, self:getHeight() - btnHeight - 10, btnWidth, btnHeight, 'Close', self,
        self.onClick)
    self.btnClose.internal = "EXIT"
    self.btnClose:initialise()
    self:addChild(self.btnClose)

    -- TODO Add it later with binos
    -- local coordinates_label = ISLabel:new(100, 150, 80, "",1, 1, 1, 1, UIFont.Medium, false)
    -- coordinates_label:initialise()
    -- self:addChild(coordinates_label)
end

function MortarUI:onClick(btn)
    if btn.internal == 'SHOOT' then
        self.mortarInstance:initializeShot()
    elseif btn.internal == 'RELOAD' then
        self.btnReload:setEnable(false)
        self.mortarInstance:reloadRound()
    elseif btn.internal == 'SET_SPOTTER' then
        self.openedPanel = SpottersViewerPanel.Open(self:getRight(), self:getBottom() - self:getHeight())
    elseif btn.internal == 'SWITCH_MODE' then
        if self.mode == 'SOLO' then
            self.mode = 'SPOT'
            self.btnSwitchMode:setTooltip("Spot Mode")
        else
            self.mode = 'SOLO'
            self.btnSwitchMode:setTooltip("Solo Mode")
        end
    elseif btn.internal == 'EXIT' then
        self:close()
    end
end

function MortarUI:updateShootButton()
    if self.mode == 'SOLO' then
        if self.mortarInstance:getIsReloaded() then
            self.btnShoot:setEnable(true)
            self.btnShoot:setTooltip("Ready to shoot")
        end
    else
        local spotterID = self.mortarInstance:getSpotterID()
        local isReadyToShoot = self.mortarInstance:isReadyToShoot()

        if spotterID == -1 then
            self.btnShoot:setEnable(false)
            self.btnShoot:setTooltip("You didn't set a spotter")
        else
            self.btnShoot:setEnable(isReadyToShoot)
        end
    end
end

function MortarUI:updateSetSpotterButton(plInv)
    if self.mode == 'SPOT' then
        if MortarCommonFunctions.CheckRadio(plInv) then
            self.btnSetSpotter:setEnable(true)
            self.btnSetSpotter:setTooltip("Select the spotter. They must be in your same faction")
        else
            self.btnSetSpotter:setEnable(false)
            self.btnSetSpotter:setTooltip("You don't have a radio to comunicate with spotters")
        end
    else
        self.btnSetSpotter:setEnable(false)
        self.btnSetSpotter:setTooltip("Solo mode")
    end
end

function MortarUI:updateReloadButton(shellsAmount)
    local isReloaded = self.mortarInstance:getIsReloaded()
    local isMidReloading = self.mortarInstance:getIsMidReloading()
    local isShellInInventory = shellsAmount > 0

    if isMidReloading then
        self.btnReload:setEnable(false)
        self.btnReload:setTooltip("Currently reloading")
    elseif not isReloaded and isShellInInventory then
        self.btnReload:setEnable(true)
        self.btnReload:setTooltip("You've got %d shells in your inventory.")
    elseif not isReloaded and not isShellInInventory then
        self.btnReload:setEnable(false)
        self.btnReload:setTooltip(" <RED> You've got no shells left!")
    else
        self.btnReload:setEnable(false)
        self.btnReload:setTooltip(" <GREEN> Shell is in the mortar")
    end
end

function MortarUI:update()
    ISCollapsableWindow.update(self)

    if self.mortarInstance == nil then
        -- Check the server and fetch it again
        self.mortarInstance = MortarData.GetOrCreateInstance(self.coords)
        self.btnSetSpotter:setEnable(false)
        self.btnShoot:setEnable(false)
        self.btnReload:setEnable(false)

        self.panelInfo:setText(" <CENTRE> <RED> MORTAR NOT AVAILABLE")
        self.panelInfo.textDirty = true
        return
    end

    -- Setup some various variables that we're gonna use later
    local pl = getPlayer()
    local plID = pl:getOnlineID()
    local inv = pl:getInventory()
    local shells = inv:FindAll('Mortar.MortarRound')
    local shellsAmount = shells:size()

    -- Set operator again
    self.mortarInstance:setOperator(plID)

    -- Update info panel
    local info = string.format(" <CENTRE> Operator: %s \n <CENTRE> Shells Left: %d", pl:getUsername(), shellsAmount)
    self.panelInfo:setText(info)
    self.panelInfo.textDirty = true

    -- Check if player has an active radio, then he can set the spotter
    self:updateSetSpotterButton(inv)
    self:updateShootButton()
    self:updateReloadButton(shellsAmount)

    -- Handle the spotters panel position. It needs to stick to the main panel!
    if self.openedPanel then
        self.openedPanel:setX(self:getRight())
        self.openedPanel:setY(self:getBottom() - self:getHeight())
    end


    -- If player goes away from the mortar, close the window
    if MortarCommonFunctions.GetDistance2D(pl:getX(), pl:getY(), self.coords.x, self.coords.y) > MortarCommonVars.distSteps then
        self:close()
    end
end

function MortarUI:setVisible(visible)
    self.javaObject:setVisible(visible)
end

function MortarUI:close()
    if self.openedPanel then
        self.openedPanel:close()
    end
    self:removeFromUIManager()
    ISCollapsableWindow.close(self)
end

--return MortarUI
