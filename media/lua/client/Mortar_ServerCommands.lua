local SpotterCommands = {}

function SpotterCommands.ReceiveNotification(args)
    -- Start a loop to check if the player is

    -- TODO Check if notification is already active.
end

---Send an updated status from the Spotter to the server
---@param args table operatorID=number
function SpotterCommands.SendUpdatedStatus(args)
    local spotterObj = getPlayer()
    local operatorID = args.operatorID
    local operatorObj = getPlayerByOnlineID(operatorID)

    local distanceCheck = MortarCommon.CheckDistance(spotterObj, operatorObj)
    local isSpotterValid = MortarCommon.IsSpotterValid(spotterObj)
    local radioCheck = MortarCommon.CheckRadio(spotterObj:getInventory())
    local variousChecks = not spotterObj:isDriving() and not spotterObj:HasTrait('ShortSighted') and not spotterObj:isAsleep()


    local status = distanceCheck and isSpotterValid and radioCheck and variousChecks
    sendClientCommand(spotterObj, MRT_COMMON.SERVER_SPOTTER_COMMAND, "RouteSpotterStatusToOperator",
        { operatorID = operatorID, status = status })
end

--******************************************************--

local OperatorCommands = {}
local MortarUI = require("UI/Mortar_MainPanel")

function OperatorCommands.NotifySelectedSpotter(args)
    --print("Notify spotter command")
    local operator = getPlayer()
    local spotterID = args.spotterID

    sendClientCommand(operator, MRT_COMMON.SERVER_COMMON_COMMAND, "RouteNotificationToSpotter", { spotterID = spotterID })
end

---Set the status of the spotter in MortarUI
---@param args table status=boolean
function OperatorCommands.ReceiveSpotterUpdate(args)
    local status = args.status
    --print("MortarUI: received updatate from spotter =" .. tostring(status))
    if MortarUI and MortarUI.instance then
        MortarUI.instance:setIsSpotterReady(args.status)
    end
end

--******************************************************--

local CommonCommands = {}
local MortarShotHandler = require("Mortar_ShotHandler")

---Sent to the operator or spotter, depending on the selected mode
---@param _ any
function CommonCommands.DoMortarShot(_)
    local pl = getPlayer()
    local hitCoords = MortarCommon.GetHitCoords(pl)
    MortarShotHandler.Fire(hitCoords)
end

---Spawns muzzle flash in the operator position
---@param args table
function CommonCommands.ReceiveMuzzleFlash(args)
    local pl = getPlayerByOnlineID(args.operatorID)
    if pl then
        pl:startMuzzleFlash()
    end
end

---Start sound from mortar position
---@param args table
function CommonCommands.ReceiveBoomSound(args)
    local x = args.x
    local y = args.y
    local z = args.z
    local sq = getCell():getGridSquare(x, y, z)
    getSoundManager():PlayWorldSound(tostring(MRT_COMMON.SOUNDS[ZombRand(1, 4)]), sq, 0, 5, 5, false)
end

-----------

local function OnServerCommand(module, command, args)
    args = args or {}

    if module == MRT_COMMON.SPOTTER_COMMAND then
        if SpotterCommands[command] then
            SpotterCommands[command](args)
        end
    elseif module == MRT_COMMON.OPERATOR_COMMAND then
        if OperatorCommands[command] then
            OperatorCommands[command](args)
        end
    elseif module == MRT_COMMON.COMMON_COMMAND then
        if CommonCommands[command] then
            CommonCommands[command](args)
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)












































local ServerCommands = {}
--local MortarHandler = require("Mortar_ClientHandler")



--* Player Actions *--

ServerCommands.DoMortarShot = function(args)
    -- TODO This doesn't make any fucking sense. We're from the spotter. We don't need to handle it from there

    -- local clientHandlerInstance = MortarHandler:GetInstance()
    -- clientHandlerInstance:startShooting()
    local pl = getPlayer()
    local hitCoords = MortarCommon.GetHitCoords(pl)
    MortarShotHandler.Fire(args.mortarPos, hitCoords)
end

----------------------------------


ServerCommands.UpdateSpotterStatus = function(args)

end



-------------------
-- Validation
-------------------
ServerCommands.updateBomberStatus = function(args)
    local player = getPlayer()
    local isValid = false

    if MortarCommon.IsBomberValid(player) then
        if MortarCommon.CheckRadio(player:getInventory()) then
            isValid = true
        end
    end

    local clientHandlerInstance = MortarHandler:GetInstance()

    -- Updates the MortarClientHandler on this side
    clientHandlerInstance:setIsBomberValid(isValid)
    clientHandlerInstance:setBomber(player)
    clientHandlerInstance:setSpotter(getPlayerByOnlineID(args.spotterId))
    sendClientCommand(player, 'Mortar', 'sendUpdatedBomberStatus', { spotterId = args.spotterId, isValid = isValid })
end

ServerCommands.updateSpotterStatus = function(args)
    -- We should resend AGAIN the status to the other player
    local player = getPlayer()
    local isValid = false


    if MortarCommon.IsSpotterValid(player) then
        if MortarCommon.CheckRadio(player:getInventory()) then
            isValid = true
        end
    end


    local clientHandlerInstance = MortarHandler:GetInstance()

    -- Updates the MortarClientHandler on this side
    clientHandlerInstance:setIsSpotterValid(isValid)
    clientHandlerInstance:setBomber(getPlayerByOnlineID(args.bomberId))
    clientHandlerInstance:setSpotter(player)
    sendClientCommand(player, 'Mortar', 'sendUpdatedSpotterStatus', { bomberId = args.bomberId, isValid = isValid })
end

ServerCommands.setUpdatedBomberValidation = function(args)
    -- This will be run on the spotter client
    local clientHandlerInstance = MortarHandler:GetInstance()
    clientHandlerInstance:setIsBomberValid(args.isValid)
end

ServerCommands.setUpdatedSpotterValidation = function(args)
    -- This will be run on the bomber client
    local clientHandlerInstance = MortarHandler:GetInstance()
    clientHandlerInstance:setIsSpotterValid(args.isValid)
end


----------------
-- Cosmetic stuff
----------------

ServerCommands.acceptMuzzleFlash = function(args)
    local pl = getPlayerByOnlineID(args.operatorID)
    if pl then
        pl:startMuzzleFlash()
    end
end

ServerCommands.receiveBoomSound = function(args)
    local x = args.x
    local y = args.y
    local z = args.z


    local sq = getCell():getGridSquare(x, y, z)
    getSoundManager():PlayWorldSound(tostring(MRT_COMMON.SOUNDS[ZombRand(1, 4)]), sq, 0, 5, 5, false)
end

----------------------------------------------
-- local function onServerCommand(module, command, args)
--     if module == 'Mortar' then
--         if ServerCommands[command] then
--             args = args or {}
--             ServerCommands[command](args)
--         end
--     end
-- end

-- Events.OnServerCommand.Add(onServerCommand)
