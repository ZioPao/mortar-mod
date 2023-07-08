MortarCommon = {}

function MortarCommon.GetHitCoords(pl)
    local directions = MRT_COMMON.DIRECTIONS[tostring(pl:getDir())]
    local dist = ZombRand(MRT_COMMON.DIST_MIN, MRT_COMMON.DIST_MAX)
    local hitCoords = { x = math.floor(pl:getX() + (directions[1] * dist)),
        y = math.floor(pl:getY() + (directions[2] * dist)) }
    return hitCoords
end

---Check if the distance between spotter and operator is acceptable
---@param player1 IsoPlayer
---@param player2 IsoPlayer
---@return boolean
function MortarCommon.CheckDistance(player1, player2)
    return player1:getDistanceSq(player2) < MRT_COMMON.WALKIE_TALKIE_RANGE
end

---Assemble and returns an ID for the mortar based on its coords
---@param coords table x,y,z
---@return string
function MortarCommon.GetAssembledID(coords)
    return tostring(coords.x) .. tostring(coords.y) .. tostring(coords.z)
end

MortarCommon.GetDistance2D = function(x1, y1, x2, y2)
    return math.sqrt(math.abs(x2 - x1) ^ 2 + math.abs(y2 - y1) ^ 2)
end

MortarCommon.RollChance = function(chance)
    local r = ZombRand(1, 101)
    if r <= chance then
        return true
    end

    return false
end

MortarCommon.IsMortarSprite = function(spriteName)
    for _, v in pairs(MRT_COMMON.tiles) do
        if tostring(spriteName) == v then
            return true
        end
    end
    return false
end

MortarCommon.GetHighestZ = function(cx, cy)
    local cz = 8
    for i = 0, 8 - 1 do
        cz = cz - 1
        local check = getCell():getGridSquare(cx, cy, cz)

        if check and check:isSolidFloor() then
            print(cz); print(check:isSolidFloor())
            return cz
        end
    end
end

MortarCommon.DestroyTile = function(tile)
    if isClient() then
        sledgeDestroy(tile)
    else
        tile:getSquare():transmitRemoveItemFromSquare(tile)
    end
end
-------------------------------------
-- Validation checks

---Check if player has an active walkie talkie
---@param playerInv ItemContainer
---@return boolean
MortarCommon.CheckRadio = function(playerInv)
    local items = playerInv:getItems()

    local radio
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local itemFullType = item:getFullType()

        -- not sure why instanceof didn't work, but this should be fine
        if luautils.stringStarts(itemFullType, "Radio.") then
            radio = item
            break
        end
    end

    -- Another problem, to check if a radio is turned on we need to get getDeviceData(), not isActivated
    if radio then
        local deviceData = radio:getDeviceData()
        return deviceData:getIsTurnedOn()
    end
    return false
end


MortarCommon.IsBomberValid = function(player)
    if player:isDriving() or player:getVehicle() then return false end
    if player:HasTrait('ShortSighted') then return false end
    if not player:isOutside() then return false end
    if player:HasTrait('Deaf') then return false end

    if not player:isAsleep() then
        if MortarCommon.CheckRadio(player:getInventory()) then
            return true
        end
    end

    return false
end

MortarCommon.IsSpotterValid = function(player)
    -- Should check traits AND inventory
    if player:isDriving() or player:getVehicle() then return false end
    if player:HasTrait('ShortSighted') then return false end


    if not player:isAsleep() then
        if MortarCommon.CheckRadio(player:getInventory()) then
            return true
        end
    end

    return false
end

--- Check if both the players are in the same faction
---@param pl1 IsoPlayer
---@param pl2 IsoPlayer
MortarCommon.ArePlayersInSameFaction = function(pl1, pl2)
    local factions = Faction:getFactions()

    local pl1Username = pl1:getUsername()
    local pl2Username = pl2:getUsername()

    for i = 0, factions:size() - 1 do
        local faction = factions:get(i)

        if faction:isMember(pl1Username) or faction:isOwner(pl1Username) then
            if faction:isMember(pl2Username) or faction:isOwner(pl2Username) then
                return true
            end
        end
    end

    return false
end


--------------------------------------

MRT_COMMON = {

    DIRECTIONS = {
        ["N"] = { 0, -1 },
        ["NE"] = { math.sqrt(2) / 2, -math.sqrt(2) / 2 },
        ["E"] = { 1, 0 },
        ["SE"] = { math.sqrt(2) / 2, math.sqrt(2) / 2 },
        ["S"] = { 0, 1 },
        ["SW"] = { -math.sqrt(2) / 2, math.sqrt(2) / 2 },
        ["W"] = { -1, 0 },
        ["NW"] = { -math.sqrt(2) / 2, -math.sqrt(2) / 2 }
    },

    TILES = {
        ["N"] = "mortar_56",
        ["NE"] = "mortar_57",
        ["E"] = "mortar_58",
        ["SE"] = "mortar_59",
        ["S"] = "mortar_60",
        ["SW"] = "mortar_61",
        ["W"] = "mortar_62",
        ["NW"] = "mortar_63",
    },

    BURST_TILES = {
        "mortarburst_0",
        "mortarburst_1",
        "mortarburst_2",
        "mortarburst_3",
        "mortarburst_4",
        "mortarburst_5",
        "mortarburst_6",
        "mortarburst_7",
        "mortarburst_8",
        "mortarburst_9",
        "mortarburst_10",
        "mortarburst_11",
        "mortarburst_12",
        "mortarburst_13",
        "mortarburst_14"
    },

    DIST_MIN = 12,
    DIST_MAX = 30,
    DIST_STEPS = 2,
    RAD = 8,

    WALKIE_TALKIE_RANGE = 30000,        -- it's not in sq... not sure why

    SOUNDS = {
        ['MortarBlast1'] = true,
        ['MortarBlast2'] = true,
        ['MortarBlast3'] = true,
    },


    SOLO_MODE = 'SOLO',
    SPOT_MODE = 'SPOT',

    GLOBAL_MOD_DATA = 'Mortar-Data',

    SPOTTER_COMMAND = 'Mortar-Spotter',
    OPERATOR_COMMAND = 'Mortar-Operator',
    COMMON_COMMAND = 'Mortar-Common',

    SERVER_COMMON_COMMAND = 'Mortar-Common-Server',
    SERVER_SPOTTER_COMMAND = 'Mortar-Spotter-Server',
    SERVER_OPERATOR_COMMAND = 'Mortar-Operator-Server',


}