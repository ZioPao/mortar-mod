local ClientCommands = {}


--* Operator only methods *--

---Send a shot to the spotter client
---@param args table Contains spotterID
ClientCommands.SendShot = function(_, args)
    local spotter = getPlayerByOnlineID(args.spotterID)
    if spotter == nil then return end
    sendServerCommand(spotter, MortarCommonVars.MOD_ID, 'DoMortarShot', {})
end

-- ---Set in the correct global mod data table that the mortar is ready to shoot and reloaded
-- ---@param args table Contains instanceID
-- ClientCommands.DoReload = function(_, args)
--     -- TODO Add timer
--     local instance = MortarDataHandler.GetModData()[args.instanceID]
--     if instance == nil then return end
--     instance.isReloaded = args.check
-- end










--* Spotter only methods *--








---------------------------------------
--* Status updates *--
---Sent by the operator
---@param operator IsoPlayer
---@param args any
ClientCommands.SendOperatorStatus = function(operator, args)

end


---Sent by the spotter
---@param spotter IsoPlayer
---@param args any
ClientCommands.SendSpotterStatus = function(spotter, args)

end








--------------------------
-- Reset Client Handlers
--------------------------

-- Wut
ClientCommands.ResetSpotterClientHandler = function(player, _)
    sendServerCommand(player, MortarCommonVars.MOD_ID, 'ResetClientHandler', {})
end




--------------------------
-- Weapon instance handling
--------------------------
ClientCommands.generateMortarWeaponInstance = function(player, args)
    local x = args.x
    local y = args.y
    local z = args.z
    local sq = getCell():getGridSquare(x, y, z)
    MortarWeapon.TryCreateNewInstance(sq)
end


--------------------
-- Validation checks
--------------------

ClientCommands.checkValidationStatus = function(player, args)
    local bomberId = args.bomberId
    local spotterId = args.spotterId
    local bomberPlayer = getPlayerByOnlineID(bomberId)
    local spotterPlayer = getPlayerByOnlineID(spotterId)

    sendServerCommand(bomberPlayer, MortarCommonVars.MOD_ID, 'updateBomberStatus', { spotterId = spotterId })
    sendServerCommand(spotterPlayer, MortarCommonVars.MOD_ID, 'updateSpotterStatus', { bomberId = bomberId })
end

ClientCommands.sendUpdatedBomberStatus = function(player, args)
    -- Let's send the updated status of the bomber to the spotter
    local check = args.isValid
    local spotterPlayer = getPlayerByOnlineID(args.spotterId)

    sendServerCommand(spotterPlayer, MortarCommonVars.MOD_ID, 'setUpdatedBomberValidation', { isValid = check })
end

ClientCommands.sendUpdatedSpotterStatus = function(player, args)
    -- Let's send the updated status of the spotter to the bomber
    local check = args.isValid
    local bomberPlayer = getPlayerByOnlineID(args.bomberId)

    sendServerCommand(bomberPlayer, MortarCommonVars.MOD_ID, 'setUpdatedSpotterValidation', { isValid = check })
end

--------------------
-- Shooting
-------------------
ClientCommands.sendMortarShot = function(player, args)
    local spotterPlayer = getPlayerByOnlineID(args.spotterId)
    sendServerCommand(spotterPlayer, MortarCommonVars.MOD_ID, 'receiveMortarShot', {})
end


--------------------
-- Reload
-------------------
ClientCommands.updateReloadStatus = function(player, args)
    print("Mortar: updating reload status")
    local weaponInstanceId = args.instanceId
    print("Weapon Instance id: " .. weaponInstanceId)
    local correctInstance

    if weaponInstanceId then
        for uuid, v in pairs(MortarWeapon.instances) do
            print("Checking this uuid: " .. uuid)
            if uuid == weaponInstanceId then
                correctInstance = v
            end
        end


        if correctInstance ~= nil then
            correctInstance.isRoundInChamber = args.check
            print("Updated instance")
        else
            print("Couldnt find WeaponInstance")
        end
    else
        print("Weapon instance id is null, cant reload")
    end
end



----------------
-- Cosmetic stuff
---------------

ClientCommands.sendMuzzleFlash = function(player, args)
    sendServerCommand(MortarCommonVars.MOD_ID, 'acceptMuzzleFlash', { operatorID = args.operatorID })
end

ClientCommands.sendBoomSound = function(player, args)
    sendServerCommand(MortarCommonVars.MOD_ID, 'receiveBoomSound', { x = args.sqX, y = args.sqY, z = args.sqZ })
end

------------------------------------------------

local OnClientCommand = function(module, command, playerObj, args)
    --print("Mortar: Received command " .. command)
    if module == MortarCommonVars.MOD_ID and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end


Events.OnClientCommand.Add(OnClientCommand)
