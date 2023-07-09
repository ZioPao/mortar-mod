local SpotterCommands = {}

---Send the status and direction received from the spotter to the operator
---@param _ any
---@param args table operatorID=number, status=boolean, direction=string
function SpotterCommands.RouteSpotterInfoToOperator(_, args)
    local operatorID = args.operatorID
    local status = args.status
    local direction = args.direction
    local operatorPl = getPlayerByOnlineID(operatorID)
    sendServerCommand(operatorPl, MRT_COMMON.OPERATOR_COMMAND, 'ReceiveSpotterUpdate', { status = status, direction = direction })
end

--******************************************************--

local OperatorCommands = {}

---Operator sends a request to the spotter for an updated status
---@param operatorObj IsoPlayer
---@param args table spotterID=number
function OperatorCommands.AskSpotterStatus(operatorObj, args)
    --print("Asking spotter status")
    local spotterID = args.spotterID
    local operatorID = operatorObj:getOnlineID()
    local spotterPl = getPlayerByOnlineID(spotterID)
    sendServerCommand(spotterPl, MRT_COMMON.SPOTTER_COMMAND, 'SendUpdatedInfo', { operatorID = operatorID })
end

function OperatorCommands.RouteNotificationToSpotter(_, args)
    local spotterID = args.spotterID
    local spotterPl = getPlayerByOnlineID(spotterID)
    sendServerCommand(spotterPl, MRT_COMMON.SPOTTER_COMMAND, 'ReceiveNotification', {})
end

---Just after shooting
---@param args table
function OperatorCommands.SendThumpSound(operatorObj, args)
    local x = operatorObj:getX()
    local y = operatorObj:getY()
    local z = operatorObj:getZ()
    sendServerCommand(MRT_COMMON.COMMON_COMMAND, 'ReceiveThumpSound', { x = x, y = y, z = z })
end

---Send to every client a muzzle flash, coming from the operator
---@param args table contains operatorID
function OperatorCommands.SendMuzzleFlash(_, args)
    sendServerCommand(MRT_COMMON.COMMON_COMMAND, 'ReceiveMuzzleFlash', { operatorID = args.operatorID })
end

---Send the shot to the correct player, who may be a spotter or the operator
---@param args table Contains shooterID
function OperatorCommands.SendShot(_, args)
    local shooterID = args.shooterID
    local hitCoords = args.hitCoords
    local shooterPl = getPlayerByOnlineID(shooterID)
    -- print("Hit coords in SendShot")
    -- print(hitCoords.x)
    -- print(hitCoords.y)
    -- print("_________________")
    sendServerCommand(shooterPl, MRT_COMMON.COMMON_COMMAND, 'DoMortarShot', {hitCoords=hitCoords})
end

--******************************************************--


local CommonCommands = {}


---Explosions on squares
---@param args table
function CommonCommands.SendBoomSound(_, args)
    sendServerCommand(MRT_COMMON.COMMON_COMMAND, 'ReceiveBoomSound', { x = args.x, y = args.y, z = args.z })
end

------------

local OnClientCommand = function(module, command, playerObj, args)
    args = args or {}
    if module == MRT_COMMON.SERVER_SPOTTER_COMMAND then
        if SpotterCommands[command] then
            SpotterCommands[command](playerObj, args)
        end
    elseif module == MRT_COMMON.SERVER_OPERATOR_COMMAND then
        if OperatorCommands[command] then
            OperatorCommands[command](playerObj, args)
        end
    elseif module == MRT_COMMON.SERVER_COMMON_COMMAND then
        if CommonCommands[command] then
            CommonCommands[command](playerObj, args)
        end
    end
end


Events.OnClientCommand.Add(OnClientCommand)
