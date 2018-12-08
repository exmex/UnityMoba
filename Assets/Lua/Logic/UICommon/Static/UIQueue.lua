--require "Logic.UICommon.Static.UIQueue"
--队列与双端队列
class("UIQueue")
function UIQueue.new()
   return {first=0, last=-1}
end
function UIQueue.EnqueueReverse(UIQueue,value)
   UIQueue.first=UIQueue.first-1
   UIQueue[ UIQueue.first ]=value
end
function UIQueue.Enqueue(UIQueue,value)
   UIQueue.last=UIQueue.last+1
   UIQueue[ UIQueue.last ]=value
end
function UIQueue.Dequeue(UIQueue)
   local first=UIQueue.first
   if first>UIQueue.last then error("UIQueue is empty!")
   end
   local value =UIQueue[first]
   UIQueue[first]=nil
   UIQueue.first=first+1
   return value
end
function UIQueue.DequeueReverse(UIQueue)
   local last=UIQueue.last
   if last<UIQueue.first then error("UIQueue is empty!")
   end
   local value =UIQueue[last]
   UIQueue[last]=nil
   UIQueue.last=last-1
   return value
end
function UIQueue.NotNull(UIQueue)
  --Debugger.LogError(UIQueue.first);Debugger.LogError(UIQueue.last);
  
  if(UIQueue.first<=UIQueue.last)then
    return true
  end
end
--[[
lp=UIQueue.new()
UIQueue.EnqueueReverse(lp,1)
UIQueue.EnqueueReverse(lp,2)
UIQueue.Enqueue(lp,-1)
UIQueue.Enqueue(lp,-2)
x=UIQueue.Dequeue(lp)
print(x)
x=UIQueue.DequeueReverse(lp)
print(x)
x=UIQueue.Dequeue(lp)
print(x)
x=UIQueue.DequeueReverse(lp)
print(x)
x=UIQueue.Dequeue(lp)
print(x)
--]]
--输出结果
-- 2
-- -2
-- 1
-- -1
-- lua：... UIQueue is empty！