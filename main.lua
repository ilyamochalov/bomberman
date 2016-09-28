-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- local loadsave = require("loadsave")
-- local file = system.pathForFile( "levels.json" , system.DocumentsDirectory)
-- local fhd1 = io.open( file )
-- local levels = nil

-- if fhd1 then
--     print ("File esixts")
--     fhd1:close( )
--     levels = loadsave.loadTable("levels.json" , system.DocumentsDirectory)
-- else
--     print("file doesn't exist")

--     levels={
--         true,
--         false
--     }
--     loadsave.saveTable(levels, "levels.json" , system.DocumentsDirectory)
--     levels = loadsave.loadTable("levels.json" , system.DocumentsDirectory)
-- end

-- levels[2] = false
-- loadsave.saveTable(levels, "levels.json" , system.DocumentsDirectory)

local composer = require( "composer" )
local options = {
        effect = "fade",
        time = 800
    }                           
composer.gotoScene( "menu", options)
display.setStatusBar( display.HiddenStatusBar )



