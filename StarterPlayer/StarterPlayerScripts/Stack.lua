Stack = {}
Stack.__index = Stack
function Stack.new() return setmetatable({}, Stack) end

function Stack:push(input)
	self[#self+1] = input
end

function Stack:pop()
	assert(#self > 0, "Stack underflow")
	local output = self[#self]
	self[#self] = nil
	return output
end
return Stack