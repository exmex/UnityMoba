--author zx
class("BountyMatchGetRewardAPI")

function BountyMatchGetRewardAPI:Awake(this)
  self.this = this
  BountyMatchGetRewardAPI.Instance = self
  self.main = self.this.transforms[0]
  --self.ctrl = self.this.transforms[0]:GetComponent("NTGLuaScript")
  self:SetFxOk(self.main)
end

function BountyMatchGetRewardAPI:Start()
  
end

function BountyMatchGetRewardAPI:Init(itemId)
  local itemData = UTGData.Instance().ItemsData[tostring(itemId)]
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.main:FindChild("But-Close").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClosePanel,self)
  listener = NTGEventTriggerProxy.Get(self.main:FindChild("But-Yes").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClosePanel,self)
  self.main:FindChild("Bg"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("icon",itemData.Quality)
  self.main:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("itemicon",itemData.Icon)
  self.main:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = itemData.Name
end

function BountyMatchGetRewardAPI:ClosePanel()
  Object.Destroy(self.this.transform.gameObject)
  if CoinMatchAPI~=nil and CoinMatchAPI.Instance~=nil then 
  	CoinMatchAPI.Instance:ClosePanel()
  end
end


function BountyMatchGetRewardAPI:SetFxOk(model)
  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
  end
end

function BountyMatchGetRewardAPI:OnDestroy()
  self.this = nil
  BountyMatchGetRewardAPI.Instance = nil
  self = nil
end