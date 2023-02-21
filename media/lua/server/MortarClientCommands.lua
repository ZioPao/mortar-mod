


local ClientCommands = {}


ClientCommands.AcceptMortarShot = function(player, args)

    local operator_id = args.operator
    local operator = getPlayerByOnlineID(operator_id)

    local spotter_id = args.spotter
    local spotter = getPlayerByOnlineID(spotter_id)


    -- TODO Run here check for walkie talkie

    -- Let's run it here directly
    sendServerCommand(spotter, "Mortar", "ReceiveMortarShot", {operator = operator_id, spotter = spotter_id})

    -- TODO make em face the direction
    --operator:faceLocation(x, y)   

end
ClientCommands.NotifySpotter = function(player, args)
    print("Mortar: Notifying spotter!")
    local spotter = getPlayerByOnlineID(args.spotter_id)
    sendServerCommand(spotter, "Mortar", "ReceiveOperatorForSpotter", {bomber_id = args.bomber_id})



end

ClientCommands.SendDirectCoordinates = function(player, args)
    local bomber = getPlayerByOnlineID(args.bomber_id)
    sendServerCommand(bomber, "Mortar", "SetDirectCoordinates", {x = args.x, y = args.y})

end

local OnClientCommand = function(module, command, player_obj, args)
    if module == "Mortar" and ClientCommands[command] then
        ClientCommands[command](player_obj, args)
    end
end


Events.OnClientCommand.Add(OnClientCommand)
