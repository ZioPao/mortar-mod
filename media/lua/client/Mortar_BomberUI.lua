--=================================--
--[[ MORTAR MOD - CUSTOM MENU UI ]]--
--=================================--
require "ISUI/ISPanel"

MortarUI = ISPanel:derive("MortarUI")
MortarUI.instance = nil


local mortarHandlerInstance


function MortarUI:onOpenPanel(handler)

    if self.instance == nil then
        self.instance = MortarUI:new(100, 100, 150, 250, handler)
        self.instance:initialise()
        self.instance:instantiate()
    end

    self.instance:addToUIManager()
    self.instance:setVisible(true)

    return self.instance

end

function MortarUI:initialise()
    ISPanel.initialise(self)
    Events.OnTick.Add(MortarUI.CheckWeaponDistanceFromPlayer)

end

function MortarUI.CheckWeaponDistanceFromPlayer(tick)

    if mortarHandlerInstance:getBomber() == nil then
        print("Mortar Info: no bomber found anymore for the UI, exiting update")
        MortarUI:close()
        return
    end

    local bomber = mortarHandlerInstance:getBomber()

    local bomberX = bomber:getX()
    local bomberY = bomber:getY()
    --local bomberZ = bomber:getZ()


    local mortarCoordinates = mortarHandlerInstance:getTilesLocation()

    if MortarCommonFunctions.GetDistance2D(bomberX, bomberY, mortarCoordinates[1], mortarCoordinates[2]) > MortarCommonVars.distSteps then
        print("Mortar Info: player too far, destroying MortarUI")
        MortarUI:close()        -- This also unset the bomber, kinda janky
    
    end
    
    
    

end

function MortarUI:createChildren()
    ISPanel.createChildren(self)

    local shoot_btn = ISButton:new(40, 50, 80, 25, "SHOOT", self, nil)
    shoot_btn:initialise()
    shoot_btn:setEnable(false)
    self:addChild(shoot_btn)

    local reload_btn = ISButton:new(40, 100, 80, 25, "RELOAD", self, nil)
    reload_btn:initialise()
    reload_btn:setEnable(false)
    self:addChild(reload_btn)

    local exit_btn = ISButton:new(40, 150, 80, 25, "EXIT", self, self.close)
    exit_btn:initialise()
    self:addChild(exit_btn)

    -- TODO Add it later with binos
    -- local coordinates_label = ISLabel:new(100, 150, 80, "",1, 1, 1, 1, UIFont.Medium, false)
    -- coordinates_label:initialise()
    -- self:addChild(coordinates_label)

    self.shoot_btn_ref = shoot_btn
    self.reload_btn_ref = reload_btn
    --self.coordinates_label_ref = coordinates_label      -- Set a reference


end

function MortarUI:close()



    --Mortar.unsetBomber()


    -- TODO This is local only?
    --Events.OnPlayerMove.Remove(MortarRotDirection)
    --Events.OnTick.Remove(MortarUI.updateCoordinatesLabel)       -- Disable the update for coordinates

    if MortarUI.instance then
        MortarUI.instance:setVisible(false)
        MortarUI.instance:removeFromUIManager()
    
        MortarUI.instance = nil     -- Removes the reference
        MortarClientHandler.GetInstance():delete()

        
        Events.OnTick.Remove(MortarClientHandler.ValidationCheckUpdate)
        Events.OnTick.Remove(MortarUI.CheckWeaponDistanceFromPlayer)

    end

end

function MortarUI:update()
    ISPanel.update(self)

    if MortarUI.instance ~= nil then
        if MortarUI.instance.shoot_btn_ref ~= nil and MortarUI.instance.reload_btn_ref ~= nil then

            if mortarHandlerInstance:isReadyToShoot() then
                --print("Mortar: ready to shoot")
                MortarUI.instance.shoot_btn_ref:setEnable(true)
                MortarUI.instance.shoot_btn_ref:setOnClick(function()
                    mortarHandlerInstance:tryStartFiring()
                end)
                MortarUI.instance.reload_btn_ref:setEnable(false)
                MortarUI.instance.reload_btn_ref:setOnClick(nil)

            else
                --print("Mortar: not ready to shoot")
                MortarUI.instance.shoot_btn_ref:setEnable(false)
                MortarUI.instance.shoot_btn_ref:setOnClick(nil)
                MortarUI.instance.reload_btn_ref:setEnable(true)
                MortarUI.instance.reload_btn_ref:setOnClick(function()
                    -- FIXME Mostly a workaround, we should add something like a loading icon
                    MortarUI.instance.reload_btn_ref:setEnable(false)
                    MortarUI.instance.reload_btn_ref:setOnClick(nil)
                    mortarHandlerInstance:reloadRound()

                end)
            end
        end
    end
end

function MortarUI:new(x, y, width, height, mortarHandler)

    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true
    o.panelTitle = "Mortar Operator Menu"


    mortarHandlerInstance = mortarHandler
    o.coordinates_label_ref = nil

    return o
end