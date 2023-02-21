--==================================--
--[[ MORTAR MOD - CLIENT COMMANDS ]]--
--==================================--


local ClientCommands = {}


ClientCommands.acceptMortarShot = function(player, args)

    local operator_id = args.operator
    local operator = getPlayerByOnlineID(operator_id)

    local spotter_id = args.spotter
    local spotter = getPlayerByOnlineID(spotter_id)


    -- TODO Run here check for walkie talkie

    -- Let's run it here directly
    sendServerCommand(spotter, "Mortar", "receiveMortarShot", {operator = operator_id, spotter = spotter_id})

    -- TODO make em face the direction
    --operator:faceLocation(x, y)   

end
ClientCommands.notifySpotter = function(player, args)
    print("Mortar: Notifying spotter!")
    local spotter = getPlayerByOnlineID(args.spotter_id)
    sendServerCommand(spotter, "Mortar", "receiveOperatorForSpotter", {bomber_id = args.bomber_id})



end
ClientCommands.sendDirectCoordinates = function(player, args)
    local bomber = getPlayerByOnlineID(args.bomber_id)
    sendServerCommand(bomber, "Mortar", "setDirectCoordinates", {x = args.x, y = args.y})

end

------------------------------------------------

local onClientCommand = function(module, command, player_obj, args)
    print("Mortar: Received command " .. command)
    if module == "Mortar" and ClientCommands[command] then
        ClientCommands[command](player_obj, args)
    end
end


Events.OnClientCommand.Add(onClientCommand)
