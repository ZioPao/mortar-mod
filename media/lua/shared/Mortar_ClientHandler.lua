--=========================================--
--[[ MORTAR MOD - BOMBER\SPOTTER HANDLER ]]--
--=========================================--

-- List of todos
-- TODO 1) we need to consider safehouses
-- TODO 2) fire spread thing to safehouses
-- TODO 3) Tweak distmin distMax
-- TODO 4) Add BurstHandler


if MortarClientHandler == nil then
    MortarClientHandler = {}
end

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
    MortarClientHandler.instance = o

    return o
end

function MortarClientHandler:instantiate(player, weaponInstance)

    self.bomber = player      -- Set the bomber
    self.weaponInstance = weaponInstance

    Events.OnTick.Add(MortarClientHandler.ValidationCheckUpdate)

end


function MortarClientHandler:delete()

    print("MortarClientHandler: destroying instance")
    Events.OnTick.Remove(MortarClientHandler.ValidationCheckUpdate)

    if self.spotter then
        sendClientCommand(getPlayer(), 'Mortar', 'sendResetSpotterClientHandler', {playerId = self.spotter:getOnlineID()})
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




    MortarClientHandler.instance = nil
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

function MortarClientHandler:setCoordinates(x,y)
    self.coordinates = {x,y}
end

function MortarClientHandler:setWeaponInstance(weaponInstance)
    self.weaponInstance = weaponInstance
end

function MortarClientHandler:getTilesLocation()

    return {self.tileX, self.tileY, self.tileZ}

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
    local player = getPlayer()

    if MortarClientHandler:getBomber() ~= nil and MortarClientHandler:getSpotter() ~= nil then
        sendClientCommand(player, 'Mortar', 'checkValidationStatus', {
            bomberId = MortarClientHandler:getBomber():getOnlineID(),
            spotterId = MortarClientHandler:getSpotter():getOnlineID()
        })
    end
end

function MortarClientHandler:isAvailable()

    if self.bomber == nil then
        return true
    end

    return false

end




-----------------------------------------
-- Weapon instance handler

function MortarClientHandler.UpdateWeaponInstances()

    local modData = ModData.get(MortarCommonVars.globalModDataId)

    if modData ~= nil then
        MortarSyncedWeapons = modData["instances"]
    end



end

function MortarClientHandler.onReceive(key, modData)
    if modData then
        ModData.remove(key)
        ModData.add(key, modData)
    end
end
Events.OnReceiveGlobalModData.Add(MortarClientHandler.onReceive)

function MortarClientHandler.onConnect()
    ModData.request(MortarCommonVars.globalModDataId)
end
Events.OnConnected.Add(MortarClientHandler.onConnect)


function MortarClientHandler.SetWeaponInstance(obj)

    if MortarSyncedWeapons == nil then
        print("Mortar Debug: No mortar synced weapons")
        return
    end

    local x = obj:getX()
    local y = obj:getY()
    local z = obj:getZ()

    for _, v in pairs(MortarSyncedWeapons) do
        for uuid, instance in pairs(v) do
            if instance.tileX == x and instance.tileY == y and instance.tileZ == z then
                MortarClientHandler.weaponInstanceId = uuid
                MortarClientHandler.tileX = x
                MortarClientHandler.tileY = y
                MortarClientHandler.tileZ = z
                return v
            end
            

        end

 
    end

    return nil

end



Events.OnTick.Add(MortarClientHandler.UpdateWeaponInstances)




------------------------------------------
-- Shooting

--- Called from bomber, will send notification to spotter to execute the code
function MortarClientHandler:tryStartFiring()
    print("Mortar: Trying to fire")

    -- Check if spotter exists
    if self.spotter == nil then
        print("No spotter")
        self.bomber:Say("I don't have a spotter right now")
        return
    end

    -- Checks if spotter is valid
    if self.isSpotterValid and self.isBomberValid then
        MortarClientHandler:executeStartFiring()
    elseif self.isBomberValid then
        self.bomber:Say("I can't reach my spotter anymore")
    else
        -- Not even the bomber is valid
        self.bomber:Say("I think I'm missing something")
    end
end


function MortarClientHandler:executeStartFiring()

    self.bomber:playEmote("_MortarClick")

    -- We need to send this to the spotter since that's where the actual "explosions" will be sent
    sendClientCommand(self.bomber, 'Mortar', 'sendMortarShot', {spotterId = self.spotter:getOnlineID()})
    sendClientCommand(self.bomber, 'Mortar', 'updateReloadStatus', {check = false, instanceId = MortarClientHandler.weaponInstanceId})
    

    -- Force set that we don't have any round directly on the client to prevent multiple spam shots
    -- FIXME Mostly a workaround for now until I think of a better solution to speed things up
    if MortarClientHandler.weaponInstanceId ~= nil then
        for _, v in pairs(MortarSyncedWeapons) do
            for uuid, instance in pairs(v) do
                if uuid == MortarClientHandler.weaponInstanceId then
                    instance.isRoundInChamber = false
                end
            end
        end
    end

end

