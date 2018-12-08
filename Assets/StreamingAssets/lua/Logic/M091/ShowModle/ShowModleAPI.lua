require "Logic.UTGData.UTGData"
class("ShowModleAPI")
----------------------------------------------------
function ShowModleAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  ShowModleAPI.Instance=self;
  -------------------------------------
  
end
----------------------------------------------------
function ShowModleAPI:ShowInNextFrame(go)
  self.Co_O= coroutine.start(self.OpenInNextFrame,self,go)
  
end
function ShowModleAPI:OpenInNextFrame(target)  --Transform,Vector3
  target:SetActive(false);
  coroutine.step();
  target:SetActive(true); --Debugger.LogError("是");
end
----------------------------------------------------
function ShowModleAPI:Init(list)
  --[[
  if(type=="hero")then
    self.getHero:SetActive(true)
  elseif(type=="skin")then
    self.getSkin:SetActive(true)
  end
]]
  
  for i = 1,#list do
    if i == self.count then
      if list[i].Type == 1 then
        if UTGDataOperator.Instance.newModelTag == "new" then 
          self.getHero:SetActive(true)
        else --if self.newModelTag == "experience" then
          self.getHeroLimit:SetActive(true) 
        end
        self:ChangeHeroSkin("hero",list[i].Id)
      elseif list[i].Type == 2 then
        if UTGDataOperator.Instance.newModelTag == "new" then 
          self.getSkin:SetActive(true)
        else
          self.getSkinLimit:SetActive(true) 
        end
        self:ChangeHeroSkin("skin",list[i].Id)
        
        --去Itme表中找到对应的Id所对应的类型，在读Param中第一个参数
        --[[
        elseif list[i].Type == 4 then  
          if(UTGData.Instance().ItemsData[tostring(list[i].Id)].Type==7)then
            self.getHeroLimit:SetActive(true)
            self:ChangeHeroSkin("hero",UTGData.Instance().ItemsData[tostring(list[i].Id)].Param[1])
          elseif(UTGData.Instance().ItemsData[tostring(list[i].Id)].Type==8)then
            self.getSkinLimit:SetActive(true)
            self:ChangeHeroSkin("skin",UTGData.Instance().ItemsData[tostring(list[i].Id)].Param[1])
          end
        --]]
      end
      local callback = function(self,e)
        self:Init(list)
      end
      self:RegisterDelegate(self,callback,false)
      self.count = self.count + 1
      break
    end
    self:RegisterDelegate(nil,nil,true)
  end
  
  --self:ChangeHeroSkin(type,skinId) 

end
function ShowModleAPI:SetLimitTime(l)
self.this.transform:FindChild("Fg/Limit"):GetComponent("Text").text=l;
end
----------------------------------------------注册--
function ShowModleAPI:RegisterDelegate(obj,func,isDestroy)
  self.obj=obj;
  self.func=func; 
  self.isDestroy = isDestroy;
end
----------------------------------------------------
function ShowModleAPI:OnEnable()
  
  --------------------------------------------------
  local butOk = NTGEventTriggerProxy.Get(self.this.transforms[0].gameObject)
  butOk.onPointerDown = butOk.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( self.DragCube,self)

  self.cube = self.this.transforms[1]:FindChild("root")
  self.desk = self.this.transforms[1]:FindChild("desk")
  self.cubespeed = self.this.floats[0]
  -----------------------------------
  self.panel ={}
  self.panel["middle"] = self.this.transform:FindChild("root/middle")
  self.modelRoot = self.panel["middle"]:FindChild("model")
  -----------------------------------
  self.count = 1
  -----------------------------------
  self.fx= self.this.transform:FindChild("root/middle/model/desk/R51140260").gameObject
  self.name = self.this.transform:FindChild("Fg/UnderName/Name"):GetComponent("Text");
  self.getHero = self.this.transform:FindChild("Fg/Under/GetHero").gameObject
  self.getSkin = self.this.transform:FindChild("Fg/Under/GetSkin").gameObject
  self.getHeroLimit = self.this.transform:FindChild("Fg/Under/GetHeroLimit").gameObject
  self.getSkinLimit = self.this.transform:FindChild("Fg/Under/GetSkinLimit").gameObject
  local butEnter = NTGEventTriggerProxy.Get(self.this.transform:FindChild("Fg/Button").gameObject)
  butEnter.onPointerClick = butOk.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()
      if self.func ~= nil and self.obj ~= nil then
        self:ShowInNextFrame(self.fx)
        self.func(self.obj);
      end

      if HeroInfoAPI ~= nil and HeroInfoAPI.Instance ~= nil then
        HeroInfoAPI.Instance.heroInfoController.self.model.gameObject:SetActive(true)
      end

      if self.isDestroy == true then
        local function anonyFunc(args)
          Object.Destroy(self.this.gameObject)
        end
        UTGDataOperator.Instance:NewAchievePanelOpen(anonyFunc)
      end
    end,self
    )
  --------------------------------------------------

  NTGApplicationController.SetShowQuality(true)
  self.modelRoot:SetParent(nil)
  self.modelRoot.localPosition = Vector3.zero
  self.modelRoot.localRotation = Quaternion.identity
  self.modelRoot.localScale = Vector3.one

  if HeroInfoAPI ~= nil and HeroInfoAPI.Instance ~= nil then
    HeroInfoAPI.Instance.heroInfoController.self.model.gameObject:SetActive(false)
  end
  
  --self:Init("hero","11000501") --(type,skinId)
