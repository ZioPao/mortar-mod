


MortarBomber = {}



------------------------------------
function MortarBomber:new()


    -- TODO HEAVILY WIP AND NOT FINISHED!!!!



        -- TODO Let this run when we spawn a mortar item\tile
        print("Mortar: Instancing new one")
        local o = {}
    
        setmetatable(o, self)
    
        self.__index = self
        o.bomber = nil
        o.linked_spotter = nil
        o.object = nil        -- Should be the item\tile that's linked to this instance
    
        o.coordinates = nil
    
        MortarBomber.instance = o
    
        return o
    
    

end

------------------------------------

function MortarBomber:setPlayer(player)
    self.o.player = player
end

function MortarBomber:setLinkedSpotter(player)
    self.o.linked_spotter = player
end

function MortarBomber:setCoordinates(x,y)
    self.o.coordinates = {x,y}
end

function MortarBomber:setObject(obj)
    self.o.object = obj
end

-------------------------------------



function MortarBomber:startFiring()



end


