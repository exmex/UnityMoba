require "Logic.UTGData.UTGData"
class("EntPanelCtrl")

function EntPanelCtrl:Awake(this) 
  self.this = this
  self.btnClone = self.this.transforms[0]
  self.btnMore = self.this.transforms[1]

  self.ani=self.this.transform:GetComponent("Animator")
end

function EntPanelCtrl:Start()

end

function EntPanelCtrl:Init()


  self.ani.enabled = true
  self.ani:Play("M014-Ent")
    self.this.transform.localPosition = Vector3.zero
    
  UITools.GetLuaScript(self.btnMore.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtnMoreClick) 

  self.entCloneData = {}
  for k,v in pairs(UTGData.Instance().EntModesData) do
    if v.Category == 1 then self.entCloneData = v end
  end

  self:InitClone()
end

function EntPanelCtrl:InitClone()
  UITools.GetLuaScript(self.btnClone.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtnCloneClick) 
  self.btnClone:FindChild("Text"):GetComponent("Text").text = self.entCloneData.OpenDesc
  local results = {}
  for k,v in pairs(self.entCloneData.StartEnd) do 
    local result = UTGData.Instance():IsActivityOpen(v[1],v[2])
    table.insert(results,result)
  end
  local isOpen = false
  for k,v in pairs(results) do
    if v.IsOpen then isOpen = true break end
  end
  if isOpen~=true then 
    self.btnClone:FindChild("Lock").gameObject:SetActive(true)
  else
    self.btnClone:FindChild("Open").gameObject:SetActive(true)
  end
  self.isCloneOpen = isOpen
end

--创建party
function EntPanelCtrl:CreateParty(playerCount, subTypeCode)
  local mainType = 2 --娱乐模式
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("NewBattle15")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
            NewBattle15API.Instance:CreateParty("", playerCount, subTypeCode,mainType)     
          end
          self.btnClone:GetComponent("Image").raycastTarget=true
        end
  coroutine.start( CreatePanelAsync,self)
end

function EntPanelCtrl:OnBtnCloneClick()
  if self.isCloneOpen then 
    self.btnClone:GetComponent("Image").raycastTarget=false
    self:CreateParty(5,80)
  else
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("未到活动开启时间")
  end
end

function EntPanelCtrl:OnBtnMoreClick()
  GameManager.CreatePanel("SelfHideNotice")
  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("更多精彩赛事，敬请期待")
end

function EntPanelCtrl:OnDestroy()
  self.this = nil
  self = nil
end
  