-----------------------------------------------------------------------------------------
--
-- data used across several modules
--
-----------------------------------------------------------------------------------------
local M={}

M.fullW = display.contentWidth
M.fullH = display.contentHeight
M.halfW = display.contentCenterX
M.halfH = display.contentCenterY

M.columns = 19
M.rows = 13
M.blockSize = M.fullH / 13

M.emptyspaceOutlook = { 0, 0.9, 0}

return M