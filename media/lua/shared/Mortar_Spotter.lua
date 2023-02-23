--==================================--
--[[ MORTAR MOD - SPOTTER HANDLER ]]--
--==================================--

if MortarSpotter == nil then
    MortarSpotter = {}
end


------------------------------------
function MortarSpotter:new(player)

    print("Mortar: instancing new spotter")

    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.spotter = player
    o.linkedBomber = nil
    o.weaponInstance = nil

    o.coordinates = nil

    MortarSpotter.instance = o

    return o
end



------------------------------------

function MortarBomber:setPlayer(player)
    self.o.player = player
end

function MortarBomber:setLinkedSpotter(player)
    self.o.linkedSpotter = player
end

function MortarBomber:setCoordinates(x,y)
    self.o.coordinates = {x,y}
end

function MortarBomber:setWeaponInstance(weaponInstance)
    self.o.weaponInstance = weaponInstance
end

-------------------------------------



function MortarBomber:startFiring()



end


