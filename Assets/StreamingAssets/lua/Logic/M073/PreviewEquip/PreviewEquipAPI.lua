--Maintenance By WYL
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
local json = require "cjson"
class("PreviewEquipAPI")
----------------------------------------------------
function PreviewEquipAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  PreviewEquipAPI.Instance=self;
  -------------------------------------
  self.selectedHeroId=nil
  -----------------引用--------------------
  
  self.equipScrowRectTransform=self.this.transform:FindChild("Right/Middle/Mask/ScrollRect"):GetComponent("RectTransform");
      
  self.Type1Button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/Menu/Type1").gameObject
  self.Type2Button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/Menu/Type2").gameObject
  self.Type3Button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/Menu/Type3").gameObject
  self.Type4Button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/Menu/Type4").gameObject
  self.Type5Button =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/Menu/Type5").gameObject
  ----右侧装备描述节点----
  self.NameP=self.this.transform:FindChild("Right/Middle/Desc/Name/Value")
  self.AttributesP=self.this.transform:FindChild("Right/Middle/Desc/ScrollRect/Content/Attributes")
  self.PassiveSkillsP=self.this.transform:FindChild("Right/Middle/Desc/ScrollRect/Content/PassiveSkills")
  
  --------------推荐装备相关-------------------
  self.selectedIcon=self.this.transform:FindChild("Bottom/Middle/Pop/IconMask/Icon"):GetComponent("UnityEngine.UI.Image");

  
  self.ButtonInside=self.this.transform:FindChild("Right/Middle/Desc/ButtonInside").gameObject
  local listener = NTGEventTriggerProxy.Get(self.ButtonInside)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.EquipInsideButtonClick,self )

  self.ButtonShadowDown=self.this.transform:FindChild("Bottom/Middle/Pop/ButtonShadowDown").gameObject   
  listener = NTGEventTriggerProxy.Get(self.ButtonShadowDown)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function()
      self.equipScrowRectTransform.sizeDelta =  Vector2.New(760, 578);
    end,self 
    )

  self.ButtonShadowUp=self.this.transform:FindChild("Bottom/Middle/ButtonShadowUp").gameObject   
  listener = NTGEventTriggerProxy.Get(self.ButtonShadowUp)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function()
      self.equipScrowRectTransform.sizeDelta =  Vector2.New(760, 450);
    end,self 
    )

  self.ButtonReplace=self.this.transform:FindChild("Bottom/Middle/Pop/ButtonReplace").gameObject   
  self.IconReplace=self.this.transform:FindChild("Bottom/Middle/Pop/IconMask/Icon").gameObject   

  listener = NTGEventTriggerProxy.Get(self.ButtonReplace)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnReplaceRoleButtonClick,self )
  listener = NTGEventTriggerProxy.Get(self.IconReplace)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnReplaceRoleButtonClick,self )
  
  self.ButtonGod=self.this.transform:FindChild("Bottom/Middle/Pop/ButtonGod").gameObject   
  listener = NTGEventTriggerProxy.Get(self.ButtonGod)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnGodButtonClick,self )

  self.ButtonDefault=self.this.transform:FindChild("Bottom/Middle/Pop/ButtonDefault").gameObject   
  listener = NTGEventTriggerProxy.Get(self.ButtonDefault)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()
          --self:DeleteFriendRequest(v.Id);
          local notice = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
          notice:InitNoticeForNeedConfirmNotice("提示","确定要恢复默认配置吗？",false,"",2)
          notice:SetTextToCenter()
          notice:TwoButtonEvent("取消",function () notice:DestroySelf(); end,self,
                                "确定",function () self:GetDefaultEquipment(); notice:DestroySelf(); end,self)
          
          --self.wannaDestory=self.ItemListFriend.itemList[k]
        end ,self 
   )
     
  self.ButtonCancel=self.this.transform:FindChild("Bottom/Middle/Pop/ButtonCancel").gameObject
  listener = NTGEventTriggerProxy.Get(self.ButtonCancel)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.GetRecommendedEquipment,self )       
    
  self.ButtonConfirm=self.this.transform:FindChild("Bottom/Middle/Pop/ButtonConfirm").gameObject
  listener = NTGEventTriggerProxy.Get(self.ButtonConfirm)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(
function ()
  self.TipText="修改成功"
  self:MyRequest()
end,self 
   
   )
 

  self.ButtonModify=self.this.transform:FindChild("Bottom/Middle/Pop/ButtonModify").gameObject
  listener = NTGEventTriggerProxy.Get(self.ButtonModify)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(

    function()  --推荐装备集合
      --self.tempRecoEquipsId=UITools.CopyTab(self.RecoEquipsId)  --Debugger.LogError("装备数组赋值给临时") 
     
    end,self 

    )
 
 self.RecoButtonFills={}
 table.insert(self.RecoButtonFills,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco1/ButtonFill").gameObject);
    table.insert(self.RecoButtonFills,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco2/ButtonFill").gameObject);
      table.insert(self.RecoButtonFills,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco3/ButtonFill").gameObject);
        table.insert(self.RecoButtonFills,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco4/ButtonFill").gameObject);
          table.insert(self.RecoButtonFills,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco5/ButtonFill").gameObject);
            table.insert(self.RecoButtonFills,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco6/ButtonFill").gameObject);
  
           self.RecoIcons={}     
  table.insert(self.RecoIcons,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco1/Icon").gameObject);
   table.insert(self.RecoIcons,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco2/Icon").gameObject);
    table.insert(self.RecoIcons,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco3/Icon").gameObject);
     table.insert(self.RecoIcons,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco4/Icon").gameObject);
      table.insert(self.RecoIcons,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco5/Icon").gameObject);
       table.insert(self.RecoIcons,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco6/Icon").gameObject);
       
                  self.RecoXs={}     
  table.insert(self.RecoXs,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco1/Icon/ButtonX").gameObject);
   table.insert(self.RecoXs,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco2/Icon/ButtonX").gameObject);
    table.insert(self.RecoXs,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco3/Icon/ButtonX").gameObject);
     table.insert(self.RecoXs,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco4/Icon/ButtonX").gameObject);
      table.insert(self.RecoXs,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco5/Icon/ButtonX").gameObject);
       table.insert(self.RecoXs,self.this.transform:FindChild("Bottom/Middle/Pop/Recommendation/Reco6/Icon/ButtonX").gameObject);

 
  -------------按类型区分表-----------
 
    self.Type1Table={}
    self.Type2Table={}
    self.Type3Table={}
    self.Type4Table={}
    self.Type5Table={}
  -----------------------------------
  
  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function PreviewEquipAPI:ResetPanel()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("PreviewEquipPanel")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.OnReturnButtonClick,nil,nil,"整备")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)
end

----------------------------------------------------
function PreviewEquipAPI:Start()
  self.TipText="修改成功"
  --UnityEngine.Resources.UnloadUnusedAssets();

  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end
  
  self:ResetPanel()--初始化资源条

  
  
  --UTGMainPanelAPI.Instance:HideSelf()
  self.Content = UITools.GetLuaScript( self.this.transform:FindChild("Right/Middle/Mask") ,
                                       "Logic.UICommon.UIShopEquipGroup")  
                                      
  --------------------------商店商品排序-------------------------                                 
  local sortTable={}
  for k,v in pairs(UTGData.Instance().PVPMallsData) do
    table.insert(sortTable,v)
  end
    
  table.sort(sortTable,function(a,b) return tonumber(a.Id)<tonumber(b.Id) end )--按Id排序        
  ----------------------------对表进行深拷贝----------------------------
  self.tableCopyMall=UITools.CopyTab(sortTable);
  
  -----------------------------插入右节点----------------------------
  for k,v in pairs(self.tableCopyMall) do
    for k1,v1 in pairs(v.PreEquips) do--对装备的左节点集合中的元素，直接将其当前对应的装备ID，插入到原表中对应自己装备Id的右节点中
      for k2,v2 in pairs(self.tableCopyMall) do
        if(v2.EquipId==v1)then
          if(v2.NextEquips==nil)then
            v2.NextEquips={}
            v2.NextEquips[#v2.NextEquips+1]=v.EquipId;
          else
            v2.NextEquips[#v2.NextEquips+1]=v.EquipId;
          end
        end
      end
    end
  end
  --------------------从Equip表取所需值添加进来,清晰结构，减少界面操作时的复杂度-----------------------
  for k,v in pairs(self.tableCopyMall) do
    for  i1,v1 in pairs(UTGData.Instance().EquipsData) do
      if(v.EquipId==v1.Id)then
        v.Name=v1.Name
        v.Icon=v1.Icon
        v.AttrDesc={}
        if(v1.HP~=0)then  table.insert(v.AttrDesc, "+" .. v1.HP .. "  生命值")  end             -- float64 //生命值
        if(v1.MP~=0)then  table.insert(v.AttrDesc, "+" .. v1.MP .. "  导力值")  end             -- float64 //法力值
        if(v1.PAtk~=0)then  table.insert(v.AttrDesc, "+" .. v1.PAtk .. "  物理攻击")  end     
        if(v1.MAtk~=0)then  table.insert(v.AttrDesc, "+" .. v1.MAtk .. "  导术攻击")  end  
        if(v1.PDef~=0)then  table.insert(v.AttrDesc, "+" .. v1.PDef .. "  物理防御")  end  
        if(v1.MDef~=0)then  table.insert(v.AttrDesc, "+" .. v1.MDef .. "  导术防御")  end  
        if(v1.MoveSpeed~=0)then  table.insert(v.AttrDesc, "+" .. v1.MoveSpeed*100 .. "%  移动速度")  end  
        if(v1.PpenetrateValue~=0)then  table.insert(v.AttrDesc, "+" .. v1.PpenetrateValue .. "  物理护甲穿透")  end  
        if(v1.PpenetrateRate~=0)then  table.insert(v.AttrDesc, "+" .. v1.PpenetrateRate*100 .. "%  物理护甲穿透率")  end  
        if(v1.MpenetrateValue~=0)then  table.insert(v.AttrDesc, "+" .. v1.MpenetrateValue .. "  导术护甲穿透值")  end  
        if(v1.MpenetrateRate~=0)then  table.insert(v.AttrDesc, "+" .. v1.MpenetrateRate*100 .. "%  导术护甲穿透率")  end  
        if(v1.AtkSpeed~=0)then  table.insert(v.AttrDesc, "+" .. v1.AtkSpeed*100 .. "%  攻速加成")  end 
        if(v1.CritRate~=0)then  table.insert(v.AttrDesc, "+" .. v1.CritRate*100 .. "%  暴击几率")  end
        if(v1.CritEffect~=0)then  table.insert(v.AttrDesc, "+" .. v1.CritEffect*100 .. "%  暴击效果")  end
        if(v1.PHpSteal~=0)then  table.insert(v.AttrDesc, "+" .. v1.PHpSteal*100 .. "%  物理吸血")  end
        if(v1.MHpSteal~=0)then  table.insert(v.AttrDesc, "+" .. v1.MHpSteal*100 .. "%  导术吸血")  end
        if(v1.CdReduce~=0)then  table.insert(v.AttrDesc, "+" .. v1.CdReduce*100 .. "%  冷却缩减")  end
        if(v1.Tough~=0)then  table.insert(v.AttrDesc, "+" .. v1.Tough*100 .. "%  韧性")  end
        if(v1.HpRecover5s~=0)then  table.insert(v.AttrDesc, "+" .. v1.HpRecover5s .. "  每5s回血")  end
        if(v1.MpRecover5s~=0)then  table.insert(v.AttrDesc, "+" .. v1.MpRecover5s .. "  每5s回蓝")  end
        
        if(v1.PassiveSkills~=nil)then
          for k2,v2 in pairs(v1.PassiveSkills) do
            for k3,v3 in pairs(UTGData.Instance().SkillsData)  do   
              if(v2==v3.Id)then
                if(v.SkillDescs==nil)then
                  v.SkillDescs={}
                  table.insert(v.SkillDescs,v3.Desc)
                  
                else
                  table.insert(v.SkillDescs,v3.Desc)
                end
                break;
              end
            end
          end
        end
        break;
      end
    end
  end
  ----------------------------输出技能描述-----------------------------
  --[[
  for k,v in pairs(self.tableCopyMall) do
    if(v.SkillDescs==nil)then
    else
      for k1,v1 in pairs(v.SkillDescs)do
        ----Debugger.LogError(v.Id .. ":"  ..  v1)
      end
    end
  end
  --]]

  ----------------------------输出右节点-----------------------------
    --[[
  for k,v in pairs(self.tableCopyMall) do
    if(v.NextEquips~=nil)then
      for k1,v1 in pairs(v.NextEquips) do--对装备的左节点集合中的元素，直接将其当前对应的装备ID，插入到原表中对应自己装备Id的右节点中
        ----Debugger.LogError(k .. ":" .. v.EquipId .. ":" .. v1);
      end
    else
      ----Debugger.LogError(k .. ":" .. v.EquipId .. ":" .. "空");
    end
  end
  --]]
  ---------------------------按类型区分------------------------------
    for i,v in pairs(self.tableCopyMall) do
      if(v.Type==1)then
        table.insert(self.Type1Table,v);
      elseif(v.Type==2)then
        table.insert(self.Type2Table,v);
      elseif(v.Type==3)then  
        table.insert(self.Type3Table,v);
      elseif(v.Type==4)then  
        table.insert(self.Type4Table,v);
      elseif(v.Type==5)then
        table.insert(self.Type5Table,v);
      end        
    end
  --------------------------每种类型中的品阶-------------------------
  self.Type1Quality1Table={}
  self.Type1Quality2Table={}
  self.Type1Quality3Table={}
  self.Type1QualityX3={
    self.Type1Quality1Table,
    self.Type1Quality2Table,
    self.Type1Quality3Table
    }
  for i,v in pairs( self.Type1Table) do
    
    if(v.Quality==1)then
       table.insert(self.Type1Quality1Table,v)
    elseif(v.Quality==2)then
       table.insert(self.Type1Quality2Table,v)
    elseif(v.Quality==3)then
       table.insert(self.Type1Quality3Table,v)
    end
    
  end
  --------------------------------------------------------------------   
  self.Type2Quality1Table={}
  self.Type2Quality2Table={}
  self.Type2Quality3Table={}
  self.Type2QualityX3={
    self.Type2Quality1Table,
    self.Type2Quality2Table,
    self.Type2Quality3Table
    }
  for i,v in pairs( self.Type2Table) do
    
    if(v.Quality==1)then
       table.insert(self.Type2Quality1Table,v)
    elseif(v.Quality==2)then
       table.insert(self.Type2Quality2Table,v)
    elseif(v.Quality==3)then
       table.insert(self.Type2Quality3Table,v)
    end
    
  end
  --------------------------------------------------------------------    
  self.Type3Quality1Table={}
  self.Type3Quality2Table={}
  self.Type3Quality3Table={}
  self.Type3QualityX3={
    self.Type3Quality1Table,
    self.Type3Quality2Table,
    self.Type3Quality3Table
      }
 
  for i,v in pairs( self.Type3Table) do
    
    if(v.Quality==1)then
       table.insert(self.Type3Quality1Table,v)
    elseif(v.Quality==2)then
       table.insert(self.Type3Quality2Table,v)
    elseif(v.Quality==3)then
       table.insert(self.Type3Quality3Table,v)
    end
    
  end
  -------------------------------------------------------------------- 
  self.Type4Quality1Table={}
  self.Type4Quality2Table={}
  self.Type4Quality3Table={}
  self.Type4QualityX3={
    self.Type4Quality1Table,
    self.Type4Quality2Table,
    self.Type4Quality3Table
     }
  for i,v in pairs( self.Type4Table) do
    
    if(v.Quality==1)then
       table.insert(self.Type4Quality1Table,v)
    elseif(v.Quality==2)then
       table.insert(self.Type4Quality2Table,v)
    elseif(v.Quality==3)then
       table.insert(self.Type4Quality3Table,v)
    end
    
  end
  --------------------------------------------------------------------   
  self.Type5Quality1Table={}
  self.Type5Quality2Table={}
  self.Type5Quality3Table={}
  self.Type5QualityX3={
    self.Type5Quality1Table,
    self.Type5Quality2Table,
    self.Type5Quality3Table
  }
 
            
            
  for i,v in pairs( self.Type5Table) do
    
    if(v.Quality==1)then
       table.insert(self.Type5Quality1Table,v)
    elseif(v.Quality==2)then
       table.insert(self.Type5Quality2Table,v)
    elseif(v.Quality==3)then
       table.insert(self.Type5Quality3Table,v)
    end
    
  end
  
  
  -----------------------------委托事件-----------------------------
 
    


    listener = NTGEventTriggerProxy.Get(self.Type1Button) 
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnType1ButtonClick,self )
    listener = NTGEventTriggerProxy.Get(self.Type2Button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnType2ButtonClick,self )
    listener = NTGEventTriggerProxy.Get(self.Type3Button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnType3ButtonClick,self )
    listener = NTGEventTriggerProxy.Get(self.Type4Button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnType4ButtonClick,self )
    listener = NTGEventTriggerProxy.Get(self.Type5Button)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( self.OnType5ButtonClick,self )
    
    self.selectedEquipId=nil --当前选择EquipId
    self.RecoEquipsId={} --推荐装备集合
    --self.tempRecoEquipsId={}; 
    --给每个填入按钮添加事件 ，暂时没封装
    local callback = function() 
      if(self.selectedEquipId==nil)then
                 GameManager.CreatePanel("SelfHideNotice")
         SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请选择装备进行填入")
        return
      end
      self.RecoIcons[1]:SetActive(true);
      self:SetIconEvent(1,self.selectedEquipId) 
      self.RecoEquipsId[1]=self.selectedEquipId; --Debugger.LogError("将选中的Id存到数组中")
     

    end
    listener = NTGEventTriggerProxy.Get( self.RecoButtonFills[1])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 

      if(self.selectedEquipId==nil)then
                 GameManager.CreatePanel("SelfHideNotice")
         SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请选择装备进行填入")
        return
      end
      self.RecoIcons[2]:SetActive(true);
      self:SetIconEvent(2,self.selectedEquipId) 
      self.RecoEquipsId[2]=self.selectedEquipId;  --Debugger.LogError("将选中的Id存到数组中")

      

    end
    listener = NTGEventTriggerProxy.Get( self.RecoButtonFills[2])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 
      if(self.selectedEquipId==nil)then
                 GameManager.CreatePanel("SelfHideNotice")
         SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请选择装备进行填入")
        return
      end
      self.RecoIcons[3]:SetActive(true);
      self:SetIconEvent(3,self.selectedEquipId) 
      self.RecoEquipsId[3]=self.selectedEquipId;  --Debugger.LogError("将选中的Id存到数组中")

      

    end
    listener = NTGEventTriggerProxy.Get( self.RecoButtonFills[3])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 
      if(self.selectedEquipId==nil)then
                 GameManager.CreatePanel("SelfHideNotice")
         SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请选择装备进行填入")
        return
      end
      self.RecoIcons[4]:SetActive(true);
      self:SetIconEvent(4,self.selectedEquipId) 
      self.RecoEquipsId[4]=self.selectedEquipId;  --Debugger.LogError("将选中的Id存到数组中")

      

    end
    listener = NTGEventTriggerProxy.Get( self.RecoButtonFills[4])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 
      if(self.selectedEquipId==nil)then
                 GameManager.CreatePanel("SelfHideNotice")
         SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请选择装备进行填入")
        return
      end
      self.RecoIcons[5]:SetActive(true);
      self:SetIconEvent(5,self.selectedEquipId) 
      self.RecoEquipsId[5]=self.selectedEquipId;  --Debugger.LogError("将选中的Id存到数组中")

      

    end
    listener = NTGEventTriggerProxy.Get( self.RecoButtonFills[5])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 
      if(self.selectedEquipId==nil)then
                 GameManager.CreatePanel("SelfHideNotice")
         SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请选择装备进行填入")
        return
      end
      self.RecoIcons[6]:SetActive(true);
      self:SetIconEvent(6,self.selectedEquipId) 
      self.RecoEquipsId[6]=self.selectedEquipId;  --Debugger.LogError("将选中的Id存到数组中")

      

    end
    listener = NTGEventTriggerProxy.Get( self.RecoButtonFills[6])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    -----------------------------------------------------
    callback = function() 
      
      self.RecoEquipsId[1]=-1; --Debugger.LogError("将-1存到临时数组中")
    end
    listener = NTGEventTriggerProxy.Get( self.RecoXs[1])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 
    
       self.RecoEquipsId[2]=-1;  --Debugger.LogError("将-1存到临时数组中")
    end
    listener = NTGEventTriggerProxy.Get( self.RecoXs[2])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 
  
       self.RecoEquipsId[3]=-1;   --Debugger.LogError("将-1存到临时数组中")
    end
    listener = NTGEventTriggerProxy.Get( self.RecoXs[3])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 
   
       self.RecoEquipsId[4]=-1;   --Debugger.LogError("将-1存到临时数组中")
    end
    listener = NTGEventTriggerProxy.Get( self.RecoXs[4])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 
   
       self.RecoEquipsId[5]=-1;   --Debugger.LogError("将-1存到临时数组中")
    end
    listener = NTGEventTriggerProxy.Get( self.RecoXs[5])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
    
    callback = function() 
     
       self.RecoEquipsId[6]=-1;   --Debugger.LogError("将-1存到临时数组中")
    end
    listener = NTGEventTriggerProxy.Get( self.RecoXs[6])
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( callback,self )
  
  ------------------------------------------------------------------------------------------------------------------------------------
  
  self:OnType1ButtonClick() --默认显示第一类装备
  --------------------------TemplateRoles排序-------------------------
  self.RoleTableSort={}  
  for k,v in pairs(UTGData.Instance().RolesData) do
    table.insert(self.RoleTableSort,v)
  end
  table.sort(self.RoleTableSort,function(a,b) return tonumber(a.Id)<tonumber(b.Id) end )--按Id排序
  
  -----------------填入第一个Role的icon---------------
  for k2,v2 in pairs(UTGData.Instance().SkinsData) do
    if(self.RoleTableSort[1].Skin==v2.Id )then
      self.selectedIcon.sprite= UITools.GetSprite("roleicon",v2.Icon);
      break;
    end
  end
  ---------------------------------------------------------------------
  --self:Initialize()

end
-------------------------Start结束--------------------------
-----------------------赋值给选中角色的Id-------------------
function PreviewEquipAPI:Initialize(rid)
  
  if(rid==nil)then
    coroutine.start( self.Init,self)
  else 
    coroutine.start( self.Init,self,rid)
  end
    
end

function PreviewEquipAPI:Init(rid)
  
  coroutine.step()

  if(rid==nil)then
    self.selectedHeroId=10000101; --self.RoleTableSort[1].Id;
  else
    self.selectedHeroId=rid;
  end
  self:GetRecommendedEquipment()
  
end
-------------------------委托方法---------------------------
function PreviewEquipAPI:OnReturnButtonClick()
  if HeroInfoAPI ~= nil and HeroInfoAPI.Instance ~= nil then

  else  

    if UTGMainPanelAPI ~= nil then
      UTGMainPanelAPI.Instance:ShowSelf()
    end
  end
  Object.Destroy(self.this.gameObject)
end

function PreviewEquipAPI:OnType1ButtonClick() 
   self:Evaluation(self.Type1QualityX3);
  --self:Evaluation(self.Type1Quality1Table,self.Type1Quality2Table,self.Type1Quality3Table );
end
function PreviewEquipAPI:OnType2ButtonClick() 
   self:Evaluation(self.Type2QualityX3);
--self:Evaluation(self.Type2Quality1Table,self.Type2Quality2Table,self.Type2Quality3Table );
end
function PreviewEquipAPI:OnType3ButtonClick()
   self:Evaluation(self.Type3QualityX3);
  --self:Evaluation(self.Type3Quality1Table,self.Type3Quality2Table,self.Type3Quality3Table );
end
function PreviewEquipAPI:OnType4ButtonClick() 
   self:Evaluation(self.Type4QualityX3);
 -- self:Evaluation(self.Type4Quality1Table,self.Type4Quality2Table,self.Type4Quality3Table );
end
function PreviewEquipAPI:OnType5ButtonClick() 
  self:Evaluation(self.Type5QualityX3);
  --self:Evaluation(self.Type5Quality1Table,self.Type5Quality2Table,self.Type5Quality3Table );
end
-------------------

----------------------------------------------------
function PreviewEquipAPI:Evaluation(tableX3)
    
  self.Content:InitDrags( #tableX3[1] , #tableX3[2] , #tableX3[3])
for m,v2 in pairs(tableX3) do
   for i,v in pairs(v2) do
     
    self.Content.drags[m][i].transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite= UITools.GetSprite("equipicon",v.Icon)
    self.Content.drags[m][i].transform:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text=v.Name
    self.Content.drags[m][i].transform:FindChild("Price"):GetComponent("UnityEngine.UI.Text").text=v.Price
    v.GO=self.Content.drags[m][i].gameObject;--暂时用不到，用的当前点选物体
      
    local data= UITools.GetLuaScript(self.Content.drags[m][i].gameObject,"Logic.UICommon.UIShopEquipData");  
    data.selfId=v.EquipId;
    if(v.PreEquips~=nil)then
      data.lIds =v.PreEquips;
    end
    if(v.NextEquips~=nil)then
      data.rIds =v.NextEquips;
    end
    data.dataTable=v;
    
    local callback = function() --function(a,b) --如果要传的方法定义在外面 方法内并不会跟有对应数值 就需要注册方法的时候 把参数也传进去，但是在被注册方法的脚本执行时也要做相应的修改，影响通用性  
      self:ShowDesc(v.Name,v.AttrDesc,v.SkillDescs)
      self.selectedEquipId=v.EquipId; --Debugger.LogError("设置选中的Id成功");

      for m,v2 in pairs(tableX3) do
        for i,v in pairs(v2) do
          self.Content.drags[m][i].transform:FindChild("Selected").gameObject:SetActive(false)
        end
      end
      v.GO.transform:FindChild("Selected").gameObject:SetActive(true)
      self.ButtonInside:SetActive(true);
    end
    local uiClick=UITools.GetLuaScript(self.Content.drags[m][i].gameObject,"Logic.UICommon.UIClick");  
    uiClick:RegisterClickDelegate(self,callback) --(self,callback,   a,b（或者传表）) --方法注册
    
    
    
  end
end

end
-----------------------------------------------------------
function PreviewEquipAPI:OnDestroy() 
  --UTGDataOperator.Instance:BgBackToPanelRoot()
  
  ------------------------------------
  PreviewEquipAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self.selectedIcon.sprite=nil
  self = nil
end
--------------------------显示装备信息--------------------------
function PreviewEquipAPI:ShowDesc(name,attrDescs,skillDescs)
 
 
  ---------------关闭显示---------------
  self.NameP.gameObject:SetActive(false);
  
  for i=1,self.AttributesP.childCount,1 do
    self.AttributesP:GetChild(i-1).gameObject:SetActive(false);
  end
  
  for i=1,self.PassiveSkillsP.childCount,1 do
    self.PassiveSkillsP:GetChild(i-1).gameObject:SetActive(false);
  end
  ---------------显示信息---------------
  self.NameP.gameObject:SetActive(true);
  self.NameP:GetComponent("UnityEngine.UI.Text").text=name;
  if(attrDescs~=nil)then
    for i,v in pairs(attrDescs) do
      self.AttributesP:GetChild(i-1):GetComponent("UnityEngine.UI.Text").text=v;
      self.AttributesP:GetChild(i-1).gameObject:SetActive(true);
    end
  end
  
  if(skillDescs~=nil)then
    for i,v in pairs(skillDescs) do
      self.PassiveSkillsP:GetChild(i-1):GetComponent("UnityEngine.UI.Text").text=v;
      self.PassiveSkillsP:GetChild(i-1).gameObject:SetActive(true);
    end
  end
  --------------------------------------
end
----------------------设置点击添加后给Icon添加事件,并设置图片----------------------
function PreviewEquipAPI:SetIconEvent(m,equipId) 
      --设置初始化图片，或选中的图片
      
      --if(equipId==-1)then return end

      for i,v in pairs(self.tableCopyMall) do 
        if(equipId==v.EquipId)then

          self.RecoIcons[m]:GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("equipicon",v.Icon)
          break;
        end
      end
         

      --给Icon添加事件
            local callback1 = function() 
              self:Execute(m,equipId)
            end
            local listener = NTGEventTriggerProxy.Get(   self.RecoIcons[m] )
            listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callback1,self  )
end
--------------------------根据RoldId获取推荐装备------------------------
function PreviewEquipAPI:GetRecommendedEquipment()
  --Icon
 
  for k,v in pairs(UTGData.Instance().RolesData) do    
    if(self.selectedHeroId==v.Id)then
      for k2,v2 in pairs(UTGData.Instance().SkinsData) do 
        if(v.Skin==v2.Id )then
          self.selectedIcon.sprite= UITools.GetSprite("roleicon",v2.Icon);
          break;
        end
      end
      break;
    end
  end
  
  --self.selectedIcon.sprite= UITools.GetSprite("icon",UTGData.Instance().SkinsData[ tostring(UTGData.Instance().RolesData[tostring (self.selectedHeroId)].Skin) ].Icon);

  --table.contains(arr, 1)  
  --self.selectedHeroId=HeroId;
  local battleEquips={}
  ----------------------------RoleDecks---------------------------
  local roleDeckTable={}
  for k,v in pairs(UTGData.Instance().RolesDeck) do
      table.insert(roleDeckTable,v)
  end
  --------------------------TemplateRoles-------------------------
  local sortRoleTable={}
  for k,v in pairs(UTGData.Instance().RolesData) do
    table.insert(sortRoleTable,v)
  end
  table.sort(sortRoleTable,function(a,b) return tonumber(a.Id)<tonumber(b.Id) end )--按Id排序
  -----------如果Deck中没有此Id，就去Template拿默认值--------
  local flag=false;
  
  for k,v in pairs(roleDeckTable) do
    if(self.selectedHeroId==v.RoleId)then
      battleEquips=v.BattleEquips;
      
     self.RecoEquipsId[1]=v.BattleEquips[1];  if(self.RecoEquipsId[1]==-1)then   self.RecoIcons[1]:SetActive(false) else self.RecoIcons[1]:SetActive(true)  end
     self.RecoEquipsId[2]=v.BattleEquips[2];  if(self.RecoEquipsId[2]==-1)then   self.RecoIcons[2]:SetActive(false) else self.RecoIcons[2]:SetActive(true)  end
     self.RecoEquipsId[3]=v.BattleEquips[3];  if(self.RecoEquipsId[3]==-1)then   self.RecoIcons[3]:SetActive(false) else self.RecoIcons[3]:SetActive(true)  end
     self.RecoEquipsId[4]=v.BattleEquips[4];  if(self.RecoEquipsId[4]==-1)then   self.RecoIcons[4]:SetActive(false) else self.RecoIcons[4]:SetActive(true)  end
     self.RecoEquipsId[5]=v.BattleEquips[5];  if(self.RecoEquipsId[5]==-1)then   self.RecoIcons[5]:SetActive(false) else self.RecoIcons[5]:SetActive(true)  end
     self.RecoEquipsId[6]=v.BattleEquips[6];  if(self.RecoEquipsId[6]==-1)then   self.RecoIcons[6]:SetActive(false) else self.RecoIcons[6]:SetActive(true)  end
              ----Debugger.LogError(v.RoleId  .. "Deck:" .. v.BattleEquips[1] .. ":" .. v.BattleEquips[2] .. ":" .. v.BattleEquips[3] .. ":" .. v.BattleEquips[4] .. ":" ..              v.BattleEquips[5] .. ":" .. v.BattleEquips[6])
              
               
        self:SetIconEvent(1,v.BattleEquips[1])  
           self:SetIconEvent(2,v.BattleEquips[2]) 
           self:SetIconEvent(3,v.BattleEquips[3]) 
           self:SetIconEvent(4,v.BattleEquips[4]) 
           self:SetIconEvent(5,v.BattleEquips[5]) 
           self:SetIconEvent(6,v.BattleEquips[6]) 
              
      flag=true;
      break;
    end
  end
  
  if(flag==false)then
    for k,v in pairs(sortRoleTable) do
      if(self.selectedHeroId==v.Id)then
        battleEquips=v.BattleEquips;
        
        self.RecoEquipsId[1]=v.BattleEquips[1];  if(self.RecoEquipsId[1]==-1)then   self.RecoIcons[1]:SetActive(false) else self.RecoIcons[1]:SetActive(true)  end
        self.RecoEquipsId[2]=v.BattleEquips[2];  if(self.RecoEquipsId[2]==-1)then   self.RecoIcons[2]:SetActive(false) else self.RecoIcons[2]:SetActive(true)  end
        self.RecoEquipsId[3]=v.BattleEquips[3];  if(self.RecoEquipsId[3]==-1)then   self.RecoIcons[3]:SetActive(false) else self.RecoIcons[3]:SetActive(true)  end
        self.RecoEquipsId[4]=v.BattleEquips[4];  if(self.RecoEquipsId[4]==-1)then   self.RecoIcons[4]:SetActive(false) else self.RecoIcons[4]:SetActive(true)  end
        self.RecoEquipsId[5]=v.BattleEquips[5];  if(self.RecoEquipsId[5]==-1)then   self.RecoIcons[5]:SetActive(false) else self.RecoIcons[5]:SetActive(true)  end
        self.RecoEquipsId[6]=v.BattleEquips[6];  if(self.RecoEquipsId[6]==-1)then   self.RecoIcons[6]:SetActive(false) else self.RecoIcons[6]:SetActive(true)  end
        ----Debugger.LogError(v.Id  .. "Template:" .. v.BattleEquips[1] .. ":" .. v.BattleEquips[2] .. ":" .. v.BattleEquips[3] .. ":" .. v.BattleEquips[4] .. ":" ..              v.BattleEquips[5] .. ":" .. v.BattleEquips[6])
        
         
        --Debugger.LogError("SetEVENT");
            self:SetIconEvent(1,v.BattleEquips[1]) 
           self:SetIconEvent(2,v.BattleEquips[2]) 
           self:SetIconEvent(3,v.BattleEquips[3]) 
           self:SetIconEvent(4,v.BattleEquips[4]) 
           self:SetIconEvent(5,v.BattleEquips[5]) 
           self:SetIconEvent(6,v.BattleEquips[6]) 
            
            
        break;
      end
    end
  end
  ----------------------------------------------------------- 
end
--------------------------恢复默认推荐装备------------------------
function PreviewEquipAPI:GetDefaultEquipment()
  
  --table.contains(arr, 1)  
  --self.selectedHeroId=HeroId;
  local battleEquips={}
  --------------------------TemplateRoles-------------------------
  local sortRoleTable={}
  for k,v in pairs(UTGData.Instance().RolesData) do
    table.insert(sortRoleTable,v)
  end
  table.sort(sortRoleTable,function(a,b) return tonumber(a.Id)<tonumber(b.Id) end )--按Id排序
  -----------如果Deck中没有此Id，就去Template拿默认值--------  
  
    for k,v in pairs(sortRoleTable) do
      if(self.selectedHeroId==v.Id)then
        battleEquips=v.BattleEquips;
        
          self.RecoEquipsId[1]=v.BattleEquips[1];  if(self.RecoEquipsId[1]==-1)then   self.RecoIcons[1]:SetActive(false) else self.RecoIcons[1]:SetActive(true)  end
          self.RecoEquipsId[2]=v.BattleEquips[2];  if(self.RecoEquipsId[2]==-1)then   self.RecoIcons[2]:SetActive(false) else self.RecoIcons[2]:SetActive(true)  end
          self.RecoEquipsId[3]=v.BattleEquips[3];  if(self.RecoEquipsId[3]==-1)then   self.RecoIcons[3]:SetActive(false) else self.RecoIcons[3]:SetActive(true)  end
          self.RecoEquipsId[4]=v.BattleEquips[4];  if(self.RecoEquipsId[4]==-1)then   self.RecoIcons[4]:SetActive(false) else self.RecoIcons[4]:SetActive(true)  end
          self.RecoEquipsId[5]=v.BattleEquips[5];  if(self.RecoEquipsId[5]==-1)then   self.RecoIcons[5]:SetActive(false) else self.RecoIcons[5]:SetActive(true)  end
          self.RecoEquipsId[6]=v.BattleEquips[6];  if(self.RecoEquipsId[6]==-1)then   self.RecoIcons[6]:SetActive(false) else self.RecoIcons[6]:SetActive(true)  end
        ----Debugger.LogError(v.Id  .. "Template:" .. v.BattleEquips[1] .. ":" .. v.BattleEquips[2] .. ":" .. v.BattleEquips[3] .. ":" .. v.BattleEquips[4] .. ":" ..              v.BattleEquips[5] .. ":" .. v.BattleEquips[6])
        
         
           --Debugger.LogError("SetEVENT");
           self:SetIconEvent(1,v.BattleEquips[1]) 
           self:SetIconEvent(2,v.BattleEquips[2]) 
           self:SetIconEvent(3,v.BattleEquips[3]) 
           self:SetIconEvent(4,v.BattleEquips[4]) 
           self:SetIconEvent(5,v.BattleEquips[5]) 
           self:SetIconEvent(6,v.BattleEquips[6]) 
            
            
        break;
      end
    end
  
  ----------------------------------------------------------- 
  self.TipText="成功恢复默认配置"
  self:MyRequest() 
end
--------------------------选择大神搭配装备------------------------
function PreviewEquipAPI:GetGodEquipment(equipIds)

    
         
    self.RecoEquipsId[1]=equipIds[1];  if(self.RecoEquipsId[1]==-1)then   self.RecoIcons[1]:SetActive(false) else self.RecoIcons[1]:SetActive(true)  end
    self.RecoEquipsId[2]=equipIds[2];  if(self.RecoEquipsId[2]==-1)then   self.RecoIcons[2]:SetActive(false) else self.RecoIcons[2]:SetActive(true)  end
    self.RecoEquipsId[3]=equipIds[3];  if(self.RecoEquipsId[3]==-1)then   self.RecoIcons[3]:SetActive(false) else self.RecoIcons[3]:SetActive(true)  end
    self.RecoEquipsId[4]=equipIds[4];  if(self.RecoEquipsId[4]==-1)then   self.RecoIcons[4]:SetActive(false) else self.RecoIcons[4]:SetActive(true)  end
    self.RecoEquipsId[5]=equipIds[5];  if(self.RecoEquipsId[5]==-1)then   self.RecoIcons[5]:SetActive(false) else self.RecoIcons[5]:SetActive(true)  end
    self.RecoEquipsId[6]=equipIds[6];  if(self.RecoEquipsId[6]==-1)then   self.RecoIcons[6]:SetActive(false) else self.RecoIcons[6]:SetActive(true)  end
    ------Debugger.LogError(v.Id  .. "Template:" .. v.BattleEquips[1] .. ":" .. v.BattleEquips[2] .. ":" .. v.BattleEquips[3] .. ":" .. v.BattleEquips[4] .. ":" ..              v.BattleEquips[5] .. ":" .. v.BattleEquips[6])

    --Debugger.LogError("SetEVENT");
    self:SetIconEvent(1,self.RecoEquipsId[1]) 
    self:SetIconEvent(2,self.RecoEquipsId[2]) 
    self:SetIconEvent(3,self.RecoEquipsId[3]) 
    self:SetIconEvent(4,self.RecoEquipsId[4]) 
    self:SetIconEvent(5,self.RecoEquipsId[5]) 
    self:SetIconEvent(6,self.RecoEquipsId[6]) 

  
  ----------------------------------------------------------- 
  self.TipText="成功修改为推荐搭配"
  self:MyRequest() 
end
-----------------------------------------------------------------------
--根据Id查找类型 生成对应类型列表 执行UIClick事件
function PreviewEquipAPI:Execute(m,equipId)    
 
              for i1,v1 in pairs(self.tableCopyMall) do
                
                if(equipId==v1.EquipId)then
                   --Debugger.LogError("EXECUTE")
                  if(v1.Type==1)then
                    self:OnType1ButtonClick() 
                    self.Type1Button:GetComponent("UnityEngine.UI.Toggle").isOn =true
                    for i2,v2 in pairs(self.Type1QualityX3) do
                      for i3,v3 in pairs(v2) do 
                        if(v3.EquipId==equipId)then
                          local uiClick=UITools.GetLuaScript(v3.GO,"Logic.UICommon.UIClick");  
                          uiClick:ExecuteClickDelegate()--强制执行委托方法
                          break
                        end
                      end
                    end
                  elseif(v1.Type==2)then
                    self:OnType2ButtonClick() 
                    self.Type2Button:GetComponent("UnityEngine.UI.Toggle").isOn =true
                    for i2,v2 in pairs(self.Type2QualityX3) do
                      for i3,v3 in pairs(v2) do  
                        if(v3.EquipId==equipId)then 
                          local uiClick=UITools.GetLuaScript(v3.GO,"Logic.UICommon.UIClick");  
                          uiClick:ExecuteClickDelegate()--强制执行委托方法
                          break
                        end
                      end
                    end
                  elseif(v1.Type==3)then
                    self:OnType3ButtonClick() 
                    self.Type3Button:GetComponent("UnityEngine.UI.Toggle").isOn =true
                    for i2,v2 in pairs(self.Type3QualityX3) do
                      for i3,v3 in pairs(v2) do 
                        if(v3.EquipId==equipId)then 
                          local uiClick=UITools.GetLuaScript(v3.GO,"Logic.UICommon.UIClick");  
                          uiClick:ExecuteClickDelegate()--强制执行委托方法
                          break
                        end
                      end
                    end
                  elseif(v1.Type==4)then
                    self:OnType4ButtonClick() 
                    self.Type4Button:GetComponent("UnityEngine.UI.Toggle").isOn =true
                    for i2,v2 in pairs(self.Type4QualityX3) do
                      for i3,v3 in pairs(v2) do 
                        if(v3.EquipId==equipId)then 
                          local uiClick=UITools.GetLuaScript(v3.GO,"Logic.UICommon.UIClick");  
                          uiClick:ExecuteClickDelegate()--强制执行委托方法
                          break
                        end
                      end
                    end
                  elseif(v1.Type==5)then
                    self:OnType5ButtonClick() 
                    self.Type5Button:GetComponent("UnityEngine.UI.Toggle").isOn =true
                    for i2,v2 in pairs(self.Type5QualityX3) do
                      for i3,v3 in pairs(v2) do 
                        if(v3.EquipId==equipId)then 
                          local uiClick=UITools.GetLuaScript(v3.GO,"Logic.UICommon.UIClick");  
                          uiClick:ExecuteClickDelegate()--强制执行委托方法
                          break
                        end
                      end
                    end
                  end
                  break;
                  
                end 
              end
end
-----------------------------------------------------------------------
function PreviewEquipAPI:MyRequest() 
  
  --self.RecoEquipsId= UITools.CopyTab(self.tempRecoEquipsId);    --Debugger.LogError("临时赋值给装备数组")
   
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestSaveEquipConfig"),
                                  JProperty.New("RoleId",self.selectedHeroId),
                                  JProperty.New("EquipIds",json.encode(self.RecoEquipsId))
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
  --Debugger.LogError("发送REQUEST：") 
  --Debugger.LogError("RoleId:" .. self.selectedHeroId) 

  --Debugger.LogError("EquipIds:" .. self.RecoEquipsId[1]) 
  --Debugger.LogError("EquipIds:" .. self.RecoEquipsId[2]) 
  --Debugger.LogError("EquipIds:" .. self.RecoEquipsId[3]) 
  --Debugger.LogError("EquipIds:" .. self.RecoEquipsId[4]) 
  --Debugger.LogError("EquipIds:" .. self.RecoEquipsId[5]) 
  --Debugger.LogError("EquipIds:" .. self.RecoEquipsId[6]) 
end
-------------------------------------------------------------------
function PreviewEquipAPI:ResponseHandler(e)
  --Debugger.LogError("进入回调");
  if e.Type == "RequestSaveEquipConfig" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data["Result"]==0)then
     
      --Debugger.LogError("失败");
    end
    if(data["Result"]==1)then
      GameManager.CreatePanel("SelfHideNotice") 
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice(self.TipText)
      
      --Debugger.LogError("成功");
    end

    return true;
  else
    return false;
  end

end

----------------------------------------------------------------------
function PreviewEquipAPI:GoToPanel(stringPanel,boolDestoySelf,func)  --panel名称，是否销毁当前界面
  coroutine.start( PreviewEquipAPI.WaitForCreatePanel,self,stringPanel,boolDestoySelf,func)
end

function PreviewEquipAPI:WaitForCreatePanel(stringPanel,boolDestoySelf,func)
  
  local async = GameManager.CreatePanelAsync (stringPanel)
  while async.Done == false do
    coroutine.wait(0.05)
  end
  if(boolDestoySelf)then
  Object.Destroy(self.this.gameObject)
  end
  if(func==1)then
    BattleRecommendEquipAPI.Instance:SetParamBy73(self.selectedHeroId) --把角色Id传给大神搭配界面
  elseif(func==2)then
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请选择装备进行填入")
  elseif(func==3)then
    EquipInsideAPI.Instance:Init(self.selectedEquipId);
  elseif(func==4)then
    if BattleMallSelectHeroAPI~=nil and BattleMallSelectHeroAPI.Instance~=nil then 
      BattleMallSelectHeroAPI.Instance:GetEquip()
    end
  end
  
end


---------------------------------------API-------------------------------
function PreviewEquipAPI:SetParamBy74(EquipIds) --点击大神搭配上的确定要调用的方法
  local equipIds=UITools.CopyTab(EquipIds)  
  self.RecoEquipsId=equipIds;
  self:GetGodEquipment(equipIds);
end
----------------------------------------------------------------------
function PreviewEquipAPI:OnGodButtonClick()
  self:GoToPanel("BattleRecommendEquip",false,1)
end
----------------------------------------------------------------------
function PreviewEquipAPI:OnReplaceRoleButtonClick()
  self:GoToPanel("BattleMallSelectHero",false,4)
end
----------------------------------------------------------------------
function PreviewEquipAPI:SetRoleIdBySelectHero(roleId) --把角色Id传给大神搭配界面
  for k,v in pairs(UTGData.Instance().RolesData) do
    if(roleId==v.Id)then
      for k2,v2 in pairs(UTGData.Instance().SkinsData) do
        if(v.Skin==v2.Id )then
          self.selectedIcon.sprite= UITools.GetSprite("roleicon",v2.Icon);
          break;
        end
      end
      break;
    end
  end
  self.selectedHeroId=roleId;
  self:GetRecommendedEquipment()
end
----------------------------------------------------------------------
function PreviewEquipAPI:EquipInsideButtonClick() 
    self:GoToPanel("EquipInside",false,3)
end
























