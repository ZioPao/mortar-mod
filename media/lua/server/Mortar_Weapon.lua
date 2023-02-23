--================================--
--[[ MORTAR MOD - WEAPON HANDLER ]]--
--================================--
-- Server Only, this needs to be synced between everyone


if MortarWeapon == nil then
    MortarWeapon = {}
    MortarWeapon.instances = {}
end


------------------------------------
function MortarWeapon:new(x, y, z)

    print("Mortar: instancing new mortar weapon")

    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.tileX = x
    o.tileY = y
    o.tileZ = z

    o.isRoundInChamber = false

    table.insert(MortarWeapon.instances, o)

    return o
end

------------------------------------
-- Setters\Getters
------------------------------------

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
    print("Mortar: saving instances")
    mortarModData["instances"] = MortarWeapon.instances
    ModData.transmit(MortarCommonVars.globalModDataId)

end
Events.OnServerStarted.Add(function()
    Events.EveryOneMinute.Add(MortarWeapon.SaveInstances)
end)

-----------------------------------------------
local function initGlobalModData()
    ModData.getOrCreate(MortarCommonVars.globalModDataId)
end
-- TODO OnPickup or deletion of mortar we should destroy the instance!!!
Events.OnInitGlobalModData.Add(initGlobalModData)