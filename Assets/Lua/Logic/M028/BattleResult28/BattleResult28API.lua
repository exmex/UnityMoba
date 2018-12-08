--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleResult28API")
--local json = require "cjson"

function BattleResult28API:Awake(this)
  self.this = this
  BattleResult28API.Instance = self
  self.bgPanel = this.transforms[0]

  self.data_28 = {}
  self.data_29 = {}

end

function BattleResult28API:Start()
  self.ctrl_28 = self.this.transform:FindChild("28"):GetComponent("NTGLuaScript")

end


--初始化
function BattleResult28API:Init(battleResultData,isWin)
  self.IsWin = tonumber(isWin)
  self:ClearUpData(battleResultData)
  self.bgPanel.gameObject:SetActive(true)

  coroutine.start(BattleResult28API.ClearBattleSceneMov,self)

end


--清理战场
function BattleResult28API:ClearBattleSceneMov( )

  for i=UnityEngine.SceneManagement.SceneManager.sceneCount-1,0,-1 do
    local s = UnityEngine.SceneManagement.SceneManager.GetSceneAt(i)
    if s.name ~= "NTGGame" then
      UnityEngine.SceneManagement.SceneManager.UnloadScene(s.name)
    end
  end 

  NTGResourceController.Instance:BattlePostClearAssetBundle()

  local index = tonumber(self.this.transform:GetSiblingIndex())
  for i=index-1,0,-1 do   
      local uipanel = GameManager.PanelRoot.transform:GetChild(i)
      local uipanel_abname = string.sub(uipanel.name,0,string.len(uipanel.name)-string.len("Panel"))
      Object.Destroy(uipanel.gameObject)
      NTGResourceController.Instance:UnloadAssetBundle(uipanel_abname, true, false)
  end
  
  coroutine.step()
  self.ctrl_28.self:Init(self.data_28)

end

--数据整理
function BattleResult28API:ClearUpData(data)
  local utgData = UTGData.Instance()
  if data.BMainType == 5 then --排位赛 battlelog
    utgData.BattleLogs = utgData.BattleLogs or {}
    table.insert(utgData.BattleLogs,1,data) 
  end
  local myPlayerId = tonumber(utgData.PlayerData.Id) --自己的玩家id
  --界面28所需要数据
  local data_28 = self.data_28
  data_28.isWin = self.IsWin
  data_28.mianType = data.BMainType
  local leveldata = utgData.PVPLevelsData[tostring(data.LevelId)]
  data_28.mapName = leveldata.Name
  data_28.modeName = leveldata.ModeName
  --玩家奖励
  data_28.playerName = utgData.PlayerData.Name
  data_28.playerIcon = utgData.PlayerData.Avatar
  data_28.player_nexLv = utgData.PlayerData.Level
  data_28.player_nexExp = utgData.PlayerData.Exp
  data_28.player_addExp = data.Reward.RExp
  data_28.player_firstAdd = data.Reward.RFirstWinExp
  --金币奖励
  data_28.coin_add = data.Reward.RCoin
  data_28.coin_first = data.Reward.RFirstWinCoin
  --角色熟练度
  data_28.roleId = data.Reward.RRoleId
  data_28.role_addExp = data.Reward.RProficiency 
  --经验加成
  data_28.expAdd = data.Reward.RExpAddRate
  --金币加成
  data_28.coinAdd = data.Reward.RCoinAddRate

  --界面29所需要数据
  local data_29 = self.data_29
  data_29.isWin = self.IsWin
  data_29.startTime = data.Start
  data_29.duration = data.Duration

  local function TeamDataClear(data_use,data_source)--待组装数据，原数据
    data_source = data_source or {}
    local allNum = 0
    local heroNum = 0
    local painNum = 0
    for i=1,#data_source do
      local data = data_source[i]
      local temp = {}
      temp.IsAi = data.IsAi
      temp.PlayerId = data.PlayerId
      temp.IsMe = false
      if myPlayerId ==tonumber(data.PlayerId) then temp.IsMe = true end
      temp.RoleLv = data.Level
      --Debugger.LogError("(data.RoleId) == "..(data.RoleId))
      local roledata = utgData.RolesData[tostring(data.RoleId)]
      temp.RoleName = roledata.Name
      temp.RoleIcon = utgData.SkinsData[tostring(roledata.Skin)].Icon
      temp.PlayerName = data.PlayerName
      --[[
      if temp.IsAi then 
        temp.PlayerName = "电脑"
      else
        temp.PlayerName = data.PlayerName
      end
      ]]
      temp.EquipIcon ={}
      for k,v in pairs(data.BattleEquips) do
        local equipdata = utgData.EquipsData[tostring(v)]
        local temp_equipIcon = ""
        if equipdata~=nil then temp_equipIcon = equipdata.Icon end
        table.insert(temp.EquipIcon,temp_equipIcon)
      end
      for i=1,6 do
        if temp.EquipIcon[i] == nil then temp.EquipIcon[i] = "" end
      end
      temp.KillAmount = data.RoleKill
      temp.DeadAmount = data.Death
      temp.SecAmount = data.Assistance
      temp.CoinAmount = math.floor(data.Coin)
      temp.PainNum = math.floor(data.SufferDamage)
      painNum = painNum + temp.PainNum
      temp.HeroNum = math.floor(data.RoleDamage)
      heroNum = heroNum + temp.HeroNum
      temp.AllNum = math.floor(data.RoleDamage+data.MobDamage+data.NeutDamage+data.BuildingDamage)
      --Debugger.LogError("temp.AllNum == "..temp.AllNum)
      allNum = allNum+temp.AllNum
      temp.IsMVP = false
      if data.TMvp then temp.IsMVP = true end
      temp.Title = {}
      for i=1,12 do
        temp.Title[i] ={}
      end
      temp.Title[1].TLegendary = data.TLegendary
      temp.Title[2].TWinnerMvp = data.TWinnerMvp
      temp.Title[3].TDPS = data.TDPS
      temp.Title[4].TAssist = data.TAssist
      temp.Title[5].TKiller = data.TKiller
      temp.Title[6].TTank = data.TTank
      temp.Title[7].TRusher = data.TRusher
      temp.Title[8].TRich = data.TRich
      temp.Title[9].TTripleKill = data.TTripleKill
      temp.Title[10].TQuadraKill = data.TQuadraKill
      temp.Title[11].TPentaKill = data.TPentaKill
      temp.Title[12].TDeserter = data.TDeserter
      table.insert(data_use,temp)
    end
    for k,v in pairs(data_use) do
      v.AllPer = v.AllNum/allNum
      v.HeroPer = v.HeroNum/heroNum
      v.PainPer = v.PainNum/painNum
    end
  end
  data_29.teamA_score = data.TAScore
  data_29.teamB_score = data.TBScore
  data_29.teamA = {}
  data_29.teamB = {}
  TeamDataClear(data_29.teamA,data.TeamA)
  TeamDataClear(data_29.teamB,data.TeamB)


end



--初始化面板29
function BattleResult28API:InitPanel29()
  GameManager.CreatePanel("BattleResult29")
  BattleResult29API.Instance:Init(self.data_29)
  Object.Destroy(self.this.gameObject)
end



function BattleResult28API:OnDestroy()
  if self.coroutine_initchat ~=nil then coroutine.stop(self.coroutine_initchat) end 
  self.this = nil
  self = nil
  BattleResult28API.Instance = nil
end