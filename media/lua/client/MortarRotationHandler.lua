-- Define the Mortartileobj table outside of the sprChecker function to avoid creating it every time the function is called.

-- TODO Made it global just as a workaround for now, it's needed to check stuff in MortarContextMenu
Mortartileobj = {
    ["N"] = "mortar_56",
    ["NE"] = "mortar_57",
    ["E"] = "mortar_58",
    ["SE"] = "mortar_59",
    ["S"] = "mortar_60",
    ["SW"] = "mortar_61",
    ["W"] = "mortar_62",
    ["NW"] = "mortar_63",
}


-- Define the getMortar function.
local function findMortarNearPlayer()
    local player = getPlayer()
    local square = player:getCurrentSquare()
    for i=0, square:getObjects():size()-1 do
        local obj = square:getObjects():get(i)
        if instanceof(obj, "IsoObject") and obj:getSprite() and MortarCommonFunctions.isMortarSprite(obj:getSprite():getName()) then
            return obj
        end
    end
end

-- Define the MortarRotDirection function.
local function MortarRotDirection()
    local player = getPlayer()
    local mortar = findMortarNearPlayer()
    if not mortar then return end
    
    local newtile = MortarRotation.tileobj[tostring(player:getDir())]
    mortar:setSprite(newtile)
    mortar:getSprite():setName(newtile)

    if isClient() then
        mortar:transmitUpdatedSpriteToServer()
        mortar:transmitUpdatedSpriteToClients()
        mortar:transmitCompleteItemToServer()
    end

    getPlayerLoot(0):refreshBackpacks()
    ISInventoryPage.dirtyUI();
end

-- Register the MortarRotDirection function with the OnPlayerMove event.
Events.OnPlayerMove.Add(MortarRotDirection)
