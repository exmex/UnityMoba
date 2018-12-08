require "System.Global"

class("UTGMainPanelAPI")

function UTGMainPanelAPI:Awake(this)
  self.this = this
  UTGMainPanelAPI.Instance = self
  self.mainPanel = self.this.transforms[0]
  
  local luaScriptsArray = {}
  for i = 1, 3 do
    luaScriptsArray[i] = self.mainPanel:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[i - 1]
  end
  
  for i = 1,#luaScriptsArray do
    if luaScriptsArray[i].luaScript == "Logic.UTGMain.UTGMainPanelControl" then
      self.mainPanelControl = luaScriptsArray[i]
    end
  end

  self:SetLoadFx(false)
end

function UTGMainPanelAPI:Start()

end

function UTGMainPanelAPI:ShowSelf()
  self.mainPanelControl.self:InitRank()
  self.mainPanelControl.self:ShowMainPanel()
  self.mainPanelControl.self.playNowButton.localScale = Vector3.New(1,1,1)
  self.mainPanelControl.self.playNowActivityBeginNotice.localScale = Vector3.New(1,1,1)
  self.mainPanelControl.self.playNowActivityBeginNotice.localPosition = Vector3.New(221.2,199.6,0)   -- 重置主界面“活动开启”图片的位置
  --self.mainPanelControl.self:InitSubMenu()
  self.mainPanelControl.self:InitGrowGuideTip()
  self.mainPanelControl.self:InitAchieveRedPoint()
  self.mainPanelControl.self:InitStoreRedPoint()
  self.mainPanelControl.self:InitPlayerSkillRedPoint()
  --UTGDataOperator.Instance:DoClearMemory()
  self.mainPanelControl.self:InitActiRed()
end

function UTGMainPanelAPI:HideSelf()
  self.mainPanelControl.self:HideMainPanel()
end

function UTGMainPanelAPI:UpdateExpBar()
  -- body
  self.mainPanelControl.self:UpdateExpBar()
end


function UTGMainPanelAPI:DestroySelf()
  Object.Destroy(self.this.gameObject)
end

function UTGMainPanelAPI:UpdateResource()
  -- body
  self.mainPanelControl.self:UpdateResource()
end

function UTGMainPanelAPI:ResetPanel()
  -- body
  self:ShowSelf()
end

function UTGMainPanelAPI:AudioControl(volume)
  -- body
  self.mainPanelControl.self:AudioControl(volume)
end

function UTGMainPanelAPI:Init()
  return self.mainPanelControl.self:Init()
end
--播放大喇叭
function UTGMainPanelAPI:BigHornMove(text)
  self.mainPanelControl.self:BigHornMove(text)
end

function UTGMainPanelAPI:UpdatePlayerName()
  -- body
  self.mainPanelControl.self:UpdatePlayerName()
end

--------临时预加载特效
function UTGMainPanelAPI:SetLoadFx(boo)
  self.fx_load = self.fx_load or self.this.transform:FindChild("Root/LoadAb")
  self.fx_load.gameObject:SetActive(boo)
  if boo == true then 
    local model = self.fx_load
    local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,btn.Length - 1 do
      model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
    end
  end
end

function  UTGMainPanelAPI:UpdateNotice()
  -- body
  self.mainPanelControl.self:UpdateNotice()
end

function UTGMainPanelAPI:OnDestroy()
  self.this = nil
  self = nil
  UTGMainPanelAPI.Instance = nil
end



