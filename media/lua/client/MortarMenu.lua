
local spotter_table = {}

local SetSpotter = function(_, player)
    print("Mortar: Setting spotter")

    Mortar.spotter = player

    -- TODO Manage cases where the spotter dies
    -- TODO Manage case when the player stopped using the mortar (should unset the spotter)
end
local SearchForSpotter = function(operator, mortar_menu, world_obj)
    -- TODO This is limited by the cell. Won't work.
    print("Mortar: Searching spotter")

    -- We need to get a list of the players within a certain distance.
    --

    local players = getOnlinePlayers()
    local acceptable_spotters = {}
    for i = 0, 1 do
        local pl = players:get(i)
        if pl ~= operator then
            -- Check distance
            local dist = pl:getDistanceSq(operator)
            if dist < 150 then          -- TODO Set a correct distance, maybe via SandboxVars
                print("Mortar: Found acceptable spotter => " .. tostring(i))
                mortar_menu:addOption(getText("UI_ContextMenu_Spotter") .. pl:getUsername(), _, SetSpotter, pl)
            end
        end
    end
end

local SendStartFiringToServer = function(_)



    if Mortar.spotter ~= nil then
        local op_id = getPlayer():getOnlineID()
        local spotter_id = Mortar.spotter:getOnlineID()
        sendClientCommand(getPlayer(), "Mortar", "AcceptMortarShot", {operator = op_id, spotter = spotter_id})


    else
        print("Can't send command, no spotter")
    end

end


local CreateMortarContextMenu = function(player, context, world_objects, _)

    local player_obj = getSpecificPlayer(player)
    local mortar_menu
    local root_menu
    spotter_table = {}        -- Reset
    local dist = 30 --player_obj:getModData()['mortarDistance'] or 8

    -- TODO won't work on old spawned mortars
    for _, v in pairs(world_objects) do

        local sprite = v:getSprite()
        if sprite ~= nil then
            local sprite_name = sprite:getName()
            if v and luautils.stringStarts(sprite_name, "mortar_") then

                if mortar_menu == nil then
                    mortar_menu = context:getNew(context)
                    root_menu = context:addOption(getText("UI_ContextMenu_OperateMortar"), world_objects, nil)

                    context:addSubMenu(root_menu, mortar_menu)

                    shoot_option = mortar_menu:addOption(getText("UI_ContextMenu_ShootMortar"), nil, SendStartFiringToServer)      -- TODO Set the sandboxvars

                    -- TODO Set distance
                    -- Distance should be handled by the spotter... Can't do it automatically, it wouldn't make any sense and it would be forever broken

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
