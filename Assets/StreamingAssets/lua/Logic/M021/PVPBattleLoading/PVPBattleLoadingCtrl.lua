--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("PVPBattleLoadingCtrl")
local json = require "cjson"

function PVPBattleLoadingCtrl:Awake(this)
  self.this = this

  self.ownPlayerId = UTGData.Instance().PlayerData.Id
  self.teamAGrid = this.transforms[0]
  self.teamBGrid = this.transforms[1]
  
  self.sceneName = ""
  self.teamAData = {}
  self.teamBData = {}
end

function PVPBattleLoadingCtrl:Start()
   
  self:Init()
end

function PVPBattleLoadingCtrl:Init()
  self.teamAData = PVPBattleLoadingAPI_1.Instance.TeamAData.Members
  self.teamBData = PVPBattleLoadingAPI_1.Instance.TeamBData.Members
  self:FilterTeamData(self.teamAData)
  self:FilterTeamData(self.teamBData)
  self:FillRoleLis(self.teamAGrid,self.teamAData)
  self:FillRoleLis(self.teamBGrid,self.teamBData)  
end

function PVPBattleLoadingCtrl:FilterTeamData(data)
  for i=#data, 1, -1 do 
    if data[i].PlayerId ==0 and data[i].IsAi == false then 
      --Debugger.LogError("ffffffffffffffffff  "..i)
      table.remove(data,i) 
    end 
  end
end


--更新玩家进度
function PVPBattleLoadingCtrl:UpdatePlayerProgress(playerId,progress)

    --Debugger.LogError("playerId "..playerId.."  progress  "..progress)
    --刷新
    for i=1,self.teamAGrid.childCount do
      local temp = self.teamAGrid:GetChild(i-1)
      if temp.name == playerId then
        temp:FindChild("progress"):GetComponent("UnityEngine.UI.Text").text = (progress.."%")
      end
    end
    for i=1,self.teamBGrid.childCount do
      local temp = self.teamBGrid:GetChild(i-1)
      if temp.name == playerId then
        temp:FindChild("progress"):GetComponent("UnityEngine.UI.Text").text = (progress.."%")
      end
    end  
end


--生成列表
function PVPBattleLoadingCtrl:FillRoleLis(grid,data)
  local api = grid:GetComponent("NTGLuaScript").self
  if data==nil then
    api:ResetItemsSimple(0)
    Debugger.LogError("没有玩家数据")
    return
  end
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    tempo.name = tostring(data[i].PlayerId)
    --召唤师技能
    if data[i].IsAi then 
      tempo:FindChild("playerskill").gameObject:SetActive(false)
    else
      tempo:FindChild("playerskill").gameObject:SetActive(true)
      tempo:FindChild("playerskill/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",tostring(data[i].PlayerSkill.Icon),"UnityEngine.Sprite")
    end
    --role图片
    local roleIcon = data[i].Role.Skin.Portrait
    tempo:FindChild("mask/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("portrait",tostring(roleIcon),"UnityEngine.Sprite")
    --玩家名称
    if self.ownPlayerId == data[i].PlayerId then
      self.ownPlayerObj = tempo
      tempo:FindChild("playername_own"):GetComponent("UnityEngine.UI.Text").text = tostring(data[i].PlayerName)
    else 
      tempo:FindChild("playername"):GetComponent("UnityEngine.UI.Text").text = tostring(data[i].PlayerName)
    end
    --if data[i].IsAi then tempo:FindChild("playername"):GetComponent("UnityEngine.UI.Text").text = "电脑" end
    --role 名称
    tempo:FindChild("rolename"):GetComponent("UnityEngine.UI.Text").text = tostring(data[i].Role.Name)
    --role熟练度
    if data[i].IsAi then 
      tempo:FindChild("pro").gameObject:SetActive(false)
    else
      tempo:FindChild("pro").gameObject:SetActive(true)
      local proIcon = data[i].Role.Proficiency.Icon
      tempo:FindChild("pro"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("pvpbattleloading",tostring(proIcon),"UnityEngine.Sprite")
    end 
    --进度
    tempo:FindChild("progress"):GetComponent("UnityEngine.UI.Text").text = data[i].PreProgress.."%"
    end
end

function PVPBattleLoadingCtrl:OnDestroy()
  self.this = nil
  self = nil
end