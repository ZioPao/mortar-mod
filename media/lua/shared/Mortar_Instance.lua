local MortarInstance = {}

function MortarInstance:new(operator, spotter, coords)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.operator = operator
    o.spotter = spotter
    o.coords = coords
    o.isOperatorValid = false
    o.isSpotterValid = false

    MortarInstance.current = o
    return o
end

--************************--
-- Getters
function MortarInstance:getOperator()
    return self.operator
end

function MortarInstance:getSpotter()
    return self.spotter
end

function MortarInstance:getCoords()
    return self.coords
end

-- Setters
function MortarInstance:setOperator(operator)
    self.operator = operator
end

function MortarInstance:setSpotter(spotter)
    self.spotter = spotter
end

function MortarInstance:setCoords(coords)
    self.coords = coords
end

--************************--
-- Actions

function MortarInstance:initializeShot()
    print("Mortar: Trying to fire")

    -- Check if spotter exists
    if self.spotter == nil then
        print("No spotter")
        self.operator:Say("I don't have a spotter right now")
        return
    end

    -- Checks if spotter is valid
    if self.isSpotterValid and self.isOperatorValid then
        self:executeShot()
    elseif self.isOperatorValid then
        self.operator:Say("I can't reach my spotter anymore")
    else
        -- Not even the bomber is valid
        self.operator:Say("I think I'm missing something")
    end
end

function MortarInstance:executeShot()
    self.operator:playEmote("_MortarClick")

    -- TODO Send shot to server
    sendClientCommand(self.operator, MortarCommonVars.MOD_ID, 'SendShot', {spotterID = self.spotter:getOnlineID()})


end

function MortarInstance:reload()

end


return MortarInstance