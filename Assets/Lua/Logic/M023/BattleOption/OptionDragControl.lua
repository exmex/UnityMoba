require "System.Global"

class("OptionDragControl")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"

function  OptionDragControl:Awake(this)
	-- body
	self.this = this
	self.UICamera=GameObject.Find("GameLogic"):GetComponent("Camera")
  	self.canvas= GameObject.Find("PanelRoot"):GetComponent("Canvas") 
  	self.y=self.canvas.transform:GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.y
  	self.status = {}
  	self.delegate = ""
  	self.test = "test"
end

function OptionDragControl:Start()
	-- body
  local listener = NTGEventTriggerProxy.Get(self.this.gameObject);
  listener.onBeginDrag = NTGEventTriggerProxy.PointerEventDelegateSelf(OptionDragControl.OnBeginDrag, self);
  listener.onDrag = NTGEventTriggerProxy.PointerEventDelegateSelf(OptionDragControl.OnDrag, self);
  --listener.onEndDrag= listener.onEndDrag+ DelegateFactory.NTGEventTriggerProxy_PointerEventDelegate_Self(self, UIDragMe.OnEndDrag);
end

function OptionDragControl:OnBeginDrag(eventData)
	-- body
	print("ABC")
end

function OptionDragControl:OnDrag(eventData)
	-- body
	if self.UICamera:ScreenToWorldPoint(Input.mousePosition).x < self.this.transform.parent.parent.position.x then
		self.this.transform.parent.localPosition = Vector3.New(-40,10.4,0)
		self.this.transform.parent:Find("Text"):GetComponent(Text).text = "关"
		self.status[1] = 0
		self:EventControl(self.delegate)
	else
		self.this.transform.parent.localPosition = Vector3.New(40,10.4,0)
		self.this.transform.parent:Find("Text"):GetComponent(Text).text = "开"
		self.status[1] = 1
		self:EventControl(self.delegate)
	end
end

function OptionDragControl:EventControl(delegate)
	-- body
	if delegate ~= nil then
		print("delegate")
		self.this:InvokeDelegate(delegate,self.status)
	end
end



function OptionDragControl:OnDestroy()
	-- body
	self.this = nil
	self = nil
end