function MortarClientHandler:startShooting()

    local finalRad = ZombRand(3, MortarCommonVars.rad)

    local explosionX
    local explosionY
    local explosionZ

    if self.coordinates then
        explosionX = self.coordinates[1]
        explosionY = self.coordinates[2]
    else
        -- TODO I think I missed something, self.spotter runs on the spotter but self.spotter is nil
        self.spotter = getPlayer()
        local nx = MortarCommonVars.directions[tostring(self.spotter:getDir())][1]
        local ny = MortarCommonVars.directions[tostring(self.spotter:getDir())][2]
        local dist = ZombRand(MortarCommonVars.distMin, MortarCommonVars.distMax)



        explosionX = math.floor(self.spotter:getX() + (nx * dist))
        explosionY = math.floor(self.spotter:getY() + (ny * dist))
    end

    explosionZ = MortarCommonFunctions.GetHighestZ(explosionX, explosionY) 
    --local trajectory = getCell():getGridSquare(explosionX, explosionY, explosionZ)

    MortarClientHandler:generateShot(explosionX, explosionY, explosionZ, finalRad)

end

function MortarClientHandler:generateShot(sqX, sqY, sqZ, rad)
    local cell = getWorld():getCell()
    sendClientCommand(self.spotter, 'Mortar', 'sendMuzzleFlash', {bomberId = self.bomber:getOnlineID()})

    for x = sqX - rad, sqX + rad + 1 do
        for y = sqY - rad, sqY + rad + 1 do
            if IsoUtils.DistanceTo(sqX, sqY, x + 0.5, y + 0.5) <= rad then
                local sq = cell:getGridSquare(x, y, sqZ)

                -- Safehouses are... safe, so let's be kind to them
                local safeHouse = SafeHouse.getSafeHouse(sq)

                if safeHouse ~= nil then
                    break   -- Next check
                else
                    print("Not a safehouse, let's destroy this square")
                end



                local vanillaCommand = 'addFireOnSquare'
                if MortarCommonFunctions.RollChance(20) then
                    vanillaCommand = 'addSmokeOnSquare'
                end   
                if sq:Is(IsoFlagType.burning) then 
                    sq:getModData()['mortarHit'] = true

                    -- TODO This needs to be in a function and removed after a while, they're gonna stack up
                    Events.OnTick.Add(function() 
                        if sq:getModData()['mortarHit'] and not sq:Is(IsoFlagType.burning) then
                            sq:getModData()['mortarHit'] = nil
                        end
                    end)



                end

                if MortarCommonFunctions.RollChance(60) then
                    local argsVanillaCommand = {
                        x = x,
                        y = y,
                        z = sqZ
                    }
                    sendClientCommand(self.spotter, 'object', vanillaCommand, argsVanillaCommand)
                end

                local chance = 40
                if MortarCommonFunctions.RollChance(chance) then
                    MortarClientHandler.SpawnDebris(sq)
                    MortarClientHandler.SpawnExplosionTile(sq)
                    sendClientCommand(self.spotter, 'Mortar', 'sendBoomSound', {sqX = sq:getX(), sqY = sq:getY(), sqZ = sq:getZ()})
                end

                -- Kill whatever thing is in the square
                local entities = sq:getMovingObjects()

                if entities then
                    for i = entities:size(), 1, -1 do
                        local entity = entities:get(i - 1)
                        if instanceof(entity, "IsoZombie") or instanceof(entity, "IsoPlayer") then
                            if not entity:isGodMod() then
                                entity:Kill(entity)
                            end
                        end
                    end
                end
            end
        end
    end



    for _, v in pairs(MortarClientHandler.explosionsTable.objects) do
        print("Listing an explosion ->" .. tostring(v))
    end


    Events.OnTick.Add(MortarClientHandler.UpdateExplosionTiles)


end

------------------------------------------
-- Reload
 
function MortarClientHandler:reloadRound()

    print("Mortar: reloading")
    local inv = getPlayer():getInventory()
    --if item:getFullType() == "Mortar.MortarRound" then 
    local item = inv:FindAndReturn('Mortar.MortarRound')
    local check
   if item and inv then
        --getPlayer():playEmote("_mortarReload")      -- TODO Make it not loop this much
        inv:RemoveOneOf('Mortar.MortarRound')
        sendClientCommand(getPlayer(), 'Mortar', 'updateReloadStatus', {check = true, instanceId = MortarClientHandler.weaponInstanceId})
    else
        getPlayer():Say(tostring('I have no ammo'))
    end


end

function MortarClientHandler:isReadyToShoot()


    if MortarClientHandler.weaponInstanceId ~= nil then
        for _, v in pairs(MortarSyncedWeapons) do

            for uuid, instance in pairs(v) do
                if uuid == MortarClientHandler.weaponInstanceId then
                    return instance.isRoundInChamber
                end
            end
        end
    end


    return false


end


-------- 
-- Visuals
---------


function MortarClientHandler.SpawnDebris(sq)

    local dug = IsoObject.new(sq, "mortar_" .. ZombRand(63)-8, "", false)
    sq:AddTileObject(dug)
    if isClient() then
        dug:transmitCompleteItemToServer()
    end
    
end


MortarClientHandler.explosionsTable = {
    count = 2,
    tickDiff = 6,           -- TODO Make this a constant somewhere and make a func to "recreate" this table instead of just recreating it manually
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
                MortarCommonFunctions.DestroyTile(v)        -- FIXME Doesn't seem to work
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