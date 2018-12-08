require "System.Global"

class("BarAutoMove")

function BarAutoMove:Awake(this)
  self.this = this
  self.panelCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.initPoint = this.transform.position
  self.moveSpeed = 20

  self.Image=self.this:GetComponent("Image");
end

function BarAutoMove:Start()
  
end

function BarAutoMove:OnEnable()
  self.co=coroutine.start( BarAutoMove.Move,self)
end

function BarAutoMove:OnDisable()
  self.this.transform.position = self.initPoint
  self.this.gameObject:SetActive(false)
end

function BarAutoMove:Move()
 
  local a=0;
  while(true) do
    coroutine.wait(0.02)
    self.this.transform.localPosition = Vector3.New(self.this.transform.localPosition.x - (10 * self.moveSpeed), 0, 0)
    a=math.lerp(0,1,0.2);  self.Image.color=Color.New(1, 1, 1, a);
    if self.this.transform.localPosition.x <= 0 then 
      self.this.transform.localPosition = Vector3.zero;self.Image.color=Color.New(1, 1, 1, 1);  
      self.panelCtrl.self:BarMoveOK()
      break
    end
  end
  
end

function BarAutoMove:OnDestroy()
  coroutine.stop(self.co)

  self.this = nil
  self = nil
end