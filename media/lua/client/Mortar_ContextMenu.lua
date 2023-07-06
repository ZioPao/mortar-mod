
-- TODO Simplify this, we don't need all this stuff here. Just handle it from the UI

local MortarHandler = require("Mortar_ClientHandler")


-- TODO Move this to the UI. We don't need to deal with this crap from here
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

                    spotterMenu:addOption(username, _, function() MortarHandler.GetInstance():setSpotter(pl) end)
                end
            end
        end
    end

end

local function CreateMortarContextMenu(playerId, context, worldObjects, _)

    if worldObjects[1] == nil then return end
    local clickedObj = worldObjects[1]
    if clickedObj:getSprite() and MortarCommonFunctions.IsMortarSprite(clickedObj:getSprite():getName()) then
        local mortarX = clickedObj:getX()
        local mortarY = clickedObj:getY()
        local mortarZ = clickedObj:getZ()

        context:addOption(getText("UI_ContextMenu_OperateMortar"), clickedObj, MortarUI.OnOpenPanel({x=mortarX, y=mortarY, z=mortarZ}))
    end

    
end

Events.OnFillWorldObjectContextMenu.Add(CreateMortarContextMenu)
