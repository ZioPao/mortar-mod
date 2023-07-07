local ShotHandler = require("Mortar_ShotHandler")
local MortarInstance = {}

---comment
---@param operatorID number
---@param spotterID number
---@param position table
---@return table
function MortarInstance:new(operatorID, spotterID, position)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.operatorID = operatorID
    o.spotterID = spotterID
    o.position = position

    o.isOperatorValid = false
    o.isSpotterValid = false

    o.isReloaded = false
    o.isMidReloading = false

    MortarInstance.current = o
    return o
end

--************************--
-- Getters
function MortarInstance:getOperatorID()
    return self.operatorID
end

function MortarInstance:getSpotterID()
    return self.spotterID
end

function MortarInstance:getPosition()
    return self.position
end

function MortarInstance:getIsReloaded()
    return self.isReloaded
end

function MortarInstance:getIsMidReloading()
    return self.isMidReloading
end

function MortarInstance:isReadyToShoot()
    return self.isReloadad and self.isOperatorValid and self.isSpotterValid
end

-- Setters

---Set operator ID
---@param operatorID number
function MortarInstance:setOperator(operatorID)
    self.operatorID = operatorID
end

--- Set spotter ID
---@param spotterID number
function MortarInstance:setSpotter(spotterID)
    self.spotterID = spotterID
end

function MortarInstance:setPosition(position)
    self.position = position
end

---Set isReloaded value
---@param val boolean
function MortarInstance:setIsReloaded(val)
    self.isReloaded = val
end

---Set isMidReloading value
---@param val boolean
function MortarInstance:setIsMidReloading(val)
    self.isMidReloading = val
end
--************************--
-- Actions

function MortarInstance:initializeSoloShot()

    local operatorPlayer

    if isClient() then
        operatorPlayer = getPlayerByOnlineID(self.operatorID)
        sendClientCommand(operatorPlayer, MortarCommonVars.MOD_ID, 'SendShot', { spotterID = self.spotterID })
    else
        operatorPlayer = getPlayer()
        local hitCoords = MortarCommonFunctions.GetHitCoords(operatorPlayer)
        ShotHandler.Fire(self.coords, hitCoords)
    end


end

function MortarInstance:initializeSpotShot()
    print("Mortar: Trying to fire")

    local spotterPlayer = getPlayerByOnlineID(self.spotterID)
    local operatorPlayer = getPlayerByOnlineID(self.operatorID)

    -- Check if spotter exists
    if spotterPlayer == nil then
        print("No spotter")
        operatorPlayer:Say("I don't have a spotter right now")
        return
    end

    -- Checks if spotter is valid
    if self.isSpotterValid and self.isOperatorValid then
        operatorPlayer:playEmote("_MortarClick")
        sendClientCommand(operatorPlayer, MortarCommonVars.MOD_ID, 'SendShot', { spotterID = self.spotterID })
    elseif self.isOperatorValid then
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
        MortarInstance.current:setIsReloaded(true)
        MortarInstance.current:setIsMidReloading(false)
        Events.OnTick.Remove(MortarInstance.HandleReloading)
    end
end

---Reload a shell into the mortar. Removes one from the inventory of the player
function MortarInstance:reloadRound()
    if self.operatorID == -1 then error("Operator was not set!") end
    local operatorPlayer
    if isClient() then
        operatorPlayer = getPlayerByOnlineID(self.operatorID)
    else
        operatorPlayer = getPlayer()
    end

    local inv = operatorPlayer:getInventory()
    inv:RemoveOneOf('Mortar.MortarRound')

    operatorPlayer:Say("Reloading...")

    self.sTimeReload = os.time()
    self:setIsMidReloading(true)
    Events.OnTick.Add(MortarInstance.HandleReloading)
end

return MortarInstance
