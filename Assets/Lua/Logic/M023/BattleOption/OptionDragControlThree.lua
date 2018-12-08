require "System.Global"

class("OptionDragControlThree")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"

function OptionDragControlThree:Awake(this)
	-- body
	self.this = this
	self.UICamera=GameObject.Find("GameLogic"):GetComponent("Camera")
  	self.canvas= GameObject.Find("PanelRoot"):GetComponent("Canvas") 
  	self.y=self.canvas.transform:GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.y
  	self.status = {}
  	self.delegate = ""

  	self.ll = ""
  	self.mm = ""
  	self.rr = ""	
end

function OptionDragControlThree:Start()
	-- body
  local listener = NTGEventTriggerProxy.Get(self.this.gameObject);
  --listener.onBeginDrag = listener.onBeginDrag + DelegateFactory.NTGEventTriggerProxy_PointerEventDelegate_Self(self, OptionDragControl.OnBeginDrag);
  listener.onDrag = NTGEventTriggerProxy.PointerEventDelegateSelf(OptionDragControlThree.OnDrag, self);
  --listener.onEndDrag= listener.onEndDrag+ DelegateFactory.NTGEventTriggerProxy_PointerEventDelegate_Self(self, UIDragMe.OnEndDrag);
end

function OptionDragControlThree:OnBeginDrag(eventData)
	-- body
	print("ABC")
end

function OptionDragControlThree:OnDrag(eventData)
	-- body
	local dis =  self.UICamera:ScreenToWorldPoint(Input.mousePosition).x - self.this.transform.parent.parent.position.x
	if dis < -0.7 then
		self.this.transform.parent.localPosition = Vector3.New(-84,10.4,0)
		self.this.transform.parent:Find("Text"):GetComponent(Text).text = self.ll
		self.status[1] = 0
		self:EventControl(self.delegate)
	elseif dis > - 0.7 and dis < 0.43 then
		self.this.transform.parent.localPosition = Vector3.New(0,10.4,0)
		self.this.transform.parent:Find("Text"):GetComponent(Text).text = self.mm
		self.status[1] = 1
		self:EventControl(self.delegate)
	elseif dis > 0.43 then
		self.this.transform.parent.localPosition = Vector3.New(84,10.4,0)
		self.this.transform.parent:Find("Text"):GetComponent(Text).text = self.rr
		self.status[1] = 2
		self:EventControl(self.delegate)		
	end
end

function OptionDragControlThree:EventControl(delegate)
	-- body
	if delegate ~= nil then
		print("delegate")
		self.this:InvokeDelegate(delegate,self.status)
	end
end

function OptionDragControlThree:OnDestroy()
	-- body
	self.this = nil
	self = nil
end