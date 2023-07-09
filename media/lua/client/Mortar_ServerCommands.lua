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
    local variousChecks = not spotterObj:isDriving() and not spotterObj:HasTrait('ShortSighted') and
    not spotterObj:isAsleep()


    local status = distanceCheck and isSpotterValid and radioCheck and variousChecks
    sendClientCommand(spotterObj, MRT_COMMON.SERVER_SPOTTER_COMMAND, "RouteSpotterStatusToOperator",
        { operatorID = operatorID, status = status })
end

--******************************************************--

local OperatorCommands = {}
local MortarUI = require("UI/Mortar_MainPanel")

---Notify a spotter that they have been selected by an operator
---@param args table spotterID=number
function OperatorCommands.NotifySelectedSpotter(args)
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
        MortarUI.instance:setIsSpotterReady(status)
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

---Start sound from the explosion
---@param args table
function CommonCommands.ReceiveBoomSound(args)
    local x = args.x
    local y = args.y
    local z = args.z
    MortarCommon.PlayBoomSound(x,y,z)
end

function CommonCommands.ReceiveThumpSound(args)
    local x = args.x
    local y = args.y
    local z = args.z
    MortarCommon.PlayThumpSound(x,y,z)
end

--------------------------------------------

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
