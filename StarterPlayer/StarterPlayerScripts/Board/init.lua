local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WinRemote = ReplicatedStorage:WaitForChild("WinEvent")
local Cell = require(script:WaitForChild("Cell"))
local Stack = require(script.Parent:WaitForChild("Stack"))

local Board = {}
local boardMt = {
	__index = Board,
}

-- Animations
-- 3bv/s
-- No guessing games
-- When win and flags wrong, dont show wrong flag image

function Board.new(x,y,mines)
	local self = setmetatable({}, boardMt)
	self.x = x
	self.y = y
	if mines >= x*y then
		self.minesCount = (x*y)-1
	else
		self.minesCount = mines	
	end
	self.grid = {}
	self.startTime = 0
	self.gameOver = false
	self.clicks = 0
	self.noFlag = true
	self.flagCount = 0
	self.nonMineCellsOpened = 0
	self.gameOverListeners = {}
	self.displayListeners = {}
	self.seed = os.time() + tick() * 10
	self.random = Random.new(self.seed)
	
	self:generateGrid()
	return self
end


function Board:openCell(x,y)
	if self.clicks == 0 then
		-- If mine of first click move mine
		if self.grid[x][y].isMine then
			self:moveMine(x,y)
			self:openCell(x,y)
			return
		end
		self:startTimer()
	end
	
	if not self.grid[x][y].isFlagged and not self.grid[x][y].isOpen then
		if self.grid[x][y].isMine then
			self.grid[x][y].isOpen = true
			self.grid[x][y].isHitMine = true
			self:endGame(false)
			return
		else	
			if self.grid[x][y].number == 0 then
				self:openMultiple(x,y)
			else
				self.grid[x][y]:open()
			end
			self.nonMineCellsOpened += 1
		end
	end
	self.clicks += 1
	self:checkWin()
end

function Board:startTimer()
	self.startTime = tick()
	local timer = 0
	coroutine.resume(coroutine.create(function()
		while not self.gameOver do
			task.wait(1)
			if self.gameOver then return end
			timer += 1
			for _, listener in ipairs(self.displayListeners) do
				listener("timer", timer)
			end
		end
	end))
end


function Board:openChord(x,y)
	if self.grid[x][y].isOpen then
		local nb = self:getCellNeighbours(x,y)
		local flagCount = 0
		for i = 1, #nb do
			if nb[i].isFlagged then
				flagCount += 1
			end
		end
		if flagCount == self.grid[x][y].number then
			for i = 1, #nb do
				if not nb[i].isFlagged then
					self:openCell(nb[i].x, nb[i].y)
				end
			end
		end
	end
end

-- When a empty cell if click open all cells until one with number is found
function Board:openMultiple(x,y)
	local myStack = Stack.new()
	self.grid[x][y]:open()
	myStack:push(self.grid[x][y])
	
	while #myStack > 0 do
		local cell = myStack:pop()	
		local nb = self:getCellNeighbours(cell.x,cell.y)
		
		-- Open all unopened neighbour cells and add empty ones to stack
		for i = 1, #nb do
			if not nb[i].isFlag and not nb[i].isOpen then
				nb[i]:open()
				self.nonMineCellsOpened += 1
				if nb[i].number == 0 then
					myStack:push(nb[i])
				end
			end
		end
	end
	
	self:checkWin()
end

function Board:flagCell(x,y)
	self.noFlag = false
	if self.grid[x][y].isFlagged then
		self.grid[x][y]:flag(false)
		self.flagCount -= 1
	else
		if not self.grid[x][y].isOpen then
			self.grid[x][y]:flag(true)
			self.flagCount += 1
		end
	end
	for _, listener in ipairs(self.displayListeners) do
		listener("mines", self.minesCount - self.flagCount)
	end
end

-- Open all mines on board if mine if hit
function Board:revealMines()
	for x = 1, self.x do
		for y = 1, self.y do
			if self.grid[x][y].isMine and not self.grid[x][y].isFlagged then
				self.grid[x][y]:open()
			elseif not self.grid[x][y].isMine and self.grid[x][y].isFlagged then
				self.grid[x][y]:open()
			end
		end
	end	
end

-- Flag all mines when game is won
function Board:flagAll()
	for x = 1, self.x do
		for y = 1, self.y do
			if self.grid[x][y].isMine then
				self.grid[x][y]:flag(true)
				self.flagCount -= 1
			end
		end
	end
end

function Board:checkWin()
	if self.nonMineCellsOpened < (self.x * self.y) - self.minesCount then return end
	self:endGame(true)
end

function Board:endGame(won)
	self.gameOver = true
	if won then
		self:flagAll()
		local tyme = tick() - self.startTime
		WinRemote:FireServer(tyme, self.x, self.y, self.minesCount, self.noFlag, self.clicks, self.seed)
	else
		self:revealMines()
	end
	for _, listener in ipairs(self.gameOverListeners) do
		listener(won)
	end
end

-- If mine is hit on first click look for new cell with
-- No mine in it starting from top left.
-- Then update numbers around cell clicked and cell that is the new mine
function Board:moveMine(x,y)
	local moved = false
	for y2 = 1, self.y do
		for x2 = 1, self.x do
			if not self.grid[x2][y2].isMine then
				self.grid[x2][y2].isMine = true
				local nb = self:getCellNeighbours(x2,y2)
				for i = 1, #nb do
					nb[i].number += 1
				end
				moved = true
				break
			end
		end
		if moved == true then
			break
		end
	end
	self.grid[x][y].isMine = false
	local nb = self:getCellNeighbours(x,y)
	for i = 1, #nb do
		nb[i].number -= 1
	end	
end

-- Return a function that will give non repeating random number bewteen 1 and max
function nonRepeatingNumbers(max, random)
	local array = table.create(max,nil)
	for i = 1, max do
		array[#array+1] = i
	end
	return function()
		if max < 0 then return nil end
		local random = random:NextInteger(1,max)
		local number = array[random]
		array[max], array[random] = array[random], array[max]
		max -= 1
		return number
	end
end

function Board:getCellNeighbours(x,y)
	local neighbours = {}
	for i = -1, 1 do
		for j = -1, 1 do
			local newX = i+x
			local newY = j+y
			if (i ~= 0 or j ~= 0) and newX > 0 and newX <= self.x and newY > 0 and newY <= self.y then
				neighbours[#neighbours+1] = self.grid[newX][newY]
			end
		end
	end
	return neighbours
end

function Board:placeMines()
	local randomNumberGenerator = nonRepeatingNumbers(self.x * self.y, self.random)
	for i = 1, self.minesCount do
		local number = randomNumberGenerator()
		number -= 1
		-- Convert 1d index into a 2d index
		local x = math.floor(number % self.x) + 1
		local y = math.floor(number / self.x) + 1
		self.grid[x][y].isMine = true
		
		-- Update number around new mine placed
		local nb = self:getCellNeighbours(x,y)
		for i = 1, #nb do
			nb[i].number += 1		
		end	
	end
end

function Board:generateGrid()
	for x = 1, self.x do
		self.grid[x] = {}
		for y = 1, self.y do
			self.grid[x][y] = Cell.new(x,y)
		end
	end	
	self:placeMines(self)
end

function Board:addDisplayerListener(func)
	table.insert(self.displayListeners, func)
end

function Board:addGameOverListener(func)
	table.insert(self.gameOverListeners, func)
end

return Board
