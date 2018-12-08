require "System.Global"

UITabControl = {}
----------------------------------------------------
function UITabControl:New(o)
  local o = o or {}
  setmetatable(o, UITabControl)
  UITabControl.__index = UITabControl
  return o
end
----------------------------------------------------
function UITabControl:Awake(this) 
  self.this = this  

  
  self.groups={};
  self.toggles={};
  
  for i=1, self.this.transforms.Length ,1 do
    
    
    
    if(  i<=1+(self.this.transforms.Length-1)/2    )then
      table.insert (self.groups,self.this.transforms[i-1])
    elseif(i>1+(self.this.transforms.Length-1)/2 )then
       table.insert (self.toggles,self.this.transforms[i-1])
    end
  
  end
  
--  table.insert (self.toggles, self.parent:GetChild(0))
--  table.insert (self.toggles, self.parent:GetChild(1))
--  table.insert (self.toggles, self.parent:GetChild(2))
--
--  table.insert (self.groups, self.parent:GetChild(0):GetChild(0))
--  table.insert (self.groups, self.parent:GetChild(1):GetChild(0))
--  table.insert (self.groups, self.parent:GetChild(2):GetChild(0))
  coroutine.start( self.Wait,self)  
  

end
----------------------------------------------------
function UITabControl:OnEnable()
  

  
end

function UITabControl:Start()
--self:MyReset()
  

  

end
----------------------------------------------------
function UITabControl:OnDestroy()
  
  self.this = nil
  self = nil
end
----------------------------------------------------
function UITabControl:ChangeEquipGroup(eventData)
  --Debugger.LogError("XXXXXXXXXXX2");
  for i=1,#self.toggles,1 do
    
    if (self.toggles[i]:GetComponent("UnityEngine.UI.Toggle").isOn==true)then
      
      for j=1,#self.groups,1 do
        self.groups[j].gameObject:SetActive(false);
      end
        self.groups[i].gameObject:SetActive(true);
       
    end
  
  end

end
----------------------------------------------------
function UITabControl:Wait()
  coroutine.step()
  
  for j=1,#self.groups,1 do
    if(j~=1)then
      self.groups[j].gameObject:SetActive(false);
    end
  end
  for i=1,#self.toggles,1 do
      listener = NTGEventTriggerProxy.Get(self.toggles[i].gameObject);
      listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( UITabControl.ChangeEquipGroup,self);
      --Debugger.LogError("XXXXXXXXXXX");
  end
  

end
-------------------------------------------------------------------
    
  
    
 