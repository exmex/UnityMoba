--author zx
require "System.Global"
--require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleResult27API")
local json = require "cjson"

function BattleResult27API:Awake(this)
  self.this = this
  BattleResult27API.Instance = self
  self.textTran = this.transforms[0]

  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.textTran.gameObject)--关闭面板
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult27API.ClickClosePanel,self)

  self.loadLogOver = false
  self.loadPanelOver = false
  self.isWin = false
  self.BattleLogId = ""

end
function BattleResult27API:SetFxOk(model)
  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
  end
end

function BattleResult27API:Start()
  self:LoadPanel()
end


--战斗结果
function BattleResult27API:SetBattleResult(isWin)
  self.isWin = tonumber(isWin)
  if self.isWin ==1 then
    coroutine.start(BattleResult27API.PlayMov,self,"BattleResult27Win")
  else
    coroutine.start(BattleResult27API.PlayMov,self,"BattleResult27Lose")
  end
  
end

function BattleResult27API:PlayMov(name)
  self.assetbundleName = name
  local chat = GameManager.CreatePanelAsync(name)
  while chat.Done == false do
    coroutine.step() 
  end
  local panel = chat.Panel
  self.panelFx = panel

  coroutine.wait(0.5) 
  panel:FindChild("fx").gameObject:SetActive(true)
  self:SetFxOk(panel:FindChild("fx"))
  coroutine.wait(1) 
  while self.loadLogOver == false or self.loadPanelOver == false do
    coroutine.wait(0.05) 
  end
  self.textTran.gameObject:SetActive(true)
end

function BattleResult27API:SetBattleLogId(logId)
  self.BattleLogId = tonumber(logId) 
  print(" BattleLogId == "..self.BattleLogId)
  self:RequestBattleLog(self.BattleLogId)

end

--从服务器获取数据
function BattleResult27API:RequestBattleLog(logId)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestBattleLog"),
                                JProperty.New("BattleLogId",tonumber(logId)))
  request.Handler = TGNetService.NetEventHanlderSelf(BattleResult27API.RequestBattleLogHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end

function BattleResult27API:RequestBattleLogHandler(e)
  if e.Type =="RequestBattleLog" then
    print("get battle log succeed~~~~")
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local log = json.decode(e.Content:get_Item("Log"):ToString())
      if log == nil then 
        Debugger.LogError("battle log == nil") 
      else
        self.battleLog = log
        self.loadLogOver = true
      end
    else
      Debugger.LogError("result == "..result)
    end
    return true
  end
  return false
end

--加载界面
function BattleResult27API:LoadPanel()
  coroutine.start(BattleResult27API.LoadPanelMov,self)
end

function BattleResult27API:LoadPanelMov()
  local result = GameManager.CreatePanelAsync("BattleResult28")
  while result.Done~= true do
    coroutine.step() 
  end
  self.loadPanelOver = true
end

--关闭面板
function BattleResult27API:ClickClosePanel()
  if self.loadLogOver and self.loadPanelOver then
    BattleResult28API.Instance:Init(self.battleLog,self.isWin)
    Object.Destroy(self.this.gameObject)
    Object.Destroy(self.panelFx.gameObject)
  else return end

end


function BattleResult27API:OnDestroy()
  NTGResourceController.Instance:UnloadAssetBundle("BattleResult27", true,false)
  NTGResourceController.Instance:UnloadAssetBundle(self.assetbundleName, true,false)
  self.this = nil
  self = nil
  BattleResult27API.Instance = nil
end