local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()
local sceneGroup
local level = require("level1meta")
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
local beginX, beginY = 0, 0
local endX, endY = 0, 0
local bomb = nil
local bombTimer = nil
local explosionTimer = nil
local explosion = {}
local paused = false
local b_pause = nil
local b_menu = nil

-- -----------------------------------------------------------------------------------
-- functions for buttons pause and menu 
-- -----------------------------------------------------------------------------------

local function handleButtonEvent_pause(event)
    if ( "ended" == event.phase ) then
        print("buttnon on game pause")
        
        if paused == false then
            paused = true

            timer.pause( mobsMoveTimer )
            if bomb ~= nil then
                timer.pause( bombTimer )
            end
            if explosionTimer ~= nil then
                timer.pause( explosionTimer )
            end

            b_pause:setLabel( "resume" )
            return

        end

        if paused == true then
            paused = false

            timer.resume( mobsMoveTimer )
            if bomb ~= nil then
                timer.resume( bombTimer )
            end
            if explosionTimer ~= nil then
                timer.resume( explosionTimer )
            end

            b_pause:setLabel( "pause" )
            return
        end         

    end
end

local function handleButtonEvent_menu(event)
    if ( "ended" == event.phase ) then
        
        local options = {
            effect = "slideRight",
            time = 800
        }                         
        

       
        composer.gotoScene( "menu", options )

    end
end

local function gameOver(  )
    
    local options = {
        effect = "fade",
        time = 800
    }                           
    
    composer.gotoScene( "gameOver", options )
end

local function nextLevel()
        
        levels[2] = true
        loadsave.saveTable(levels, "levels.json" , system.DocumentsDirectory)
        local options = {
            effect = "slideLeft",
            time = 800
        }
              

        composer.gotoScene( "level2", options )
        composer.removeScene( "level1" ) 

end
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

--function checks weather mob kills our player
local function killedByMob(r, c)
    if r == level.player.r and c == level.player.c then
        gameOver()
        print("killedByMob")
    end
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
            killedByMob(level.mobs[i].r, level.mobs[i].c+1) --check weather the place we are moving to
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "empty"
            level.mobs[i].c = level.mobs[i].c+1
            level.mobs[i].x = level.grid[level.mobs[i].r][level.mobs[i].c].x
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "mob"
        elseif direction == "left" then
            killedByMob(level.mobs[i].r, level.mobs[i].c-1) --check weather there is a player on the place we are moving to
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "empty"
            level.mobs[i].c = level.mobs[i].c-1
            level.mobs[i].x = level.grid[level.mobs[i].r][level.mobs[i].c].x
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "mob"
        elseif direction == "down" then
            killedByMob(level.mobs[i].r+1, level.mobs[i].c) --check weather the place we are moving to
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "empty"
            level.mobs[i].r = level.mobs[i].r+1
            level.mobs[i].y = level.grid[level.mobs[i].r][level.mobs[i].c].y
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "mob"
        elseif direction == "up" then
            killedByMob(level.mobs[i].r-1, level.mobs[i].c) --check weather the place we are moving to
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "empty"
            level.mobs[i].r = level.mobs[i].r-1
            level.mobs[i].y = level.grid[level.mobs[i].r][level.mobs[i].c].y
            level.grid[level.mobs[i].r][level.mobs[i].c].status = "mob"
        end

        print("level.mobs"..i.."r "..level.mobs[i].r)
        print("level.mobs"..i.."c "..level.mobs[i].c)

    end

end
    

-- -----------------------------------------------------------------------------------
-- functions for player 
-- -----------------------------------------------------------------------------------

--function determines weather we can move our player
local function canMovePlayer(direction)
    if direction == "right" then
        if (level.grid[level.player.r][level.player.c+1].status ~= "wall") and (level.grid[level.player.r][level.player.c+1].status ~= "removable") then
            print("can move our player right")
            return true
        end
    elseif direction == "left" then
        if (level.grid[level.player.r][level.player.c-1].status ~= "wall") and (level.grid[level.player.r][level.player.c-1].status ~= "removable") then
            print("can move our player left")
            return true
        end
    elseif direction == "down" then
        if (level.grid[level.player.r+1][level.player.c].status ~= "wall") and (level.grid[level.player.r+1][level.player.c].status ~= "removable") then
            print("can move our player down")
            return true
        end
    elseif direction == "up" then
        if (level.grid[level.player.r-1][level.player.c].status ~= "wall") and (level.grid[level.player.r-1][level.player.c].status ~= "removable") then
            print("can move our player up")
            return true
        end
    end
