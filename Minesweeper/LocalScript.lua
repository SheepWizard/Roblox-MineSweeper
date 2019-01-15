--[[
	Minesweeper remake by Sheep Wizard
--]]


local content = game:GetService('ContentProvider');
local UserInputService = game:GetService("UserInputService");
local localPlayer = game:GetService("Players").LocalPlayer;

local images = {
	boardTop = "rbxassetid://2743008362";
	board = "rbxassetid://2742700526";
	closedCell = "rbxgameasset://Images/cell_hidden";
	openCell = "rbxgameasset://Images/cell_unhidden";
	flagCell = "rbxgameasset://Images/cell_flag";
	mineCell = "rbxgameasset://Images/cell_mine";
	mineHitCell = "rbxgameasset://Images/cell_minehit";
	wrongFlagCell = "rbxgameasset://Images/cell_wrongflag";
	cell_1 = "rbxgameasset://Images/cell_1";
	cell_2 = "rbxgameasset://Images/cell_2";
	cell_3 = "rbxgameasset://Images/cell_3";
	cell_4 = "rbxgameasset://Images/cell_4";
	cell_5 = "rbxgameasset://Images/cell_5";
	cell_6 = "rbxgameasset://Images/cell_6";
	cell_7 = "rbxgameasset://Images/cell_7";
	cell_8 = "rbxgameasset://Images/cell_8";
	smiley_dead = "rbxassetid://2670782483";
	smiley_oface = "rbxassetid://2670782548";
	smiley_play = "rbxassetid://2670782592";
	smiley_pressed = "rbxassetid://2670782631";
	smiley_win = "rbxassetid://2670782665";
	number_0 = "rbxassetid://2670879412";
	number_1 = "rbxassetid://2670879480";
	number_2 = "rbxassetid://2670879566";
	number_3 = "rbxassetid://2670879615";
	number_4 = "rbxassetid://2670879658";
	number_5 = "rbxassetid://2670879709";
	number_6 = "rbxassetid://2670879760";
	number_7 = "rbxassetid://2670879800";
	number_8 = "rbxassetid://2670879830";
	number_9 = "rbxassetid://2670879892";
	number_blank = "rbxassetid://2670879934";
	boarder_top = "rbxassetid://2670918220";
	boarder_side = "rbxassetid://2670918184";
	boarder_top_left = "rbxassetid://2670918261";
	boarder_top_right = "rbxassetid://2670918304";
	boarder_bottom_left = "rbxassetid://2670918075";
	boarder_bottom_right = "rbxassetid://2670918147";
	count_number_0 = "rbxassetid://2670879412";
	count_number_1 = "rbxassetid://2670879480";
	count_number_2 = "rbxassetid://2670879566";
	count_number_3 = "rbxassetid://2670879615";
	count_number_4 = "rbxassetid://2670879658";
	count_number_5 = "rbxassetid://2670879709";
	count_number_6 = "rbxassetid://2670879760";
	count_number_7 = "rbxassetid://2670879800";
	count_number_8 = "rbxassetid://2670879830";
	count_number_9 = "rbxassetid://2670879892";
	count_number_10 = "rbxassetid://2670879934";

};

local easy = {
	x = 9;
	y = 9;
	mines = 10;
}
local medium = {
	x = 16;
	y = 16;
	mines = 40;
};
--i messed up x and y
local hard = {
	x = 16;
	y = 30;
	mines = 99;
}

local difficulty = easy;
local gridX = difficulty.x;
local gridY = difficulty.y;
local minesTotal = difficulty.mines;

local mineSweeperGame = {
	gameRunning = false;
	gameOver = false;
	clicks = 0;
	timeTaken = 0;
	flagsPlaced = 0;
	gameLost = false;
};

--[[
--remove top bar gui
pcall(function()
	local starterGui = game:GetService('StarterGui')
	starterGui:SetCore("TopbarEnabled", false)
end)
--]]

local cellSize = 32;
local barHeight = 90;
local boarderSize = 15;
local smileySize = 48;
local counterWidth = 28;
local counterHeight = smileySize;

local function drawImage(parent, position, size, image)
	local img = Instance.new("ImageLabel");
	img.Parent = parent;
	img.Position = position;
	img.Size = size;
	img.Image = image;
	img.BorderSizePixel = 0;
	img.ZIndex = 2;--3 parts of the frame decided to have a differnt zindex for some reason so need this :|
end

