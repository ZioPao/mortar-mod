local SpottersViewerPanel = require("UI/Mortar_SpottersPanel")

local MortarUI = ISCollapsableWindow:derive("MortarUI")
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
    o.id = MortarCommon.GetAssembledID(coords)
    o.mode = MRT_COMMON.SPOT_MODE
    o.mortarInstance = MortarDataHandler.GetOrCreateInstance(coords)


    -- Spotter related stuff
    o.isSPotterReady = false
    o.isOperatorReady = false


    MortarUI.instance = o
    return o
end

function MortarUI:initialise()
    ISCollapsableWindow.initialise(self)
    local operator = getPlayer()


    if not operator:isOutside() then
        operator:Say("I don't think using it here would be a good idea...")
        self:close()
    end

    if operator:HasTrait("Deaf") then
        self.mode = MRT_COMMON.SOLO_MODE
    end



end

--------------------------------

--* Getters *--
function MortarUI:getIsOperatorReady()
    return self.isOperatorReady
end

function MortarUI:getIsSpotterReady()
    return self.isSpotterReady
end

--* Setters *--

function MortarUI:setIsOperatorReady(isOperatorReady)
    self.isOperatorReady = isOperatorReady
end

function MortarUI:setIsSpotterReady(isSpotterReady)
    self.isSpotterReady = isSpotterReady
end

-------------------------------

function MortarUI:createChildren()
    --ISCollapsableWindow.createChildren(self)

    self.panelInfo = ISRichTextPanel:new(0, 20, self:getWidth(), self:getHeight() / 4)
    self.panelInfo.autosetheight = false
    self.panelInfo.background = true
    self.panelInfo.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.panelInfo.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.panelInfo.marginTop = 20
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


    local isPlayerDeaf = getPlayer():HasTrait('Deaf')

    self.btnSwitchMode = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, 'Switch Mode', self, self.onClick)
    self.btnSwitchMode.internal = "SWITCH_MODE"
    self.btnSwitchMode:initialise()
    if isPlayerDeaf then
        self.btnSwitchMode:setEnable(false)
        self.btnSwitchMode:setTooltip("You are deaf! You can't use Spot mode")
    else
        self.btnSwitchMode:setEnable(true)
    end
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
        if self.mode == MRT_COMMON.SOLO_MODE then
            self.mortarInstance:initializeSoloShot()
        else
            self.mortarInstance:initializeSpotShot()
        end
    elseif btn.internal == 'RELOAD' then
        self.btnReload:setEnable(false)
        self.mortarInstance:reloadRound()
    elseif btn.internal == 'SET_SPOTTER' then
        if instanceof(self.openedPanel, 'ISCollapsableWindow') then
            self.openedPanel:close()
        else
            self.openedPanel = SpottersViewerPanel.Open(self:getRight(), self:getBottom() - self:getHeight(),
                self.mortarInstance)
        end
    elseif btn.internal == 'SWITCH_MODE' then
        if self.mode == MRT_COMMON.SOLO_MODE then
            self.mode = MRT_COMMON.SPOT_MODE
            --self.btnSwitchMode:setTooltip("Spot Mode")
        else
            self.mode = MRT_COMMON.SOLO_MODE
            --self.btnSwitchMode:setTooltip("Solo Mode")
        end
    elseif btn.internal == 'EXIT' then
        self:close()
    end
end

function MortarUI:updateShootButton()
    if self.mode == MRT_COMMON.SOLO_MODE then
        self.btnShoot:setEnable(self.mortarInstance:getIsReloaded())
        self.btnShoot:setTooltip(nil)
    else
        local spotterID = self.mortarInstance:getSpotterID()

        if spotterID == -1 then
            self.btnShoot:setEnable(false)
            self.btnShoot:setTooltip("You didn't set a spotter")
        else
            local isReady = self.mortarInstance:getIsReloaded() and self:getIsOperatorReady() and self:getIsSpotterReady()
            self.btnShoot:setEnable(isReady)
            if not isReady then
                self.btnShoot:setTooltip("Spotter not ready or no shell in the mortar")
            else
                self.btnShoot:setTooltip(nil)
            end
        end
    end
