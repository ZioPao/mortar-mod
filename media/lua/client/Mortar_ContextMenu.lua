--local MortarUI = require("Mortar_MainPanel")

local function OpenMortarPanel(clickedObj)
    local mortarX = clickedObj:getX()
    local mortarY = clickedObj:getY()
    local mortarZ = clickedObj:getZ()
    MortarUI.Open({ x = mortarX, y = mortarY, z = mortarZ })
end


local function CreateMortarContextMenu(_, context, worldObjects, _)
    if worldObjects[1] == nil then return end
    local clickedObj = worldObjects[1]
    if clickedObj:getSprite() and MortarCommonFunctions.IsMortarSprite(clickedObj:getSprite():getName()) then
        context:addOption(getText("UI_ContextMenu_OperateMortar"), clickedObj,OpenMortarPanel)
    end
end

Events.OnFillWorldObjectContextMenu.Add(CreateMortarContextMenu)