local screenGui = Instance.new("ScreenGui");
screenGui.Parent = game.Players.LocalPlayer.PlayerGui;
local frame = Instance.new("Frame");
local topBoard = Instance.new("Frame");
local mineCounter = {};
mineCounter[1] = Instance.new("ImageLabel");
mineCounter[2] = Instance.new("ImageLabel");
mineCounter[3] = Instance.new("ImageLabel");
local timeCounter = {}
timeCounter[3] = Instance.new("ImageLabel");
timeCounter[2] = Instance.new("ImageLabel");
timeCounter[1] = Instance.new("ImageLabel");
local cellBoardFrame = Instance.new("Frame");
local cellBoard = Instance.new("Frame");
local gridLayout = Instance.new("UIGridLayout")
local smiley = Instance.new("ImageButton");
function loadUI()
	frame.Parent = screenGui;
	frame.Position = UDim2.new(0, 0, 0, -36);
	frame.Size = UDim2.new(1, 0, 1, 36);
	frame.BackgroundColor3 = Color3.new(0,0,0);
	
	topBoard.Parent = frame;
	topBoard.Position = UDim2.new(0.5,-(cellSize*gridY+boarderSize*2)/2 ,0.1,0);
	topBoard.Size = UDim2.new(0,cellSize*gridY + boarderSize*2,0,barHeight);--x and y differnt way round
	topBoard.BackgroundColor3 = Color3.fromRGB(192,192,192);
	
	
	mineCounter[1].Parent = topBoard;
	mineCounter[1].Position = UDim2.new(0,boarderSize*2,0.5,-(counterHeight/2));
	mineCounter[1].Size = UDim2.new(0,counterWidth,0,counterHeight);
	mineCounter[1].Image = images.count_number_0;
	
	mineCounter[2].Parent = topBoard;
	mineCounter[2].Position = UDim2.new(0,(boarderSize*2)+counterWidth,0.5,-(counterHeight/2));
	mineCounter[2].Size = UDim2.new(0,counterWidth,0,counterHeight);
	mineCounter[2].Image = images.count_number_0;
	
	mineCounter[3].Parent = topBoard;
	mineCounter[3].Position = UDim2.new(0,(boarderSize*2)+counterWidth*2,0.5,-(counterHeight/2));
	mineCounter[3].Size = UDim2.new(0,counterWidth,0,counterHeight);
	mineCounter[3].Image = images.count_number_0;
	
	
	timeCounter[3].Parent = topBoard;
	timeCounter[3].Position = UDim2.new(1,-(boarderSize*2) + (-counterWidth),0.5,-(counterHeight/2));
	timeCounter[3].Size = UDim2.new(0,counterWidth,0,counterHeight);
	timeCounter[3].Image = images.count_number_0;
	
	timeCounter[2].Parent = topBoard;
	timeCounter[2].Position = UDim2.new(1,-(boarderSize*2) + (-(counterWidth*2)),0.5,-(counterHeight/2));
	timeCounter[2].Size = UDim2.new(0,counterWidth,0,counterHeight);
	timeCounter[2].Image = images.count_number_0;
	
	timeCounter[1].Parent = topBoard;
	timeCounter[1].Position = UDim2.new(1,-(boarderSize*2) + (-(counterWidth*3)),0.5,-(counterHeight/2));
	timeCounter[1].Size = UDim2.new(0,counterWidth,0,counterHeight);
	timeCounter[1].Image = images.count_number_0;
	
	drawImage(topBoard, UDim2.new(0,(boarderSize),0,0), UDim2.new(1,-(boarderSize*2),0,boarderSize), images.boarder_top);
	drawImage(topBoard, UDim2.new(0,0,0,boarderSize), UDim2.new(0,(boarderSize),1,-(boarderSize*2)), images.boarder_side);
	drawImage(topBoard, UDim2.new(1,-boarderSize,0,boarderSize), UDim2.new(0,(boarderSize),1,-(boarderSize*2)), images.boarder_side);
	drawImage(topBoard, UDim2.new(0,boarderSize,1,-boarderSize), UDim2.new(1,-(boarderSize*2),0,boarderSize), images.boarder_top);
	drawImage(topBoard, UDim2.new(0,0,0,0), UDim2.new(0,(boarderSize),0,boarderSize), images.boarder_top_left);
	drawImage(topBoard, UDim2.new(1,-boarderSize,0,0), UDim2.new(0,(boarderSize),0,boarderSize), images.boarder_top_right);
	drawImage(topBoard, UDim2.new(0,0,1,-boarderSize), UDim2.new(0,(boarderSize),0,boarderSize), images.boarder_bottom_left);
	drawImage(topBoard, UDim2.new(1,-boarderSize,1,-boarderSize), UDim2.new(0,(boarderSize),0,boarderSize), images.boarder_bottom_right);
	
	cellBoardFrame.Parent = topBoard;
	cellBoardFrame.Position = UDim2.new(0,0,0,barHeight);
	cellBoardFrame.Size = UDim2.new(0, (cellSize*gridY) + (boarderSize),0,cellSize*gridX +boarderSize);--x and y differnt way round
	cellBoardFrame.BorderSizePixel = 0;
	
	--left side. -3 to cover border from angle bit at top
	drawImage(cellBoardFrame, UDim2.new(0,0,0,-3), UDim2.new(0,(boarderSize),1,-(boarderSize) +3), images.boarder_side);
	drawImage(cellBoardFrame, UDim2.new(0,0,1,-boarderSize), UDim2.new(0,(boarderSize),0,boarderSize), images.boarder_bottom_left);
	drawImage(cellBoardFrame, UDim2.new(0,boarderSize,1,-boarderSize), UDim2.new(1,-(boarderSize),0,boarderSize), images.boarder_top);
	drawImage(cellBoardFrame, UDim2.new(1,0,1,-boarderSize),  UDim2.new(0,(boarderSize),0,boarderSize), images.boarder_bottom_right);
	drawImage(cellBoardFrame, UDim2.new(1,0,0,-3),UDim2.new(0,(boarderSize),1,-(boarderSize) +3), images.boarder_side);
	
	cellBoard.Parent = cellBoardFrame;
	cellBoard.Position = UDim2.new(0,boarderSize,0,0);
	cellBoard.Size = UDim2.new(1,0,1,0);
	cellBoard.BorderSizePixel = 0;

	gridLayout.Parent = cellBoard;
	gridLayout.CellPadding = UDim2.new(0,0,0,0);
	gridLayout.CellSize = UDim2.new(0,cellSize,0,cellSize);

	smiley.Parent = topBoard;
	smiley.Position = UDim2.new(0.5,-(smileySize/2),0.5,-(smileySize/2) );
	smiley.Size = UDim2.new(0,smileySize,0,smileySize);
	smiley.Image = images.smiley_play;
	smiley.BorderSizePixel = 0;
	smiley.MouseButton1Down:connect(function()
		smiley.Image = images.smiley_pressed;
	end)
	smiley.MouseButton1Up:connect(function()
		smiley.Image = images.smiley_play;
		restartGame();
	end)
	smiley.MouseLeave:connect(function()
		if mineSweeperGame.gameLost == true then
			smiley.Image = images.smiley_dead;
		end
	end)
