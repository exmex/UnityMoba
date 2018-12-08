--Maintenance By WYL

require "Logic.UICommon.Static.UITools"
require "Logic.UICommon.Static.UIQueue"
class("UIDamage")
----------------------------------------------------
function UIDamage:Awake(this) 
  self.this = this  
  -------------------------------------
  UIDamage.Instance=self;
  -------------------------------------
  self.showInterval = 0.1  --显示间隔0.2
  self.damageTipQueue=UIQueue.new()
  self.canStartCoroutine=true
  
  self.cotable={}
end
----------------------------------------------------
function UIDamage:Start()
  ---------------------队列----------------------
  --[[
  lp=UIQueue.new()

  UIQueue.Enqueue(lp,1)
  UIQueue.Enqueue(lp,2)
 
  if(UIQueue.NotNull(lp))then
  x=UIQueue.Dequeue(lp)
  print(x)
  end
  if(UIQueue.NotNull(lp))then
  x=UIQueue.Dequeue(lp)
  print(x)
  end
  if(UIQueue.NotNull(lp))then
  x=UIQueue.Dequeue(lp)
  print(x)
  end
  --]]

  
--[[
  self:ShowDamage(0, 43,true);
  self:ShowDamage(1, 43,true);
  self:ShowDamage(2, 43);
  self:ShowDamage(4, 43);
  self:ShowDamage(6, 43);
 --]]



end
----------------------------------------------------
function UIDamage:OnDestroy() 
  if(self.cotable~=nil)then
    for k,v in pairs(self.cotable) do
      coroutine.stop(v)
    end
  end
  
  ------------------------------------
  UIDamage.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
-----------------------------------------------------
function UIDamage:ShowDamage(hitType,damage,critical,x,y) 
    

    if(self==nil)then return end
    --UIPool.Instance:Return(v)
    local go =UIPool.Instance:Get("Damage");
    go.transform:SetParent(self.this.transform);
    go.transform.localPosition=Vector3.zero
    go.transform.localScale=Vector3.one
    go.transform.localRotation = Quaternion.identity 
    UIQueue.Enqueue(self.damageTipQueue,{UITools.GetLuaScript(go,"Logic.M022.UIBattle.UIDisplayDamage"),hitType,damage,critical})
    if(x==nil or y==nil)then

    else 
      self.this.transform.localPosition=Vector3.New(x,y,0)-self.this.transform.parent.localPosition;  --相对血条的位置=相对UI中心的localPosition-血条相对UI中心的localPosition
    end
    
      self:MyStartCoroutine() 
    
end
-----------------------------------------------------
function UIDamage:ShowDamageInterval() 
  self.canStartCoroutine=false
	while(true)do
		if(UIQueue.NotNull(self.damageTipQueue))then
			local o=UIQueue.Dequeue(self.damageTipQueue)
			o[1]:DisplayDamage(o[2],o[3],o[4])
		
			UIPool.Instance:ReturnDelay(o[1].this.gameObject,1) 
			
      coroutine.wait(self.showInterval)
    else
      break;
		end	
	end
  self.canStartCoroutine=true
end
--------------------------------------------------------
function UIDamage:MyStartCoroutine() 
  if(self.canStartCoroutine==true)then
    if(self.this.gameObject.activeInHierarchy==true)then
      table.insert(self.cotable,
                   coroutine.start(self.ShowDamageInterval,self)
                  )
    end
  end
end
--------------------------------------------------------

  