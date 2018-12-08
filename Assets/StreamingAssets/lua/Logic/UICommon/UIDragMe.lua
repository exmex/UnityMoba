require "System.Global"
--lua标准模板
UIDragMe = {}
----------------------------------------------------
function UIDragMe:New(o)
  local o = o or {}
  setmetatable(o, UIDragMe)
  UIDragMe.__index = UIDragMe
  return o
end
----------------------------------------------------
function UIDragMe:Awake(this) 
  self.this = this  



  self.dragOnSurfaces = true;
	self.m_DraggingIcon=nil;--GameObject
  self.m_DraggingIconRT =nil;-- RectTransform 
	self.m_DraggingPlane=nil;-- RectTransform 
  
  
   self.UICamera=GameObject.Find("GameLogic"):GetComponent("Camera")
  self.canvas= GameObject.Find("PanelRoot"):GetComponent("Canvas"); 
  self.y=self.canvas.transform:GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.y
  if(self.canvas==nil)then
    return;  
    end
  
  
 
  
end
----------------------------------------------------
function UIDragMe:Start()
  
   
  listener = NTGEventTriggerProxy.Get(self.this.gameObject);
  listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( UIDragMe.OnBeginDrag,self);
  listener.onDrag= listener.onDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf( UIDragMe.OnDragself,self);
  listener.onEndDrag= listener.onEndDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf( UIDragMe.OnEndDrag,self);

end
----------------------------------------------------
function UIDragMe:OnDestroy()
  
  self.this = nil
  self = nil
end
----------------------------------------------------
function UIDragMe:OnBeginDrag(eventData)
   
  	self.m_DraggingIcon= GameObject.New("icon");
    self.m_DraggingIcon.transform:SetParent (self.canvas.transform, false);    --不受父节点的影响，保持原局部坐标和缩放。
    self.m_DraggingIcon.transform:SetAsLastSibling();                          --移动该变换到此局部变换列表的末尾。
   
    local image=self.m_DraggingIcon:AddComponent(NTGLuaScript.GetType("UnityEngine.UI.Image"));
    local canvasGroup=self.m_DraggingIcon:AddComponent(NTGLuaScript.GetType("UnityEngine.CanvasGroup"));
    canvasGroup.blocksRaycasts = false;                                        --不受射线影响，即不可点击等
  
  	image.sprite = self.this:GetComponent("UnityEngine.UI.Image").sprite;
    image:SetNativeSize();

    if (dragOnSurfaces) then
      self.m_DraggingPlane=self.this:GetComponent("RectTransform");
    else
      self.m_DraggingPlane=self.canvas.transform:GetComponent("RectTransform");
    end
  
    self.m_DraggingIconRT = self.m_DraggingIcon:GetComponent("RectTransform");--获取生成的Icon的RectTransform
  	self:SetDraggedPosition(eventData); 
  
end

function UIDragMe:SetDraggedPosition(eventData)
    
    self.m_DraggingIconRT.anchoredPosition=self:MouseToUIposition(Input.mousePosition)
  
end

function UIDragMe:MouseToUIposition(mousePosition) --Input.mousePosition
    
    local y=self.y;--720要改的吧从canvas获取
    
    local wash= Screen.width / Screen.height;

    local screenPos = self.UICamera:ScreenToViewportPoint(mousePosition);
 
    return Vector3.New((screenPos.x - 0.5) * y * wash, (screenPos.y - 0.5) * y, 0);
  
end

function UIDragMe:OnDrag(eventData) 
    
  if( self.m_DraggingIcon ~= nil )then
    self:SetDraggedPosition(eventData); 
    end
    
end

function UIDragMe:OnEndDrag(eventData) 
    
  if( self.m_DraggingIcon ~= nil )then
    Object.Destroy(self.m_DraggingIcon);    
    end
    
end