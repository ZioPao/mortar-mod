--========================================--
--[[ MORTAR MOD - CONTEXT MENU HANDLING ]]--
--========================================--

local function SearchAndSetNearbySpotters(spotterMenu, playerInMenu)
    -- We're not gonna check for radio here, just players

    print("Mortar: searching spotters")
    local players = getOnlinePlayers()
    for i = 0, players:size() - 1 do
        local pl = players:get(i)
        if pl ~= playerInMenu then
            -- Check distance
           
            local dist = pl:getDistanceSq(playerInMenu)
            if dist < 500 then          -- TODO Set a correct distance, maybe via SandboxVars

                -- TODO Merge it with the dist check
                if MortarCommonFunctions.ArePlayersInSameFaction(pl, playerInMenu) then
                    -- Validation is done at a later time
                    print("Mortar: Found acceptable spotter => " .. tostring(i))
                    local username = pl:getUsername()
                    print(username)

                    spotterMenu:addOption(username, _, function() MortarClientHandler.GetInstance():setSpotter(pl) end)
                end
            end
        end
    end

end

-------------------------

local function CreateMortarContextMenu(playerId, context, worldObjects, _)
    for _, v in pairs(worldObjects) do

        local playerObj = getPlayer()
        local pl_x = playerObj:getX()
        local pl_y = playerObj:getY()
        local obj_x = v:getX()
        local obj_y = v:getY()

        local distanceCheck = MortarCommonFunctions.GetDistance2D(pl_x, pl_y, obj_x, obj_y) < MortarCommonVars.distSteps

        if v:getSprite() and MortarCommonFunctions.IsMortarSprite(v:getSprite():getName()) and distanceCheck then

            -- We need to search the server for an active MortarWeapon. if there is none, we'll have to create one
            local weaponInstance = MortarClientHandler.SetWeaponInstance(v)

            -- This will run JUST when OnLoadgridsquare failed.
            if weaponInstance == nil then
                sendClientCommand(playerObj, 'Mortar', 'generateMortarWeaponInstance', {
                    x = v:getX(),
                    y = v:getY(),
                    z = v:getZ()
                })
                weaponInstance = MortarClientHandler.SetWeaponInstance(v)
            end



            if weaponInstance ~= nil then

                context:getNew(context)
                if MortarCommonFunctions.IsBomberValid(playerObj) then

                    local clientHandler = MortarClientHandler.GetInstance()

                    if clientHandler:getBomber() == playerObj then
                        context:addOption(getText("UI_ContextMenu_StopOperatingMortar"), worldObjects, function()
                            clientHandler:delete()
                            MortarUI:close()
                        end)
                    elseif clientHandler:isAvailable() then
                        context:addOption(getText("UI_ContextMenu_OperateMortar"), worldObjects, function()

                
                            clientHandler:instantiate(playerObj, v)
                            MortarUI:onOpenPanel(clientHandler)
                        end)
                    end


                    local spotterOption = context:addOption(getText("UI_ContextMenu_SetSpotter"), _, nil)
                    local spotterMenu = ISContextMenu:getNew(context)
                    context:addSubMenu(spotterOption, spotterMenu)
                    SearchAndSetNearbySpotters(spotterMenu, playerObj)

                    break

                else
                    -- TODO ADD CONTEXT MENU THAT SAYS THAT THERE IS SOMETHING MISSING
                    local cantOperateOption = context:addOption(getText("UI_ContextMenu_CantOperateMortar"), _, nil)
                    cantOperateOption.notAvailable = true
                    return

                end
            end

        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(CreateMortarContextMenu)
