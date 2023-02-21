--==================================--
--[[ MORTAR MOD - SERVER COMMANDS ]]--
--==================================--


local ServerCommands = {}


ServerCommands.receiveMortarShot = function(args)
    local operator_id = args.operator
    local operator = getPlayerByOnlineID(operator_id)

    local spotter_id = args.spotter
    local spotter = getPlayerByOnlineID(spotter_id)


    local rad = 8
    local dist = 30

    Mortar.startFiring(operator, spotter, rad, dist)


end

ServerCommands.receiveOperatorForSpotter = function(args)
    print("Mortar: setting the correct bomber for the spotter")
    local bomber_id = args.bomber_id
    Mortar.bomber = getPlayerByOnlineID(bomber_id)


end

ServerCommands.setDirectCoordinates = function(args)
    Mortar.direct_coordinates = {args.x, args.y}
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
