Coroutine = {}
function Coroutine.New(o)
  local o = o or {}
  setmetatable(o, Coroutine)
  Coroutine.__index = Coroutine
  return o
end

function Coroutine:Create(f, fself, ...)	
	self.co = coroutine.create(f)
  self.fself= fself
  self.args = {...}
end

function Coroutine:Resume()
  return coroutine.resume(self.co, self.fself, unpack(self.args))
end

function Coroutine:Destory()
  if coroutine.status(self.co) == "dead" then
      self = nil
      return true
  end
    
  return false
end
