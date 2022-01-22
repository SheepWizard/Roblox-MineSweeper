local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players")
local localPlayer = Player.LocalPlayer
local playerScripts = localPlayer.PlayerScripts
local Board = require(playerScripts:WaitForChild("Board"))
local Settings = require(playerScripts:WaitForChild("Settings"))
local GUI = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MinesweeperGui")
local gameFrame = GUI:WaitForChild("GameFrame")


local cellOpenImage = "rbxassetid://6079443592"
local numberImages = {
	"rbxassetid://6079444536",
	"rbxassetid://6079444462",
	"rbxassetid://6079444395",
	"rbxassetid://6079444333",
	"rbxassetid://6079444270",
	"rbxassetid://6079444204",
	"rbxassetid://6079444118",
	"rbxassetid://6079444039",
}
local dotDisplayImages = {
	"rbxassetid://6079443218",
	"rbxassetid://6079443103",
	"rbxassetid://6079443016",
	"rbxassetid://6079442947",
	"rbxassetid://6079442882",
	"rbxassetid://6079442804",
	"rbxassetid://6079442719",
	"rbxassetid://6079442642",
	"rbxassetid://6079442541",
}
dotDisplayImages[0] = "rbxassetid://6079443288"
local dotDisplayMinus = "rbxassetid://6079442468"
local cellHiddenImage = "rbxassetid://6079443882"
local cellMineImage = "rbxassetid://6079443779"
local cellMineHitImage = "rbxassetid://6079443663"
local wrongFlagImage = "rbxassetid://6079443515"
local flagImage = "rbxassetid://6079443956"


local BoardGui = {}
local boardGuiMt = {
	__index = BoardGui
}

function BoardGui.new(x,y,mines)
	local self = setmetatable({}, boardGuiMt)
	self.tileSize = Settings.tileSize
	self.board = Board.new(x,y,mines)
	self.resetButton = nil
	self.cellButtons = {}
	self.resetButton = nil
	self.minesDotDisplay = {}
	self.timeDotDisplay = {}
	self.cellsAnimated = {}
	self.isDragging = true
	self.smile = nil
	
	self.leftClickDown = false
	self.rightClickDown = false
	self.chording = false
	self.cellEvents = {}
	
	self:create(self.board.x, self.board.y)
	
	return self
end

local function newImageLabel(width,height,x,y,image)
	local il = Instance.new("ImageLabel")
	il.Size = UDim2.new(0,width,0,height)
	il.Position = UDim2.new(0,x,0,y)
	il.Image = image
	il.BackgroundTransparency = 1
	il.Parent = gameFrame.Board
	return il
end

local function newImageButton(width,height,x,y,image)
	local ib = Instance.new("ImageButton")
	ib.Size = UDim2.new(0,width,0,height)
	ib.Position = UDim2.new(0,x,0,y)
	ib.Image = image
	ib.BackgroundTransparency = 1
	ib.Parent = gameFrame.Board
	return ib
end

local function newTextButton(width,height,x,y,text)
	local tb = Instance.new("TextButton")
	tb.Size = UDim2.new(0,width,0,height)
	tb.Position = UDim2.new(0,x,0,y)
	tb.BackgroundTransparency = 1
	tb.Text = text
	tb.Parent = gameFrame.Board
	return tb
end

local function newFrame(width,height,x,y,colour)
	local pf = Instance.new("Frame")
	pf.Size = UDim2.new(0,width,0,height)
	pf.Position = UDim2.new(0,x,0,y)
	pf.BorderSizePixel = 0
	pf.BackgroundColor3 = colour
	pf.Parent = gameFrame.Board
	return pf
end

local function isLeftMouseDown()
	return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

local function isRightMouseDown()
	return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

function BoardGui:openCell(x,y)
	if not self.board.gameOver then
		self.board:openCell(x,y)
	end
end

function BoardGui:chordCell(x,y)
	if not self.board.gameOver then
		self.board:openChord(x,y)
	end
end

function BoardGui:flagCell(x,y)
	if not self.board.gameOver then
		self.board:flagCell(x,y)
	end
end

function BoardGui:gameOver(won)
	if won then
		self.smile.Image = "rbxassetid://2670782665"
	else
		self.smile.Image = "rbxassetid://2670782483"
	end
	for _, event in ipairs(self.cellEvents) do
		event:Disconnect()
	end
	table.clear(self.cellEvents)
