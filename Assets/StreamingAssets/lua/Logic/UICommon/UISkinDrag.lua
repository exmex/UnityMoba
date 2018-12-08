require "System.Global"
--自动获取父亲物体上的UISkinList.lua，并调用其方法
UISkinDrag = {}
------------------------------------------------
function UISkinDrag:New(o)
  local o = o or {}
  setmetatable(o, UISkinDrag)
  UISkinDrag.__index = UISkinDrag
  return o
end
------------------------------------------------
function UISkinDrag:Awake(this) 
  self.this = this  

end
------------------------------------------------
function UISkinDrag:Start()
  --self.dragDelta={}  --Vector2
  self.draging = false;
  self.skinList={}
    
  self.luaScriptTable={}

  table.insert(self.luaScriptTable,self.this.transforms[0]:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[0])
  table.insert(self.luaScriptTable,self.this.transforms[0]:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[1])
  for i=1, #self.luaScriptTable,1 do  
    if(self.luaScriptTable[i].luaScript=="Logic.UICommon.UISkinList") then
      self.skinListScript=self.luaScriptTable[i].self; 
      self.skinList=self.luaScriptTable[i].self.skinList; 
    end
  end
  
  
  --self.skinListScript=self.this.transform.parent:GetComponent("NTGLuaScript").self;
  --self.skinList= self.skinListScript.skinList;--获取父物体上的脚本中的skinList
  
  listener = NTGEventTriggerProxy.Get(self.this.gameObject);
  listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( UISkinDrag.OnBeginDrag,self);
  listener.onDrag= listener.onDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf( UISkinDrag.OnDrag,self);
  
end
------------------------------------------------
function UISkinDrag:Update()

end
------------------------------------------------
function UISkinDrag:test()
  
end
------------------------------------------------
function UISkinDrag:OnDestroy()
  
  self.this = nil
  self = nil
end
------------------------------------------------
function UISkinDrag:OnBeginDrag(eventData)
 
  self.draging = true;
end

function UISkinDrag:OnDrag(eventData)
    
  --dragDelta = eventData.delta;
  if( self.draging ==true)then
                       
    if(eventData.delta.x>2)then 
      self.skinListScript:MoveRight();
    elseif(eventData.delta.x<-2)then 
      self.skinListScript:MoveLeft();
    end
    self.draging=false;
  end

end