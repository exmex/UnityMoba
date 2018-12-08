require "System.Global"
--加载Prefab的时候，标准化RectTransform的数值以匹配屏幕
UIMatchScreen = {}
----------------------------------------------------
function UIMatchScreen:New(o)
  local o = o or {}
  setmetatable(o, UIMatchScreen)
  UIMatchScreen.__index = UIMatchScreen
  return o
end
----------------------------------------------------
function UIMatchScreen:Awake(this) 
  self.this = this

  self.rt=self.this:GetComponent("RectTransform");
  
end

function UIMatchScreen:OnEnable() 



end
----------------------------------------------------
function UIMatchScreen:Start()
  self:MatchScreen()
end

function UIMatchScreen:MatchScreen()
  self.rt.anchorMin = Vector2.New(0, 0);
   self.rt.anchorMax =  Vector2.New(1, 1);
   self.rt.sizeDelta =  Vector2.New(0, 0);
   self.rt.localScale = Vector3.one;
   self.rt.localPosition = Vector3.zero;

end


----------------------------------------------------
function UIMatchScreen:OnDestroy()
  
  self.this = nil
  self = nil
end