end

--two timers can run at once
--high scores
--fix hover bug

local grid = {};
function createGrid()
	grid = {};
	gridX = difficulty.x;
	gridY = difficulty.y;
	minesTotal = difficulty.mines;
	for i = 1, gridX do
		grid[i] = {};
		for j = 1, gridY do
			grid[i][j] = {
				flagged = false;
				opened = false;
				number = 0;
				mine = false;
				button = nil;
				x = i;
				y = j;
			};
		end
	end
end

UserInputService.InputBegan:Connect(function(input,processed)
    if input.KeyCode == Enum.KeyCode.F2 then
		restartGame();
	end	
end)

function updateMineCounter()
	local mines;
	local flagged = difficulty.mines - mineSweeperGame.flagsPlaced
	if flagged < 0 then 
		mines = tostring(math.abs(-(flagged)));	
	else
		mines = tostring(flagged);
	end
	local num1 = 0;
	local num2 = 0;
	local num3 = 0;
	if string.len(mines) == 3 then
		num1 = tonumber(string.sub(mines,0,1));
		num2 = tonumber(string.sub(mines,1,1));
		num3 = tonumber(string.sub(mines,3));
	end	
	if string.len(mines) == 2 then
		num2 = tonumber(string.sub(mines,0,1));
		num3 = tonumber(string.sub(mines,2));
	end
	if string.len(mines) == 1 then
		num3 = tonumber(mines);
	end
	if flagged < 0 then 
		num1 = 10;
	end
	mineCounter[1].Image = images["count_number_"..num1];
	mineCounter[2].Image = images["count_number_"..num2];
	mineCounter[3].Image = images["count_number_"..num3];
end

