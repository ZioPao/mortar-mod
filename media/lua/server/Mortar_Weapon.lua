--================================--
--[[ MORTAR MOD - WEAPON HANDLER ]]
                                    --
--================================--
-- Server Only, this needs to be synced between everyone

-- TODO OnPickup or deletion of mortar we should destroy the instance!!!

MortarWeapon = {}
MortarWeapon.instances = {}

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

    --local tempTable = {}
    --tempTable[id] = o

    MortarWeapon.instances[id] = o

    --table.insert(MortarWeapon.instances, tempTable)

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

function MortarWeapon.FindInstance(object)
    local x = object:getX()
    local y = object:getY()
    local z = object:getZ()

    if MortarWeapon.instances == nil then
        print("MortarMod: something wrong is going on in FindInstance, the instances table is nil")
    end


    for key, table in pairs(MortarWeapon.instances) do
        if table.tileX == x and table.tileY == y and table.tileZ == z then
            print("MortarInfo: found MortarWeapon instance in GlobalModData")
            print("MortarInfo: key " .. tostring(key))
            return table
        end
    end

    return nil
end

function MortarWeapon.TransmitInstances()

    -- TODO This is unreliable

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

    if MortarWeapon.FindInstance(sq) then
        print("MortarInfo: onLoadGridsquare instace already created before")
        return
    end


    local objects = sq:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        local sprite = obj:getSprite()

        if sprite ~= nil then
            local sprite_name = sprite:getName()
            local check = MortarCommonFunctions.IsMortarSprite(sprite_name)
            if check then
                print("Mortar: found object, instancing new MortarWeapon")
                MortarWeapon:new(x, y, z)
                break
            end
        end
    end
end

function MortarWeapon.DestroyInstance(object)
    -- FIXME pretty awful right now, redo it
    -- TODO Reload status will disappear with this method. We should pass it as modData to the object
    local instance = MortarWeapon.FindInstance(object)

    if instance then
        instance.tileX = nil
        instance.tileY = nil
        instance.tileZ = nil
        instance.isRoundInChamber = nil
    end
end

Events.OnObjectAboutToBeRemoved.Add(MortarWeapon.DestroyInstance)

