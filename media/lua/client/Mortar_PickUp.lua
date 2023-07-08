local DataHandler = require("Mortar_DataHandler")

--- When we pick up a mortar, we need to get its shell (if it has any) and delete its instance in Global Mod Data
---@param obj IsoObject
local function HandleRemovedMortar(obj)
    local coords = { x = obj:getX(), y = obj:getY(), z = obj:getZ() }
    local id = MortarCommon.GetAssembledID(coords)

    local instance = DataHandler.GetInstance(id)

    if instance then
        if instance:getIsReloaded() then
            -- Give back the shell to the player
            local plInv = getPlayer():getInventory()
            plInv:AddItem("Mortar.MortarRound")
        end

        DataHandler.DestroyInstance(id)
    end
end

local ogISMoveableSpritePropsPickUpMoveable = ISMoveableSpriteProps.pickUpMoveable

function ISMoveableSpriteProps:pickUpMoveable(_character, _square, _createItem, _forceAllow)
    if self.isMoveable and instanceof(_character, "IsoGameCharacter") and instanceof(_square, "IsoGridSquare") then
        local obj, _ = self:findOnSquare(_square, self.spriteName)
        if obj ~= nil and MortarCommon.IsMortarSprite(obj:getSprite():getName()) then
            HandleRemovedMortar(obj)
        end
    end

    ogISMoveableSpritePropsPickUpMoveable(self, _character, _square, _createItem, _forceAllow)
end
