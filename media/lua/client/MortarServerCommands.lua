--==================================--
--[[ MORTAR MOD - SERVER COMMANDS ]]--
--==================================--


local ServerCommands = {}


ServerCommands.receiveMortarShot = function(args)
    local operator = getPlayerByOnlineID(args.operator)
    local spotter = getPlayerByOnlineID(args.spotter)
    if operator == nil or spotter == nil then
        print("Mortar: operator or spotter are null, can't start firing")

        -- TODO this would run ONLY on the spotter client, since receiveMortarShot is intended to be run there
        operator:Say(tostring('I need a spotter')) 
        spotter:Say(tostring('I need a bomber')) 
        
        return
    end

    local rad = 8
    local dist = 30


    Mortar.startFiring(operator, spotter, rad, dist)

    -- TODO Same problem as before, only from the spotter perspective the operator would play the emote, but nothing would happen on the operator\bomber client
    spotter:playEmote("_SpotterScope4")
    operator:playEmote("_SpotterScope5")
    --spotter:playEmote("_SpotterScope4") --or use this
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
