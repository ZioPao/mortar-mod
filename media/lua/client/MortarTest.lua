


function testBoom(pl, bommX, bommY, bommZ, Xtype)
    local args = {
        x = bommX,
        y = bommY,
        z = bommZ
    }
    sendClientCommand(pl, 'object', Xtype, args)
    -- getSoundManager():PlayWorldSound("explode",  trajectory, 0, Mortar.distMax*2, 1.0, false);
end
