--=========================================--
--[[ MORTAR MOD - BOMBER\SPOTTER HANDLER ]]
                                            --
--=========================================--







-- TODO Rethink this crap


local MortarClientHandler = {}
local instance -- Single instance of Clienthandler


if MortarSyncedWeapons == nil then
    MortarSyncedWeapons = {}
end


------------------------------------
function MortarClientHandler:new()
    print("Mortar: instancing new client handler")

    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.bomber = nil
    o.spotter = nil

    o.weaponInstanceId = nil
    o.tileX = nil
    o.tileY = nil
    o.tileZ = nil

    o.isBomberValid = false
    o.isSpotterValid = false

    o.coordinates = nil
    instance = o

    return o
end

function MortarClientHandler:instantiate(player, weaponInstance)
    self.bomber = player -- Set the bomber
    self.weaponInstance = weaponInstance

    Events.OnTick.Add(MortarClientHandler.ValidationCheckUpdate)
end

function MortarClientHandler:delete()
    print("MortarClientHandler: destroying instance")
    Events.OnTick.Remove(MortarClientHandler.ValidationCheckUpdate)

    if self.spotter then
        sendClientCommand(getPlayer(), 'Mortar', 'sendResetSpotterClientHandler', { playerId = self.spotter:getOnlineID() })
    end


    local tbl = {}
    setmetatable(tbl, nil)


    self.bomber = nil
    self.spotter = nil
    self.tileX = nil
    self.tileY = nil
    self.tileZ = nil

    self.weaponInstanceId = nil

    self.isBomberValid = false
    self.isSpotterValid = false

    self.coordinates = nil




    instance = nil
end

--- Get or creates a new instance
---@return MortarClientHandler
function MortarClientHandler.GetInstance()
    if instance then
        return instance
    else
        return MortarClientHandler:new()
    end
end

------------------------------------
-- Setter\Getters

function MortarClientHandler:setBomber(player)
    self.bomber = player
end

function MortarClientHandler:getBomber()
    return self.bomber
end

function MortarClientHandler:setSpotter(player)
    self.spotter = player
end

function MortarClientHandler:getSpotter()
    return self.spotter
end

function MortarClientHandler:setCoordinates(x, y)
    self.coordinates = { x, y }
end

function MortarClientHandler:setWeaponInstance(weaponInstance)
    self.weaponInstance = weaponInstance
end

function MortarClientHandler:getTilesLocation()
    return { self.tileX, self.tileY, self.tileZ }
end

-----------------------------------------
-- Validation

function MortarClientHandler:setIsBomberValid(check)
    self.isBomberValid = check
end

function MortarClientHandler:setIsSpotterValid(check)
    self.isSpotterValid = check
end

function MortarClientHandler.ValidationCheckUpdate()
    -- Agnostic, we don't care if it's the bomber or the spotter

    --print("Mortar: checking validation status")

    local currentInstance = MortarClientHandler.GetInstance()


    local player = getPlayer()

    if currentInstance:getBomber() ~= nil and currentInstance:getSpotter() ~= nil then
        sendClientCommand(player, 'Mortar', 'checkValidationStatus', {
            bomberId = currentInstance:getBomber():getOnlineID(),
            spotterId = currentInstance:getSpotter():getOnlineID()
        })
    end
end

function MortarClientHandler:isAvailable()
    if self.bomber == nil then
        return true
    end

    return false
end

function MortarClientHandler.SpawnDebris(sq)
    local dug = IsoObject.new(sq, "mortar_" .. ZombRand(63) - 8, "", false)
    sq:AddTileObject(dug)
    if isClient() then
        dug:transmitCompleteItemToServer()
    end
end

MortarClientHandler.explosionsTable = {
    count = 2,
    tickDiff = 6, -- TODO Make this a constant somewhere and make a func to "recreate" this table instead of just recreating it manually
    objects = {}
}


function MortarClientHandler.SpawnExplosionTile(sq)
    -- Generate a NEW tile
    local explosionObject = IsoObject.new(sq, MortarCommonVars.burstTiles[1], "", false)
    sq:AddTileObject(explosionObject)
    if isClient() then
        explosionObject:transmitCompleteItemToServer()
    end

    -- TODO This is not working ocrrectly, only one object gets added
    table.insert(MortarClientHandler.explosionsTable.objects, explosionObject)
end

function MortarClientHandler.UpdateExplosionTiles(_)
    MortarClientHandler.explosionsTable.tickDiff = MortarClientHandler.explosionsTable.tickDiff - 1
    local count = MortarClientHandler.explosionsTable.count


    if MortarClientHandler.explosionsTable.tickDiff <= 0 then
        for _, v in pairs(MortarClientHandler.explosionsTable.objects) do
            if count > 15 then
                MortarCommonFunctions.DestroyTile(v) -- FIXME Doesn't seem to work
            else
                --print("MortarInfo: updating sprite for explosion, count " .. tostring(count))
                local newTile = MortarCommonVars.burstTiles[count]
                --print(newTile)

                v:setSprite(newTile)
                v:getSprite():setName(newTile)

                v:transmitUpdatedSpriteToServer()
                v:transmitUpdatedSpriteToClients()
            end
        end
        -- Update count and reset tickDiff
        MortarClientHandler.explosionsTable.count = count + 1
        MortarClientHandler.explosionsTable.tickDiff = 6
    end


    if count > 15 then
        Events.OnTick.Remove(MortarClientHandler.UpdateExplosionTiles)

        -- Reset table
        MortarClientHandler.explosionsTable = {
            count = 2,
            tickDiff = 6,
            objects = {}
        }
    end
end

function TestMortarInstances()
    for uuid, weaponInstance in pairs(MortarSyncedWeapons) do
        print(uuid)
    end
end
