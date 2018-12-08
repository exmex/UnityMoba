--author zx
class("PageTextAPI")

function PageTextAPI:Awake(this)
  PageTextAPI.instance = self
  self.this = this
  self.txttitle = this.transforms[0]:GetComponent("UnityEngine.UI.Text")
  self.txtcontent = this.transforms[1]:GetComponent("UnityEngine.UI.Text")
  --添加事件
  local butClose = NTGEventTriggerProxy.Get(this.transforms[2].gameObject)
  butClose.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PageTextAPI.ClosePanel,self)

  --self:Init("",self.txt)
  end

--初始化 param：标题 内容
function PageTextAPI:Init(title,content)
  self.data = data
  self.txttitle.text = tostring(title)
  self.txtcontent.text = tostring(content)
end

--关闭面板
function PageTextAPI:ClosePanel()
  GameObject.Destroy(self.this.gameObject)
end

function PageTextAPI:OnDestroy()
  self.this = nil
  self = nil
end