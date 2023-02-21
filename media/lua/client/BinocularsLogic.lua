--====================================--
--[[ MORTAR MOD - BINOCULARS LOGIC--]]--
--====================================--

-- TODO Use GLobal Object thing as a base

local function HandleBinocularsClick(obj, x,y)

    Events.OnObjectLeftMouseButtonDown.Remove(HandleBinocularsClick)

    local obj_x = obj:getX()
    local obj_y = obj:getY()

    print("Bino: clicked " .. obj_x .. " - " .. obj_x)

    -- TODO Can't handle Z with this method


    -- Send direct coordinates from the spotter
    Mortar.direct_coordinates = {obj_x, obj_y}


    -- After the removal in case of errors
    sendClientCommand(getPlayer(), "Mortar", "SendDirectCoordinates", {bomber_id = Mortar.bomber:getOnlineID(), x = obj_x, y = obj_y})

end


-- TODO Bind this to the item
function TestBinoculars()

    -- Force zoom out (Java limitation, we can't really tweak this too much
    for i=0, 10 do
        getCore():doZoomScroll(0, 1)

    end

    -- TODO Force max zoom out

    --Add on click event handler
    Events.OnObjectLeftMouseButtonDown.Add(HandleBinocularsClick)


end