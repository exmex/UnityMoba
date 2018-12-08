
class("UILongPress")
----------------------------------------------------
function UILongPress:Awake(this) 
  self.this = this  
  -------------------------------------
  --self.timerLocker=false
  self.cumulativeTime =0;
  self.shadowGameObject=self.this.transforms[0].gameObject;--要隐藏、显示的，可能是提示框、摇杆或者是空：脚本只作为短时间的Click
  self.pressShowTime= 2;
self.Draged=false;--已经被拖拽标记
  --self:Timing()
  
end
----------------------------------------------------
function UILongPress:Start()
  
  local listener = NTGEventTriggerProxy.Get(self.this.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnPointerDown,self);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnPointerUp,self);
  
  listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
         self.shadowGameObject:SetActive(false);
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
function UILongPress:OnDestroy() 
  
  
  coroutine.stop(self.co)
  ------------------------------------
  self.this = nil
  self = nil
end
------------------委托方法----------------
function UILongPress:OnPointerDown() 
 
  --self.timerLocker = true;
  self.co= coroutine.start( self.TimingCo,self)  
end

function UILongPress:OnPointerUp() 
  
   --self.timerLocker = false;
   coroutine.stop(self.co)
   self.cumulativeTime = 0;
   self.shadowGameObject:SetActive(false);
   
   --self.this:StopAllCoroutines()
end
--------------------协程----------------------
function UILongPress:TimingCo()  --Transform,Vector3
  
  while(true) do  
      self.cumulativeTime =self.cumulativeTime + Time.deltaTime;
      if( self.cumulativeTime >= self.pressShowTime and self.shadowGameObject.activeSelf == false )then  
        if(self.Draged==false)then
          self.shadowGameObject:SetActive(true);
          break
        end
      end
   coroutine.step();
  end
 
end

------------------------------------------
function UILongPress:OnDisable ()  --Transform,Vector3
  
  self:OnPointerUp() 
 
end