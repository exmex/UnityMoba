require "Logic.UICommon.Static.UITools"
class("UICountDownHMS")
----------------------------------------------------
function UICountDownHMS:Awake(this) 
  self.this = this  
  -------------------------------------
  UICountDownHMS.Instance=self;
  -------------------------------------
  
  
end
----------------------------------------------------
function UICountDownHMS:Start()
  self.textTime = self.this.transforms[0]:GetComponent("Text")
end
----------------------------------------------------
function UICountDownHMS:OnDestroy() 
  if(self.co~=nil)then
    coroutine.stop(self.co)
  end


  ------------------------------------
  UICountDownHMS.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
----------------------------------------------------
function UICountDownHMS:StartCountDown(t)
 
  self.co = coroutine.start( self.StartCountDownCo,self, t)

end

function UICountDownHMS:StartCountDownCo(t)
  coroutine.step()
  while(true) do
    
    self.textTime.text=UITools.GetStringTime(t)  --与当前时间差 输出格式00:00:00
    coroutine.wait(1)
  end
end



