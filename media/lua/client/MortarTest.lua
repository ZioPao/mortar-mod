


function testBoom(pl, bommX, bommY, bommZ, Xtype)
    local args = {
        x = bommX,
        y = bommY,
        z = bommZ
    }
    sendClientCommand(pl, 'object', Xtype, args)
    -- getSoundManager():PlayWorldSound("explode",  trajectory, 0, Mortar.distMax*2, 1.0, false);
end
--[[
--local Xtype = 'addFireOnSquare'
local Xtype = 'addExplosionOnSquare'
local pl = getPlayer()
testBoom(pl, 11964,6912,0,Xtype)
--local teleportto = {12329,6755,0}
local teleportto={11964,6912,0}
SendCommandToServer(tostring("/teleportto \"".. teleportto[1]..','..teleportto[2]..','..teleportto[3]  .."\" " .. " \""))
 ]]

-- sendClientCommand(pl, 'object', 'addExplosionOnSquare', args)
-- sendClientCommand(pl, 'object', 'addFireOnSquare', args)



--[[
function ISWorldObjectContextMenu.getSquaresInRadius(worldX, worldY, worldZ, radius, doneSquares, squares)
	local minX = math.floor(worldX - radius)
	local maxX = math.ceil(worldX + radius)
	local minY = math.floor(worldY - radius)
	local maxY = math.ceil(worldY + radius)
	for y = minY,maxY do
		for x = minX,maxX do
			local square = getCell():getGridSquare(x, y, worldZ)
			if square and not doneSquares[square] then
				doneSquares[square] = true
				table.insert(squares, square)
			end
		end
	end
end

local x,y,z = getPlayer():getX(), getPlayer():getY(), getPlayer():getZ()
getGameTime():getModData()['MortarHit'] ='wew'
print(getGameTime():getModData()['MortarHit'])
getGameTime():getModData()[
]]
