

local SetSpotter = function(sq, player)
    print("Mortar: Setting spotter")

    Mortar.spotter = player

    -- TODO Manage cases where the spotter dies
end


local SearchForSpotter = function(operator_player)
    -- TODO Search the cell for a player with something on him like a radio
    print("Mortar: Searching spotter")

    -- TODO search player in zone



    -- TODO Check if the player is holding a radio item
    return getPlayer()

end




local CreateMortarContextMenu = function(player, context, world_objects, _)
    local player_obj = getSpecificPlayer(player)

    for _, v in pairs(world_objects) do
        -- TODO Check if v is a mortar
        if instanceof(v, "IsoObject") then      -- TODO This should check if it's the mortar
            local mortar_menu = context:getNew(context)
            local root_menu = context:addOption(getText("UI_ContextMenu_OperateMortar"), world_objects, nil)
            context:addSubMenu(root_menu, mortar_menu)


            for x = v:getSquare():getX() - 1, v:getSquare():getX() + 1 do
                for y = v:getSquare():getY() - 1, v:getSquare():getY() + 1 do
                    local sq = getCell():getGridSquare(x,y,v:getSquare():getZ())

                    if sq then
                        for i = 0, sq:getMovingObjects():size() - 1 do
                            local obj = sq:getMovingObjects():get(i)

                            if instanceof(obj, "IsoPlayer") then
                                print("Checking player for spotter")
                                mortar_menu:addOption(getText("UI_ContextMenu_Spotter") .. obj:getUsername(), world_objects, SetSpotter, obj)

                            end

                        end
                    end

                end
            end


            -- TODO add the options such as
            -- 1) Set spotter
            -- 2) Reload mortar?
            -- 3) Something else

        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(CreateMortarContextMenu)
