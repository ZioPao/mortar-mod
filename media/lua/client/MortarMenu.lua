
local spotter_table = {}

local SetSpotter = function(_, player)
    print("Mortar: Setting spotter")

    Mortar.spotter = player

    -- TODO Manage cases where the spotter dies
    -- TODO Manage case when the player stopped using the mortar (should unset the spotter)
end




local SearchForSpotter = function(operator, mortar_menu, world_obj)
    -- TODO Search the cell for a player with something on him like a radio
    print("Mortar: Searching spotter")
    for x = world_obj:getSquare():getX() - 1, world_obj:getSquare():getX() + 1 do
        for y = world_obj:getSquare():getY() - 1, world_obj:getSquare():getY() + 1 do
            local sq = getCell():getGridSquare(x,y,world_obj:getSquare():getZ())

            if sq then
                for i = 0, sq:getMovingObjects():size() - 1 do
                    local obj = sq:getMovingObjects():get(i)

                    if instanceof(obj, "IsoPlayer") then

                        if obj:getUsername() ~= operator:getUsername() then
                            if spotter_table[obj:getUsername()] == nil then
                                spotter_table[obj:getUsername()] = true

                                print("Checking player for spotter")
                                local walkietalkie_check = Mortar.CheckSpotterForWalkieTalkie(obj)
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
end




local CreateMortarContextMenu = function(player, context, world_objects, _)

    local player_obj = getSpecificPlayer(player)
    local mortar_menu
    local root_menu
    spotter_table = {}        -- Reset
    local dist = player_obj:getModData()['mortarDistance'] or 8

    -- TODO won't work on old spawned mortars
    for _, v in pairs(world_objects) do
        local sprite = v:getSpriteName()
        if sprite ~= nil then
            print(sprite_name)
            if v and luautils.stringStarts(sprite, "mortar_weapon_") then

                if mortar_menu == nil then
                    mortar_menu = context:getNew(context)
                    root_menu = context:addOption(getText("UI_ContextMenu_OperateMortar"), world_objects, nil)

                    context:addSubMenu(root_menu, mortar_menu)

                    shoot_option = mortar_menu:addOption(getText("UI_ContextMenu_ShootMortar"), nil, Mortar.StartFiring, 10, dist )

                    -- TODO Set distance


                    -- TODO Set Range

                    disassemble_option = mortar_menu:addOption(getText("UI_ContextMenu_DisassembleMortar"), world_objects, Mortar.Disassemble)

                end

                if SandboxVars.Mortar.NecessarySpotter then
                    SearchForSpotter(player_obj, mortar_menu, v)
                end

                -- TODO add the options such as
                -- 1) Set spotter
                -- 2) Reload mortar?
                -- 3) Something else

                break       -- Stop searching for a mortar after one is found

            end

        end


    end
end
Events.OnFillWorldObjectContextMenu.Add(CreateMortarContextMenu)
