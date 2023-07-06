local MortarUI = require("Mortar_MainPanel")

local function CreateMortarContextMenu(_, context, worldObjects, _)
    if worldObjects[1] == nil then return end
    local clickedObj = worldObjects[1]
    if clickedObj:getSprite() and MortarCommonFunctions.IsMortarSprite(clickedObj:getSprite():getName()) then
        local mortarX = clickedObj:getX()
        local mortarY = clickedObj:getY()
        local mortarZ = clickedObj:getZ()

        context:addOption(getText("UI_ContextMenu_OperateMortar"), clickedObj,
            MortarUI.OnOpenPanel({ x = mortarX, y = mortarY, z = mortarZ }))
    end
end

Events.OnFillWorldObjectContextMenu.Add(CreateMortarContextMenu)
