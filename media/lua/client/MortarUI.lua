--==================================--
--[[ MORTAR MOD - CUSTOM MENU UI--]]--
--==================================--

require "ISUI/ISPanel"

MortarUI = ISPanel:derive("MortarUI")
MortarUI.instance = nil


local SendStartFiringToServer = function(_)
    --- TODO ONLY FOR DEBUG, DELETE ME

    ---------------------------
    if not isServer() and not isClient() then
        Mortar.spotter = getPlayer()
        print(" SP DEBUG THING")
        local rad = 8
        local dist = 30
        Mortar.startFiring(getPlayer(), getPlayer(), rad, dist)
        return
    end
    ---------------------------

    if Mortar.spotter ~= nil then
        local op_id = getPlayer():getOnlineID()
        local spotter_id = Mortar.spotter:getOnlineID()
        sendClientCommand(getPlayer(), "Mortar", "AcceptMortarShot", {operator = op_id, spotter = spotter_id})


    else
        print("Can't send command, no spotter")
    end

end





function MortarUI.OnOpenPanel()

    if MortarUI.instance == nil then
        MortarUI.instance = MortarUI:new(100, 100, 250, 250, "Mortar UI")
        MortarUI.instance:initialise()
        MortarUI.instance:instantiate()
    end

    MortarUI.instance:addToUIManager()
    MortarUI.instance:setVisible(true)

    return MortarUI.instance

end
function MortarUI:initialise()
    ISPanel.initialise(self)
end
function MortarUI:UpdateCoordinatesLabel()


    if Mortar.direct_coordinates ~= nil then

        local test = Mortar.direct_coordinates


        local coords = "X: " .. tostring(test[1]) .. ", Y: " .. tostring(test[2])

        if MortarUI.instance.coordinates_label_ref ~= nil then
            MortarUI.instance.coordinates_label_ref:setName(coords)

        else
            print("Mortar: no reference to coordinates label...")
        end
    end

end
function MortarUI:createChildren()
    ISPanel.createChildren(self)

    local shoot_btn = ISButton:new(100, 50, 80, 25, "SHOOT", self, SendStartFiringToServer)
    shoot_btn:initialise()
    self:addChild(shoot_btn)

    local exit_btn = ISButton:new(100, 100, 80, 25, "EXIT", self, self.close)
    exit_btn:initialise()
    self:addChild(exit_btn)

    local coordinates_label = ISLabel:new(100, 150, 80, "",1, 1, 1, 1, UIFont.Medium, false)
    coordinates_label:initialise()
    self:addChild(coordinates_label)

    self.coordinates_label_ref = coordinates_label      -- Set a reference

    Events.OnTick.Add(MortarUI.UpdateCoordinatesLabel)



end
function MortarUI:close()
    Mortar.unsetBomber()
    Events.OnTick.Remove(MortarUI.UpdateCoordinatesLabel)       -- Disable the update for coordinates
    MortarUI.instance:setVisible(false)
    MortarUI.instance:removeFromUIManager()

    MortarUI.instance = nil     -- Removes the reference
end
function MortarUI:update()
    ISPanel.update(self)
end
function MortarUI:new(x, y, width, height)

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
    o.panelTitle = title

    o.coordinates_label_ref = nil

    return o
end