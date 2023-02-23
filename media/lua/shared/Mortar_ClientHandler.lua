--=========================================--
--[[ MORTAR MOD - BOMBER\SPOTTER HANDLER ]]--
--=========================================--

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
    o.weaponInstance = nil

    o.isBomberValid = false
    o.isSpotterValid = false
    
    o.coordinates = nil
    MortarClientHandler.instance = o

    return o
end

function MortarClientHandler:instantiate(player, weaponInstance)

    self.bomber = player      -- Set the bomber
    self.weaponInstance = weaponInstance

    Events.OnTick.Add(MortarClientHandler.validationCheckUpdate)

end


function MortarClientHandler:delete()

    MortarClientHandler.instance = nil
    Events.OnTick.Remove(MortarClientHandler.validationCheckUpdate)
end


------------------------------------

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


-----------------------------------------
-- Validation

function MortarClientHandler:setIsBomberValid(check)

    self.isBomberValid = check
end

function MortarClientHandler:setIsSpotterValid(check)
    self.isSpotterValid = check
end

function MortarClientHandler:validationCheckUpdate()

    -- Agnostic, we don't care if it's the bomber or the spotter
    local player = getPlayer()


    if self.bomber ~= nil and self.spotter ~= nil then
        sendClientCommand(player, 'Mortar', 'checkValidationStatus', {bomberId = self.bomber:getOnlineID(), spotterId = self.spotter:getOnlineID()})
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
        

        if v.tileX == x and v.tileY == y and v.tileZ == z then
            MortarClientHandler.weaponInstance = v
            return v
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

    -- We need to send this to the spotter since that's where the actual "explosions" will be sent
    sendClientCommand(self.bomber, 'Mortar', 'sendMortarShot', {spotterId = self.spotter:getOnlineID()})

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

------------------------------------------
-- Reload
 
function MortarClientHandler:reloadRound()

    local inv = getPlayer():getInventory()
    --if item:getFullType() == "Mortar.MortarRound" then 
    local item = inv:FindAndReturn('Mortar.MortarRound')
    local check
   if item and inv then
        --getPlayer():playEmote("_mortarReload")      -- TODO Make it not loop this much
        inv:RemoveOneOf('Mortar.MortarRound')
        check = true
    else
        getPlayer():Say(tostring('I have no ammo'))
        check = false
    end

    sendClientCommand(getPlayer(), 'Mortar', 'updateReloadStatus', {check = check, weaponInstance = self.weaponInstance})

end

function MortarClientHandler:isReadyToShoot()

    if MortarClientHandler.weaponInstance then
        return MortarClientHandler.weaponInstance:getIsRoundInChamber()        -- TODO Not sure if it'll work
    end

    return false


end