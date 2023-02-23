--=================================--
--[[ MORTAR MOD - BOMBER HANDLER ]]--
--=================================--

if MortarBomber == nil then
    MortarBomber = {}
end


------------------------------------
function MortarBomber:new(player)

    print("Mortar: instancing new bomber")

    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.bomber = player
    o.linkedSpotter = nil
    o.weaponInstance = nil

    o.coordinates = nil

    MortarBomber.instance = o

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


