

local ServerCommands = {}


ServerCommands.ReceiveMortarShot = function(args)
    local operator_id = args.operator
    local operator = getPlayerByOnlineID(operator_id)

    local spotter_id = args.spotter
    local spotter = getPlayerByOnlineID(spotter_id)


    local rad = 8
    local dist = 30

    Mortar.StartFiring(operator, spotter, rad, dist)


end



local function OnServerCommand(module, command, args)
    if module == 'Mortar' then
        if ServerCommands[command] then
            args = args or {}
            ServerCommands[command](args)
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)
