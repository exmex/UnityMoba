require "System.Global"

class("PromotePanelCtrl")

function PromotePanelCtrl:Awake(this)
	-- body
	self.this = this
	self.PromoteAnim = self.this.transforms[0]
	self.animFX1  = self.this.transforms[1]
	self.animFX2  = self.this.transforms[2]
	self.animFX3  = self.this.transforms[3]
	self.animFX4  = self.this.transforms[4]
	self.animFX5  = self.this.transforms[5]
	self.animFX6  = self.this.transforms[6]
	self.animFX7  = self.this.transforms[7]
	self.animFX8  = self.this.transforms[8]
	self.animFX9  = self.this.transforms[9]
	self.animFX10 = self.this.transforms[10]
	self.animFX11 = self.this.transforms[11]
	self.promoteTipPanel =self.this.transforms[12]

	self.lastGroup =self.this.transforms[13]
	self.nowGroup  =self.this.transforms[14]

	self.skillIcon =self.this.transforms[15]:GetComponent("UnityEngine.UI.Image")
	self.skillText =self.this.transforms[16]:GetComponent("UnityEngine.UI.Text")

	self.lastPool  =self.this.transforms[17]
	self.nowPool   =self.this.transforms[18]

	self.backGround =self.this.transforms[19]
	self.staticEA   =self.this.transforms[20]

	self.animFX_1  = self.this.transforms[21]
	self.animFX_2  = self.this.transforms[22]
	self.animFX_3  = self.this.transforms[23]
	self.animFX_4  = self.this.transforms[24]
	self.animFX_5  = self.this.transforms[25]
	self.animFX_6  = self.this.transforms[26]
	self.animFX_7  = self.this.transforms[27]
	self.animFX_8  = self.this.transforms[28]
	self.animFX_9  = self.this.transforms[29]
	self.animFX_10 = self.this.transforms[30]
	self.animFX_11 = self.this.transforms[31]

	self.levelGroup =self.this.transforms[32]
	self.levelPool  =self.this.transforms[33]
	self.staticLevelGroup =self.this.transforms[34]


	self.isPlayed = false

	self.PromoteAnimFx = {}
	table.insert(self.PromoteAnimFx,self.animFX1)
	table.insert(self.PromoteAnimFx,self.animFX2)
	table.insert(self.PromoteAnimFx,self.animFX3)
	table.insert(self.PromoteAnimFx,self.animFX4)
	table.insert(self.PromoteAnimFx,self.animFX5)
	table.insert(self.PromoteAnimFx,self.animFX6)
	table.insert(self.PromoteAnimFx,self.animFX7)
	table.insert(self.PromoteAnimFx,self.animFX8)
	table.insert(self.PromoteAnimFx,self.animFX9)
	table.insert(self.PromoteAnimFx,self.animFX10)
	table.insert(self.PromoteAnimFx,self.animFX11)
	table.insert(self.PromoteAnimFx,self.animFX_1)
	table.insert(self.PromoteAnimFx,self.animFX_2)
	table.insert(self.PromoteAnimFx,self.animFX_3)
	table.insert(self.PromoteAnimFx,self.animFX_4)
	table.insert(self.PromoteAnimFx,self.animFX_5)
	table.insert(self.PromoteAnimFx,self.animFX_6)
	table.insert(self.PromoteAnimFx,self.animFX_7)
	table.insert(self.PromoteAnimFx,self.animFX_8)
	table.insert(self.PromoteAnimFx,self.animFX_9)
	table.insert(self.PromoteAnimFx,self.animFX_10)
	table.insert(self.PromoteAnimFx,self.animFX_11)
end

