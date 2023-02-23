--===================================--
--[[ MORTAR MOD - BINOCULARS LOGIC ]]--
--===================================--

-- TODO Use GLobal Object thing as a base
require "MortarCheckAxisZ"

local function HandleBinocularsClick(obj, x,y)

    Events.OnObjectLeftMouseButtonDown.Remove(HandleBinocularsClick)
    if Mortar.bomber == nil then
        print("Mortar: no bomber available for this spotter. Won't send coordinates")
        return
    end
    local obj_x = obj:getX()
    local obj_y = obj:getY()

    print("Bino: clicked " .. obj_x .. " - " .. obj_x)

    -- TODO Can't handle Z with this method


    -- Send direct coordinates from the spotter
    Mortar.direct_coordinates = {obj_x, obj_y}


    -- After the removal in case of errors
    -- TODO make sure to make the bomber ti face the direction of the target 	getPlayer():setDir(x,y)
    sendClientCommand(getPlayer(), "Mortar", "sendDirectCoordinates", {bomber_id = Mortar.bomber:getOnlineID(), x = obj_x, y = obj_y})

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