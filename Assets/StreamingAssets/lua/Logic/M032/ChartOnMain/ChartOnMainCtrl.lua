--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("ChartOnMainCtrl")


function ChartOnMainCtrl:Awake(this)
  self.this = this
  self.ani = this.transform.parent:GetComponent("Animator")
  self.ani.enabled = false
  local listener = {}
  --Main 
  local main = this.transforms[0]
  self.grid = main:FindChild("ScrollView/Grid")
  self.scroll = main:FindChild("ScrollView")
  self.temp_playericon = main:FindChild("Temp_PlayerIcon")
  self.temp_playericon.gameObject:SetActive(false)
  listener = NTGEventTriggerProxy.Get(main:FindChild("Click").gameObject) --打开排行榜
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChartOnMainCtrl.ClickOpenChartPanel,self)

  self.this.transform.localPosition = Vector3.New(0,1000,0)

end

function ChartOnMainCtrl:Start()
  ChartAPI.Instance:GetRankData(1,false,self,ChartOnMainCtrl.Init)
end

function ChartOnMainCtrl:SetRankData(isfriend)
  ChartAPI.Instance:GetRankData(1,isfriend,self,ChartOnMainCtrl.Init)
end

--初始化
function ChartOnMainCtrl:Init(data)
  self.this.transform.localPosition = Vector3.zero
  self.ani.enabled = true
  self.ani:Play("show")
  self.scroll.transform:GetComponent("UnityEngine.UI.ScrollRect").verticalNormalizedPosition = 1
  self:FillList(data)
end

--生成列表
function ChartOnMainCtrl:FillList(listdata)
  if self.coroutine_filllist ~= nil then 
    coroutine.stop(self.coroutine_filllist)
  end
  self.coroutine_filllist = coroutine.start(self.FillListMov,self,listdata)

end
--生成列表
function ChartOnMainCtrl:FillListMov(listdata)
  self.myPlayerIcon = nil
  coroutine.step()
  local count = #listdata
  for i=1,count do
    local tempo = self.grid:FindChild(tostring(i))
    if tempo == nil then
      tempo = GameObject.Instantiate(self.temp_playericon)
      tempo.gameObject:SetActive(true)
      tempo.transform:SetParent(self.grid)
      tempo.transform.localPosition = Vector3.zero
      tempo.transform.localRotation = Quaternion.identity
      tempo.transform.localScale = Vector3.one
    end
    coroutine.step()
    tempo.gameObject:SetActive(true)
    local data = listdata[i]
    tempo.name = tostring(i)
    tempo:FindChild("Bg"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("frameicon",tostring(data.PlayerFrame),"UnityEngine.Sprite")

    tempo:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(data.PlayerIcon),"UnityEngine.Sprite")
    
    --排名
    for j=(tempo:FindChild("Num").childCount-1),0,-1 do
      tempo:FindChild("Num"):GetChild(j).gameObject:SetActive(false)
    end
    if i ==1 then 
      tempo:FindChild("Num/1").gameObject:SetActive(true) 
    elseif i==2 then
      tempo:FindChild("Num/2").gameObject:SetActive(true)  
    elseif i==3 then
      tempo:FindChild("Num/3").gameObject:SetActive(true) 
    end
    UITools.GetLuaScript(tempo:FindChild("Icon").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickOpenChartPanel)

    if data.PlayerId == ChartAPI.Instance.myPlayerId then self.myPlayerIcon = tempo end
  end

  --隐藏剩余的item
  local gridCount = (self.grid.childCount-1)
  for j=gridCount,count,-1 do
    self.grid:GetChild(j).gameObject:SetActive(false)
  end
  self.coroutine_filllist = nil
end

--更换头像框后，要刷新UI
function ChartOnMainCtrl:UpdateSelfPlayerIcon(playerFrameIcon)
  if self.myPlayerIcon == nil then return end
  self.myPlayerIcon:FindChild("Bg"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("frameicon",tostring(playerFrameIcon),"UnityEngine.Sprite")
end

--返回大厅
function ChartOnMainCtrl:ClickOpenChartPanel()
  self.ani:Play("hide")
  ChartAPI.Instance:InitChartPanel()
    
end

function ChartOnMainCtrl:OnDestroy()
  if self.coroutine_filllist~=nil then  coroutine.stop(self.coroutine_filllist) end
  self.this = nil
  self = nil
end