local MortarShotHandler = {}

---Kill entities within a square
---@param sq IsoGridSquare
function MortarShotHandler.KillEntities(sq)
    local entities = sq:getMovingObjects()
    if entities == nil then return end

    for i = 0, entities:size() - 1 do
        local entity = entities:get(i)
        if (instanceof(entity, "IsoZombie") or instanceof(entity, "IsoPlayer")) and not entity:isGodMod() then
            entity:Kill(entity)
        end
    end
end

---Spawn some tiles that looks like debris
---@param sq IsoGridSquare
function MortarShotHandler.SpawnDebris(sq)
    local debrisObj = IsoObject.new(sq, "mortar_" .. ZombRand(63) - 8, "", false)
    sq:AddTileObject(debrisObj)
    if isClient() then
        debrisObj:transmitCompleteItemToServer()
    end
end

---Gets a command, could be fire or just smoke
---@return string
function MortarShotHandler.GetRandomCommand()
    local vanillaCommand = 'addFireOnSquare'
    if MortarCommonFunctions.RollChance(20) then
        vanillaCommand = 'addSmokeOnSquare'
    end

    return vanillaCommand
end

---Check if the current sq should be considered in the explosion
---@param ogCoords table x,y,z
---@param currCoords table x,y,z
---@param rad number
---@return boolean
function MortarShotHandler.CheckExplosionRad(ogCoords, currCoords, rad)
    return IsoUtils.DistanceTo(ogCoords.x, ogCoords.y, currCoords.x + 0.5, currCoords.y + 0.5) <= rad
end

---Main function which handles shooting from a mortar.
---@param hitCoords table x,y,z
function MortarShotHandler.Fire(hitCoords)
    local rad = ZombRand(3, MortarCommonVars.rad)
    local z = MortarCommonFunctions.GetHighestZ(hitCoords.x, hitCoords.y)

    --self:generateShot(coords.x, coords.y, z, finalRad)

    local cell = getWorld():getCell()
    local pl = getPlayer()
    sendClientCommand(pl, MRT_COMMON.SERVER_COMMON_COMMAND, 'SendMuzzleFlash', {operatorID = pl:getOnlineID() })

    for x = hitCoords.x - rad, hitCoords.x + rad + 1 do
        for y = hitCoords.y - rad, hitCoords.y + rad + 1 do
            local currCoords = { x = x, y = y, z = z }

            if not MortarShotHandler.CheckExplosionRad(hitCoords, currCoords, rad) then
                break
            end

            local sq = cell:getGridSquare(x, y, z)

            -- Safehouses should be skipped
            local safehouse = SafeHouse.getSafeHouse(sq)
            if safehouse then break end

            -- Fire or smoke
            local command = MortarShotHandler.GetRandomCommand()
            if MortarCommonFunctions.RollChance(60) then
                sendClientCommand(getPlayer(), 'object', command, { x = x, y = y, z = z })
            end

            -- Debris and explosions spawning
            if MortarCommonFunctions.RollChance(40) then
                MortarShotHandler.SpawnDebris(sq)
                -- TODO Add explosion thing
            end

            -- Kill entities
            MortarShotHandler.KillEntities(sq)
        end
    end
end

return MortarShotHandler
