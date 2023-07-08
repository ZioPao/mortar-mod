local SpotterCommands = {}

function SpotterCommands.RouteSpotterStatusToOperator(_, args)
    --print("Received spotter status, = " .. tostring(args.status))
    --print(args.operatorID)
    local operatorID = args.operatorID
    local status = args.status
    local operatorPl = getPlayerByOnlineID(operatorID)
    sendServerCommand(operatorPl, MRT_COMMON.OPERATOR_COMMAND, 'ReceiveSpotterUpdate', { status = status })
end

--******************************************************--

local OperatorCommands = {}

---comment
---@param operatorObj IsoPlayer
---@param args any
function OperatorCommands.AskSpotterStatus(operatorObj, args)
    --print("Asking spotter status")
    local spotterID = args.spotterID
    local operatorID = operatorObj:getOnlineID()
    local spotterPl = getPlayerByOnlineID(spotterID)
    sendServerCommand(spotterPl, MRT_COMMON.SPOTTER_COMMAND, 'SendUpdatedStatus', {operatorID = operatorID})
end

function OperatorCommands.RouteNotificationToSpotter(_, args)
    local spotterID = args.spotterID
    local spotterPl = getPlayerByOnlineID(spotterID)
    sendServerCommand(spotterPl, MRT_COMMON.SPOTTER_COMMAND, 'ReceiveNotification', {})
end

---Send the shot to the correct player, who may be a spotter or the operator
---@param args table Contains shooterID
function OperatorCommands.SendShot(_, args)
    local shooterID = args.shooterID
    local shooterPl = getPlayerByOnlineID(shooterID)
    sendServerCommand(shooterPl, MRT_COMMON.COMMON_COMMAND, 'DoMortarShot', {})
end

--******************************************************--


local CommonCommands = {}

---Send to every client a muzzle flash, coming from the operator
---@param args table contains operatorID
function CommonCommands.SendMuzzleFlash(_, args)
    sendServerCommand(MRT_COMMON.COMMON_COMMAND, 'AcceptMuzzleFlash', { operatorID = args.operatorID })
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
