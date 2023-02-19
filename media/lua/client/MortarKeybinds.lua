
-- TODO Use dhert stuff as a base for this kind of things

local HandleMortarKeybinds = function(key)
    local pl = getPlayer()
    local dist = pl:getModData()['mortarDistance'] or 8
    if not pl then
        return
    end
    if (key == 83) then -- numpad .
        -- Mortar.init()
        Mortar.StartFiring(_,25, 95)
        return key
    end
    if (key == 211) then -- DEL
        local teleportto = {12329, 6755, 0}
        SendCommandToServer(tostring(
                "/teleportto \"" .. teleportto[1] .. ',' .. teleportto[2] .. ',' .. teleportto[3] .. "\" " .. " \""))
        return key
    end

    if (key == 79) then -- num1
        -- reduce distance
        local pl = getPlayer()
        local dist = pl:getModData()['mortarDistance']
        if dist > Mortar.distMin then
            dist = dist - Mortar.distSteps
        end
        pl:Say(tostring(dist));
        print(dist)
        return key
    end

    if (key == 80) then -- num2
        local pl = getPlayer()
        local dist = pl:getModData()['mortarDistance']
        if dist < Mortar.distMax then
            dist = dist - Mortar.distSteps
        end
        pl:Say(tostring(dist));
        print(dist)
        return key
    end

    if (key == 81) then -- num3
        pl:Say(tostring(dist))
        print('-------------')
        print('dist: ' .. dist)
        print('distMin: ' .. Mortar.distMin)
        print('distMax: ' .. Mortar.distMax)
        print('distSteps: ' .. Mortar.distSteps)
        print('-------------')
        return key
    end
    --[[     print(getPlayer():getSquare():getAdjacentSquare(getPlayer():getDir()):getX())
    print(getPlayer():getSquare():getAdjacentSquare(getPlayer():getDir()):getY())
    print(getPlayer():getSquare():getX())
    print(getPlayer():getSquare():getY()) ]]

end

Events.OnGameStart.Add(function()
    Events.OnKeyPressed.Remove(HandleMortarKeybinds)
    Events.OnKeyPressed.Add(HandleMortarKeybinds)
end)
