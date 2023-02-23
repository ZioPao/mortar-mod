--==================================--
--[[ MORTAR MOD - SERVER COMMANDS ]]--
--==================================--


local ServerCommands = {}


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

     -- Updates the MortarClientHandler on this side
    MortarClientHandler:setIsBomberValid(isValid)
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


    -- Updates the MortarClientHandler on this side
    MortarClientHandler:setIsSpotterValid(isValid)
    sendClientCommand(player, 'Mortar', 'sendUpdatedSpotterStatus', {bomberId = args.bomberId, isValid = isValid} )

end

ServerCommands.setUpdatedBomberValidation = function(args)
    -- This will be run on the spotter client
    MortarClientHandler:setIsBomberValid(args.isValid)
end

ServerCommands.setUpdatedSpotterValidation = function(args)
    -- This will be run on the bomber client
    MortarClientHandler:setIsSpotterValid(args.isValid)
end


--------------------------
-- Shooting logic
-------------------------

ServerCommands.receiveMortarShot = function(args)

    MortarClientHandler:startShooting()


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