end

function BoardGui:displayUpdate(display, value)
	if display == "timer" then
		self:updateDotDisplay(self.timeDotDisplay, value)
	elseif display == "mines" then
		self:updateDotDisplay(self.minesDotDisplay, value)
	end
end


function BoardGui:updateDotDisplay(display, number)
	if number > 999 then
		number = 999
	elseif number < -99 then
		number = -99
	end
	
	local negative = false
	if number < 0 then negative = true end
	
	local str = tostring(number)
	local offset = 3 - string.len(str)
	
	for i = 1, 3 do
		if i > offset then
			local substr = string.sub(str, i-offset, i-offset)
			if substr == "-" then
				display[i].Image = dotDisplayMinus	
			else
				display[i].Image = dotDisplayImages[tonumber(substr)]
			end
		else
			display[i].Image = dotDisplayImages[0]
		end
	end
	
end

-- Update a cells image based on it properties
function BoardGui:cellUpdate(x,y)
	if self.board.grid[x][y].isOpen then
		if self.board.grid[x][y].isMine then
			if self.board.grid[x][y].isHitMine then
				self.cellButtons[x][y].Image = cellMineHitImage
			else
				self.cellButtons[x][y].Image = cellMineImage
			end
		else
			if self.board.grid[x][y].isFlagged then
				self.cellButtons[x][y].Image = wrongFlagImage
			elseif self.board.grid[x][y].number > 0 then
				self.cellButtons[x][y].Image = numberImages[self.board.grid[x][y].number]
			else
				self.cellButtons[x][y].Image = cellOpenImage
			end
		end
	else
		if self.board.grid[x][y].isFlagged then
			self.cellButtons[x][y].Image = flagImage
		else
			self.cellButtons[x][y].Image = cellHiddenImage
		end
	end
end

