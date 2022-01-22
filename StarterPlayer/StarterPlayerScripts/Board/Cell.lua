local Cell = {}
local cellMt = {
	__index = Cell
}

function Cell.new(x,y)
	local self = setmetatable({}, cellMt)
	self.x = x
	self.y = y
	self.isMine = false
	self.isFlagged = false
	self.number = 0
	self.isOpen = false
	self.isHitMine = false
	self.listeners = {}
	return self
end

function Cell:open()
	self.isOpen = true
	for _, listener in ipairs(self.listeners) do
		listener(self.x, self.y)
	end
end

function Cell:flag(flagged)
	if flagged then
		self.isFlagged = true
	else
		self.isFlagged = false
	end
	for _, listener in ipairs(self.listeners) do
		listener(self.x, self.y)
	end
end

function Cell:addEventListener(func)
	table.insert(self.listeners, func)
end

return Cell
