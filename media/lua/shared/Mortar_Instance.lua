local ShotHandler = require("Mortar_ShotHandler")
local MortarInstance = {}

-----------------------------------------------------------

---Creates a new instance for a mortar
---@param dataTable table Reference of the synced table
---@return table
function MortarInstance:new(dataTable)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.dataTable = dataTable -- reference
    o.id = MortarCommon.GetAssembledID(dataTable.position)

    MortarInstance.current = o
    return o
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

--************************--
-- Setters

---Set operator ID
---@param operatorID number
function MortarInstance:setOperatorID(operatorID)
    self.dataTable.operatorID = operatorID
end

--- Set spotter ID
---@param spotterID number
function MortarInstance:setSpotterID(spotterID)
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

---Handles the delayed shot after the click has happened
function MortarInstance.HandleShotDelay()
    local sTime = MortarInstance.current.sTimeShot
    local timeToLand = MortarInstance.current.timeToLand
    local mode = MortarInstance.current.currentMode
    local cTime = os.time()

    if cTime > sTime + timeToLand then
        if mode == MRT_COMMON.SOLO_MODE then
            MortarInstance.current:initializeSoloShot()
        else
            MortarInstance.current:initializeSpotShot()
        end

        MortarInstance.current.sTimeShot = nil
        MortarInstance.current.timeToLand = nil
        MortarInstance.current.currentMode = nil

        Events.OnTick.Remove(MortarInstance.HandleShotDelay)
    end
end

---Main function to handle shots
---@param mode string
function MortarInstance:initializeShot(mode)
    self:setIsReloaded(false)
    MortarDataHandler.SyncData(self.id)
    local operatorPlayer = getPlayerByOnlineID(self.dataTable.operatorID)

    if operatorPlayer == nil then
        operatorPlayer = getPlayer() -- TODO Mostly a workaround,figure out why it would return nil
    end

    operatorPlayer:playEmote("MortarClick")

    if isClient() then
        sendClientCommand(operatorPlayer, MRT_COMMON.SERVER_OPERATOR_COMMAND, 'SendMuzzleFlash',
            { operatorID = self.dataTable.operatorID })
        sendClientCommand(operatorPlayer, MRT_COMMON.SERVER_OPERATOR_COMMAND, 'SendThumpSound', {})
    else
        operatorPlayer:startMuzzleFlash()
        MortarCommon.PlayThumpSound(operatorPlayer:getX(), operatorPlayer:getY(), operatorPlayer:getZ())
    end

    self.sTimeShot = os.time()

    if SandboxVars.Mortars.FixedShotDelay ~= 0 then
        self.timeToLand = SandboxVars.Mortars.FixedShotDelay
    else
        self.timeToLand = ZombRand(1, 5) -- Fake delay, it should be based on the distance between spotter and operator but who cares tbh
    end
    self.currentMode = mode

    Events.OnTick.Add(MortarInstance.HandleShotDelay)
end

---Handle a solo shot
function MortarInstance:initializeSoloShot()
    local operatorPlayer

    if isClient() then
        operatorPlayer = getPlayerByOnlineID(self.dataTable.operatorID)
        sendClientCommand(operatorPlayer, MRT_COMMON.SERVER_OPERATOR_COMMAND, 'SendShot',
            { shooterID = self.dataTable.operatorID })
    else
        operatorPlayer = getPlayer()
        local hitCoords = MortarCommon.GetHitCoords(operatorPlayer)
        ShotHandler.Fire(hitCoords)
    end
end

---Handle a spot shot
function MortarInstance:initializeSpotShot()
    --print("Mortar: Trying to fire")

    local spotterPlayer = getPlayerByOnlineID(self.dataTable.spotterID)
    local operatorPlayer = getPlayerByOnlineID(self.dataTable.operatorID)

    -- Check if spotter exists
    if spotterPlayer == nil then
        --print("No spotter")
        operatorPlayer:Say("I don't have a spotter right now")
        return
    end
    operatorPlayer:playEmote("_MortarClick")
    sendClientCommand(operatorPlayer, MRT_COMMON.SERVER_OPERATOR_COMMAND, 'SendShot',
        { shooterID = self.dataTable.spotterID })
end

---------------------------

---Handle the loop to reload a mortar
function MortarInstance.HandleReloading()
    -- 5 secs
    local cTime = os.time()
    --print("Waiting for reload")
    if cTime > MortarInstance.current.sTimeReload + 5 then
        --print("Reloaded!")
        MortarInstance.current:setIsReloaded(true)
        MortarInstance.current:setIsMidReloading(false)
        local player = getPlayer()
        player:setBlockMovement(false)
        player:setVariable("EmotePlaying", false) -- Mistake by Umbrella

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
    operatorPlayer:setVariable("EmotePlaying", true) -- Mistake by Umbrella
    operatorPlayer:playEmote("MortalReload")

    self.sTimeReload = os.time()
    self:setIsMidReloading(true) -- Local only.. Could be a problem, but it shouldn't be
    Events.OnTick.Add(MortarInstance.HandleReloading)
end

--************************--

return MortarInstance