end

local function movePlayer( event )
    if paused == false then    
        if event.phase == "began" then
            beginX, beginY = event.x, event.y
        end

        
        if event.phase == "ended" then
            endX, endY = event.x, event.y
            
            if (math.abs(endX-beginX) >= math.abs(endY-beginY)) then
                if (endX-beginX)>0 then
                    --print("move right")
                    if canMovePlayer("right") then
                        if level.grid[level.player.r][level.player.c+1].status == "mob" then
                            print("killed..ran into the mob")
                            gameOver()
                        end
                        level.grid[level.player.r][level.player.c].status = "empty"
                        level.player.c = level.player.c+1
                        level.player.x = level.grid[level.player.r][level.player.c].x   
                        level.grid[level.player.r][level.player.c].status = "player"                        
                    end
                elseif (endX-beginX)<0 then
                    --print("move left")
                    if canMovePlayer("left") then
                        if level.grid[level.player.r][level.player.c-1].status == "mob" then
                            print("killed..ran into the mob")
                            gameOver()
                        end
                        level.grid[level.player.r][level.player.c].status = "empty"
                        level.player.c = level.player.c-1
                        level.player.x = level.grid[level.player.r][level.player.c].x   
                        level.grid[level.player.r][level.player.c].status = "player"
                    end
                end
            else
                if (endY-beginY)>0 then
                    --print("move down")
                    if canMovePlayer("down") then
                        if level.grid[level.player.r+1][level.player.c].status == "mob" then
                            print("killed..ran into the mob")
                            gameOver()
                        end
                        level.grid[level.player.r][level.player.c].status = "empty"
                        level.player.r = level.player.r+1
                        level.player.y = level.grid[level.player.r][level.player.c].y   
                        level.grid[level.player.r][level.player.c].status = "player"
                    end
                elseif (endY-beginY)<0 then
                    --print("move up")
                    if canMovePlayer("up") then
                        if level.grid[level.player.r-1][level.player.c].status == "mob" then
                            print("killed..ran into the mob")
                            gameOver()
                        end
                        level.grid[level.player.r][level.player.c].status = "empty"
                        level.player.r = level.player.r-1
                        level.player.y = level.grid[level.player.r][level.player.c].y   
                        level.grid[level.player.r][level.player.c].status = "player"
                    end
                end
            end

            print("level.player.r "..level.player.r)
            print("level.player.c "..level.player.c)
        end

        --goto the next level
        if level.player.r == level.nextL.r and level.player.c == level.nextL.c and #level.mobs == 0 then
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!NEXT level!")
            nextLevel()
        end

    end
end

-- -----------------------------------------------------------------------------------
-- functions for bomb 
-- -----------------------------------------------------------------------------------

local function explodeRemovable( side )
    print("going to explode"..side)
    if side == "up" then
        for i=1,#level.removable do
            if (level.removable[i].r == bomb.r-1) and (level.removable[i].c == bomb.c) then
                
                level.grid[bomb.r-1][bomb.c].status = "empty"
                level.removable[i]:removeSelf()
               table.remove(level.removable, i)
               print("removed obsticle")
               return
            end
        end
    elseif side == "down" then
        for i=1,#level.removable do
            if (level.removable[i].r == bomb.r+1) and (level.removable[i].c == bomb.c) then
                
                level.grid[bomb.r+1][bomb.c].status = "empty"
                level.removable[i]:removeSelf()
                table.remove(level.removable, i)
                print("removed obsticle")
                return
            end
        end
    elseif side == "left" then
        for i=1,#level.removable do
            if (level.removable[i].r == bomb.r) and (level.removable[i].c == bomb.c-1) then
                
                level.grid[bomb.r][bomb.c-1].status = "empty"
                level.removable[i]:removeSelf()
                table.remove(level.removable, i)
                print("removed obsticle")
                return
            end
        end
    elseif side == "right"then
        for i=1,#level.removable do
            if (level.removable[i].r == bomb.r) and (level.removable[i].c == bomb.c+1) then
                
                level.grid[bomb.r][bomb.c+1].status = "empty"
                level.removable[i]:removeSelf()
                table.remove(level.removable, i)
                print("removed obsticle")
                return
            end
        end
    end
