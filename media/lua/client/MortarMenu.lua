
local spotter_table = {}

local SetSpotter = function(_, player)
    print("Mortar: Setting spotter")

    Mortar.spotter = player

    -- TODO Manage cases where the spotter dies
end


local CheckSpotterForWalkieTalkie = function(spotter)

    local accepted_item = "Radio.WalkieTalkie"


    local primary_hand_item = spotter:getPrimaryHandItem()
    local secondary_hand_item = spotter:getSecondaryHandItem()


    if primary_hand_item then
        local primary_item_type = primary_hand_item:getFullType()

        if string.find(primary_item_type,accepted_item) then
            return true
        end

    elseif secondary_hand_item then
        local secondary_item_type = secondary_hand_item:getFullType()

        if string.find(secondary_item_type, accepted_item) then
            return true
        end
    end

    return false


end


local SearchForSpotter = function(mortar_menu, world_obj)
    -- TODO Search the cell for a player with something on him like a radio
    print("Mortar: Searching spotter")
    for x = world_obj:getSquare():getX() - 1, world_obj:getSquare():getX() + 1 do
        for y = world_obj:getSquare():getY() - 1, world_obj:getSquare():getY() + 1 do
            local sq = getCell():getGridSquare(x,y,world_obj:getSquare():getZ())

            if sq then
                for i = 0, sq:getMovingObjects():size() - 1 do
                    local obj = sq:getMovingObjects():get(i)

                    if instanceof(obj, "IsoPlayer") then

                        if spotter_table[obj:getUsername()] == nil then
                            spotter_table[obj:getUsername()] = true

                            print("Checking player for spotter")
                            local walkietalkie_check = CheckSpotterForWalkieTalkie(obj)
                            if walkietalkie_check then
                                mortar_menu:addOption(getText("UI_ContextMenu_Spotter") .. obj:getUsername(), _, SetSpotter, obj)
                            end

                        end
                    end
                end
            end
        end
    end
end




local CreateMortarContextMenu = function(player, context, world_objects, _)

    --local player_obj = getSpecificPlayer(player)
    local mortar_menu
    local root_menu
    spotter_table = {}        -- Reset

    for _, v in pairs(world_objects) do
        -- TODO Check if v is a mortar
        if instanceof(v, "IsoObject") then      -- TODO This should check if it's the mortar

            if mortar_menu == nil then
                mortar_menu = context:getNew(context)
                root_menu = context:addOption(getText("UI_ContextMenu_OperateMortar"), world_objects, nil)
            end

            context:addSubMenu(root_menu, mortar_menu)
            SearchForSpotter(mortar_menu, v)




            -- TODO add the options such as
            -- 1) Set spotter
            -- 2) Reload mortar?
            -- 3) Something else

        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(CreateMortarContextMenu)
