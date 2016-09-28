-----------------------------------------------------------------------------------------
--
-- level 1 meta data and functions
--
-----------------------------------------------------------------------------------------
local myData = require("myData")

local M={}


-- "n" stands for an empty place
-- "w" stands for a wall
-- "p" stands for a player
-- "m" stands for mobs
-- "r" stands for removable obstacle
M.map = {
	{"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w"},
	{"w", "p", "n", "r", "m", "r", "n", "n", "n", "n", "m", "n", "r", "n", "n", "n", "n", "r", "w"},
	{"w", "n", "w", "r", "w", "n", "w", "r", "w", "r", "w", "r", "w", "n", "w", "n", "w", "r", "w"},
	{"w", "n", "n", "r", "n", "n", "n", "n", "n", "r", "n", "n", "n", "n", "n", "n", "n", "n", "w"},
	{"w", "n", "w", "n", "w", "n", "w", "n", "w", "r", "w", "n", "w", "n", "w", "n", "w", "n", "w"},
	{"w", "n", "n", "n", "n", "n", "n", "n", "n", "r", "n", "n", "n", "n", "n", "n", "n", "n", "w"},
	{"w", "n", "w", "n", "w", "n", "w", "n", "w", "r", "w", "n", "w", "n", "w", "m", "w", "n", "w"},
	{"w", "n", "n", "n", "n", "n", "n", "n", "n", "r", "n", "n", "n", "n", "n", "n", "n", "n", "w"},
	{"w", "r", "w", "n", "w", "n", "w", "n", "w", "r", "w", "n", "w", "n", "w", "n", "w", "n", "w"},
	{"w", "n", "r", "n", "n", "n", "r", "n", "r", "r", "n", "n", "n", "n", "n", "n", "n", "n", "w"},
	{"w", "n", "w", "n", "w", "n", "w", "r", "w", "r", "w", "r", "w", "r", "w", "r", "w", "l", "w"},
	{"w", "m", "r", "n", "n", "n", "n", "n", "n", "r", "n", "r", "n", "m", "n", "n", "n", "n", "w"},
	{"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w"}
}


M.nextL = { -- indexes of entrance to the next level
	r = 11,
	c = 18
} 


M.grid = {} -- 2d table for indexes


--function that determines coordinates for our grid system, later we will use this coordinates to place level objects and move payer with monsters
--we save our coordinates in 2D table M.grid with keys *.x and *.y
function M.createGrid( sceneGroup) -- c is a number of columns, r is a number of rows
    blockSize = myData.fullH/myData.rows
    local xCoordinate = (myData.fullW-(blockSize*myData.columns))/2+blockSize/2
    local yCoordinate = blockSize/2

    for i=1,myData.rows do
        M.grid[i] = {}
        for j=1,myData.columns do
            M.grid[i][j] = {
                x = xCoordinate,
                y = yCoordinate
            }
            M.grid[i][j] = display.newRect( xCoordinate, yCoordinate, blockSize, blockSize )
            M.grid[i][j]:setFillColor( unpack( myData.emptyspaceOutlook) )
            sceneGroup:insert( M.grid[i][j] )
            M.grid[i][j].status = "empty" -- can be empty, wall, player, mob, bomb ...
            xCoordinate = xCoordinate + blockSize
        end
        xCoordinate = (myData.fullW-(blockSize*myData.columns))/2+blockSize/2
        yCoordinate = yCoordinate + blockSize
    end

    --this block of code prints our coordinates 
    -- local temp = ""
    -- for i=1,myData.rows do
    --     for j=1,myData.columns do
    --         temp = temp.."["..i.."]["..j.."]="..string.format("%1.1f", M.grid[i][j].x)..","..string.format("%1.1f", M.grid[i][j].y).." "
    --     end
    --     print(temp)
    --     temp = ""
    -- end    
end



M.player = {}
M.walls = {}
M.mobs = {}
M.removable = {}
M.nextLevel = nil

--function uses grid system created in previous function and table M.map with "map" of our level
function M.createObjects(sceneGroup )
    
    for i=1,myData.rows do
        for j=1,myData.columns do
            if M.map[i][j] == "w" then
                M.walls[#M.walls+1] = display.newImageRect( "images/level1/w.png" , blockSize, blockSize)
                M.walls[#M.walls].x = M.grid[i][j].x
                M.walls[#M.walls].y = M.grid[i][j].y
                M.grid[i][j].status = "wall"
                sceneGroup:insert( M.walls[#M.walls] )
            elseif M.map[i][j] == "n" then
                M.grid[i][j].status = "empty"
            elseif M.map[i][j] == "p" then
                M.player = display.newImageRect( "images/level1/bm.png" , blockSize, blockSize)
                M.player.x = M.grid[i][j].x
                M.player.y = M.grid[i][j].y
                M.grid[i][j].status = "player"
                M.player.r = i
                M.player.c = j
                sceneGroup:insert( M.player )             
            elseif M.map[i][j] == "m" then
                M.mobs[#M.mobs+1] = {}
                M.mobs[#M.mobs] = display.newImageRect( "images/level1/m.png" , blockSize, blockSize)
                M.grid[i][j].status = "mob"
                M.mobs[#M.mobs].x = M.grid[i][j].x
                M.mobs[#M.mobs].y = M.grid[i][j].y                
                M.mobs[#M.mobs].r = i
                M.mobs[#M.mobs].c = j
                sceneGroup:insert(  M.mobs[#M.mobs] )
            elseif M.map[i][j] == "r" then
                M.removable[#M.removable+1] = {}
                M.removable[#M.removable] = display.newImageRect( "images/level1/removable.jpg" , blockSize, blockSize)
                M.grid[i][j].status = "removable"
                M.removable[#M.removable].x = M.grid[i][j].x
                M.removable[#M.removable].y = M.grid[i][j].y                
                M.removable[#M.removable].r = i
                M.removable[#M.removable].c = j
                sceneGroup:insert(  M.removable[#M.removable] )
            elseif M.map[i][j] == "l" then
                M.nextLevel = display.newImageRect( "images/level1/nextl.png" , blockSize, blockSize)
                M.nextLevel.x = M.grid[i][j].x
                M.nextLevel.y = M.grid[i][j].y
                sceneGroup:insert(  M.nextLevel )
                M.removable[#M.removable+1] = {}
                M.removable[#M.removable] = display.newImageRect( "images/level1/removable.jpg" , blockSize, blockSize)
                M.grid[i][j].status = "removable"
                M.removable[#M.removable].x = M.grid[i][j].x
                M.removable[#M.removable].y = M.grid[i][j].y                
                M.removable[#M.removable].r = i
                M.removable[#M.removable].c = j
                sceneGroup:insert(  M.removable[#M.removable] )
            end
        end
        
    end 
end

return M