end

local function killMobs( side )
    print("going to kill mob")
    if side == "up" then
        for i=1,#level.mobs do
            if (level.mobs[i].r == bomb.r-1) and (level.mobs[i].c == bomb.c) then
                
                level.grid[bomb.r-1][bomb.c].status = "empty"
                level.mobs[i]:removeSelf()
                table.remove(level.mobs, i)
                print("killed")
                return
            end
        end
    elseif side == "down" then
        for i=1,#level.mobs do
            if (level.mobs[i].r == bomb.r+1) and (level.mobs[i].c == bomb.c) then
                
                level.grid[bomb.r+1][bomb.c].status = "empty"
                level.mobs[i]:removeSelf()
                table.remove(level.mobs, i)
                print("killed")
                return
            end
        end
    elseif side == "left" then
        for i=1,#level.mobs do
            if (level.mobs[i].r == bomb.r) and (level.mobs[i].c == bomb.c-1) then
                
                level.grid[bomb.r][bomb.c-1].status = "empty"
                level.mobs[i]:removeSelf()
                table.remove(level.mobs, i)
                print("killed")
                return
            end
        end
    elseif side == "right"then
        for i=1,#level.mobs do
            if (level.mobs[i].r == bomb.r) and (level.mobs[i].c == bomb.c+1) then
                
                level.grid[bomb.r][bomb.c+1].status = "empty"
                level.mobs[i]:removeSelf()
                table.remove(level.mobs, i)
                print("killed")
                return
            end
        end
    end
end

local function explosionOnTimer()
    bombTimer = nil
    level.grid[bomb.r][bomb.c].status = "empty"
    bomb:removeSelf()
    bomb = nil
    for i=1,#explosion do
        explosion[i]:removeSelf()
        explosion[i] = nil
    end
    explosionTimer = nil
end

