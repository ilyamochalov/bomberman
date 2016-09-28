local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()
local sceneGroup
local level = require("menumeta")
local myData = require("myData")
math.randomseed( os.time() )


-- -----------------------------------------------------------------------------------
-- JSON 
-- -----------------------------------------------------------------------------------
local loadsave = require("loadsave")
local file = system.pathForFile( "levels.json" , system.DocumentsDirectory)
local fhd1 = io.open( file )
local levels = nil

if fhd1 then
    print ("File esixts")
    fhd1:close( )
    levels = loadsave.loadTable("levels.json" , system.DocumentsDirectory)
else
    print("file doesn't exist")

    levels={
        true,
        false
    }
    loadsave.saveTable(levels, "levels.json" , system.DocumentsDirectory)
    levels = loadsave.loadTable("levels.json" , system.DocumentsDirectory)
end

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local mobsMoveTimer = nil
local bLevel1 = nil
local bLevel2 = nil


-- -----------------------------------------------------------------------------------
-- functions for mobs 
-- -----------------------------------------------------------------------------------

--function returns the table with possible direction mob can move to
local function mobCanMove( i )
    local answer = {}

    if (level.grid[level.mobs[i].r][level.mobs[i].c+1].status ~= "wall") and (level.grid[level.mobs[i].r][level.mobs[i].c+1].status ~= "removable") then
        answer[#answer+1] = "right"
    end

    if (level.grid[level.mobs[i].r][level.mobs[i].c-1].status ~= "wall") and (level.grid[level.mobs[i].r][level.mobs[i].c-1].status ~= "removable") then
        answer[#answer+1] = "left"
    end

    if (level.grid[level.mobs[i].r+1][level.mobs[i].c].status ~= "wall") and (level.grid[level.mobs[i].r+1][level.mobs[i].c].status ~= "removable") then
        answer[#answer+1] = "down"
    end

    if (level.grid[level.mobs[i].r-1][level.mobs[i].c].status ~= "wall") and (level.grid[level.mobs[i].r-1][level.mobs[i].c].status ~= "removable") then
        answer[#answer+1] = "up"
    end

    return answer
end


--function randomly moves our mobs
local function moveMobs()
    for i=1,#level.mobs do
        
        local canMoveTo = mobCanMove(i)
        
        if #canMoveTo < 1 then
            direction = ""
        else 
            direction = canMoveTo[math.random(1,#canMoveTo)]
        end

        
        if direction == "right" then
             
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "empty"
            level.mobs[i].c = level.mobs[i].c+1
            level.mobs[i].x = level.grid[level.mobs[i].r][level.mobs[i].c].x
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "mob"
        elseif direction == "left" then
             
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "empty"
            level.mobs[i].c = level.mobs[i].c-1
            level.mobs[i].x = level.grid[level.mobs[i].r][level.mobs[i].c].x
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "mob"
        elseif direction == "down" then
             
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "empty"
            level.mobs[i].r = level.mobs[i].r+1
            level.mobs[i].y = level.grid[level.mobs[i].r][level.mobs[i].c].y
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "mob"
        elseif direction == "up" then
           
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "empty"
            level.mobs[i].r = level.mobs[i].r-1
            level.mobs[i].y = level.grid[level.mobs[i].r][level.mobs[i].c].y
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "mob"
        end

    end
end

local function bLevel1Event(event)
    
        

        if ( "ended" == event.phase ) and levels[1] == true then
            local options = {
                effect = "slideLeft",
                time = 800
            }          
            

            composer.gotoScene( "level1", options )
             


        end
    
end

local function bLevel2Event(event)
    

        if ( "ended" == event.phase ) and levels[2] == true then
            local options = {
                effect = "slideLeft",
                time = 800
            }
            
            
            composer.gotoScene( "level2", options )
             

        end
    
end
    


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    background = display.newRect( myData.halfW, myData.halfH, myData.fullW, myData.fullH )
    background:setFillColor( 0, 0, 0 )
    sceneGroup:insert( background )

    
    level.createGrid(sceneGroup)
    level.createObjects(sceneGroup)
    mobsMoveTimer = timer.performWithDelay( 750, moveMobs, -1 )   

    bLevel1 = widget.newButton(
        {
            width = 100,
            height = 32,
            defaultFile = "images/menu/button1.png",
            overFile = "images/menu/button1.png",
            label = "",
            onEvent = bLevel1Event
        }
    )

    sceneGroup:insert(bLevel1)
    bLevel1.x = myData.halfW
    bLevel1.y = myData.fullH*0.4

    if levels[2] == true then
        bLevel2 = widget.newButton(
            {
                width = 100,
                height = 32,
                defaultFile = "images/menu/button2.png",
                overFile = "images/menu/button2.png",
                label = "",
                onEvent = bLevel2Event
            }
        )
    else
        bLevel2 = widget.newButton(
            {
                width = 100,
                height = 32,
                defaultFile = "images/menu/locked.png",
                overFile = "images/menu/locked.png",
                label = "",
                onEvent = bLevel2Event
            }
        )
    end

    sceneGroup:insert(bLevel2)
    bLevel2.x = myData.halfW
    bLevel2.y = myData.fullH*0.6

end



-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        
    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        print("hide will")
        timer.cancel( mobsMoveTimer )

                
        sceneGroup:removeSelf()
        sceneGroup = nil
        

        package.loaded["menumeta"] = nil
        package.loaded["myData"] = nil
        package.loaded["loadsave"] = nil

        composer.removeScene( "menu" )

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        print("hide did")

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    print("destroy")
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene