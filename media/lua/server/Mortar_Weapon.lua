--================================--
--[[ MORTAR MOD - WEAPON HANDLER ]]--
--================================--
-- Server Only, this needs to be synced between everyone

-- TODO OnPickup or deletion of mortar we should destroy the instance!!!

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


    local id = MortarCommonFunctions.GenerateUUID()

    local tempTable = {}
    tempTable[id] = o

    table.insert(MortarWeapon.instances, tempTable)

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

function MortarWeapon.TransmitInstances()
    local mortarModData = ModData.getOrCreate(MortarCommonVars.globalModDataId)
    --print("Mortar: saving instances")
    mortarModData["instances"] = MortarWeapon.instances
    ModData.transmit(MortarCommonVars.globalModDataId)

end
Events.OnServerStarted.Add(function()
    Events.EveryOneMinute.Add(MortarWeapon.TransmitInstances)
end)


function MortarWeapon.TryCreateNewInstance(sq)
    -- Checks already instanced weapons
    local x = sq:getX()
    local y = sq:getY()
    local z = sq:getZ()

    for _, v in pairs(MortarWeapon.instances) do

        for key, table in pairs(v) do
            if table.tileX == x and table.tileY == y and table.tileZ == z then
                print("Mortar Info: onLoadGridsquare instace already created before")
                return
            end
        end
    end


    local objects = sq:getObjects()
    for i=0, objects:size() - 1 do

        local obj = objects:get(i)
        local sprite = obj:getSprite()

        if sprite ~= nil then
            local sprite_name = sprite:getName()
            local check = MortarCommonFunctions.IsMortarSprite(sprite_name)
            if check then
                print("Mortar: found object, instancing new MortarWeapon")
                MortarWeapon:new(x,y,z)
                break
            end
        end

    end



end


-----------------------------------------------
local function initGlobalModData()
    local modData = ModData.getOrCreate(MortarCommonVars.globalModDataId)
    MortarWeapon.instances = modData['instances']

    print("MortarInfo: checking mod data received")

    for _,v in pairs(modData['instances']) do
        print("MortarInfo: loading " .. tostring(v))

        for _, value in pairs(v) do
            print(value.tileX)
            print(value.tileY)
            print(value.tileZ)
            print(value.isRoundInChamber)
        end
    end

    print("MortarInfo: finished loading mod data")

    Events.LoadGridsquare.Add(MortarWeapon.TryCreateNewInstance)

end
Events.OnInitGlobalModData.Add(initGlobalModData)