function BoardGui:visuals(x,y)
	self.tileSize = Settings.tileSize
	local boardWidth = (self.tileSize * x) + ((self.tileSize+12)*2)
	local boardHeight = (self.tileSize * y) + ((self.tileSize+12)*3) + self.tileSize+32
	local screenWidth = gameFrame.AbsoluteSize.X
	local screenHeight = gameFrame.AbsoluteSize.y
	local startXOffset = (screenWidth/2) - (boardWidth/2)
	local startYOffset = (screenHeight/2) - (boardHeight/2)
	
	-- Add padding if for canvas so board is never on the edge of screen
	local canvasPadding = 50	
	if startXOffset < canvasPadding then
		startXOffset = canvasPadding
	end
	if startYOffset < canvasPadding then
		startYOffset = canvasPadding
	end
	
	local xOffset = startXOffset
	local yOffset = startYOffset
	local panelXSize = 0
	
	gameFrame.Board:ClearAllChildren()
	
	-- Top left corner
	newImageLabel(self.tileSize-12,self.tileSize-12,xOffset,yOffset,"rbxassetid://6079444711")
	xOffset += self.tileSize-12
	
	-- Top border
	for i = 1, x do
		newImageLabel(self.tileSize,self.tileSize-12,xOffset,yOffset,"rbxassetid://6079444803")
		panelXSize += self.tileSize
		xOffset += self.tileSize
	end
	
	-- Top right corner
	newImageLabel(self.tileSize-12,self.tileSize-12,xOffset,yOffset,"rbxassetid://6079444630")
	xOffset = startXOffset
	yOffset += self.tileSize-12
	
	-- Top panel left border
	newImageLabel(self.tileSize-12,self.tileSize+32,xOffset,yOffset,"rbxassetid://6079444889")
	xOffset += self.tileSize-12
	
	-- Panel grey
	local panel = newFrame(panelXSize,self.tileSize+32,xOffset,yOffset,Color3.fromRGB(189, 189, 189))
	self.resetButton = newTextButton(panelXSize,self.tileSize+32,xOffset,yOffset,"")
	xOffset += panelXSize
	
	self.smile = newImageLabel(self.tileSize+20,self.tileSize+20,0,0,"rbxassetid://2670782592")
	self.smile.Position = UDim2.new(0.5,0,0.5,0)
	self.smile.AnchorPoint = Vector2.new(0.5,0.5)
	self.smile.Parent = panel
	
	-- Dot displays	
	local dotDisplayWidth = self.tileSize-4
	local dotDisplayHeight = self.tileSize+20
	local minesDisplayXOffset = self.tileSize/4
	local timerDisplayerXoffset = (panelXSize - dotDisplayWidth)-minesDisplayXOffset
	
	-- Mine count dot display
	self.minesDotDisplay[1] = newImageLabel(dotDisplayWidth, dotDisplayHeight, minesDisplayXOffset,((self.tileSize+32)/2)-(dotDisplayHeight/2), dotDisplayImages[0])
	self.minesDotDisplay[2] = newImageLabel(dotDisplayWidth, dotDisplayHeight, dotDisplayWidth+minesDisplayXOffset,((self.tileSize+32)/2)-(dotDisplayHeight/2), dotDisplayImages[0])
	self.minesDotDisplay[3] = newImageLabel(dotDisplayWidth, dotDisplayHeight, (dotDisplayWidth*2)+minesDisplayXOffset,((self.tileSize+32)/2)-(dotDisplayHeight/2), dotDisplayImages[0])
	
	self.minesDotDisplay[1].Parent = panel
	self.minesDotDisplay[2].Parent = panel
	self.minesDotDisplay[3].Parent = panel
	
	self:updateDotDisplay(self.minesDotDisplay, self.board.minesCount)
	
	-- Time dot display
	self.timeDotDisplay[3] = newImageLabel(dotDisplayWidth, dotDisplayHeight, timerDisplayerXoffset,((self.tileSize+32)/2)-(dotDisplayHeight/2), dotDisplayImages[0])
	self.timeDotDisplay[2] = newImageLabel(dotDisplayWidth, dotDisplayHeight, timerDisplayerXoffset-dotDisplayWidth,((self.tileSize+32)/2)-(dotDisplayHeight/2), dotDisplayImages[0])
	self.timeDotDisplay[1] = newImageLabel(dotDisplayWidth, dotDisplayHeight, timerDisplayerXoffset-(dotDisplayWidth*2),((self.tileSize+32)/2)-(dotDisplayHeight/2), dotDisplayImages[0])
	
	self.timeDotDisplay[3].Parent = panel
	self.timeDotDisplay[2].Parent = panel
	self.timeDotDisplay[1].Parent = panel
	
	-- Top panel right border
	newImageLabel(self.tileSize-12,self.tileSize+32,xOffset,yOffset,"rbxassetid://6079444889")
	yOffset += self.tileSize+32
	xOffset = startXOffset
	
	-- Joint left
	newImageLabel(self.tileSize-12,self.tileSize-12,xOffset,yOffset,"rbxassetid://6079443423")
	xOffset += self.tileSize-12
	
	-- Bottom panel border
	for i = 1, x do
		newImageLabel(self.tileSize,self.tileSize-12,xOffset,yOffset,"rbxassetid://6079444803")
		xOffset += self.tileSize
	end
	
	-- Joint Right
	newImageLabel(self.tileSize-12,self.tileSize-12,xOffset,yOffset,"rbxassetid://6079443361")
	xOffset = startXOffset
	yOffset += self.tileSize-12
	
	-- Play area
	for i = 1, y do
		newImageLabel(self.tileSize-12,self.tileSize,xOffset,yOffset,"rbxassetid://6079444889")
		xOffset += self.tileSize-12
		for j = 1, x do
			local cellButton = newImageButton(self.tileSize,self.tileSize,xOffset,yOffset,"rbxassetid://6079443882")
			self.cellButtons[j][i] = cellButton
			xOffset += self.tileSize
		end
		newImageLabel(self.tileSize-12,self.tileSize,xOffset,yOffset,"rbxassetid://6079444889")
		xOffset = startXOffset
		yOffset += self.tileSize
	end
	
	-- Bottom left corner
	newImageLabel(self.tileSize-12,self.tileSize-12,xOffset,yOffset,"rbxassetid://6079445051")
	xOffset += self.tileSize-12
	
	-- Bottom border
	for i = 1, x do
		newImageLabel(self.tileSize,self.tileSize-12,xOffset,yOffset,"rbxassetid://6079444803")
		xOffset += self.tileSize
	end
	
	-- Bottom right corner
	newImageLabel(self.tileSize-12,self.tileSize-12,xOffset,yOffset,"rbxassetid://6079444967")
	xOffset += self.tileSize-12
	
	-- Set canvas size so you can scroll if board is bigger then the screen	
	local canvasWidth = boardWidth
	local canvadHeight = boardHeight
	if boardWidth > screenWidth then
		boardWidth += canvasPadding * 2
	end
	if boardHeight > screenHeight then
		boardHeight += canvasPadding * 2
	end
	
	gameFrame.CanvasSize = UDim2.new(0,boardWidth,0,boardHeight)
