
class("UIRandomColor")
----------------------------------------------------
function UIRandomColor:Awake(this) 
  self.this = this  
  -------------------------------------
  UIRandomColor.Instance=self;
  -------------------------------------
  
  
end
----------------------------------------------------
function UIRandomColor:Start()
	self.image=self.this:GetComponent("Image");
	--self:ChangeColor()
	

end
----------------------------------------------------
function UIRandomColor:OnDestroy() 
  
  coroutine.stop(self.co)
  ------------------------------------
  UIRandomColor.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
----------------------------------------------------
function UIRandomColor:ChangeColor()
  self.co= coroutine.start( self.ChangeColorCoro,self)

end
function UIRandomColor:ChangeColorCoro()  --Transform,Vector3
  while(true) do 
    coroutine.wait(math.random(0.5,3.0))
    self.image.color = Color.New(1,1, 1, math.random())
  end
end