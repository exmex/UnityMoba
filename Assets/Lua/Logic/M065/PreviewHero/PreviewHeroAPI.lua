--Maintenance By WYL
local json = require "cjson"
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
class("PreviewHeroAPI")
----------------------------------------------------

function PreviewHeroAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  PreviewHeroAPI.Instance=self;
  -----------------引用--------------------
  
  self.CategoryAllbutton =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/CategoryAll").gameObject
  self.Category0button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Category0").gameObject
  self.Category1button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Category1").gameObject
  self.Category2button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Category2").gameObject
  self.Category3button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Category3").gameObject
  self.Category4button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Category4").gameObject
  self.Category5button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Category5").gameObject
  -------------按职业区分表-----------
    self.class0Table={}
    self.class1Table={}
    self.class2Table={}
    self.class3Table={}
    self.class4Table={}
    self.class5Table={}
    self.selectedTable={}
  
  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function PreviewHeroAPI:ResetPanel()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("PreviewHeroPanel")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.OnReturnButtonClick,nil,nil,"姬神列表")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)
end

----------------------------------------------------

function PreviewHeroAPI:Start()

  --临时添加等待
  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end




    --UnityEngine.Resources.UnloadUnusedAssets();
  self:ResetPanel()



  self.Content = UITools.GetLuaScript( self.this.transform:FindChild("Right/Middle/Mask/ScrollRect/Content") ,
                                       "Logic.UICommon.UIItems")  

    self:ValidLimitFreeRoleListRequest()
  
    
    
end

