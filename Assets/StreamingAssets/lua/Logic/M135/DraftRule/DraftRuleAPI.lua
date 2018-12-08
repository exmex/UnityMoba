--author zx
class("DraftRuleAPI")

function DraftRuleAPI:Awake(this)
  self.this = this

  local listener = {}
  --添加事件
  local butClose = NTGEventTriggerProxy.Get(this.transforms[0].gameObject)
  butClose.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(DraftRuleAPI.ClosePanel,self)

  self.but_left = this.transforms[1]
  self.but_right = this.transforms[2]

  listener = NTGEventTriggerProxy.Get(self.but_left.gameObject)--左
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickLeft,self)
  listener = NTGEventTriggerProxy.Get(self.but_right.gameObject)--右
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickRight,self)

  self.grid_main = this.transform:FindChild("Grid_Main")
  self.grid_dian = this.transform:FindChild("Grid_Dian")

  self.indexMax = 2
end

function DraftRuleAPI:Start()
  self:Init()
end

--初始化
function DraftRuleAPI:Init()
  self.index = 0
  self:Show(self.index)
end

function DraftRuleAPI:Show(index)
  if index == 0 then 
    self.but_left.gameObject:SetActive(false)
    self.but_right.gameObject:SetActive(true)
  elseif index == self.indexMax then 
    self.but_left.gameObject:SetActive(true)
    self.but_right.gameObject:SetActive(false)
  end

  for i=1,self.grid_main.childCount do
    self.grid_main:GetChild(i-1).gameObject:SetActive(false)
  end
  self.grid_main:GetChild(index).gameObject:SetActive(true)

  for i=1,self.grid_dian.childCount do
    self.grid_dian:GetChild(i-1):FindChild("Dian").gameObject:SetActive(false)
  end
  self.grid_dian:GetChild(index):FindChild("Dian").gameObject:SetActive(true)

end

function DraftRuleAPI:ClickLeft()
  self.index = self.index - 1
  self:Show(self.index)
end
function DraftRuleAPI:ClickRight()
  self.index = self.index + 1
  self:Show(self.index)
end

--关闭面板
function DraftRuleAPI:ClosePanel()
  GameObject.Destroy(self.this.gameObject)
end

function DraftRuleAPI:OnDestroy()
  self.this = nil
  self = nil
end