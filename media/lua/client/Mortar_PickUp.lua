local DataHandler = require("Mortar_DataHandler")

--- When we pick up a mortar, we need to get its shell (if it has any) and delete its instance in Global Mod Data
---@param obj IsoObject
local function HandleRemovedMortar(obj)
    if not MortarCommonFunctions.IsMortarSprite(obj:getSprite():getName()) then return end

    local coords = { x = obj:getX(), y = obj:getY(), z = obj:getZ() }
    local id = MortarCommonFunctions.GetAssembledID(coords)

    local instance = DataHandler.GetInstance(id)

    if instance then
        if instance:getIsReloaded() then
            -- Give back the shell to the player
            local plInv = getPlayer():getInventory()
            plInv:AddItem("Mortar.MortarRound")
        end

        DataHandler.DestroyInstance(id)
    else
        print("Didn't found instance")
    end
end



local ogISMoveableSpritePropsPickUpMoveable = ISMoveableSpriteProps.pickUpMoveable

function ISMoveableSpriteProps:pickUpMoveable( _character, _square, _createItem, _forceAllow )

    print("Pick Up Moveable")
    if self.isMoveable and instanceof(_character,"IsoGameCharacter") and instanceof(_square,"IsoGridSquare") then
        local obj, sprInstance = self:findOnSquare( _square, self.spriteName )
        HandleRemovedMortar(obj)

    end

    ogISMoveableSpritePropsPickUpMoveable(self, _character, _square, _createItem, _forceAllow)
end

--Events.OnTileRemoved.Add(HandleRemovedMortar)
