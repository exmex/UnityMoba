
class("UIDragAndUp")
----------------------------------------------------
function UIDragAndUp:Awake(this) 
  self.this = this  
  -------------------------------------
  

  self.clickSFs={}--存储委托方法和对应的self键值对的集合
  
  self:Timing()
end
----------------------------------------------------
function UIDragAndUp:Start()
  

  local listener = NTGEventTriggerProxy.Get(self.this.gameObject);
  listener.onEndDrag = listener.onEndDrag + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnEndDrag,self);
  
end
----------------------------------------------------
function UIDragAndUp:OnDestroy() 
  
  

  ------------------------------------
  self.this = nil
  self = nil
end
------------------委托方法----------------
function UIDragAndUp:OnEndDrag() 
  for  i,v in pairs(self.clickSFs) do --执行委托方法
     v[2](v[1],v[3]);
  end 
end


--------------------协程----------------------
function UIDragAndUp:Timing()
  coroutine.start( self.TimingCo,self)
end

function UIDragAndUp:TimingCo()  --Transform,Vector3

  if( self.timerLocker==true )then
    self.cumulativeTime =    self.cumulativeTime +Time.deltaTime;
  end
  coroutine.step();

end
-----------------------------------------------

function UIDragAndUp:RegisterClickDelegate(obj,func,paramTable) --多跟了参数应该不影响，不会被赋值而已
   
   table.insert( self.clickSFs,{obj,func,paramTable})
   --self.aaa=paramTable[1]
   --self.bbb=paramTable[2]
end
function UIDragAndUp:ExecuteClickDelegate()
  
  for  i,v in pairs(self.clickSFs) do --执行委托方法
     v[2](v[1],v[3]);
  end 
  
end