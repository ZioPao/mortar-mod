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

    o.dataTable = dataTable -- reference it
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


local function DelayShot()
    local sTime = MortarInstance.current.sTimeShot
    local timeToLand = MortarInstance.current.timeToLand
    local mode = MortarInstance.current.currentMode

    print("_____________")
    print(sTime)
    print(os.time() + timeToLand)

    if sTime > os.time() + timeToLand then
        if mode == MRT_COMMON.SOLO_MODE then
            MortarInstance.current:initializeSoloShot()
        else
            MortarInstance.current:initializeSpotShot()
        end

        MortarInstance.current.sTimeShot = nil
        MortarInstance.current.timeToLand = nil
        MortarInstance.current.currentMode = nil

        Events.OnTick.Remove(DelayShot)
    end
end


function MortarInstance:initializeShot(mode)
    self:setIsReloaded(false)
    MortarDataHandler.SyncData(self.id)
    local pl = getPlayer()
    sendClientCommand(pl, MRT_COMMON.SERVER_COMMON_COMMAND, 'SendMuzzleFlash', { operatorID = pl:getOnlineID() })

    self.sTimeShot = os.time()
    self.timeToLand = ZombRand(0, 4)
    self.currentMode = mode


    Events.OnTick.Add(DelayShot)
end

function MortarInstance:initializeSoloShot()
    local operatorPlayer

    if isClient() then
        operatorPlayer = getPlayerByOnlineID(self.dataTable.operatorID)
        sendClientCommand(operatorPlayer, MortarCommonVars.SERVER_OPERATOR_COMMAND, 'SendShot',
            { shooterID = self.dataTable.operatorID })
    else
        operatorPlayer = getPlayer()
        local hitCoords = MortarCommon.GetHitCoords(operatorPlayer)
        ShotHandler.Fire(hitCoords)
    end
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
    operatorPlayer:playEmote("_MortarClick")
    sendClientCommand(operatorPlayer, MRT_COMMON.SERVER_OPERATOR_COMMAND, 'SendShot',
        { shooterID = self.dataTable.spotterID })
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
