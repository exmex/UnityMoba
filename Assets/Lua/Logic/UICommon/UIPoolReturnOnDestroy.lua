
class("UIPoolReturnOnDestroy")
----------------------------------------------------
function UIPoolReturnOnDestroy:Awake(this) 
  self.this = this  
  -------------------------------------
  UIPoolReturnOnDestroy.Instance=self;
  -------------------------------------
  self.returns=self.this.transforms[0];
end
----------------------------------------------------
function UIPoolReturnOnDestroy:Start()
  
end
----------------------------------------------------
function UIPoolReturnOnDestroy:OnDestroy() 
	--[[
  for i=1,self.returns.childCount,1 do 
  	UIPool.Instance:Return(self.returns:GetChild(i-1).gameObject)
  	local NumberP= self.returns:GetChild(i-1):FindChild("Number")
  	for j=1, NumberP.childCount,1 do Debugger.LogError("Fuck3")
       UIPool.Instance:Return(NumberP:GetChild(j-1).gameObject)
  	end
  end
--]]
  while(self.returns.childCount>0)do
    local damage=self.returns:GetChild(0)
    --if(damage==nil)then return end
  	UIPool.Instance:Return(damage.gameObject)
    local number=damage:FindChild("Number")
    while(number.childCount>0)do 
      --if(number:GetChild(0)==nil)then return end
      UIPool.Instance:Return(number:GetChild(0).gameObject)
    end
  end
  
  ------------------------------------
  UIPoolReturnOnDestroy.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end