--========================================--
--[[ MORTAR MOD - CONTEXT MENU HANDLING ]]--
--========================================--



local spotter_table = {}


local searchAndSetNearbySpotters = function(spotter_menu, operator)
    print("Mortar: searching spotters")

    local players = getOnlinePlayers()
    for i = 0, players:size() - 1 do
        local pl = players:get(i)
        if pl ~= operator then
            -- Check distance
            local dist = pl:getDistanceSq(operator)
            if dist < 150 then          -- TODO Set a correct distance, maybe via SandboxVars

                if Mortar.isSpotterValid(pl) then
                    print("Mortar: Found acceptable spotter => " .. tostring(i))
                    local username = pl:getUsername()
                    print(username)
                    spotter_menu:addOption(username, _, Mortar.setSpotter, pl)
                end


            end
        end
    end
end


---------------------------------------------------------------------------

-- OCreate the Context menu for the Mortar
local createOperateMortarContextMenu = function(_, context, world_objects)

    local root_menu
    local mortar_menu

    for _, v in pairs(world_objects) do
        local square = v:getSquare()
        print(v:getSprite():getName())

        print(MortarRotation.isMortar(v:getSprite():getName()))

        local player_obj= getPlayer()

        local pl_x = player_obj:getX()
        local pl_y = player_obj:getY()
        local obj_x = v:getX()
        local obj_y = v:getY()



        local distance_check = MortarCommonFunctions.getDistance2D(pl_x, pl_y, obj_x, obj_y) < Mortar.distSteps


        if v:getSprite() and MortarRotation.isMortar(v:getSprite():getName()) and distance_check  then

            Mortar.setCurrentMortar(v)
            root_menu = context:getNew(context)

            if Mortar.isBomberValid(player_obj) then
                if Mortar.getBomber(player) then
                    mortar_menu = context:addOption(getText("UI_ContextMenu_StopOperatingMortar"), world_objects, function() MortarUI:close() end)
                else
                    -- TODO I think it's the opposite, check it out
                    mortar_menu = context:addOption(getText("UI_ContextMenu_OperateMortar"), world_objects, function() Mortar.setBomber(getPlayer():getOnlineID()) end)
    
                end
            end
            
 

            -- TODO Set it so we can't access it if sp
            if isClient() then
                if SandboxVars.Mortar.NecessarySpotter  then
                    local spotter_option = context:addOption(getText("UI_ContextMenu_SetSpotter"), _, nil)
                    local spotter_menu = ISContextMenu:getNew(context)
                    context:addSubMenu(spotter_option, spotter_menu)
                    searchAndSetNearbySpotters(spotter_menu, player_obj)
                end
            end

            break

        end

    end

end
Events.OnFillWorldObjectContextMenu.Add(createOperateMortarContextMenu)
