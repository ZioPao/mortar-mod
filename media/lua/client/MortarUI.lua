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
        Mortar.StartFiring(getPlayer(), getPlayer(), rad, dist)
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
    if isClient() then
        return
    end

    if MortarUI.instance == nil then
        MortarUI.instance = MortarUI:new(100, 100, 1000, 600, "Mortar UI")
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







function MortarUI:createChildren()
    ISPanel.createChildren(self)

    local shoot_btn = ISButton:new(0, 0, 80, 25, "SHOOT", self, SendStartFiringToServer)
    shoot_btn:initialise()
    self:addChild(shoot_btn)


    local exit_btn = ISButton:new(20, 20, 80, 25, "EXIT", self, self.close)
    exit_btn:initialise()
    self:addChild(exit_btn)

end


function MortarUI:close()
    Mortar.UnsetBomber()
    self:setVisible(false)
    self:removeFromUIManager()

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

    return o
end