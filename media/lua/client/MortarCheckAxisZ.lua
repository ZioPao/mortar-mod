
function MortarFloorTest(cx,cy)
	local cz = 8
	for i = 0, 8-1  do
		cz=cz-1
		local check = getCell():getGridSquare(cx, cy, cz )
		print(cz); print(check)
	end
end

--[[ 
--to test
MortarFloorTest(getPlayer():getX(), getPlayer():getY())
 ]]
 ------------------------               ---------------------------

function MortarGetHighestZ(cx,cy)
	local cz = 8
	for i = 0, 8-1  do
		cz=cz-1
		local check = getCell():getGridSquare(cx, cy, cz )		
		if check then
			print(cz); print(check)	
			return cz
		end
	end
end

--[[ 
--to test
MortarGetHighestZ(getPlayer():getX(), getPlayer():getY())
 ]]