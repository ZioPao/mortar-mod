
local spotter_table = {}

local PredicateMortarShell = function(item)
    if item:isBroken() then return false end
    return item:hasTag("Mortar.round") or item:getFullType() == "Mortar.round"
end



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

    --if not isClient() and not isServer()
    --
    --end
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



---------------------------------------------------------------------------


-- Operate the mortar menu
local CreateOperateMortarContextMenu = function(player, context, world_objects)

    local root_menu
    local mortar_menu

    for _, v in pairs(world_objects) do
        local square = v:getSquare()
        print(v:getSprite():getName())

        print(MortarRotation.isMortar(v:getSprite():getName()))


        if v:getSprite() and MortarRotation.isMortar(v:getSprite():getName()) then
            mortar_menu = context:getNew(context)


            if Mortar.GetBomber(player) then
                root_menu = context:addOption(getText("UI_ContextMenu_StopOperatingMortar"), world_objects, function() MortarUI:close() end)
            else
                -- TODO I think it's the opposite, check it out
                root_menu = context:addOption(getText("UI_ContextMenu_OperateMortar"), world_objects, function() Mortar.SetBomber(player) end)

            end


            context:addSubMenu(root_menu, mortar_menu)


            -- TODO Set it so we can't access it if sp
            if isClient() then
                if SandboxVars.Mortar.NecessarySpotter  then
                    SearchForSpotter(player_obj, mortar_menu, v)
                end
            end

            break

        end

    end

end

Events.OnFillWorldObjectContextMenu.Add(CreateOperateMortarContextMenu)













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
            if v:getSprite() and MortarRotation.isMortar(v:getSprite():getName()) then

                if mortar_menu == nil then
                    mortar_menu = context:getNew(context)
                    root_menu = context:addOption(getText("UI_ContextMenu_OperateMortar"), world_objects, nil)

                    context:addSubMenu(root_menu, mortar_menu)

                    shoot_option = mortar_menu:addOption(getText("UI_ContextMenu_ShootMortar"), nil, SendStartFiringToServer)      -- TODO Set the sandboxvars
                    if not player:getInventory():containsEvalRecurse(PredicateMortarShell) then
                        self:addTooltip(option, getText("Tooltip_RequireMortarShell"))
                    end
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
