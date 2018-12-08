--jit.off()
--jit.opt(3)

class("GameManager")

GameData = {}

function GameManager:Awake(this) 
  self.this = this  
  self:Init()
  self.this.gameObject:AddComponent(NTGLuaScript.GetType("NTGLuaScript")):Load("Logic.UTGData.UTGDataOperator")
  GameManager.Instance = self
  if GameManager.PanelRoot ~= nil then
    GameManager.CreatePanel("NewLogin2", nil)
    --GameManager.CreatePanel("Login", nil)
    --GameManager.CreatePanel("UpdateResource", nil)
    --GameManager.CreatePanel("Promote", nil)
    --GameManager.CreatePanel("Matching") 
  end
end

function GameManager:Init()
  GameManager.NetDispatcherHost = self.this    
  GameManager.PanelRoot = self.this.transforms[0]
  GameManager.UIAudioListener = self.this.transforms[1]:GetComponent("AudioListener")
  
  self.this.gameObject:AddComponent(NTGLuaScript.GetType("NTGLuaScript")):Load("Logic.GameGuard")
end

function GameManager:OnDestroy()
  self.this = nil
  self = nil
end

function GameManager.CreatePanel(name)
  local assetName = name .. "Panel"
  --print("Creating Panel: " .. assetName) 
  local prefab = NTGResourceController.Instance:LoadAsset(name, assetName)
  
  local go
  --print("assetName " .. assetName) 
  if GameManager.PanelRoot:FindChild(assetName) == nil and prefab ~= nil then
    go = GameObject.Instantiate(prefab)
    go.name = assetName
    go.transform:SetParent(GameManager.PanelRoot)
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    go:SetActive(true)
    --NTGResourceController.Instance:UnloadAssetBundle(name, false);
  end
  if GameManager.PanelRoot:FindChild(assetName) ~= nil then go = GameManager.PanelRoot:FindChild(assetName) end
  return go.transform
end

function GameManager.CreateDialog(name)
  local assetName = name .. "Dialog"
  --print("Creating Dialog: " .. assetName) 
  local prefab = NTGResourceController.Instance:LoadAsset(name, assetName)
  
  local go  
  if prefab ~= nil then
    go = GameObject.Instantiate(prefab)
    go.name = assetName
    go.transform:SetParent(GameManager.PanelRoot)
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    go:SetActive(true)       
    --NTGResourceController.Instance:UnloadAssetBundle(name, false);       
  end
  return go.transform
end

function GameManager:OnDestroy()
  self.this = nil
  self = nil
end

function GameManager.CreatePanelAsync(name)
  local result = {Done = false}     
  
  coroutine.start(GameManager.doCreatePanelAsync, GameManager.Instance, name, result)
  return result
end

function GameManager:doCreatePanelAsync(name, result)
  local assetLoader = nil
  local prefab = nil
  local assetName = name .. "Panel"
  if UTGDataOperator.Instance.assetLoader ~= nil then 
      while prefab == nil do 
        if UTGDataOperator.Instance.currentAssetName == name then
          while UTGDataOperator.Instance.assetLoader.Done ~= true do
            coroutine.step()
          end
          prefab = UTGDataOperator.Instance.assetLoader.Asset
        else
          if UTGDataOperator.Instance.panelList[1] ~= name then 
            local isIn = false
            for i,v in ipairs(UTGDataOperator.Instance.panelList) do
              if v == name then 
                table.insert(UTGDataOperator.Instance.panelList,1,name)
                table.remove(UTGDataOperator.Instance.panelList,i)
                isIn = true
              end
            end
            if isIn == false then table.insert(UTGDataOperator.Instance.panelList,1,name) end
          end
        end
        coroutine.step()
      end
  else
    assetLoader = NTGResourceController.AssetLoader.New()
    assetLoader:LoadAsset(name, assetName)
    while assetLoader.Done ~= true do
      coroutine.step()
    end
    prefab = assetLoader.Asset
    assetLoader:Close()
    assetLoader = nil
  end
  local go
  if GameManager.PanelRoot:FindChild(assetName) == nil and prefab ~= nil then
    go = GameObject.Instantiate(prefab)
    go.name = assetName
    go.transform:SetParent(GameManager.PanelRoot)
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    go:SetActive(true)
    --NTGResourceController.Instance:UnloadAssetBundle(name, false);
  end  
  
  if go ~= nil then
    result.Panel = go.transform
  end
  result.Done = true  
  
end


