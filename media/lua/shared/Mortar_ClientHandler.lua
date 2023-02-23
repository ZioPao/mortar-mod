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

    self.o.bomber = player      -- Set the bomber
    self.o.weaponInstance = weaponInstance

    Events.OnTick.Add(MortarClientHandler.validationCheckUpdate)
    Events.OnTick.Add(MortarClientHandler.UpdateWeaponInstances)

end


function MortarClientHandler:delete()

    self.o = nil

    Events.OnTick.Remove(MortarClientHandler.validationCheckUpdate)
    Events.OnTick.Remove(MortarClientHandler.UpdateWeaponInstances)
end


------------------------------------

function MortarClientHandler:setBomber(player)
    self.o.bomber = player
end

function MortarClientHandler:getBomber()
    return self.o.bomber
end

function MortarClientHandler:setSpotter(player)
    self.o.spotter = player
end

function MortarClientHandler:getSpotter()
    return self.o.spotter
end

function MortarClientHandler:setCoordinates(x,y)
    self.o.coordinates = {x,y}
end

function MortarClientHandler:setWeaponInstance(weaponInstance)
    self.o.weaponInstance = weaponInstance
end


-----------------------------------------
-- Validation

function MortarClientHandler:setIsBomberValid(check)

    self.o.isBomberValid = check
end

function MortarClientHandler:setIsSpotterValid(check)
    self.o.isSpotterValid = check
end

function MortarClientHandler:validationCheckUpdate()

    -- Agnostic, we don't care if it's the bomber or the spotter
    local player = getPlayer()


    if self.o.bomber ~= nil and self.o.spotter ~= nil then
        sendClientCommand(player, 'Mortar', 'checkValidationStatus', {bomberId = self.o.bomber:getOnlineID(), spotterId = self.o.spotter:getOnlineID()})
    end
end

function MortarClientHandler:isAvailable()

    if self.o.bomber == nil then
        return true
    end

    return false

end

-----------------------------------------
-- Weapon instance handler

function MortarClientHandler.UpdateWeaponInstances()
    MortarSyncedWeapons = ModData.getOrCreate(MortarCommonVars.globalModDataId)
end

function MortarClientHandler.FindWeaponInstance(obj)

    if MortarSyncedWeapons == nil then
        print("Mortar Debug: No mortar synced weapons")
        return
    end

    for _, v in pairs(MortarSyncedWeapons) do

        if v.tileObj == obj then
            return v
        end
        
    end

    return nil

end
------------------------------------------

--- Called from bomber, will send notification to spotter to execute the code
function MortarClientHandler:tryStartFiring()
    print("Mortar: Trying to fire")

    -- Check if spotter exists
    if self.o.spotter == nil then
        print("No spotter")
        self.o.bomber:Say("I don't have a spotter right now")
        return
    end

    -- Checks if spotter is valid
    if self.o.isSpotterValid and self.o.isBomberValid then
        MortarClientHandler:executeStartFiring()
    elseif self.o.isBomberValid then
        self.o.bomber:Say("I can't reach my spotter anymore")
    else
        -- Not even the bomber is valid
        self.o.bomber:Say("I think I'm missing something")
    end
end


function MortarClientHandler:executeStartFiring()

    -- We need to send this to the spotter since that's where the actual "explosions" will be sent
    sendClientCommand(self.o.bomber, 'Mortar', 'sendMortarShot', {spotterId = self.o.spotter:getOnlineID()})

end

function MortarClientHandler:startShooting()

    local finalRad = ZombRand(3, MortarCommonVars.rad)

    local explosionX
    local explosionY
    local explosionZ

    if self.o.coordinates then
        explosionX = self.o.coordinates[1]
        explosionY = self.o.coordinates[2]
    else
        local nx = MortarCommonVars.directions[tostring(self.o.spotter:getDir())][1]
        local ny = MortarCommonVars.directions[tostring(self.o.spotter:getDir())][2]
        local dist = ZombRand(MortarCommonVars.distMin, MortarCommonVars.distMax)

        explosionX = math.floor(self.o.spotter:getX() + (nx * dist))
        explosionY = math.floor(self.spotter:getY() + (ny * dist))
    end

    explosionZ = MortarCommonFunctions.GetHighestZ(explosionX, explosionY) 
    --local trajectory = getCell():getGridSquare(explosionX, explosionY, explosionZ)

    MortarClientHandler:generateShot(explosionX, explosionY, explosionZ, finalRad)

end