local function updateTimer()
	local _time = tostring(mineSweeperGame.timeTaken);
	local num1 = 0;
	local num2 = 0;
	local num3 = 0;
	if string.len(_time) == 3 then
		num1 = tonumber(string.sub(_time,0,1));
		num2 = tonumber(string.sub(_time,2,2));
		num3 = tonumber(string.sub(_time,3));
	end	
	if string.len(_time) == 2 then
		num2 = tonumber(string.sub(_time,0,1));
		num3 = tonumber(string.sub(_time,2));
	end
	if string.len(_time) == 1 then
		num3 = tonumber(_time);
	end
	timeCounter[1].Image = images["count_number_"..num1];
	timeCounter[2].Image = images["count_number_"..num2];
	timeCounter[3].Image = images["count_number_"..num3];	
end

--timer script
local timer = coroutine.create(function()
	local x = 1;
	print("timer start");
	while true do
		if mineSweeperGame.gameRunning == true and mineSweeperGame.timeTaken < 999 then
			wait(0.1);
			x = x + 0.1;
			if x >= 1 then
				x = 0;
				mineSweeperGame.timeTaken = mineSweeperGame.timeTaken+1;
				updateTimer();
			end
		else
			print("timer end");
			coroutine.yield();
			x = 1;
		end
	
	end
end)

--Place mines on grid
--Parameters are the x,y for the first click to stop it being a mine
function placeMines(x, y)
	local minesPlaced = 0;
	while minesPlaced < minesTotal do
		local ran = Random.new();
		local rndX = math.floor(ran:NextNumber(1, gridX));
		local rndY = math.floor(ran:NextNumber(1, gridY));
		if grid[rndX][rndY].mine == false and rndX ~= x and rndY ~= y then
			grid[rndX][rndY].mine = true;
			minesPlaced = minesPlaced + 1;
		end
	end
end

function getNeighbours(g)
	local cells = {};
	local x = g.x;
	local y = g.y;
	local oldX = x;
	local oldY = y;
	
	for i = -1, 1 do
		x = i + oldX;
		for j = -1, 1 do
			y = j + oldY;
			if x <= gridX and x >= 1 and y <= gridY and y >= 1 then
				table.insert(cells,grid[x][y]);
			end
		end
	end
	return cells;
end

--Get number of mines surrounding cell
--Returns int
function getSurroundingMines(g)
	local mines = 0;
	local cells = getNeighbours(g);
	for i,v in ipairs(cells) do
		if cells[i].mine == true then
			mines = mines+1;
		end
	end
	return mines;
end

--Open all surrounding cells to create island
function openSurroundingCells(g)
	local cells = getNeighbours(g);
	for i,v in ipairs(cells) do
		if cells[i].mine == false and cells[i].opened == false and cells[i].flagged == false then
			openCell(cells[i]);
			if cells[i].number == 0 then
				openSurroundingCells(cells[i]);
			end
		end
	end
end

--Give each cell a number
function placeNumbers()
	for x,v in ipairs(grid) do
		for y,v in ipairs(grid[x]) do
			if grid[x][y].mine == false then
				grid[x][y].number = getSurroundingMines(grid[x][y]);
			end
		end
	end
end

