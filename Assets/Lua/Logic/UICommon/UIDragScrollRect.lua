
class("UIDragScrollRect")

----------------------------------------------------
function UIDragScrollRect:Awake(this) 
  self.this = this  

end
----------------------------------------------------
function UIDragScrollRect:Start()
  if self.scrollRect==nil then
    self.scrollRect=self.this.transforms[0]:GetComponent("ScrollRect")
  end
  listener = NTGEventTriggerProxy.Get(self.this.gameObject);
  listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf(UIDragScrollRect.OnBeginDrag,self);
  listener.onDrag= listener.onDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf(UIDragScrollRect.OnDrag,self);
  listener.onEndDrag= listener.onEndDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf(UIDragScrollRect.OnEndDrag,self);

end
----------------------------------------------------
function UIDragScrollRect:OnDestroy()
  
  self.this = nil
  self = nil
end

function UIDragScrollRect:OnBeginDrag(eventData)
    if (self.scrollRect~=nil)then
      self.scrollRect:OnBeginDrag(eventData);
    end
end

function UIDragScrollRect:OnDrag(eventData) 
    
    if (self.scrollRect~=nil)then
      self.scrollRect:OnDrag(eventData);
    end
    
end

function UIDragScrollRect:OnEndDrag(eventData) 
    
   if (self.scrollRect~=nil)then
      self.scrollRect:OnEndDrag(eventData);
    end
    
end