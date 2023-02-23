--================================--
--[[ MORTAR MOD - WEAPON HANDLER ]]--
--================================--
-- Server Only, this needs to be synced between everyone


if MortarWeapon == nil then
    MortarWeapon = {}
    MortarWeapon.instances = {}
end


------------------------------------
function MortarWeapon:new(tileObject)

    print("Mortar: instancing new mortar weapon")

    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.tileObj = tileObject
    o.isRoundInChamber = false

    table.insert(MortarWeapon.instances, o)

    return o
end

------------------------------------
-- Setters\Getters
------------------------------------

function MortarWeapon:setTileObject(tileObject)
    self.tileObj = tileObject
end

function MortarWeapon:getTileObject()
    return self.tileObj
end


function MortarWeapon:setIsRoundInChamber(check)
    self.isRoundInChamber = check
end
function MortarWeapon:getIsRoundInChamber()
    return self.isRoundInChamber
end

-----------------------------------
-- Save\Load handling
------------------------------------

function MortarWeapon.SaveInstances()
    local mortarModData = ModData.getOrCreate(MortarCommonVars.globalModDataId)

    mortarModData["instances"] = MortarWeapon.instances
    ModData.transmit(MortarCommonVars.globalModDataId)

end
Events.OnGameStart.Add(function()
    Events.EveryOneMinute.Add(MortarWeapon.SaveInstances)
end)

-----------------------------------------------
local function initGlobalModData()
    ModData.getOrCreate(MortarCommonVars.globalModDataId)
end

Events.OnInitGlobalModData.Add(initGlobalModData)