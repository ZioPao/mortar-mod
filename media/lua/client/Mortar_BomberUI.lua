--=================================--
--[[ MORTAR MOD - CUSTOM MENU UI ]]--
--=================================--

MortarUI = ISCollapsableWindow:derive("MortarUI")
MortarUI.instance = nil

function MortarUI:new(x, y, width, height, mortarInstance)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.width = width
    o.height = height

    o.resizable = false

    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.moveWithMouse = true
    o.mortarInstance = mortarInstance

    MortarUI.instance = o
    return o
end

function MortarUI:createChildren()
    local xPadding = 10
    local yOffset = 10

    local btnWidth = self:getWidth() - xPadding*2
    local btnHeight = 25

    self.btnShoot = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, 'SHOOT', self, self.onClick)
    self.btnShoot:initialise()
    self.btnShoot:setEnable(false)
    self:addChild(self.btnShoot)

    yOffset = yOffset + self.btnShoot:getHeight()

    self.btnReload = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, 'RELOAD', self, self.onClick )
    self.btnReload:initialise()
    self.btnReload:setEnable(false)
    self:addChild(self.btnReload)


    self.btnClose = ISButton:new(xPadding, self:getBottom() + 10, btnWidth, btnHeight, 'EXIT', self, self.onClick)
    self.btnClose:initialise()
    self:addChild(self.btnClose)

    -- TODO Add it later with binos
    -- local coordinates_label = ISLabel:new(100, 150, 80, "",1, 1, 1, 1, UIFont.Medium, false)
    -- coordinates_label:initialise()
    -- self:addChild(coordinates_label)


end

function MortarUI:onClick(btn)
    if btn.internal == 'SHOOT' then
        self.mortarInstance:tryStartFiring()
    elseif btn.internal == 'RELOAD' then
        self.mortarInstance:reloadRound()
    elseif btn.internal == 'EXIT' then
        self:close()
    end

end

function MortarUI:update()

    local isReadyToShoot = self.mortarInstance:isReadyToShoot()

    self.btnShoot:setEnable(isReadyToShoot)
    self.btnReload:setEnable(not isReadyToShoot)


    -----------------
    -- Check distance from other players
    local bomber = self.mortarInstance:getBomber()
    if self.bomber == nil then self:close() end

    local bomberX = bomber:getX()
    local bomberY = bomber:getY()
    --local bomberZ = bomber:getZ()


    local mortarCoordinates = self.mortarInstance:getTilesLocation()

    if MortarCommonFunctions.GetDistance2D(bomberX, bomberY, mortarCoordinates[1], mortarCoordinates[2]) > MortarCommonVars.distSteps then
        print("Mortar Info: player too far, closing MortarUI")
        MortarUI:close()        -- This also unset the bomber, kinda janky
    
    end
end

function MortarUI:setVisible(visible)
    self.javaObject:setVisible(visible)
end

function MortarUI.OnOpenPanel(mortarInstance)

    if MortarUI.instance then
        MortarUI.instance:close()
    end

    -- TODO Should be in the middle of the screen
    local pnl = MortarUI:new(50, 200, 400, 700, mortarInstance)
    pnl:initialise()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end