function PreviewHeroAPI:SetParam()
    --------------------------全部英雄-------------------------
    local sortTable={}
    for k,v in pairs(UTGData.Instance().RolesData) do
      table.insert(sortTable,v)
    end
    
    table.sort(sortTable,function(a,b) return tonumber(a.Id)<tonumber(b.Id) end )--按Id排序

    --------------------------拥有及体验英雄-------------------------
    local deckTable={}  --拥有
    local experienceTable={}  --体验
    for k,v in pairs(UTGData.Instance().RolesDeck) do --Debugger.LogError("拥有英雄")
      if(v.IsOwn==true)then
        table.insert(deckTable,v)
      elseif(UTGData.Instance():GetLeftTime(v.ExperienceTime)>0 )then 
        table.insert(experienceTable,v)
      end
    end
    --------------------------限免英雄-------------------------
    local freeTable={}
    for k,v in pairs(self.LimitFreeData) do
      table.insert(freeTable,v)
    end
    --------------------------Sort-------------------------
    
    --s meaning Sroted
    local sTable1Own={};   --拥有（包括限免）
    local sTable1IIExp={}; --体验
    local sTable2NoOwn={}; --没有
    
    for i,v1 in pairs(sortTable) do
      
      local flag=false;
      local ID=v1.Id;
      
      for j,v2 in pairs(deckTable) do
        if(ID==v2.RoleId)then
          table.insert(sTable1Own,v1);
          flag=true
        end
      end
      
      if(flag==false)then
        
        local isIn=false;
        
        for k3,v3 in pairs(experienceTable) do
          if(ID==v3.RoleId)then
            table.insert(sTable1IIExp,v1);
            isIn=true
            break
          end
        end
        
        if(isIn==false)then
          table.insert(sTable2NoOwn,v1);
        end

      end
      
    end
    
    ----Debugger.LogError("Sorted : sTable1Own:" .. #sTable1Own);
    ----Debugger.LogError("Sorted:table1NoOwn:" .. #sTable2NoOwn);
    
    local sTable3Free={}  --没有&&限免
    local sTable4NoOwn={} --没有&&不是限免
    
    for i,v1 in pairs(sTable2NoOwn) do
    
      local flag=false;
      local ID=v1.Id;
    
      for j,v2 in pairs(freeTable) do
        if(ID==v2)then
          table.insert(sTable3Free,v1);
          flag=true
        end
      end
      
      if(flag==false)then
        table.insert(sTable4NoOwn,v1);
      end
    
    end
    
    ----Debugger.LogError("Sorted : sTable3Free:" .. #sTable3Free);
    ----Debugger.LogError("Sorted:sTable4NoOwn:" .. #sTable4NoOwn);
    ------------------------------将Sorted数据存进一个table--------------------------------
    
    local sTableAll={};
    for i,v in pairs(sTable1Own) do
      table.insert(sTableAll,v);
    end
    for i,v in pairs(sTable3Free) do
      table.insert(sTableAll,v);
    end
    for i,v in pairs(sTable1IIExp) do --体验
      table.insert(sTableAll,v);
    end
    for i,v in pairs(sTable4NoOwn) do
      table.insert(sTableAll,v);
    end   
    -----------------------------------对排好序的表进行深拷贝------------------------------
    --local tableCopy=self:CopyTab(sTableAll);
    self.tableCopy=UITools.CopyTab(sTableAll); 
    -----------------------------将所需要的属性添加进tableCopy-----------------------------
    for i,v1 in pairs(self.tableCopy) do
      --已经拥有所需数据:职业,名字
      local ID=v1.Id;
      
      v1.Deck=false;--是否拥有
      for j,v in pairs(deckTable) do 
        if(ID==v.RoleId)then
          v1.Deck=true;
        end
      end
      
      v1.Free=false;--是否限免
      for j,v in pairs(freeTable) do
        if(ID==v)then
          v1.Free=true;
        end
      end

      v1.Exper=false;--是否体验
      for j,v in pairs(experienceTable) do
        if(ID==v.RoleId)then
          v1.Exper=true;
        end
      end
      
      v1.ProficiencyQuality=0;--熟练度等级
      for j,v in pairs(deckTable) do
        if(ID==v.RoleId)then
          for k,v2 in pairs(UTGData.Instance().RoleProficiencysData) do
           
            if(v.ProficiencyId==v2.Id )then
             
              v1.ProficiencyQuality=v2.Quality;
            end
          end
        end
      end

      v1.Portrait="";--皮肤
      ------------------------先把默认皮肤赋值给拷贝表的Portrait----------------------
      for k,v2 in pairs(UTGData.Instance().SkinsData) do --在表中找出对应的Portrait
        if(v1.Skin==v2.Id )then
          v1.Portrait=v2.Portrait;
          v1.CurrentSkin=v2.Id
        end
      end
      
      ---------------------再赋值上次使用过的皮肤，有的话就覆盖默认了-----------------
      for j,v in pairs(deckTable) do --在Deck表中找到对应的Skin
        if(ID==v.RoleId)then
          for k,v2 in pairs(UTGData.Instance().SkinsData) do --在表中找出对应的Portrait
            if(v.Skin==v2.Id )then
              v1.Portrait=v2.Portrait;
              v1.CurrentSkin=v2.Id
            end
          end
        end
      end
      
    end
    --[[
    for i,v in pairs(self.tableCopy) do
      --Debugger.LogError("Id      ：" .. v.Id);
      --Debugger.LogError("名字    ：" .. v.Name);
      --Debugger.LogError("职业    ：" .. v.Class);
          
      --Debugger.LogError("是否拥有：" .. tostring(v.Deck));
      --Debugger.LogError("是否限免：" .. tostring(v.Free));
      --Debugger.LogError("熟练度：  " .. v.ProficiencyQuality);
      --Debugger.LogError("当前皮肤：" .. v.Portrait);
               
    end
    --]]
    -------------------------------------按职业区分-----------------------------------------
    self.class0Table={}
    self.class1Table={}
    self.class2Table={}
    self.class3Table={}
    self.class4Table={}
    self.class5Table={}

    for i,v in pairs(self.tableCopy) do
      if(v.Class==0)then
        table.insert(self.class0Table,v);
      elseif(v.Class==1)then
        table.insert(self.class1Table,v);
      elseif(v.Class==2)then  
        table.insert(self.class2Table,v);
      elseif(v.Class==3)then  
        table.insert(self.class3Table,v);
      elseif(v.Class==4)then
        table.insert(self.class4Table,v);
      elseif(v.Class==5)then
        table.insert(self.class5Table,v);
      end        
    end
    
    -----------------------------委托事件-----------------------------
    
    
    local listener = NTGEventTriggerProxy.Get(self.CategoryAllbutton)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnCategoryAllButtonClick,self)
    listener = NTGEventTriggerProxy.Get(self.Category0button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnCategory0ButtonClick,self)
    listener = NTGEventTriggerProxy.Get(self.Category1button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnCategory1ButtonClick,self)
    listener = NTGEventTriggerProxy.Get(self.Category2button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnCategory2ButtonClick,self)
    listener = NTGEventTriggerProxy.Get(self.Category3button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnCategory3ButtonClick,self)
    listener = NTGEventTriggerProxy.Get(self.Category4button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnCategory4ButtonClick,self)
    listener = NTGEventTriggerProxy.Get(self.Category5button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnCategory5ButtonClick,self)
    -------------------------------------
    
    self:OnCategoryAllButtonClick()--执行一次点击事件，默认显示全部Item
    end
-------------------------Start结束--------------------------
-------------------------委托方法---------------------------
function PreviewHeroAPI:OnReturnButtonClick()
  if(UTGMainPanelAPI~=nil)then
          UTGMainPanelAPI.Instance:ShowSelf()
         end
  Object.Destroy(self.this.gameObject)

end
function PreviewHeroAPI:OnCategoryAllButtonClick() 
  self.selectedTable=self.tableCopy
  self.Content:ResetItemsSimple(#self.tableCopy) 
  self:Evaluation(self.tableCopy);
end
function PreviewHeroAPI:OnCategory0ButtonClick() 
  self.selectedTable=self.class0Table
  self.Content:ResetItemsSimple(#self.class0Table) 
  self:Evaluation(self.class0Table);
end
function PreviewHeroAPI:OnCategory1ButtonClick() 
  self.selectedTable=self.class1Table
  self.Content:ResetItemsSimple(#self.class1Table) 
  self:Evaluation(self.class1Table);
end
function PreviewHeroAPI:OnCategory2ButtonClick() 
  self.selectedTable=self.class2Table
  self.Content:ResetItemsSimple(#self.class2Table) 
  self:Evaluation(self.class2Table);
end
function PreviewHeroAPI:OnCategory3ButtonClick() 
  self.selectedTable=self.class3Table
  self.Content:ResetItemsSimple(#self.class3Table) 
  self:Evaluation(self.class3Table);
end
function PreviewHeroAPI:OnCategory4ButtonClick() 
  self.selectedTable=self.class4Table
  self.Content:ResetItemsSimple(#self.class4Table) 
  self:Evaluation(self.class4Table);
end
function PreviewHeroAPI:OnCategory5ButtonClick() 
  self.selectedTable=self.class5Table
  self.Content:ResetItemsSimple(#self.class5Table) 
  self:Evaluation(self.class5Table);
end
------------------------为Item赋值----------------------------
function PreviewHeroAPI:Evaluation(temp)
  
  for i=1, #self.Content.itemList,1 do
    --赋值
    self.Content.itemList[i].transform:FindChild("IconMask/Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("portrait",temp[i].Portrait);
    self.Content.itemList[i].transform:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text=temp[i].Name;
    self.Content.itemList[i].transform:FindChild("Free").gameObject:SetActive(temp[i].Free);
    if(temp[i].Free==false and temp[i].Exper==true)then
      self.Content.itemList[i].transform:FindChild("Exper").gameObject:SetActive(true);
    else
      self.Content.itemList[i].transform:FindChild("Exper").gameObject:SetActive(false);
    end 
   
    if(temp[i].ProficiencyQuality==0)then
      --self.Content.itemList[i].transform:FindChild("Proficiency"):GetComponent("UnityEngine.UI.Image").color=Color.New(0.25,0.25,0.25,1)
    else
      self.Content.itemList[i].transform:FindChild("Proficiency"):GetComponent("UnityEngine.UI.Image").color=Color.white;
      self.Content.itemList[i].transform:FindChild("Proficiency"):GetComponent("UnityEngine.UI.Image").sprite
      = UITools.GetSprite("icon", "Ishuliandu-" .. temp[i].ProficiencyQuality ); 


      self.Content.itemList[i].transform:FindChild("Proficiency"):GetComponent("UnityEngine.UI.Image"):SetNativeSize()
    end
  
    if(temp[i].Deck or temp[i].Free or temp[i].Exper)then
      self.Content.itemList[i].transform:FindChild("IconMask/Icon"):GetComponent("UnityEngine.UI.Image").color=Color.white 
    else
      self.Content.itemList[i].transform:FindChild("IconMask/Icon"):GetComponent("UnityEngine.UI.Image").color=Color.New(0.25,0.25,0.25,1)
    end

    if(temp[i].Deck)then
      self.Content.itemList[i].transform:FindChild("Proficiency"):GetComponent("UnityEngine.UI.Image").color=Color.white 
    else
      self.Content.itemList[i].transform:FindChild("Proficiency"):GetComponent("UnityEngine.UI.Image").color=Color.New(0.25,0.25,0.25,1)
    end

    --按钮委托
    local callback = function()
      ----Debugger.LogError(temp[i].Id);
      ----Debugger.LogError(temp[i].Class);
      --创建预览详情Panel
      GameManager.CreatePanel("Waiting")
    
     
 

      local tableCurrentSkin={}
      for k,v in pairs(self.selectedTable) do
        table.insert(tableCurrentSkin,UTGData.Instance().SkinsData[tostring(v.CurrentSkin)]) 
      end  

      
      

      
      self:GoToOtherPanel("HeroInfo",temp[i].Id,self.selectedTable,temp[i].CurrentSkin,tableCurrentSkin)
      --调用XXXAPI.Instance:XXX()方法
    end
    
    UITools.GetLuaScript(self.Content.itemList[i],"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)
 
  end
  
end

function PreviewHeroAPI:GoToOtherPanel(name,id,selectedTable,skinId,skinList)


    coroutine.start( PreviewHeroAPI.GoToOtherPanelCoroutine,self,name,id,selectedTable,skinId,skinList)

    
end

function PreviewHeroAPI:GoToOtherPanelCoroutine(name,id,selectedTable,skinId,skinList)
  local async = GameManager.CreatePanelAsync(name)
  while async.Done == false do
    coroutine.wait(0.05)
  end
  HeroInfoAPI.Instance:Init(id,selectedTable)
  print("44444444444444")
  HeroInfoAPI.Instance:InitCenterBySkinId(skinId,skinList)
end

----------------------------------------------------
function PreviewHeroAPI:OnDestroy() 
  
  ------------------------------------
  PreviewHeroAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
---------------------------------获取当前可用的限免英雄-----------------------------
function PreviewHeroAPI:ValidLimitFreeRoleListRequest() --RequestValidLimitFreeRoleList

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestValidLimitFreeRoleList")
                         
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ValidLimitFreeRoleListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end


----------------------------------------------------------------------
function PreviewHeroAPI:ValidLimitFreeRoleListResponseHandler(e)

  if e.Type == "RequestValidLimitFreeRoleList" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
     
    elseif(data.Result==1)then
      self.LimitFreeData=data.List
      UTGDataTemporary.Instance().LimitedData = data.List 
      self:SetParam()
    end

    return true;
  else
    return false;
  end

end