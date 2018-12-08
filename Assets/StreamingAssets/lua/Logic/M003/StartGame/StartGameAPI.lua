require "System.Global"
class("StartGameAPI")

function StartGameAPI:Awake(this)
  self.this = this
  StartGameAPI.Instance = self
  self.ctrl = self.this.gameObject:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[0]
end

function StartGameAPI:Start()
  
end

--传递参数
function StartGameAPI:SetParam(accountid,sessionkey)
  --print(verson)
  self.ctrl.self.AccountId = accountid
  self.ctrl.self.SessionKey = sessionkey
end

--下载数据 and 初始化
function StartGameAPI:DownLoadData( )
  return self.ctrl.self:DownLoadData()
end

function StartGameAPI:OnDestroy()
  self.this = nil
  self = nil
  StartGameAPI.Instance = nil
end