--bomb countdown
local function bombOnTimer()
    print(bomb.countdown)
    bomb.countdown = bomb.countdown - 1
    level.grid[bomb.r][bomb.c].status = "wall"
    if bomb.countdown < 1 then
        explosion[#explosion+1] = display.newImageRect( "images/level1/fire.png" , myData.blockSize, myData.blockSize )
        explosion[#explosion].x = level.grid[bomb.r][bomb.c].x
        explosion[#explosion].y = level.grid[bomb.r][bomb.c].y
        
        if bomb.r == level.player.r and bomb.c == level.player.c then
                gameOver()
                print("killed by bomb")
        end

        --up
        if level.grid[bomb.r-1][bomb.c].status ~= "wall" then
            explosion[#explosion+1] = display.newImageRect( "images/level1/fire.png" , myData.blockSize, myData.blockSize )
            explosion[#explosion].x = level.grid[bomb.r][bomb.c].x
            explosion[#explosion].y = level.grid[bomb.r-1][bomb.c].y
            
            if level.grid[bomb.r-1][bomb.c].status == "removable" then
                explodeRemovable( "up" )
            elseif level.grid[bomb.r-1][bomb.c].status == "mob" then
                killMobs("up")
            elseif level.grid[bomb.r-1][bomb.c].status == "player" then
                gameOver()
                print("killed by bomb")
            end
        end

        --down
        if level.grid[bomb.r+1][bomb.c].status ~= "wall" then
            explosion[#explosion+1] = display.newImageRect( "images/level1/fire.png" , myData.blockSize, myData.blockSize )
            explosion[#explosion].x = level.grid[bomb.r][bomb.c].x
            explosion[#explosion].y = level.grid[bomb.r+1][bomb.c].y

            if level.grid[bomb.r+1][bomb.c].status == "removable" then
                explodeRemovable( "down" )
            elseif level.grid[bomb.r+1][bomb.c].status == "mob" then
                killMobs("down")
            elseif level.grid[bomb.r+1][bomb.c].status == "player" then
                gameOver()
                print("killed by bomb")
            end
        end

        --left
        if level.grid[bomb.r][bomb.c-1].status ~= "wall" then
            explosion[#explosion+1] = display.newImageRect( "images/level1/fire.png" , myData.blockSize, myData.blockSize )
            explosion[#explosion].x = level.grid[bomb.r][bomb.c-1].x
            explosion[#explosion].y = level.grid[bomb.r][bomb.c].y

            if level.grid[bomb.r][bomb.c-1].status == "removable" then
                explodeRemovable( "left" )
            elseif level.grid[bomb.r][bomb.c-1].status == "mob" then
                killMobs("left")
            elseif level.grid[bomb.r][bomb.c-1].status == "player" then
                gameOver()
                print("killed by bomb")
            end
        end

        --right
        if level.grid[bomb.r][bomb.c+1].status ~= "wall" then
            explosion[#explosion+1] = display.newImageRect( "images/level1/fire.png" , myData.blockSize, myData.blockSize )
            explosion[#explosion].x = level.grid[bomb.r][bomb.c+1].x
            explosion[#explosion].y = level.grid[bomb.r][bomb.c].y

            if level.grid[bomb.r][bomb.c+1].status == "removable" then
                explodeRemovable( "right" )
            elseif level.grid[bomb.r][bomb.c+1].status == "mob" then
                killMobs("right")
            elseif level.grid[bomb.r][bomb.c+1].status == "player" then
                gameOver()
                print("killed by bomb")
            end
        end

        explosionTimer = timer.performWithDelay(500, explosionOnTimer, 1)
        
    end
end

--placing the bomb
local function placeABomb( event )
    if event.numTaps == 2  and bomb == nil and paused == false then
       print("place a bomb")
       bomb = display.newImageRect("images/level1/bomb.png" , myData.blockSize, myData.blockSize)
       bomb.x = level.grid[level.player.r][level.player.c].x
       bomb.y = level.grid[level.player.r][level.player.c].y
       bomb.r = level.player.r
       bomb.c = level.player.c
       print("bomb places at row"..bomb.r.." coll "..bomb.c)
       sceneGroup:insert(bomb)
       bomb.countdown = 6
       bombTimer = timer.performWithDelay(333, bombOnTimer, 6)

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
    
    sceneGroup:addEventListener( "touch", movePlayer )
    sceneGroup:addEventListener( "tap", placeABomb)

    b_pause = widget.newButton(
        {
            label = "pause",
            onEvent = handleButtonEvent_pause,
            fontSize = (display.contentHeight/15),
            labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
            emboss = true,
            textOnly = true,
            fontweight = bold
        }
    )

    sceneGroup:insert(b_pause)
    b_pause.x = (myData.fullW-(myData.blockSize*myData.columns))/2+(myData.blockSize*(myData.columns-2))
    b_pause.y = myData.blockSize/2

    b_menu = widget.newButton(
        {
            label = "menu",
            onEvent = handleButtonEvent_menu,
            fontSize = blockSize,
            labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
            emboss = true,
            textOnly = true,
            fontweight = bold
        }
    )


    sceneGroup:insert(b_menu)
    b_menu.x = (myData.fullW-(myData.blockSize*myData.columns))/2+2*myData.blockSize
    b_menu.y = myData.blockSize/2


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
        
        if bomb ~= nil then
            timer.cancel( bombTimer )
        end
        if explosionTimer ~= nil then
            timer.cancel( explosionTimer )
        end

        sceneGroup:removeSelf()
        sceneGroup = nil

        package.loaded["level1meta"] = nil
        package.loaded["myData"] = nil
        package.loaded["loadsave"] = nil
        
        composer.removeScene( "level1" ) 


    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        print("hide did")


    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
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