require "Logic.UICommon.Static.UITools"
class("UICountDown")
----------------------------------------------------
function UICountDown:Awake(this) 
  self.this = this  
  -------------------------------------
  UICountDown.Instance=self;
  -------------------------------------
  
  
end
----------------------------------------------------
function UICountDown:Start()
  self.textTime = self.this.transforms[0]:GetComponent("Text")
end
----------------------------------------------------
function UICountDown:OnDestroy() 
  
  coroutine.stop(self.co)
  ------------------------------------
  UICountDown.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
----------------------------------------------------
function UICountDown:StartCountDown(t)
  
  self.co = coroutine.start( self.StartCountDownCo, self,t)

end

function UICountDown:StartCountDownCo(t)
coroutine.step()  --等一帧，当前帧有多个相同脚本执行协称赋值text会停止
  while(true) do
   
    self.textTime.text=UITools.GetStringTimeII(t)  --与当前时间差 输出格式00:00
      if(self.textTime.text=="00:00")then
        Object.Destroy(self.this.gameObject)
      end
    coroutine.wait(1)
  end
end

--[[
function UICountDown:GetStringTime(t)  --创建战队时间

  local T= UTGData.Instance():GetLeftTime(t)  
  T=math.abs(T);
  local day = T / 86400; --以天数为单位取整 
  local hour= T % 86400 / 3600; --以小时为单位取整 
  local min = T % 86400 % 3600 / 60; --以分钟为单位取整 
  local seconds = T % 86400 % 3600 % 60 / 1; --以秒为单位取整 
  local str ;
  if(day>=7)then
    str = "最近上线  " .. "7天前"
    --str = (  math.floor(day) .. "天" .. math.floor(hour) .. "小时" .. math.floor(min) .. "分" .. math.floor(seconds) .. "秒" )
  elseif(day>=1 )then --day<7
    str = "最近上线  " .. math.floor(day) .. "天前"
  elseif(hour>=1)then --<24
    str = "最近上线  " .. math.floor(hour) .. "小时" .. math.floor(min) .. "分钟前"
  elseif(min>=1 )then --<60  
    str = "最近上线  " .. math.floor(min) .. "分钟前"
  else
    str = "最近上线  " .. math.floor(seconds) .. "秒钟前"
  end
  return str
  
end
--]]



