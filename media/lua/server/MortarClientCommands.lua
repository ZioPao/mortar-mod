


local ClientCommands = {}


ClientCommands.AcceptMortarShot = function(player, args)

    local operator_id = args.operator
    local operator = getPlayerByOnlineID(operator_id)

    local spotter_id = args.spotter
    local spotter = getPlayerByOnlineID(spotter_id)


    -- TODO Run here check for walkie talkie

    -- Let's run it here directly
    sendServerCommand(spotter, "Mortar", "ReceiveMortarShot", {operator = operator_id, spotter = spotter_id})




end



local OnClientCommand = function(module, command, player_obj, args)
    if module == "Mortar" and ClientCommands[command] then
        ClientCommands[command](player_obj, args)
    end
end


Events.OnClientCommand.Add(OnClientCommand)
