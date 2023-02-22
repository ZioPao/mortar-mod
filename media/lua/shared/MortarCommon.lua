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



MortarCommonFunctions.isMortarSprite = function(sprite_name)
    for _, v in pairs(Mortartileobj) do 
        if tostring(sprite_name) == v then 	
            return true
        end
    end 
    return false
end



--------------------------------------


if MortarCommonVars == nil then

    MortarCommonVars = {
        directions = {
            ["N"] = {0, -1},
            ["NE"] = {math.sqrt(2) / 2, -math.sqrt(2) / 2},
            ["E"] = {1, 0},
            ["SE"] = {math.sqrt(2) / 2, math.sqrt(2) / 2},
            ["S"] = {0, 1},
            ["SW"] = {-math.sqrt(2) / 2, math.sqrt(2) / 2},
            ["W"] = {-1, 0},
            ["NW"] = {-math.sqrt(2) / 2, -math.sqrt(2) / 2}
        },
        distMin = 4,
        distMax = 12,
        distSteps = 2,
        rad = 8,
    }
end