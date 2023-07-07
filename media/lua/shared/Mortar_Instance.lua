local ShotHandler = require("Mortar_ShotHandler")
--local DataHandler = require("Mortar_ClientData")

local MortarInstance = {}

---Creates a new instance for a mortar
---@param operatorID number
---@param spotterID number
---@param position table Used even for ID creation
---@return table
function MortarInstance:new(data)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.data = data       -- reference it

    -- o.operatorID = operatorID
    -- o.spotterID = spotterID
    -- o.position = position

    -- o.isOperatorValid = false
    -- o.isSpotterValid = false

    -- o.isReloaded = false
    -- o.isMidReloading = false

    o.id = tostring(data.position.x) .. tostring(data.position.y) .. tostring(data.position.z)

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
    return self.data.operatorID
end

function MortarInstance:getSpotterID()
    return self.data.spotterID
end

function MortarInstance:getPosition()
    return self.data.position
end

function MortarInstance:getIsReloaded()
    return self.data.isReloaded
end

function MortarInstance:getIsMidReloading()
    return self.data.isMidReloading
end

function MortarInstance:isReadyToShoot()
    return self.data.isReloadad and self.data.isOperatorValid and self.data.isSpotterValid
end

--************************--
-- Setters

---Set operator ID
---@param operatorID number
function MortarInstance:setOperator(operatorID)
    self.data.operatorID = operatorID
end

--- Set spotter ID
---@param spotterID number
function MortarInstance:setSpotter(spotterID)
    self.data.spotterID = spotterID
end

function MortarInstance:setPosition(position)
    self.data.position = position
end

---Set isReloaded value
---@param val boolean
function MortarInstance:setIsReloaded(val)
    self.data.isReloaded = val
end

---Set isMidReloading value
---@param val boolean
function MortarInstance:setIsMidReloading(val)
    self.data.isMidReloading = val
end

--************************--
-- Actions

function MortarInstance:initializeSoloShot()
    local operatorPlayer

    if isClient() then
        operatorPlayer = getPlayerByOnlineID(self.data.operatorID)
        sendClientCommand(operatorPlayer, MortarCommonVars.MOD_ID, 'SendShot', { spotterID = self.data.operatorID })
    else
        operatorPlayer = getPlayer()
        local hitCoords = MortarCommonFunctions.GetHitCoords(operatorPlayer)
        ShotHandler.Fire(self.data.position, hitCoords)
        self.isReloaded = false
    end

    MortarDataHandler.SyncData(self.id)
end

function MortarInstance:initializeSpotShot()
    print("Mortar: Trying to fire")

    local spotterPlayer = getPlayerByOnlineID(self.data.spotterID)
    local operatorPlayer = getPlayerByOnlineID(self.data.operatorID)

    -- Check if spotter exists
    if spotterPlayer == nil then
        print("No spotter")
        operatorPlayer:Say("I don't have a spotter right now")
        return
    end

    -- Checks if spotter is valid
    if self.data.isSpotterValid and self.data.isOperatorValid then
        operatorPlayer:playEmote("_MortarClick")
        sendClientCommand(operatorPlayer, MortarCommonVars.MOD_ID, 'SendShot', { spotterID = self.spotterID })
        MortarDataHandler.SyncData(self.id)
    elseif self.data.isOperatorValid then
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
    if cTime > MortarInstance.current.data.sTimeReload + 5 then
        MortarInstance.current:setIsReloaded(true)
        MortarInstance.current:setIsMidReloading(false)
        --MortarDataHandler.SetIsReloaded()
        MortarDataHandler.SyncData(MortarInstance.current.id)
        Events.OnTick.Remove(MortarInstance.HandleReloading)
    end
end

---Reload a shell into the mortar. Removes one from the inventory of the player
function MortarInstance:reloadRound()
    if self.data.operatorID == -1 then error("Operator was not set!") end
    local operatorPlayer
    if isClient() then
        operatorPlayer = getPlayerByOnlineID(self.data.operatorID)
    else
        operatorPlayer = getPlayer()
    end

    local inv = operatorPlayer:getInventory()
    inv:RemoveOneOf('Mortar.MortarRound')

    operatorPlayer:Say("Reloading...")

    self.sTimeReload = os.time()
    self:setIsMidReloading(true) -- Local only.. Could be a problem, but it shouldn't be
    Events.OnTick.Add(MortarInstance.HandleReloading)
end

--************************--

return MortarInstance