end
----------------------------------------------------
function ShowModleAPI:OnDestroy() 
  if(self.Co_O~=nil)then coroutine.stop(self.Co_O) end
  if(self.Co_D~=nil)then coroutine.stop(self.Co_D) end

  if HeroInfoAPI ~= nil and HeroInfoAPI.Instance ~= nil then
    NTGApplicationController.SetShowQuality(true)
  end

  if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil and StoreCtrl ~= nil and StoreCtrl.Instance ~= nil and   StoreCtrl.Instance.typePage == 1   then
    StoreNewCtrl.Instance:ApiModelActive(true)
  end 

  Object.Destroy(self.modelRoot.gameObject) 
  ------------------------------------
  ShowModleAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
----------------------------------------------------
function ShowModleAPI:DragCube()
 self.Co_D=coroutine.start( self.DragMov,self)
end
----------------------------------------------------
function ShowModleAPI:DragMov()

  local startpos = Input.mousePosition
  --print(startpos)
  local offet = {}
  local isClick = true
  while Input.GetMouseButton(0) do  
    coroutine.step() 

    offet = (Input.mousePosition-startpos).x
    if math.abs(offet) > 0.1 then isClick = false end
    startpos = Input.mousePosition
    self.cube.localEulerAngles = self.cube.localEulerAngles + Vector3.New(0,-self.cubespeed*offet,0)
    self.desk.localEulerAngles = self.desk.localEulerAngles + Vector3.New(0,-self.cubespeed*offet,0)
  end
  if isClick then
    self:SetModelPlayerAnimator()
  end
end
--更换皮肤模型--------------------------------------
function ShowModleAPI:ChangeHeroSkin(idType,skinId)

  local skindata
  if idType == "hero" then
    skindata = UTGData.Instance().SkinsData[tostring(UTGData.Instance().RolesData[tostring(skinId)].Skin)]
    self.name.text=UTGData.Instance().RolesData[tostring(skinId)].Name
  else
    skindata = UTGData.Instance().SkinsData[tostring(skinId)]
    self.name.text=skindata.Name
  end

  
  -- skindata.Resource 
  local tempo = self.panel["middle"]
  local temp_model = self.modelRoot:FindChild("root/model")

  tempo:FindChild("rawevent").gameObject:SetActive(true)
  self.modelRoot:FindChild("root").localRotation = Quaternion.identity

  --删除模型
  for i=1,temp_model.childCount do
    --Object.DestroyImmediate(temp_model:GetChild(i-1).gameObject,true)
    Object.Destroy(temp_model:GetChild(i-1).gameObject)
  end
  self.fxShow = nil
  self.fxPlay = nil
  self.modelAnimator = nil
  --创建模型
  local temp  = NTGResourceController.Instance:LoadAsset("skin".. skindata.Resource,tostring(skindata.Resource .."-Show")) -- 
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
end
----------------------------------------------------
function ShowModleAPI:SetModelPlayerAnimator()
  if self.modelAnimator ~= nil then
    self.modelAnimator:SetTrigger("play")
  end
  if self.fxPlay ~= nil then
    local fx = self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
    local renderer = self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))

    for k = 0,renderer.Length - 1 do
      self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(renderer[k].material.shader.name)
    end

    for k = 0,fx.Length - 1 do
      fx[k]:Play()
    end
  end
end