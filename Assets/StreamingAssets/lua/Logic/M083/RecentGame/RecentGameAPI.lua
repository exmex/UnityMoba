require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
class("RecentGameAPI")
----------------------------------------------------
function RecentGameAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  RecentGameAPI.Instance=self;
  -------------------------------------
  
  
end
function RecentGameAPI:Start()
	local listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("ButtonReturn").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    	function ()
    	  Object.Destroy(self.this.gameObject);
    	end,self
    	)
	
end
----------------------------------------------------
function RecentGameAPI:Init(tablePvpBattleClientLog)
  if(tablePvpBattleClientLog==nil)then return end
  self.ownPlayerId = UTGData.Instance().PlayerData.Id
  self.ItemList=UITools.GetLuaScript(self.this.transform:FindChild("ScrollView/Viewport/Content").gameObject,"Logic.UICommon.UIItems")
  self.ItemList:ResetItemsSimple(#tablePvpBattleClientLog);
  self.tableSelfRecentGame={};	--提取自身的PvpBattleMemberData 
  self.tableBattleIsWin={};     --每局中是否胜利
  for k,v in pairs(tablePvpBattleClientLog) do
  	local selfZY;
  	for k1,v1 in pairs(v.TeamA) do
  	  if(v1.PlayerId==self.ownPlayerId)then
        table.insert(self.tableSelfRecentGame,v1)
        selfZY=1;
  	  end
  	end
  	for k2,v2 in pairs(v.TeamB) do
  	  if(v2.PlayerId==self.ownPlayerId)then
        table.insert(self.tableSelfRecentGame,v2)
        selfZY=2;
  	  end
  	end
    if(selfZY==v.Winner)then
      table.insert(self.tableBattleIsWin,true)
    else
      table.insert(self.tableBattleIsWin,false)
    end
  end

  for k3,v3 in pairs(self.tableSelfRecentGame) do 

  	self.ItemList.itemList[k3].transform:FindChild("Icon/IconMask/Icon"):GetComponent("UnityEngine.UI.Image").sprite=
  	UITools.GetSprite("roleicon",UTGData.Instance().SkinsData[ tostring(UTGData.Instance().RolesData[tostring(v3.RoleId)].Skin) ].Icon);
  	if(self.tableBattleIsWin[k3]==true)then
  	  self.ItemList.itemList[k3].transform:FindChild("TextVictory").gameObject:SetActive(true)
  	else
  	  self.ItemList.itemList[k3].transform:FindChild("TextDefeated").gameObject:SetActive(true)
  	end
  	local pattern_go = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"--"2016-04-27T20:32:22+08:00",
  	
  	local year_go, month_go, day_go, hour_go, minute_go, seconds_go = tostring(tablePvpBattleClientLog[k3].Start):match(pattern_go)
  	self.ItemList.itemList[k3].transform:FindChild("TextTime"):GetComponent("UnityEngine.UI.Text").text=month_go .. "月" .. day_go .. "日  " .. hour_go .. ":" .. minute_go;
  	self.ItemList.itemList[k3].transform:FindChild("TextA"):GetComponent("UnityEngine.UI.Text").text=v3.RoleKill       
  	self.ItemList.itemList[k3].transform:FindChild("TextB"):GetComponent("UnityEngine.UI.Text").text=v3.Death                 
  	self.ItemList.itemList[k3].transform:FindChild("TextC"):GetComponent("UnityEngine.UI.Text").text=v3.Assistance   
    

    local equip=self.ItemList.itemList[k3].transform:FindChild("Equips");
    

	for k4,v4 in pairs(v3.BattleEquips) do 
		
		  equip:GetChild(k4-1).gameObject:SetActive(true);
		  equip:GetChild(k4-1):FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("equipicon",UTGData.Instance().EquipsData[tostring(v4)].Icon) 
	    
	end

  end

end
----------------------------------------------------
function RecentGameAPI:OnDestroy() 
  
  
  ------------------------------------
  RecentGameAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end