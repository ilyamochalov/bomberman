local composer = require( "composer" )

local scene = composer.newScene()

local widget = require( "widget" )



-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------


local function handleButtonEvent( event )
    print("buttnon on menu pressed")

    if ( "ended" == event.phase ) then
        local options = {
            effect = "fade",
            time = 800
        }
        composer.gotoScene( "menu", options )    
    end
end

function scene:create( event )

    sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    backGround = display.newRect (display.contentCenterX, display.contentCenterY, display.contentWidth*0.9, display.contentHeight*0.9)
    sceneGroup:insert( backGround )
    backGround:setFillColor(169/256, 169/256, 169/256 )


    local playAgain = widget.newButton({
            label = "play again",
            onEvent = handleButtonEvent,
            fontSize = (display.contentHeight/15),
            labelColor = { default={ 20/256, 20/256, 210/256 }, over={ 69/256, 69/256, 237/256 } },
            emboss = true,
            textOnly = true
        })
    sceneGroup:insert(playAgain)
    playAgain.x = display.contentCenterX
    playAgain.y = display.contentCenterY
end


-- show()
function scene:show( event )

    sceneGroup = self.view
    phase = event.phase

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
        
        display.remove(playAgain)
        playAgain = nil
        composer.removeScene( "gameOver" )
        

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    sceneGroup:removeSelf()

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