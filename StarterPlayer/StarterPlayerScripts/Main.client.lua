local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players")
local localPlayer = Player.LocalPlayer
local playerScripts = localPlayer.PlayerScripts
local BoardGui = require(playerScripts:WaitForChild("BoardGui"))
local Settings = require(playerScripts:WaitForChild("Settings"))
local PlayerGui = localPlayer:WaitForChild("PlayerGui")
PlayerGui.ScreenOrientation = Enum.ScreenOrientation.Portrait
local GUI = PlayerGui:WaitForChild("MinesweeperGui")
local SideBar = GUI:WaitForChild("SideBar")
local onMobile = false
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
	onMobile = true
	SideBar.Visible = false
	SideBar = GUI:WaitForChild("SideBarMobile")
	SideBar.Visible = true
end
local SideBarButton = SideBar:WaitForChild("OpenButton")
local EasyButton = SideBar:WaitForChild("Easy")
local MediumButton = SideBar:WaitForChild("Medium")
local HardButton = SideBar:WaitForChild("Hard")
local CustomButton = SideBar:WaitForChild("Custom")
local CellSizeButton = SideBar:WaitForChild("CellSize")
local SizeXInput = SideBar:WaitForChild("SizeX")
local SizeYInput = SideBar:WaitForChild("SizeY")
local MinesInput = SideBar:WaitForChild("MineCount")
local CellSizeInput = SideBar:WaitForChild("CellSizeInput")

local SIDE_TWEEN_TIME = 0.2
local sideBarOpen = false
local minesweeper = BoardGui.new(9,9,10)

SideBarButton.Activated:Connect(function()
	if not sideBarOpen then
		local udim2 = if onMobile then UDim2.fromScale(0.5,1.01) else UDim2.fromScale(0,0.5)
		SideBar:TweenPosition(udim2, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, SIDE_TWEEN_TIME)
		task.wait(SIDE_TWEEN_TIME)
		SideBarButton.Text = if onMobile then "˅" else "<"
		sideBarOpen = true
	else
		local udim2 = if onMobile then UDim2.fromScale(0.5, 0.1) else UDim2.fromScale(-0.185,0.5)
		SideBar:TweenPosition(udim2, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, SIDE_TWEEN_TIME)
		task.wait(SIDE_TWEEN_TIME)
		SideBarButton.Text = if onMobile then "^" else ">"
		sideBarOpen = false
	end
end)

EasyButton.Activated:Connect(function()
	minesweeper:reset(9,9,10)
end)

MediumButton.Activated:Connect(function()
	minesweeper:reset(16,16,40)
end)

HardButton.Activated:Connect(function()
	minesweeper:reset(30,16,99)
end)

CustomButton.Activated:Connect(function()
	local x = SizeXInput.Text
	local y = SizeYInput.Text
	local mines = MinesInput.Text
	if not tonumber(x) or not tonumber(y) or not tonumber(mines) then return end
	minesweeper:reset(tonumber(x),tonumber(y),tonumber(mines))
end)

CellSizeButton.Activated:Connect(function()
	local cellSize = CellSizeInput.Text
	if not tonumber(cellSize) then return end
	Settings.tileSize = tonumber(cellSize)
	minesweeper:reset()
end)
CellSizeInput.Text = Settings.tileSize

-- Disable default controls
local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()
Controls:Disable()




local assets = {
	"rbxassetid://6079444536",
	"rbxassetid://6079444462",
	"rbxassetid://6079444395",
	"rbxassetid://6079444333",
	"rbxassetid://6079444270",
	"rbxassetid://6079444204",
	"rbxassetid://6079444118",
	"rbxassetid://6079444039",
	"rbxassetid://6079443218",
	"rbxassetid://6079443103",
	"rbxassetid://6079443016",
	"rbxassetid://6079442947",
	"rbxassetid://6079442882",
	"rbxassetid://6079442804",
	"rbxassetid://6079442719",
	"rbxassetid://6079442642",
	"rbxassetid://6079442541",
	"rbxassetid://6079443592",
	"rbxassetid://6079443288",
	"rbxassetid://6079442468",
	"rbxassetid://6079443882",
	"rbxassetid://6079443779",
	"rbxassetid://6079443663",
	"rbxassetid://6079443515",
	"rbxassetid://6079443956",
	"rbxassetid://2670782592",
	"rbxassetid://2670782665",
	"rbxassetid://2670782483"
}

task.spawn(function() 
	ContentProvider:PreloadAsync(assets)
end)




