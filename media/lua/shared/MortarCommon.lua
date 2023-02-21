--===================================--
--[[ MORTAR MOD - COMMON FUNCTIONS ]]--
--===================================--

if MortarCommonFunctions == nil then
    MortarCommonFunctions = {}
end


MortarCommonFunctions.getDistance2D = function(x1, y1, x2, y2)
    return math.sqrt(math.abs(x2 - x1)^2 + math.abs(y2 - y1)^2)

end

MortarCommonFunctions.roll = function(chance)

    local r = ZombRand(1, 101)
    if r <= chance then
        return true
    end
    
    return false


end
