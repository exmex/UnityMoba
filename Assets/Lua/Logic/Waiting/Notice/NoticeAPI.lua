require "System.Global"

class("NoticeAPI")

function NoticeAPI:Awake(this)
  self.this = this
  self.needConfirmNoticePanel = self.this.transforms[0]:GetComponent("NTGLuaScript")
end

function NoticeAPI:Start()
end

--弹出框标题/第一条内容/是否显示第二条内容/true则设置第二条内容/按钮类型：0；1；2；3；4   对应：没有按钮；一个按钮；两个普通按钮；一长一短（黄）；一长一短（蓝）
--showImage:是否显示图片，true/false
function NoticeAPI:InitNoticeForNeedConfirmNotice(title,info1,showInfo2,info2,buttonType,showImage)
  self.needConfirmNoticePanel.self:InitNotice(title,info1,showInfo2,info2,buttonType,showImage)
end

function NoticeAPI:ShowNoticeInfo2ForNeedConfirmNotice(text)
  self.needConfirmNoticePanel.self:ShowNoticeInfo2(text)
end

function NoticeAPI:ImagePanelControl(list)    --1：英雄  2：皮肤  3：芯片   4：背包item
  -- body
  self.needConfirmNoticePanel.self:ImagePanelControl(list)
end

--1个按钮时的按钮事件
function NoticeAPI:OneButtonEvent(buttonName,fun,funself)
  self.needConfirmNoticePanel.self:ButtonEventType1(buttonName,fun,funself)
end

--2个按钮时的按钮事件
function NoticeAPI:TwoButtonEvent(buttonNameA,funcA,funASelf,buttonNameB,funcB,funBSelf)
  self.needConfirmNoticePanel.self:ButtonEventType2(buttonNameA,funcA,funASelf,buttonNameB,funcB,funBSelf)
end

function NoticeAPI:ButtonEventType3(payType,price,buttonNameA,funcA,funASelf,buttonNameB,funcB,funBSelf)    --购买需要的货币类型：1金币2宝石3点券 
                                                                                                            --售价（下同）
  -- body
  self.needConfirmNoticePanel.self:ButtonEventType3(payType,price,buttonNameA,funcA,funASelf,buttonNameB,funcB,funBSelf)
end

function NoticeAPI:ButtonEventType4(payType,price,buttonNameA,funcA,funASelf,buttonNameB,funcB,funBSelf)
  -- body
  self.needConfirmNoticePanel.self:ButtonEventType4(payType,price,buttonNameA,funcA,funASelf,buttonNameB,funcB,funBSelf)
end

function NoticeAPI:HideCloseButton(isHide)    --是否隐藏右上角关闭按钮 true：隐藏   false：显示
  -- body
  self.needConfirmNoticePanel.self:HideCloseButton(isHide)
end

--邀请人姓名 邀请人头像 邀请人头像框  邀请人段位   邀请信息
function NoticeAPI:RankInvitation(invitorName,invitorIcon,invitorFrame,invitorGrade,invitorDes)
  -- body
  self.needConfirmNoticePanel.self:RankInvitation(invitorName,invitorIcon,invitorFrame,invitorGrade,invitorDes)
end

function NoticeAPI:FxControl(isShow)
  -- body
  self.needConfirmNoticePanel.self:FxControl(isShow)
end

function NoticeAPI:SetTextToCenter()
  -- body
  self.needConfirmNoticePanel.self:SetTextToCenter()
end

function NoticeAPI:DoShowByStep(count)
  -- body
  self.needConfirmNoticePanel.self:DoShowByStep(count)
end

function NoticeAPI:DestroySelf()
  
  table.remove(UTGDataOperator.Instance.Dialog,#UTGDataOperator.Instance.Dialog)
  GameObject.Destroy(self.this.gameObject)
end

function NoticeAPI:DestroySelfWithNotice()
  -- body
  GameManager.CreatePanel("SelfHideNotice")
  if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在建设中")
  end
  table.remove(UTGDataOperator.Instance.Dialog,#UTGDataOperator.Instance.Dialog)
  Object.Destroy(self.this.gameObject)  
end


function NoticeAPI:OnDestroy()
  self.this = nil
  self = nil
  NoticeAPI.Instance = nil
end



  
