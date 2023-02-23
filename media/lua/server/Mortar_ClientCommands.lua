--==================================--
--[[ MORTAR MOD - CLIENT COMMANDS ]]--
--==================================--
local ClientCommands = {}




--------------------------
-- Weapon instance handling
--------------------------
ClientCommands.generateMortarWeaponInstance = function(player, args)

    local x = args.x
    local y = args.y
    local z = args.z
    local objects = getCell():getGridSquare(x, y, z):getObjects()

    for i=0, objects:size() - 1 do

        local obj = objects:get(i)

        local sprite = obj:getSprite()

        if sprite ~= nil then
            local sprite_name = sprite:getName()
            local check = MortarCommonFunctions.IsMortarSprite(sprite_name)
            if check then
                print("Mortar: found object, instancing new MortarWeapon")
                MortarWeapon:new(x,y,z)
                break
            end
        end

    end


end


--------------------
-- Validation checks
--------------------

ClientCommands.checkValidationStatus = function(player, args)

    local bomberId = args.bomberId
    local spotterId = args.spotterId
    local bomberPlayer = getPlayerByOnlineID(bomberId)
    local spotterPlayer = getPlayerByOnlineID(spotterId)

    sendServerCommand(bomberPlayer, 'Mortar', 'updateBomberStatus', {spotterId = bomberId})
    sendServerCommand(spotterPlayer, 'Mortar', 'updateSpotterStatus', {bomberId = spotterId})

end

ClientCommands.sendUpdatedBomberStatus = function(player, args)
    -- Let's send the updated status of the bomber to the spotter
    local check = args.isValid
    local spotterPlayer = getPlayerByOnlineID(args.spotterId)

    sendServerCommand(spotterPlayer, 'Mortar', 'setUpdatedBomberValidation', {isValid = check})
end

ClientCommands.sendUpdatedSpotterStatus = function(player, args)
    -- Let's send the updated status of the spotter to the bomber
    local check = args.isValid
    local bomberPlayer = getPlayerByOnlineID(args.bomberId)

    sendServerCommand(bomberPlayer, 'Mortar', 'setUpdatedSpotterValidation', {isValid = check})


end

--------------------
-- Shooting
-------------------
ClientCommands.sendMortarShot = function(player, args)

    local spotterPlayer = getPlayerByOnlineID(args.spotterId)
    sendServerCommand(spotterPlayer, 'Mortar', 'receiveMortarShot')

end


--------------------
-- Reload
-------------------
ClientCommands.updateReloadStatus = function(player, args)
    local weaponInstance = args.weaponInstance
    weaponInstance:setIsRoundInChamber(args.check)
end


------------------------------------------------

local onClientCommand = function(module, command, player_obj, args)
    print("Mortar: Received command " .. command)
    if module == "Mortar" and ClientCommands[command] then
        ClientCommands[command](player_obj, args)
    end
end


Events.OnClientCommand.Add(onClientCommand)
