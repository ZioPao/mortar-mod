-- When we pick up a mortar, we need to get its shell (if it has any) and delete its instance in Global Mod Data
local MortarClientData = require("Mortar_ClientData")

---@param obj IsoObject
local function HandleRemovedMortar(obj)
    if not MortarCommonFunctions.IsMortarSprite(obj:getSprite()) then return end

    local coords = { x = obj:getX(), y = obj:getY(), z = obj:getZ() }
    local id = MortarCommonFunctions.GetAssembledID(coords)

    local instance = MortarClientData.GetInstance(id)

    if instance then
        if instance:getIsReloaded() then
            -- Give back the shell to the player
            local plInv = getPlayer():getInventory()
            plInv:AddItem("Mortar.MortarRound")
        end

        MortarClientData.DestroyInstance(id)
    end
end


Events.OnTileRemoved.Add(HandleRemovedMortar)
