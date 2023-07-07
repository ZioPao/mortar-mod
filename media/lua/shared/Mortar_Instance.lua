local ShotHandler = require("Mortar_ShotHandler")
--local DataHandler = require("Mortar_ClientData")

local MortarInstance = {}


-- TODO Time to do it again :) 
-----------------------------------------------------------


---Creates a new instance for a mortar
---@param dataTable table Reference of the synced table
---@return table
function MortarInstance:new(dataTable)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.dataTable = dataTable       -- reference it
    o.id = tostring(dataTable.position.x) .. tostring(dataTable.position.y) .. tostring(dataTable.position.z)

    MortarInstance.current = o
    return o
end

function MortarInstance.WrapData(data)
    local instance = MortarInstance:new(data)
    -- instance.data.isOperatorValid = false
    -- instance.data.isSpotterValid = false

    -- instance.data.isReloaded = table.isReloaded
    -- instance.data.isMidReloading = false
    instance.id = data.id

    MortarInstance.current = instance
    return instance
end

--************************--
-- Getters
function MortarInstance:getOperatorID()
    return self.dataTable.operatorID
end

function MortarInstance:getSpotterID()
    return self.dataTable.spotterID
end

function MortarInstance:getPosition()
    return self.dataTable.position
end

function MortarInstance:getIsReloaded()
    return self.dataTable.isReloaded
end

function MortarInstance:getIsMidReloading()
    return self.dataTable.isMidReloading
end

function MortarInstance:isReadyToShoot()
    return self.dataTable.isReloadad and self.dataTable.isOperatorValid and self.dataTable.isSpotterValid
end

--************************--
-- Setters

---Set operator ID
---@param operatorID number
function MortarInstance:setOperator(operatorID)
    self.dataTable.operatorID = operatorID
end

--- Set spotter ID
---@param spotterID number
function MortarInstance:setSpotter(spotterID)
    self.dataTable.spotterID = spotterID
end

function MortarInstance:setPosition(position)
    self.dataTable.position = position
end

---Set isReloaded value
---@param val boolean
function MortarInstance:setIsReloaded(val)
    self.dataTable.isReloaded = val
end

---Set isMidReloading value
---@param val boolean
function MortarInstance:setIsMidReloading(val)
    self.dataTable.isMidReloading = val
end

--************************--
-- Actions

function MortarInstance:initializeSoloShot()
    local operatorPlayer

    if isClient() then
        operatorPlayer = getPlayerByOnlineID(self.dataTable.operatorID)
        sendClientCommand(operatorPlayer, MortarCommonVars.MOD_ID, 'SendShot', { spotterID = self.dataTable.operatorID })
    else
        operatorPlayer = getPlayer()
        local hitCoords = MortarCommonFunctions.GetHitCoords(operatorPlayer)
        ShotHandler.Fire(self.dataTable.position, hitCoords)
    end

    self:setIsReloaded(false)
    MortarDataHandler.SyncData(self.id)
    
end

function MortarInstance:initializeSpotShot()
    print("Mortar: Trying to fire")

    local spotterPlayer = getPlayerByOnlineID(self.dataTable.spotterID)
    local operatorPlayer = getPlayerByOnlineID(self.dataTable.operatorID)

    -- Check if spotter exists
    if spotterPlayer == nil then
        print("No spotter")
        operatorPlayer:Say("I don't have a spotter right now")
        return
    end

    -- Checks if spotter is valid
    if self.dataTable.isSpotterValid and self.dataTable.isOperatorValid then
        operatorPlayer:playEmote("_MortarClick")
        sendClientCommand(operatorPlayer, MortarCommonVars.MOD_ID, 'SendShot', { spotterID = self.spotterID })
        self:setIsReloaded(false)
        MortarDataHandler.SyncData(self.id)
    elseif self.dataTable.isOperatorValid then
        operatorPlayer:Say("I can't reach my spotter anymore")
    else
        -- Not even the bomber is valid
        operatorPlayer:Say("I think I'm missing something")
    end
end

function MortarInstance.HandleReloading()
    -- 5 secs
    local cTime = os.time()
    --print("Waiting for reload")
    if cTime > MortarInstance.current.sTimeReload + 5 then
        print("Reloaded!")
        MortarInstance.current:setIsReloaded(true)
        MortarInstance.current:setIsMidReloading(false)
        getPlayer():setBlockMovement(false)

        MortarDataHandler.SyncData(MortarInstance.current.id)
        Events.OnTick.Remove(MortarInstance.HandleReloading)
    end
end

---Reload a shell into the mortar. Removes one from the inventory of the player
function MortarInstance:reloadRound()
    if self.dataTable.operatorID == -1 then error("Operator was not set!") end
    local operatorPlayer
    if isClient() then
        operatorPlayer = getPlayerByOnlineID(self.dataTable.operatorID)
    else
        operatorPlayer = getPlayer()
    end

    local inv = operatorPlayer:getInventory()
    inv:RemoveOneOf('Mortar.MortarRound')

    operatorPlayer:Say("Reloading...")
    operatorPlayer:setBlockMovement(true)

    self.sTimeReload = os.time()
    self:setIsMidReloading(true) -- Local only.. Could be a problem, but it shouldn't be
    Events.OnTick.Add(MortarInstance.HandleReloading)
end

--************************--

return MortarInstance
