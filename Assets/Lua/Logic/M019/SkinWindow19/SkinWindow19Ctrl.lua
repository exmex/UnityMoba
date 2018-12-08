require "System.Global"

class("SkinWindow19Ctrl")

local json = require "cjson"

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

function SkinWindow19Ctrl:Awake(this)
  self.this = this
  self.attrItemTemp = this.transforms[0]
  self.price = this.transforms[1]
  self.pricePic = this.transforms[2]
  self.hint = this.transforms[3]
  self.closeBtn = this.transforms[4]

  self.frameTitle = self.this.transform:Find("NameTxt")
  self.buySkinButton = self.this.transform:Find("BuyAndEquipBtn")
  self.model = self.this.transform:Find("SkinShow/Model")

  self.butSendGift = self.this.transform:FindChild("SendGiftBtn")

  local listener = NTGEventTriggerProxy.Get(self.closeBtn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickClosePanel,self)

end

function SkinWindow19Ctrl:Start()
    self:Init(SkinWindow19API.Instance.skinId)
end

function SkinWindow19Ctrl:ClickClosePanel()
  GameObject.Destroy(self.this.transform.parent.gameObject)
end



function SkinWindow19Ctrl:Init(skinId)

  self.skinData = UTGData.Instance().SkinsData[tostring(skinId)]

  self.frameTitle:GetComponent(Text).text = self.skinData.Name
  
  self:SetPrice(skinId)
  --
  self:InitAttrs(skinId)


  self:ShowModle(self.skinData)

  local listener = {}
  if SkinWindow19API.Instance.sendGift == true then 
    self.butSendGift.gameObject:SetActive(true)
    listener = NTGEventTriggerProxy.Get(self.butSendGift.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickSendGift,self)
  end
end  


function  SkinWindow19Ctrl:ClickSendGift()
  GameManager.CreatePanel("GiftSkin")
  GiftSkinAPI.Instance:InitGiftSkin(self.shopData.CommodityId)
  self:ClickClosePanel()
end

function SkinWindow19Ctrl:InitAttrs(skinId)
  local skinAttr = UTGDataOperator.Instance:GetSortedPropertiesByKey("Skin",skinId)
  local go = ""
  for i = 1,#skinAttr do
    go = GameObject.Instantiate(self.attrItemTemp.gameObject)
    go.transform:SetParent(self.this.transform:FindChild("Scroll/Content"))
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    go.transform.gameObject:SetActive(true)
    go.transform:FindChild("Des"):GetComponent(Text).text = skinAttr[i].Des
    go.transform:FindChild("Value"):GetComponent(Text).text ="+"..skinAttr[i].Attr
  end
end

--显示价格
function SkinWindow19Ctrl:SetPrice(skinId)
  local shopData = Data.ShopsData[tostring(skinId)][1]
  local payType = ""
  local price = 0
  if shopData.CoinPrice > 0 then
    payType = "Coin"
    price = shopData.CoinPrice
  elseif shopData.GemPrice > 0 then
    payType = "Gem"
    price = shopData.GemPrice
  elseif shopData.VoucherPrice > 0 then
    payType = "Voucher"
    price = shopData.VoucherPrice
  end

  self.pricePic:GetComponent(Image).sprite = UITools.GetSprite("resourceicon",payType)
  self.price:GetComponent(Text).text = price

  self.shopData = shopData
end


--显示模型
function  SkinWindow19Ctrl:ShowModle(skindata)

  local temp_model = self.this.transforms[5]

  self.model_ab_name = nil
  self.fxShow = nil
  self.fxPlay = nil
  self.modelAnimator = nil
  --创建模型
  self.model_ab_name = "skin"..skindata.Resource
  local temp  = NTGResourceController.Instance:LoadAsset("skin"..skindata.Resource,tostring(""..skindata.Resource.."-Show"))
  if temp ==nil or temp:Equals(nil) then return end
  local model = GameObject.Instantiate(temp)
  model.gameObject:SetActive(true)
  --model.gameObject.layer = LayerMask.NameToLayer("Player")
  --model.name = "model"
  model.transform:SetParent(temp_model)
  model.transform.localPosition = Vector3.zero
  model.transform.localRotation = Quaternion.identity
  model.transform.localScale = Vector3.one
  self.modelAnimator = model:GetComponent("Animator")

  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    --print("btn[k].material.shader.name " .. btn[k].transform.name)
    if k ~= btn.Length-1 and btn[k].transform.name ~= btn[k+1].transform.name then
      for i = 0,btn[k].materials.Length-1 do
        model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].materials[i].shader = UnityEngine.Shader.Find(btn[k].materials[i].shader.name)
      end
    end
  end
  self.modelAnimator:SetTrigger("show")
  --人物展示特效
  if model.transform:FindChild("FX-Show") ~= nil then
    self.fxShow = model.transform:FindChild("FX-Show")
    local fx = self.fxShow:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
    local renderer = self.fxShow:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,renderer.Length - 1 do
      self.fxShow:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(renderer[k].material.shader.name)
    end
    for k = 0,fx.Length - 1 do
        fx[k]:Play()
    end
  end

  if model.transform:FindChild("FX-Play") ~= nil then
      self.fxPlay = model.transform:FindChild("FX-Play")
  end


  --设置滑动
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.this.transforms[6].gameObject)
  listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(self.DragCube,self)
end

function SkinWindow19Ctrl:DragCube()
  self.coroutine_drag = coroutine.start(self.DragMov,self)
end
function SkinWindow19Ctrl:DragMov()
  local model = self.this.transforms[5]
  self.cubespeed = 0.6
  local startpos = Input.mousePosition
  local offet = {}
  local isClick = true
  while Input.GetMouseButton(0) do  
    coroutine.step() 
    offet = (Input.mousePosition-startpos).x
    if math.abs(offet) > 0.1 then isClick = false end
    startpos = Input.mousePosition
    model.localEulerAngles = model.localEulerAngles + Vector3.New(0,-self.cubespeed*offet,0)
    --self.desk.localEulerAngles = self.desk.localEulerAngles + Vector3.New(0,-self.cubespeed*offet,0)
  end
  if isClick then
    --self.ctrl.self:SetModelPlayerAnimator()
  end
  self.coroutine_drag = nil
end

function SkinWindow19Ctrl:OnDestroy()
  if self.coroutine_drag ~= nil then coroutine.stop(self.coroutine_drag) end
  self.this = nil
  self = nil
end