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






-------------------------------------------------

local ClientCommands = {}

--* Operator only methods *--

---Send a shot to the spotter client


-- ---Set in the correct global mod data table that the mortar is ready to shoot and reloaded
-- ---@param args table Contains instanceID
-- ClientCommands.DoReload = function(_, args)
--     -- TODO Add timer
--     local instance = MortarDataHandler.GetModData()[args.instanceID]
--     if instance == nil then return end
--     instance.isReloaded = args.check
-- end




--------------------
-- Validation checks
--------------------

ClientCommands.AskSpotterStatus = function(playerObj, args)
    local spotterID = args.spotterID
    local operatorID = args.operatorID
    local spotterPl = getPlayerByOnlineID(spotterID)
    sendServerCommand(spotterPl, MortarCommonVars.MOD_ID, "UpdateSpotterStatus", { operatorID = operatorID })
end





ClientCommands.checkValidationStatus = function(player, args)
    local bomberId = args.bomberId
    local spotterId = args.spotterId
    local bomberPlayer = getPlayerByOnlineID(bomberId)
    local spotterPlayer = getPlayerByOnlineID(spotterId)

    sendServerCommand(bomberPlayer, MortarCommonVars.MOD_ID, 'updateBomberStatus', { spotterId = spotterId })
    sendServerCommand(spotterPlayer, MortarCommonVars.MOD_ID, 'updateSpotterStatus', { bomberId = bomberId })
end

ClientCommands.sendUpdatedBomberStatus = function(player, args)
    -- Let's send the updated status of the bomber to the spotter
    local check = args.isValid
    local spotterPlayer = getPlayerByOnlineID(args.spotterId)

    sendServerCommand(spotterPlayer, MortarCommonVars.MOD_ID, 'setUpdatedBomberValidation', { isValid = check })
end

ClientCommands.sendUpdatedSpotterStatus = function(player, args)
    -- Let's send the updated status of the spotter to the bomber
    local check = args.isValid
    local bomberPlayer = getPlayerByOnlineID(args.bomberId)

    sendServerCommand(bomberPlayer, MortarCommonVars.MOD_ID, 'setUpdatedSpotterValidation', { isValid = check })
end

--------------------
-- Shooting
-------------------
ClientCommands.sendMortarShot = function(player, args)
    local spotterPlayer = getPlayerByOnlineID(args.spotterId)
    sendServerCommand(spotterPlayer, MortarCommonVars.MOD_ID, 'receiveMortarShot', {})
end


----------------
-- Cosmetic stuff
---------------

ClientCommands.sendMuzzleFlash = function(player, args)
    sendServerCommand(MortarCommonVars.MOD_ID, 'acceptMuzzleFlash', { operatorID = args.operatorID })
end

ClientCommands.sendBoomSound = function(player, args)
    sendServerCommand(MortarCommonVars.MOD_ID, 'receiveBoomSound', { x = args.sqX, y = args.sqY, z = args.sqZ })
end

------------------------------------------------
