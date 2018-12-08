require "System.Global"
--lua标准模板
UIDropMe = {}
----------------------------------------------------
function UIDropMe:New(o)
  local o = o or {}
  setmetatable(o, UIDropMe)
  UIDropMe.__index = UIDropMe
  return o
end
----------------------------------------------------
function UIDropMe:Awake(this) 
  self.this = this  
  
   
   
  self.containerImage=self.this.transforms[0]:GetComponent("UnityEngine.UI.Image")--Image：进入范围放置
  self.receivingImageTemp1=self.this.transforms[1]:GetComponent("UnityEngine.UI.Image")--Image: 用来接收图片的Image
  self.receivingImageTemp2=self.this.transforms[2]:GetComponent("UnityEngine.UI.Image")--Image: 用来接收图片的Image
  self.receivingImage=self.receivingImageTemp1;
  self.normalColor=nil;--Color 
  self.highlightColor=Color.New(1, 0.9215686, 0.01568628, 1); 
  
  
end
----------------------------------------------------
function UIDropMe:ChangeReceiveTarget()
  
  if(self.receivingImage==self.receivingImageTemp1)then
    self.receivingImage=self.receivingImageTemp1
  else
    self.receivingImage=self.receivingImageTemp2
  end
  
end
----------------------------------------------------
function UIDropMe:OnEnable()
   self.normalColor=self.containerImage.color;
end
----------------------------------------------------
function UIDropMe:Start()
    listener = NTGEventTriggerProxy.Get(self.this.gameObject);
    listener.onDrop = listener.onDrop + NTGEventTriggerProxy.PointerEventDelegateSelf( UIDropMe.OnDrop,self);
    listener.onPointerEnter = listener.onPointerEnter + NTGEventTriggerProxy.PointerEventDelegateSelf( UIDropMe.OnPointerEnter,self);
    listener.onPointerExit = listener.onPointerExit + NTGEventTriggerProxy.PointerEventDelegateSelf( UIDropMe.OnPointerExit,self);
end
----------------------------------------------------
function UIDropMe:OnDestroy()
  
  self.this = nil
  self = nil
end
----------------------------------------------------
function UIDropMe:OnDrop(eventData)
  
  self.containerImage.color=self.normalColor;
  local dropSprite = self:GetDropSprite (eventData);
   self.receivingImage.overrideSprite = dropSprite;
  
end
----------------------------------------------------
function UIDropMe:GetDropSprite(eventData)
  
  local originalObj = eventData.pointerDrag;
  if (originalObj == nil) then 
			return nil;
  end
  
  local srcImage = originalObj:GetComponent("UnityEngine.UI.Image");
  if (originalObj == nil) then 
			return nil;
  end
  
  return srcImage.sprite;
  
end
----------------------------------------------------
function UIDropMe:OnPointerEnter(eventData) --进入RectTransform即Image区域触发，由于需要看上去是containerImage区域变亮，而脚本又写在当前图片上，所以需要让当前区域变大进行适配， 勾选PreserveAspect可以使当前前景图片成比例的被区域约束；当然containerImage也可以是前景本身
  
 	if (self.containerImage == nil)then
			return;
  end
    
  local dropSprite = self:GetDropSprite (eventData);
  if (dropSprite ~= nil) then
    	self.containerImage.color = self.highlightColor;
  end
  
end
----------------------------------------------------
function UIDropMe:OnPointerExit(eventData)
  
 	if (self.containerImage == nil)then
			return;
  end
  
  
  self.containerImage.color = self.normalColor;
  
  
end





