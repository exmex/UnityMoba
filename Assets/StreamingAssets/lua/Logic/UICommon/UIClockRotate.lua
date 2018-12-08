require "System.Global"
--控制自身旋转，可选平滑模式与时钟模式
UIClockRotate = {}
----------------------------------------------------
function UIClockRotate:New(o)
  local o = o or {}
  setmetatable(o, UIClockRotate)
  UIClockRotate.__index = UIClockRotate
  return o
end
----------------------------------------------------
function UIClockRotate:Awake(this) 
  self.this = this  

  --------------字段----------------
  self.motionSpeed=45;
  self.uniformMotion=0;   --bool
  self.clockMotion=0;     --bool
  
  self.moveIterval=0.2;
  self.moveAngel=15;
  ----------------------------------
  self.uniformMotion=self.this.ints[0];
  self.clockMotion=self.this.ints[1];
  
  if(self.this.floats[0]~=nil)then
    self.motionSpeed=self.this.floats[0];end
  if(self.this.floats[1]~=nil)then
    self.moveIterval=self.this.floats[1];end
  if(self.this.floats[2]~=nil)then
    self.moveAngel=self.this.floats[2];end
  
end
----------------------------------------------------
function UIClockRotate:OnEnable()
  
  if(self.clockMotion==1)then
    self.co1= coroutine.start(UIClockRotate.ClockRotate,self )
    
  end
  if(self.uniformMotion==1)then
    self.co2=coroutine.start( UIClockRotate.UniformRotate,self)
    
  end
  
end
----------------------------------------------------
function UIClockRotate:OnDestroy()
  if(self.co1~=nil)then
    coroutine.stop(self.co1)
  end
  if(self.co2~=nil)then
    coroutine.stop(self.co2)
  end

  self.this = nil
  self = nil
end
----------------------------------------------------
function UIClockRotate:ClockRotate()
  
  while(true) do
    coroutine.wait(self.moveIterval)
    self.this.transform:Rotate(  Vector3.New(0, 0, self.moveAngel) );
  end

end
----------------------------------------------------
function UIClockRotate:UniformRotate()
  
  while(true) do
    coroutine.step()
    self.this.transform:Rotate(  Vector3.New(0, 0, self.uniformMotion)* Time.deltaTime);
  end

end