end

function BoardGui:chordAnimate(x,y)
	local neighbours = self.board:getCellNeighbours(x,y)
	for _, neighbour in ipairs(neighbours) do
		self.cellButtons[neighbour.x][neighbour.y].Image = cellOpenImage
		table.insert(self.cellsAnimated, {neighbour.x,neighbour.y})
	end
end

function BoardGui:chordUnAnimate()
	for _, vec2 in ipairs(self.cellsAnimated) do
		self:cellUpdate(vec2[1],vec2[2])
	end
	table.clear(self.cellsAnimated)
end

function BoardGui:addCellEvent(x,y)

	-- Mobile open
	table.insert(self.cellEvents, self.cellButtons[x][y].TouchTap:Connect(function()
		self:openCell(x,y)
	end))
	-- Mobile flag
	table.insert(self.cellEvents ,self.cellButtons[x][y].TouchLongPress:Connect(function()
		self:flagCell(x,y)
	end))
	
	-- Left click on cell
	table.insert(self.cellEvents, self.cellButtons[x][y].MouseButton1Up:Connect(function()
		self.leftClickDown = false
		if self.rightClickDown then
			self.chording = true
			self:chordCell(x,y)
		else
			if not self.chording then
				self:openCell(x,y)	
			else
				self.chording = false
			end
		end
	end))
	table.insert(self.cellEvents, self.cellButtons[x][y].MouseButton1Down:Connect(function()
		self.leftClickDown = true
		if self.rightClickDown then
			--self:chordAnimate(x,y)
		elseif not self.board.grid[x][y].isOpen then
			self.cellButtons[x][y].Image = cellOpenImage
		end
	end))
	-- Mouse leaves cell
	table.insert(self.cellEvents, self.cellButtons[x][y].MouseLeave:Connect(function()
		if self.leftClickDown and self.rightClickDown then
			--self:chordUnAnimate()
		elseif self.leftClickDown then
		end
		self:cellUpdate(x,y)
	end))
	-- Mouse enter cell
	table.insert(self.cellEvents, self.cellButtons[x][y].MouseEnter:Connect(function()
		if self.leftClickDown and self.rightClickDown then
			--self:chordAnimate(x,y)
		elseif self.leftClickDown and not self.board.grid[x][y].isOpen then
			self.cellButtons[x][y].Image = cellOpenImage
		end
	end))
	-- Right click on cell
	table.insert(self.cellEvents, self.cellButtons[x][y].MouseButton2Up:Connect(function()
		self.rightClickDown = false
		if self.leftClickDown then
			--self.chording = true
			self:chordCell(x,y)
		end
	end))
	table.insert(self.cellEvents, self.cellButtons[x][y].MouseButton2Down:Connect(function()
		self.rightClickDown = true
		self:flagCell(x,y)
	end))
	
end


function BoardGui:create(x,y)
	for x = 1, x do
		self.cellButtons[x] = {}
	end
	self:visuals(x,y)
	self.board:addGameOverListener(function(won) self:gameOver(won) end)
	self.board:addDisplayerListener(function(display, value) self:displayUpdate(display, value) end)
	for x = 1, self.board.x do
		for y = 1, self.board.y do
			self:addCellEvent(x,y)
			self.board.grid[x][y]:addEventListener(function(x,y) self:cellUpdate(x,y) end)
		end
	end
	-- Mobile reset
	self.resetButton.TouchTap:Connect(function()
		self:reset()
	end)
	-- Left click on reset
	self.resetButton.MouseButton1Up:Connect(function()
		self:reset()
	end)
	self.resetButton.MouseButton1Down:Connect(function()

	end)
	UserInputService.TouchPan:Connect(function(_,_,velocity)
		print(velocity)
		self.isDragging = true
	end)
end

function BoardGui:reset(newX, newY, newMines)
	local x = newX or self.board.x
	local y = newY or self.board.y
	local mines = newMines or self.board.minesCount
	self.board.gameOver = true
	
	self.board = Board.new(x,y,mines)
	self:create(self.board.x,self.board.y)
end


return BoardGui