function PromotePanelCtrl:Start()
	-- body
	for i,v in ipairs(self.PromoteAnimFx) do
    	local btn = self.PromoteAnimFx[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    	for k = 0,btn.Length - 1 do
      		self.PromoteAnimFx[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
    	end
  	end

  	--self.this:StartCoroutine(NTGLuaCoroutine.New(self, PromotePanelCtrl.AnimationIsEnd))
end

function PromotePanelCtrl:LevelShow(levelStr)
	-- body
	self.levelPool:FindChild("level"..string.sub(levelStr,1,1)).transform.parent=self.levelGroup
	if(string.len(levelStr)>1)
	then
		self.levelPool:FindChild("level"..string.sub(levelStr,2,2)).transform.parent=self.levelGroup
	end
end
function PromotePanelCtrl:StaticLevelShow(SlevelStr)
	-- body
	self.levelGroup:FindChild("level"..string.sub(SlevelStr,1,1)).transform.parent=self.staticLevelGroup
	if(string.len(SlevelStr)>1)
	then
		self.levelGroup:FindChild("level"..string.sub(SlevelStr,2,2)).transform.parent=self.staticLevelGroup
	end
end
function PromotePanelCtrl:PromoteInfoInit(nowLevel,skillID,skillName)
	-- body
	lastLevelStr = tostring(nowLevel-1)
	self:lastLevelShow(lastLevelStr)

	nowLevelStr  = tostring(nowLevel)
	self:nowLevelShow(nowLevelStr)
	self:LevelShow(nowLevelStr)

	self:SkillIconShow(skillID,skillName)

	self.this:StartCoroutine(NTGLuaCoroutine.New(self, PromotePanelCtrl.AnimationIsEnd))
	--self.lastPool:FindChild("LNum".."3").transform.parent=self.lastGroup;
	--self.lastPool:FindChild("LNum".."5").transform.parent=self.lastGroup;
end

function PromotePanelCtrl:SkillIconShow(IconId,IconName)
	-- body
	self.skillIcon.sprite=NTGResourceController.Instance:LoadAsset("playerskillicon",IconId,"UnityEngine.Sprite")
	self.skillText.text=IconName
end

function PromotePanelCtrl:lastLevelShow(lStr)
	-- body
	self.lastPool:FindChild("LNum"..string.sub(lStr,1,1)).transform.parent=self.lastGroup
	if(string.len(lStr)>1)
	then
		self.lastPool:FindChild("LNum"..string.sub(lStr,2,2)).transform.parent=self.lastGroup
	end
end

function PromotePanelCtrl:nowLevelShow(nStr)
	-- body
	self.nowPool:FindChild("NNum"..string.sub(nStr,1,1)).transform.parent=self.nowGroup
	if(string.len(nStr)>1)
	then
		self.nowPool:FindChild("NNum"..string.sub(nStr,2,2)).transform.parent=self.nowGroup
	end
end

function PromotePanelCtrl:AnimationIsEnd()
	-- body
	self.PromoteAnim.gameObject:SetActive(true)
	local listener
	listener = NTGEventTriggerProxy.Get(self.backGround.gameObject)
	listener.onPointerClick = listener.onPointerClick + DelegateFactory.NTGEventTriggerProxy_PointerEventDelegate_Self(self,self.OnScreen)
	coroutine.yield(WaitForSeconds.New(2.50))
	self.isPlayed=true
	self:PromoteTipPanelShow()
end

function PromotePanelCtrl:OnScreen()
	-- body
	if(self.isPlayed)
	then
		self:DestroyNow()
	else 
		self.isPlayed=true
		self.PromoteAnim.gameObject:SetActive(false)
		self:StaticLevelShow(nowLevelStr)
		self.staticEA.gameObject:SetActive(true)
		self:PromoteTipPanelShow()
	end
end

function PromotePanelCtrl:DestroyNow()
	-- body
	GameObject.DestroyImmediate(GameManager.PanelRoot:FindChild("PromotePanel").gameObject,true)
end

function PromotePanelCtrl:PromoteTipPanelShow()
	-- body
	self.promoteTipPanel.gameObject:SetActive(true)
end
function PromotePanelCtrl:OnDestroy()
	-- body
	self.this = nil
	self = nil
end
