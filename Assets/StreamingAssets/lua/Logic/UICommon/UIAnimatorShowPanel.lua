require "System.Global"
--lua标准模板
UIAnimatorShowPanel = {}
----------------------------------------------------
function UIAnimatorShowPanel:New(o)
  local o = o or {}
  setmetatable(o, UIAnimatorShowPanel)
  UIAnimatorShowPanel.__index = UIAnimatorShowPanel
  return o
end
----------------------------------------------------
function UIAnimatorShowPanel:Awake(this) 
  self.this = this  

  self.animator= self.this:GetComponent("Animator");

end
----------------------------------------------------
function UIAnimatorShowPanel:OnEnable()
       self.animator:SetInteger( "Show" ,1 );
end

function UIAnimatorShowPanel:OnDisable()
       self.animator:SetInteger( "Show" ,0 );
       --由于5.3版本升级导致动画播放完毕会保留位置等信息，所以必要的时候你会需要在隐藏界面时
       --重置回归坐标位置等信息，当然你需要编辑一个貌似一帧的动画就可以了，放在现在NewState的位置吧
       --暂时NewState是空动画，所以没有重置坐标的功能
end
----------------------------------------------------
function UIAnimatorShowPanel:OnDestroy()
  
  self.this = nil
  self = nil
end