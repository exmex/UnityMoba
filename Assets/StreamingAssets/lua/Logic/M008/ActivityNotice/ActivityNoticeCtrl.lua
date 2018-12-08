require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("ActivityNoticeCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

local Data = UTGData.Instance()


function ActivityNoticeCtrl:Awake(this) 
  self.this = this
  self.topBtnPart = this.transforms[0]
  self.uiPart = this.transforms[1]
  self.btnClose = this.transforms[2]
  self.redNotice = this.transforms[3]
  self.redActi = this.transforms[4]
end

function ActivityNoticeCtrl:Start()
  self:btnInit()
  self:onClickTop("ActivityPart")
  self:redNoticeUpdate()
end

function ActivityNoticeCtrl:redNoticeUpdate(args)
  local isRead = ActivityNoticeApi.Instance:isAllNoticeHaveRead()
  self.redNotice.gameObject:SetActive(not isRead)
end

function ActivityNoticeCtrl:OnDestroy()
  self.this = nil
  
  self = nil
end

function ActivityNoticeCtrl:btnInit(args)
  --顶部选择
  local listener = {}
  for i=1,self.topBtnPart.childCount do
    listener = self.topBtnPart:GetChild(i-1).gameObject
    UITools.GetLuaScript(listener,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.onClickTop,listener.name)
  end

  listener = NTGEventTriggerProxy.Get(self.btnClose.gameObject)
  local callBack = function (self,e)
    Object.Destroy(self.this.transform.parent.gameObject)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end

function ActivityNoticeCtrl:onClickTop(name)
--  if ( name == "ActivityPart") then
--    GameManager.CreatePanel("SelfHideNotice")
--    if SelfHideNoticeAPI ~= nil then
--      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
--    end
--    return
--  end
  self:topUiSet(name)

  self:uiPartActive(name)
end

function ActivityNoticeCtrl:topUiSet(name)
  for i = 0,self.topBtnPart.childCount-1,1 do
    local obj = self.topBtnPart:GetChild(i);
    if obj.name == name then
      obj:FindChild("White").gameObject:SetActive(true)
    else
      obj:FindChild("White").gameObject:SetActive(false)
    end
  end
end

function ActivityNoticeCtrl:uiPartActive(name)
  for i = 0,self.uiPart.childCount-1,1 do
    local obj = self.uiPart:GetChild(i);
    if obj.name == name then
      obj.gameObject:SetActive(true)
    else
      obj.gameObject:SetActive(false)
    end
  end
end

function ActivityNoticeCtrl:redActiUpdate(num)
   if (num == 0) then
     self.redActi.gameObject:SetActive(false)
   elseif (num > 0) then
     self.redActi.gameObject:SetActive(true)
     local lab = self.redActi:FindChild("RedCnt")
     lab:GetComponent(Text).text = num
   end
end

  