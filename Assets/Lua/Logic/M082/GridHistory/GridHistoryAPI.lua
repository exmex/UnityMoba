require "Logic.UICommon.Static.UITools"
local json = require "cjson"

class("GridHistoryAPI")
----------------------------------------------------
function GridHistoryAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  GridHistoryAPI.Instance=self;
  -------------------------------------
  
  
end
----------------------------------------------------
function GridHistoryAPI:Start()
  local listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("ButtonReturn").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        Object.Destroy(self.this.gameObject);
      end,self
      )

  self.ItemList=UITools.GetLuaScript(self.this.transform:FindChild("ScrollView/Viewport/Content").gameObject,"Logic.UICommon.UIItems")
  local seasonDeck=UTGData.Instance().PlayerSeasonDeck   --PlayerSeason 
  local gradesData=UTGData.Instance().GradesData         --TemplateGradeAttrs 
  local seasonsData=UTGData.Instance().SeasonsData       --TemplateGradeSeason 
  

  local seasonDeckTemp={};
  for k,v in pairs(seasonDeck) do
    table.insert(seasonDeckTemp,v);
  end 
  table.sort(seasonDeckTemp,function(a,b) return tonumber(a.SeasonId)<tonumber(b.SeasonId) end )--按Id排序
  seasonDeck=seasonDeckTemp;
  
  local lenth=0;
  for k,v in pairs(seasonDeck) do
    lenth=lenth+1;
  end 
  self.ItemList:ResetItemsSimple(lenth); 
  local index=0;
  for k,v in pairs(seasonDeck) do 
    index= index+1;
    --Debugger.LogError(v.SeasonId)
    self.ItemList.itemList[index].transform:FindChild("BgSmall/TextTime"):GetComponent("UnityEngine.UI.Text").text=
    "(" .. seasonsData[tostring(v.SeasonId)].Name.. ") " .. seasonsData[tostring(v.SeasonId)].From .. "~" .. seasonsData[tostring(v.SeasonId)].To;
    self.ItemList.itemList[index].transform:FindChild("BgBig/TextTime"):GetComponent("UnityEngine.UI.Text").text=
    "(" .. seasonsData[tostring(v.SeasonId)].Name.. ") " .. seasonsData[tostring(v.SeasonId)].From .. "~" .. seasonsData[tostring(v.SeasonId)].To;
    if(v.Grade==0)then
      self.ItemList.itemList[index].transform:FindChild("BgSmall/TextDan"):GetComponent("UnityEngine.UI.Text").text="";
      self.ItemList.itemList[index].transform:FindChild("BgBig/TextDan"):GetComponent("UnityEngine.UI.Text").text="";
    else
      self.ItemList.itemList[index].transform:FindChild("BgSmall/TextDan"):GetComponent("UnityEngine.UI.Text").text=gradesData[tostring(v.Grade)].Title;
      self.ItemList.itemList[index].transform:FindChild("BgBig/TextDan"):GetComponent("UnityEngine.UI.Text").text=gradesData[tostring(v.Grade)].Title;
    end
    local textHeros="";  
    
    for k1,v1 in pairs(v.UsualRoles) do
      textHeros=textHeros .. UTGData.Instance().RolesData[tostring(v1.RoleId)].Name .. " ";
    end

    local tableHero={};
    table.insert( tableHero, self.ItemList.itemList[index].transform:FindChild("BgBig/Heros/Hero1").gameObject )
    table.insert( tableHero, self.ItemList.itemList[index].transform:FindChild("BgBig/Heros/Hero2").gameObject )
    table.insert( tableHero, self.ItemList.itemList[index].transform:FindChild("BgBig/Heros/Hero3").gameObject )
    table.insert( tableHero, self.ItemList.itemList[index].transform:FindChild("BgBig/Heros/Hero4").gameObject )
    for k2,v2 in pairs(tableHero) do
      if(v.UsualRoles[k2]~=nil)then
        tableHero[k2]:SetActive(true);
        tableHero[k2].transform:FindChild("TextAmountVictory"):GetComponent("UnityEngine.UI.Text").text=v.UsualRoles[k2].WinnerCount 
        tableHero[k2].transform:FindChild("TextAmountBattle"):GetComponent("UnityEngine.UI.Text").text=v.UsualRoles[k2].BattleCount

        tableHero[k2].transform:FindChild("Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("roleicon", UTGData.Instance().SkinsData[ tostring(UTGData.Instance().RolesData[tostring(v.UsualRoles[k2].RoleId)].Skin) ].Icon);
     
      else
        tableHero[k2]:SetActive(false);
      end
    end

    self.ItemList.itemList[index].transform:FindChild("BgSmall/TextHero"):GetComponent("UnityEngine.UI.Text").text=textHeros
    --seasonsData[tostring(v.SeasonId)]
    --gradesData[tostring(v.Grade)].Title
    self.ItemList.itemList[index].transform:FindChild("BgBig/TextHero"):GetComponent("UnityEngine.UI.Text").text=textHeros
    self.ItemList.itemList[index].transform:FindChild("BgBig/TextAmountBattle"):GetComponent("UnityEngine.UI.Text").text=v.BattleCount
    self.ItemList.itemList[index].transform:FindChild("BgBig/TextAmountVictory"):GetComponent("UnityEngine.UI.Text").text=v.WinnerCount    
    if(v.BattleCount==0)then
      self.ItemList.itemList[index].transform:FindChild("BgBig/TextWinningProbability"):GetComponent("UnityEngine.UI.Text").text="0.00%";
    else
      self.ItemList.itemList[index].transform:FindChild("BgBig/TextWinningProbability"):GetComponent("UnityEngine.UI.Text").text=math.ceil(100*(v.WinnerCount/v.BattleCount)) .. "%";
    end
    self.ItemList.itemList[index].transform:FindChild("BgBig/TextWinningStreak"):GetComponent("UnityEngine.UI.Text").text=v.EverMaxWinning 
    
  end
end
----------------------------------------------------
function GridHistoryAPI:OnDestroy() 
  
  
  ------------------------------------
  GridHistoryAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end