--==================================--
--[[ MORTAR MOD - SERVER COMMANDS ]]--
--==================================--


local ServerCommands = {}
local MortarShotHandler = require("Mortar_ShotHandler")
--local MortarHandler = require("Mortar_ClientHandler")



--* Player Actions *--

ServerCommands.DoMortarShot = function(args)

    -- TODO This doesn't make any fucking sense. We're from the spotter. We don't need to handle it from there

    -- local clientHandlerInstance = MortarHandler:GetInstance()
    -- clientHandlerInstance:startShooting()
    local pl = getPlayer()
    local plCoords = {x = pl:getX(), y = pl:getY(), z = pl:getZ()}

    MortarShotHandler.Fire(args.mortarPos, plCoords)
end

----------------------------------








--------------------------
-- Reset Client Handlers
--------------------------
ServerCommands.resetClientHandler = function(args)
    local clientHandlerInstance = MortarHandler:GetInstance()
    clientHandlerInstance:delete()

end



-------------------
-- Validation
-------------------
ServerCommands.updateBomberStatus = function(args)

    local player = getPlayer()
    local isValid = false

    if MortarCommonFunctions.IsBomberValid(player) then
        if MortarCommonFunctions.CheckRadio(player:getInventory()) then
            isValid = true
        end
    end

    local clientHandlerInstance = MortarHandler:GetInstance()

     -- Updates the MortarClientHandler on this side
    clientHandlerInstance:setIsBomberValid(isValid)
    clientHandlerInstance:setBomber(player)
    clientHandlerInstance:setSpotter(getPlayerByOnlineID(args.spotterId))
    sendClientCommand(player, 'Mortar', 'sendUpdatedBomberStatus', {spotterId = args.spotterId, isValid = isValid})

end

ServerCommands.updateSpotterStatus = function(args)

    -- We should resend AGAIN the status to the other player
    local player = getPlayer()
    local isValid = false


    if MortarCommonFunctions.IsSpotterValid(player) then
        if MortarCommonFunctions.CheckRadio(player:getInventory()) then
            isValid = true
        end
    end


    local clientHandlerInstance = MortarHandler:GetInstance()

    -- Updates the MortarClientHandler on this side
    clientHandlerInstance:setIsSpotterValid(isValid)
    clientHandlerInstance:setBomber(getPlayerByOnlineID(args.bomberId))
    clientHandlerInstance:setSpotter(player)
    sendClientCommand(player, 'Mortar', 'sendUpdatedSpotterStatus', {bomberId = args.bomberId, isValid = isValid} )

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


--------------------------
-- Shooting logic
-------------------------




----------------
-- Cosmetic stuff
----------------

ServerCommands.acceptMuzzleFlash = function(args)

    local pl = getPlayerByOnlineID(args.bomberId)
    if pl then
        pl:startMuzzleFlash()
    end
end

ServerCommands.receiveBoomSound = function(args)

    local x = args.x
    local y = args.y
    local z = args.z


    local sq = getCell():getGridSquare(x, y, z)
    getSoundManager():PlayWorldSound(tostring(MortarCommonVars.sounds[ZombRand(1,4)]), sq, 0, 5, 5, false)

end

----------------------------------------------
local function onServerCommand(module, command, args)
    if module == 'Mortar' then
        if ServerCommands[command] then
            args = args or {}
            ServerCommands[command](args)
        end
    end
end

Events.OnServerCommand.Add(onServerCommand)