end

function MortarUI:updateSetSpotterButton()
    if self.mode == MRT_COMMON.SPOT_MODE then
        if self:getIsOperatorReady() then
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

function MortarUI:updateOperatorStatus(opInventory)
    -- Check if he has a radio, if it's in SPOT mode

    if self.mode == MRT_COMMON.SPOT_MODE then
        self:setIsOperatorReady(MortarCommon.CheckRadio(opInventory))
    else
        self:setIsOperatorReady(true)
    end
end

function MortarUI:updateSpotterStatus()
    local spotterID = self.mortarInstance:getSpotterID()
    if spotterID == -1 then
        -- TODO Set no spotter
        self:setIsSpotterReady(false)
    else
        -- TODO This should be run every once in a while, not constantly
        sendClientCommand(getPlayer(), MRT_COMMON.SERVER_OPERATOR_COMMAND, 'AskSpotterStatus', {spotterID = spotterID})
    end
end

function MortarUI:updateCloseButton()
    local isMidReloading = self.mortarInstance:getIsMidReloading()

    if isMidReloading then
        self.btnClose:setEnable(false)
    else
        self.btnClose:setEnable(true)
    end
end

---Updated info panel
---@param shellsAmount number
function MortarUI:updateInfoPanel(shellsAmount)
    local info = ""


    if self.mode == MRT_COMMON.SPOT_MODE then
        local spotterUsername = "-------"
        local spotterID = self.mortarInstance:getSpotterID()
        if spotterID ~= -1 then
            local spotterPl = getPlayerByOnlineID(spotterID)
            spotterUsername = spotterPl:getUsername()
        end

        local spotterInfo = " <CENTRE> <SIZE:medium> Spotter: %s <LINE> <CENTRE> Spotter Status: %s"
        spotterInfo = string.format(spotterInfo, spotterUsername, tostring(self:getIsSpotterReady()))

        info = spotterInfo .. " <LINE> "
    end


    local shellsInfo = " <CENTRE> <SIZE:medium> Shells Left: %d"
    shellsInfo = string.format(shellsInfo, shellsAmount)
    info = info .. shellsInfo

    local modeInfo = " <CENTRE> <SIZE:medium> Mode: %s"
    modeInfo = string.format(modeInfo, self.mode)
    info = info .. " <LINE> " .. modeInfo


    -- Update info panel
    if self.mortarInstance:getIsMidReloading() then
        info = "<SIZE:large> <CENTRE> <RED> RELOADING! <LINE> " .. info
    end

    self.panelInfo:setText(info)
    self.panelInfo.textDirty = true
end

function MortarUI:update()
    ISCollapsableWindow.update(self)

    if self.mortarInstance == nil then
        -- Check the server and fetch it again
        self.mortarInstance = MortarDataHandler.GetOrCreateInstance(self.coords)
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
    self:updateOperatorStatus(inv)

    -- Update spotter status
    self:updateSpotterStatus()

    -- Updates Info Panel
    self:updateInfoPanel(shellsAmount)


    -- Check if player has an active radio, then he can set the spotter
    self:updateSetSpotterButton()
    self:updateShootButton()
    self:updateReloadButton(shellsAmount)
    self:updateCloseButton()

    -- Handle the spotters panel position. It needs to stick to the main panel!
    if self.openedPanel then
        self.openedPanel:setX(self:getRight())
        self.openedPanel:setY(self:getBottom() - self:getHeight())
    end

    -- If player goes away from the mortar, close the window
    if MortarCommon.GetDistance2D(pl:getX(), pl:getY(), self.coords.x, self.coords.y) > MRT_COMMON.DIST_STEPS then
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

return MortarUI
