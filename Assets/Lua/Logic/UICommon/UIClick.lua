--限定时间按下抬起且禁止拖拽响应
class("UIClick")
----------------------------------------------------
function UIClick:Awake(this) 
  self.this = this  
  -------------------------------------
  self.Draged=false;--已经被拖拽标记

  self.timeLimit=nil;
  --self.timerLocker=false
  self.cumulativeTime = 0;
  self.shadowGameObject={};--要隐藏、显示的，可能是提示框、摇杆或者是空：脚本只作为短时间的Click
  

  self.clickSFs={}--存储委托方法和对应的self键值对的集合
  
  self.coTable={}
end
----------------------------------------------------
function UIClick:Start()
  if(self.this.floats.Length~=0)then
    self.timeLimit=self.this.floats[0];
  end

  local listener = NTGEventTriggerProxy.Get(self.this.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnPointerDown,self);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnPointerUp,self);

  listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
        
      self.Draged=true;
    end,self
    );
  listener.onEndDrag = listener.onEndDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
        
      self.Draged=false;
    end,self
    );
  
end
----------------------------------------------------
function UIClick:OnDestroy() 
  
  for k,v in pairs(self.coTable) do
    coroutine.stop(v)
  end

  ------------------------------------
  self.this = nil
  self = nil
end
------------------委托方法----------------
function UIClick:OnPointerDown(eventData) 
  --self.timerLocker = true;
  local coT= coroutine.start( self.TimingCo,self)  
  table.insert(self.coTable,coT)
--Debugger.LogError(eventData.position)   Debugger.LogError(eventData.pressPosition)  --没什么用 是屏幕坐标  
end

function UIClick:OnPointerUp(eventData) 
 
  --self.timerLocker = false;

    if(self.Draged==false and self.this.floats.Length==0)then --没有时间限制，直接执行

      for  i,v in pairs(self.clickSFs) do --执行委托方法
        v[2](v[1],v[3]);
      end 

    elseif( self.Draged==false  and  self.cumulativeTime  <= self.timeLimit)then --小于限制时间
      
      --带参数执行例子:self.clickFunc(self.clickSelf,self.aaa,self.bbb)  --原方法:UITest:SetText(sss,zzz) 
      for  i,v in pairs(self.clickSFs) do --执行委托方法
        v[2](v[1],v[3]);
      end 
      
    end
  self.cumulativeTime = 0;
  
  for k,v in pairs(self.coTable) do
    coroutine.stop(v)
  end
  
end
--------------------协程----------------------


function UIClick:TimingCo()  --Transform,Vector3
  while(true) do
    --if( self.timerLocker==true )then
      self.cumulativeTime =    self.cumulativeTime +Time.deltaTime;
    
    --end
    coroutine.step();
  end
end
-----------------------------------------------

function UIClick:RegisterClickDelegate(obj,func,paramTable) 
 
   table.insert( self.clickSFs,{obj,func,paramTable})
   --self.aaa=paramTable[1]
   --self.bbb=paramTable[2]
end
function UIClick:ExecuteClickDelegate()

  for  i,v in pairs(self.clickSFs) do --执行委托方法
     v[2](v[1],v[3]);
  end 
  
end