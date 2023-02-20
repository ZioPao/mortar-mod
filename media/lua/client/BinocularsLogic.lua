

-- TODO Use GLobal Object thing as a base

local function HandleBinocularsClick(obj, x,y)

    local obj_x = obj:getX()
    local obj_y = obj:getY()

    print("Bino: clicked " .. obj_x .. " - " .. obj_x)

    -- TODO Can't handle Z with this method


    -- Send direct coordinates from the spotter
    Mortar.direct_coordinates = {obj_x, obj_y}


    Events.OnObjectLeftMouseButtonDown.Remove(HandleBinocularsClick)
end



function TestStuff()

    -- Force zoom out (Java limitation, we can't really tweak this too much
    for i=0, 10 do
        getCore():doZoomScroll(0, 1)

    end

    -- TODO Force max zoom out

    --Add on click event handler
    Events.OnObjectLeftMouseButtonDown.Add(HandleBinocularsClick)


end