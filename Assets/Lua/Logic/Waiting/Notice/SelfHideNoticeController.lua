require "System.Global"
require "Logic.UTGData.UTGData"

class("SelfHideNoticeController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

function SelfHideNoticeController:Awake(this)
  self.this = this
  
  self.noticeFrame = self.this.transforms[0]
  self.noticeText = self.noticeFrame:Find("NoticeInfo-label")
  
end

function SelfHideNoticeController:Start()
end

function SelfHideNoticeController:InitInfo(text,text2)
  --初始化
  self.noticeText:GetComponent(Text).text = ""
  self.noticeFrame:GetComponent(Image).color = Color.New(self.noticeFrame:GetComponent(Image).color.r,self.noticeFrame:GetComponent(Image).color.g,self.noticeFrame:GetComponent(Image).color.b,1)
  --self.noticeText:GetComponent(Text).color = Color.New(self.noticeText:GetComponent(Text).color.r,self.noticeText:GetComponent(Text).color.g,self.noticeText:GetComponent(Text).color.b,1)
  
  --实现

  self.noticeText:GetComponent(Text).text = text
  if self.cor~=nil then 
    coroutine.stop(self.cor)
  end
  self.cor = coroutine.start(SelfHideNoticeController.Hide,self)
end

function SelfHideNoticeController:Hide()
  local frameColor = self.noticeFrame:GetComponent(Image).color
  --local labelColor = self.noticeText:GetComponent(Text).color
  local alpha = 1
  while true do
    --labelColor = Color.New(labelColor.r,labelColor.g,labelColor.b,alpha)
    alpha = alpha + 1
    coroutine.wait(1)
    if alpha == 3 then
      SelfHideNoticeAPI.Instance:DestroySelf()
    end
  end
end

function SelfHideNoticeController:OnDestroy()
  coroutine.stop(self.cor)
  self.this = nil
  self = nil
end


