--author zx
require "System.Global"
--require "Logic.UTGData.UTGData"
require "Logic.UICommon.Static.UITools"
class("PVPBattleLoadingAPI_1")
--local json = require "cjson"

function PVPBattleLoadingAPI_1:Awake(this)
  self.this = this
  PVPBattleLoadingAPI_1.Instance = self
  --local bgPanel = UTGDataOperator.Instance:SetBgToPosition(self.this.transform)
  --bgPanel:SetAsFirstSibling()
  self.myProgress = 0
end

function PVPBattleLoadingAPI_1:Start()
  
  --监听进度
  self.Delegate_UpdateBattleProgress = TGNetService.NetEventHanlderSelf(PVPBattleLoadingAPI_1.UpdatePlayerProgress, self)
  TGNetService.GetInstance():AddEventHandler("NotifyPreBattleProgress",self.Delegate_UpdateBattleProgress ,1)

  self.ctrl = self.this.transform:FindChild("root"):GetComponent("NTGLuaScript")

  self.cor= coroutine.start(self.NetLoadingProgressMov,self) 

end

function PVPBattleLoadingAPI_1:SetParamBy18(teama,teamb)
  self.TeamAData = UITools.CopyTab(teama)
  self.TeamBData = UITools.CopyTab(teamb)
end


function PVPBattleLoadingAPI_1:SetLoadProgress(progress)
  --Debugger.LogError("playerid= "..playerid.." progress= "..progress)
  self.myProgress = progress
end

function PVPBattleLoadingAPI_1:NetLoadingProgressMov()
  local progress = 0
  while true do 
    if progress ~= self.myProgress then 
      progress = self.myProgress
      self:NetLoadingProgress(progress)
    end
    coroutine.wait(0.2)
  end
  self.cor = nil
end

--网络 发送自己的加载进度
function PVPBattleLoadingAPI_1:NetLoadingProgress(progress)
    local request = NetRequest.New()
    request.Content = JObject.New(JProperty.New("Type","RequestReportBPreProgress"),JProperty.New("Progress",tonumber(progress)))
    TGNetService.GetInstance():SendRequest(request)
end

function PVPBattleLoadingAPI_1:UpdatePlayerProgress(e)
  if e.Type == "NotifyPreBattleProgress" then
    local playerId  = tostring(e.Content:get_Item("PlayerId"):ToString())
    local progress  = tonumber(e.Content:get_Item("Progress"):ToString())
    self.ctrl.self:UpdatePlayerProgress(playerId,progress)
    return true
  end
  return false
end



function PVPBattleLoadingAPI_1:DestroySelf()
  Object.DestroyImmediate(self.this.gameObject,true)
end

function PVPBattleLoadingAPI_1:OnDestroy()
  if self.cor ~=nil then coroutine.stop(self.cor) end
  TGNetService.GetInstance():RemoveEventHander("NotifyPreBattleProgress",self.Delegate_UpdateBattleProgress)
  self.this = nil
  self = nil
  PVPBattleLoadingAPI_1.Instance = nil
end