--Open all cells that are mines
function openMineCells(x1,y1)
	for x,v in ipairs(grid) do
		for y,v in ipairs(grid[x]) do
			if grid[x][y].mine == true then --[and x1 ~= x and y1 ~= y then
				grid[x][y].button.Image = images.mineCell;
			end
			if grid[x][y].flagged == true and grid[x][y].mine == false then
				grid[x][y].button.Image = images.wrongFlagCell;
			end
		end
	end
	grid[x1][y1].button.Image = images.mineHitCell;
end

--Open a cell
function openCell(grid)
	grid.opened = true;
	if grid.mine == true then
		grid.button.Image = images.mineHitCell;
		openMineCells(grid.x, grid.y);
	else
		if grid.number ~= 0 then
			grid.button.Image = images["cell_".. grid.number];
		else
			grid.button.Image = images.openCell;
		end	
	end	
end

--Flag all mines
function flagMines()
	for x,v in ipairs(grid) do
		for y,v in ipairs(grid[x]) do
			if grid[x][y].mine == true then
				grid[x][y].button.Image = images.flagCell;
			end
		end
	end
end

--Check if player won
function checkWin()
	for x,v in ipairs(grid) do
		for y,v in ipairs(grid[x]) do
			if grid[x][y].mine == false and grid[x][y].opened == false then
				return;
			end	
		end
	end
	mineSweeperGame.gameOver = true;
	flagMines();
	smiley.Image = images.smiley_win;
	mineSweeperGame.gameRunning = false;
	mineSweeperGame.flagsPlaced = difficulty.mines;
	updateMineCounter();
end

--Handle a cell left click
function leftClickCell(grid)
	if grid.opened == true or grid.flagged == true then
		return;
	end
	if grid.mine == true then
		openCell(grid);
		mineSweeperGame.gameOver = true;
		smiley.Image = images.smiley_dead;
		mineSweeperGame.gameLost = true;
		mineSweeperGame.gameRunning = false;
	else
		if grid.number == 0 then
			openSurroundingCells(grid);
		else
			openCell(grid);
		end
		checkWin();
	end
end

--Handle cell right click aka flagging cell
function flagCell(grid)
	if grid.opened == false then
		if grid.flagged == false then
			grid.flagged = true;
			grid.button.Image = images.flagCell;
			mineSweeperGame.flagsPlaced = mineSweeperGame.flagsPlaced+1;
		else
			grid.flagged = false;
			grid.button.Image = images.closedCell;
			mineSweeperGame.flagsPlaced = mineSweeperGame.flagsPlaced-1;
		end
	end	
	updateMineCounter();
end

--Restart game
function restartGame()
	for x,v in ipairs(grid) do
		for y,v in ipairs(grid[x]) do
			grid[x][y].flagged = false;
			grid[x][y].opened = false;
			grid[x][y].number = 0;
			grid[x][y].mine = false;
			grid[x][y].button.Image = images.closedCell;
		end
	end
	mineSweeperGame.gameRunning = false;
	mineSweeperGame.clicks = 0;
	mineSweeperGame.timeTaken = 0;
	mineSweeperGame.gameOver = false;
	mineSweeperGame.flagsPlaced = 0;
	mineSweeperGame.gameLost = false;
	updateTimer();
	updateMineCounter();
end

--Build the board on first click
function buildBoard(x, y)
	placeMines(x, y);
	placeNumbers();
	--spawn(timer);
	mineSweeperGame.gameRunning = true;
	coroutine.resume(timer);
end

function getSurroundingFlags(g)
	local flags = 0;
	local cells = getNeighbours(g);
	for i,v in ipairs(cells) do
		if cells[i].flagged == true then
			flags = flags + 1;
		end
	end
	return flags;
end

function chording(g)
	if g.opened then
		if g.number == getSurroundingFlags(g) then
			local cells = getNeighbours(g);
			for i,v in ipairs(cells) do
				if cells[i].opened == false and cells[i].flagged == false then
					leftClickCell(cells[i]);
				end
			end
		end
	end
end

local isChording = false;
local hoverCells = {};
function doHover(g)
	local leftButton = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1);
	local rightButton = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
	for i,v in ipairs(hoverCells) do
		if hoverCells[i].opened == false and hoverCells[i].flagged == false then
			hoverCells[i].button.Image = images.closedCell;
			table.remove(hoverCells, i);
		end
	end
	if leftButton and rightButton == false then
		if g.opened == false and g.flagged == false then
			g.button.Image = images.openCell;
			table.insert(hoverCells, g);
		end	
	elseif leftButton and rightButton then
		isChording = true;
		local cells = getNeighbours(g);
		if g.opened == false and g.flagged == false then	
			g.button.Image = images.openCell;
			table.insert(hoverCells, g);
		end
		for i,v in ipairs(cells) do
			if cells[i].opened == false and cells[i].flagged == false then
				cells[i].button.Image = images.openCell;
				table.insert(hoverCells, cells[i]);
			end		
		end
	elseif leftButton == false and rightButton == false then
	end
end

