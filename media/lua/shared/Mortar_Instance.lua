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

function MortarInstance:shoot()

end

function MortarInstance:reload()

end


return MortarInstance