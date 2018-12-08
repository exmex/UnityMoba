
GameGuard = {}

function GameGuard.New(o)
  local o = o or {}
  setmetatable(o, GameGuard)
  GameGuard.__index = GameGuard
  return o
end

function GameGuard:Awake(this) 
  self.this = this  
  self.GuardList = {}
  
  GameGuard.Instance = self  
  
  self.co = coroutine.start(GameGuard.DoCheck, self)  
end

function GameGuard:OnDestroy()
  self.this = nil
  self = nil
end

function GameGuard:Set(name, time, callback, callbackSelf)
  
  print("name " .. name .. "time " .. time)
  self.GuardList[name] = {time = Time.time + time, callback = callback, callbackSelf = callbackSelf}
  print("name " .. name)
end

function GameGuard:Reset(name)
  print("endname " .. name)
  self.GuardList[name] = nil  
end

function GameGuard:DoCheck()  
  while true do
    for k in pairs(self.GuardList) do
      if Time.time > self.GuardList[k].time then
        self.GuardList[k].callback(self.GuardList[k].callbackSelf)
        self.GuardList[k] = nil
      end
    end
    coroutine.step()
  end  
end
