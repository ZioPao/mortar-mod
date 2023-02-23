--===================================--
--[[ MORTAR MOD - COMMON FUNCTIONS ]]--
--===================================--

if MortarCommonFunctions == nil then
    MortarCommonFunctions = {}
end


MortarCommonFunctions.GetDistance2D = function(x1, y1, x2, y2)
    return math.sqrt(math.abs(x2 - x1)^2 + math.abs(y2 - y1)^2)

end
MortarCommonFunctions.RollChance = function(chance)

    local r = ZombRand(1, 101)
    if r <= chance then
        return true
    end
    
    return false


end
MortarCommonFunctions.IsMortarSprite = function(spriteName)
    for _, v in pairs(MortarCommonVars.tiles) do
        if tostring(spriteName) == v then
            return true
        end
    end
    return false
end

MortarCommonFunctions.GetHighestZ = function(cx, cy)
	local cz = 8
	for i = 0, 8-1  do
		cz=cz-1
		local check = getCell():getGridSquare(cx, cy, cz )

		if check and check:isSolidFloor() then
			print(cz); print(check:isSolidFloor())
			return cz
		end
	end
end

-------------------------------------
-- Validation checks


MortarCommonFunctions.CheckRadio = function(player_inventory)
    local items = player_inventory:getItems()

    local radio
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local item_full_type = item:getFullType()

        -- not sure why instanceof didn't work, but this should be fine
        if luautils.stringStarts(item_full_type, "Radio.") then
            radio = item
            break
        end
    end

    -- Another problem, to check if a radio is turned on we need to get getDeviceData(), not isActivated
    if radio then
        local device_data = radio:getDeviceData()
        if device_data:getIsTurnedOn() then
            --print("Mortar: Radio is ready to go")
            return true
        end
    end
    return false

end


MortarCommonFunctions.IsBomberValid = function(player)
    if player:isDriving() or player:getVehicle() then return false end
    if player:HasTrait('ShortSighted')  then return false end


    if not player:isAsleep() then
        if MortarCommonFunctions.CheckRadio(player:getInventory()) then
            return true
       end
    end

    return false
end

MortarCommonFunctions.IsSpotterValid = function(player)

    -- Should check traits AND inventory
    if player:isDriving() or player:getVehicle() then return false end
    if player:HasTrait('ShortSighted')  then return false end


    if not player:isAsleep() then
        if MortarCommonFunctions.CheckRadio(player:getInventory()) then
            return true
        end
    end

    return false
end


--------------------------------
-- Various
-------------------------------
function MortarCommonFunctions.GenerateUUID()
    -- Based on Aiteron's code

    local seed = {'e','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}

    local tb = {}
    for i=1, 32 do
        table.insert(tb, seed[ZombRand(16)+1])
    end

    local sid = table.concat(tb)
    return string.format('%s-%s-%s-%s-%s', string.sub(sid, 1, 8), string.sub(sid,9,12),string.sub(sid,13,16),string.sub(sid,17,20),string.sub(sid,21,32))

end


--------------------------------------


if MortarCommonVars == nil then


    MortarCommonVars = {}
    
    MortarCommonVars.directions = {
        ["N"] = {0, -1},
        ["NE"] = {math.sqrt(2) / 2, -math.sqrt(2) / 2},
        ["E"] = {1, 0},
        ["SE"] = {math.sqrt(2) / 2, math.sqrt(2) / 2},
        ["S"] = {0, 1},
        ["SW"] = {-math.sqrt(2) / 2, math.sqrt(2) / 2},
        ["W"] = {-1, 0},
        ["NW"] = {-math.sqrt(2) / 2, -math.sqrt(2) / 2}
    }

    MortarCommonVars.tiles = {
            ["N"] = "mortar_56",
            ["NE"] = "mortar_57",
            ["E"] = "mortar_58",
            ["SE"] = "mortar_59",
            ["S"] = "mortar_60",
            ["SW"] = "mortar_61",
            ["W"] = "mortar_62",
            ["NW"] = "mortar_63",
    }

    MortarCommonVars.distMin = 12
    MortarCommonVars.distMax = 30
    MortarCommonVars.distSteps = 2
    MortarCommonVars.rad = 8

    MortarCommonVars.sounds = {
        ['MortarBlast1'] = true,
        ['MortarBlast2'] = true,
        ['MortarBlast3'] = true,
    }
    
    MortarCommonVars.globalModDataId = "MORTAR_INFO"

end