--Create a cell button
function newCell(grid)
	local cell = Instance.new("ImageButton");
	cell.Parent = cellBoard;
	cell.BorderSizePixel = 0;
	cell.Image = images.closedCell;
	cell.AutoButtonColor = false;
	grid.button = cell;
	cell.MouseButton1Up:connect(function()
		if mineSweeperGame.gameOver == false and isChording == false then
			if mineSweeperGame.clicks == 0 then
				buildBoard(grid.x, grid.y);
			end
			doHover(grid);
			mineSweeperGame.clicks = mineSweeperGame.clicks + 1;
			leftClickCell(grid);
			getNeighbours(grid);
		elseif isChording == true then
			isChording = false;
		end
	end)
	cell.MouseButton2Down:connect(function()
		if mineSweeperGame.gameOver == false then
			local leftButton = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1);
            if leftButton == false then
                flagCell(grid);
            end 
			doHover(grid);
		end
	end)
	cell.MouseButton1Down:connect(function()
		if mineSweeperGame.gameOver == false then
			smiley.Image = images.smiley_oface;
			doHover(grid);
		end
	end)
	cell.MouseButton1Up:connect(function()
		local rightButton = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
		if rightButton == true then
			chording(grid)
		end
		if mineSweeperGame.gameOver == false then
			smiley.Image = images.smiley_play;
		end
		doHover(grid);
	end)
	cell.MouseButton2Up:connect(function()
		local leftButton = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1);
		if leftButton == true then
			chording(grid)
		end
		doHover(grid);
	end)
	cell.MouseEnter:connect(function()
		if mineSweeperGame.gameOver == false then
			doHover(grid);
		end
		
	end)
	cell.MouseLeave:connect(function()
		if mineSweeperGame.gameOver == false and grid.opened == false then
		end
	end)
end

function destroyCells()
	for x,v in ipairs(grid) do
		for y,v in ipairs(grid[x]) do
			grid[x][y].button:Destroy();
		end
	end
end

--Create buttons
function drawCells()
	for x,v in ipairs(grid) do
		for y,v in ipairs(grid[x]) do
			newCell(grid[x][y]);
		end
	end
end



function loadGame()
	createGrid();
	loadUI();
	drawCells();
	updateMineCounter();
end
loadGame();

--freeze player / disable zooming in and out
localPlayer.CameraMaxZoomDistance = 100;
localPlayer.CameraMinZoomDistance = 100;
repeat wait() until localPlayer.Character.Humanoid -- wait for player to spawn
localPlayer.Character.Humanoid.Torso.Anchored = true;

local sideBarOpen = false;
local sideBar = Instance.new("Frame");
sideBar.Parent = screenGui;
sideBar.Size = UDim2.new(0,150,0,300);
sideBar.Position = UDim2.new(0,-(sideBar.AbsoluteSize.X),0.5,-(sideBar.AbsoluteSize.Y/2));
sideBar.BackgroundColor3 = Color3.new(192/256,208/256,255/256);
sideBar.BorderSizePixel = 5;
sideBar.BorderColor3 = Color3.new(1,1,1);
sideBar.ZIndex = 3;

local sideButton = Instance.new("TextButton");
sideButton.Parent = sideBar;
sideButton.Size = UDim2.new(0,30,0,100);
sideButton.Position = UDim2.new(1,0,0.5,-(sideButton.AbsoluteSize.Y/2));
sideButton.BackgroundColor3 = Color3.new(192,208,255);
sideButton.Text = ">>";
sideButton.BorderSizePixel = 0;
sideButton.ZIndex = 3;
sideButton.MouseButton1Down:connect(function()
	if sideBarOpen == false then
		sideBar:TweenPosition(UDim2.new(0,0,0.5,-(sideBar.AbsoluteSize.Y/2)), "Out", "Quint", 0.5, false, function()
			sideBarOpen = true;	
		end)
		sideButton.Text = "<<";
	else
		sideBar:TweenPosition(UDim2.new(0,-(sideBar.AbsoluteSize.X),0.5,-(sideBar.AbsoluteSize.Y/2)), "Out", "Quint", 0.5, false, function()
			sideBarOpen = false;
			
		end)
		sideButton.Text = ">>";		
	end
end)

local function sideBarButton(text, position, callBack)
	local button = Instance.new("TextButton");
	button.Parent = sideBar;
	button.Size = UDim2.new(0,100,0,30);
	button.Position = position;
	button.BackgroundColor3 = Color3.new(192/256,208/256,255/256);
	button.BorderSizePixel = 5;
	button.BorderColor3 = Color3.new(1,1,1);
	button.Text = text;
	button.ZIndex = 3;
	button.MouseButton1Down:connect(function()
		callBack();
	end)
	
end

function loadNew()
	destroyCells();
	loadGame();
	restartGame();
end

sideBarButton("Easy", UDim2.new(0.5,-50,0.1,0), function()
	difficulty = easy;
	loadNew();
end)

sideBarButton("Medium", UDim2.new(0.5,-50,0.1,50), function()
	difficulty = medium;
	loadNew();
end)

sideBarButton("Hard", UDim2.new(0.5,-50,0.1,100), function()
	difficulty = hard;
	loadNew();
end)
