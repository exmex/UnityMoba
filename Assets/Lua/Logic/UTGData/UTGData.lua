require "System.Global"
require "Logic.UICommon.Static.UITools"

class("UTGData")

function UTGData.Instance()
  if UTGData.instance == nil then
    UTGData.instance = UTGData.New()
    
  end
  return UTGData.instance
end

local json = require "cjson"

--公共变量 用于查看 .Instance().xxx 访问
UTGData.LoginServerIp = "127.0.0.1"
UTGData.LoginServerPort = 25001


--数据是否加载完毕
UTGData.LoadTemplate = false
UTGData.LoadPlayerDeck = false
UTGData.LoadConfig = false
UTGData.LoadFriendList = false


function UTGData:Test()
  
  --self.AccountId = nil
  
end


--**************
--获取Server信息
--**************
function UTGData:UTGServerList()
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestServerList"))
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(UTGData.UTGServerListHandler,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

function UTGData:UTGServerListHandler(e)
  if e.Type == "RequestServerList" then
    local servers = json.decode(e.Content:get_Item("Servers"):ToString())
    self.Servers = {}
    for k,v in pairs(servers) do
      self.Servers[tostring(servers[k].Id)] = servers[k]
    end
    return true
  end
  return false
end



--*****************
--获取服务器版本号
--*****************
function UTGData:GetResourceVersion()
  -- body
  local versionRequest = NetRequest.New()
  versionRequest.Content = JObject.New(JProperty.New("Type","RequestVersion"))
  versionRequest.Handler = TGNetService.NetEventHanlderSelf(UTGData.VersionHandler,self)
  TGNetService.GetInstance():SendRequest(versionRequest)  
end

function UTGData:VersionHandler(e)
  -- body
  if e.Type == "RequestVersion" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local serverVersion = tostring(e.Content:get_Item("DataVersion"):ToString())
      --print("serverVersion " .. serverVersion)
      local path = NTGResourceController.GetDataPath("GlobalData")
      local temp = e.Content:ToString()
      local LocalE = ""
      if Directory.Exists(path) and File.Exists(path .. "VersionData.ini") then
        Version = json.decode(NTGResourceController.ReadAllText(path .. "VersionData.ini"))
        local localVersion = Version.DataVersion
        --print("localVersion " .. localVersion)
        if localVersion == serverVersion then
          self:GetTemplateFromLocal()
          UTGData.LoadTemplate = true
        else
          self:UTGDataTemplate()
        end
      else
        self:UTGDataTemplate()
      end
      NTGResourceController.WriteAllText(path.."VersionData.ini",temp)
    end
    return true
  end
  return false
end




--*****************
--获取Template信息
--*****************
function UTGData:UTGDataTemplate()
  UTGData.LoadTemplate = false
  local templateRequest = NetRequest.New()
  templateRequest.Content = JObject.New(JProperty.New("Type","RequestTemplate"),
                                        JProperty.New("Category",0xffffffffffff))
  templateRequest.Handler = TGNetService.NetEventHanlderSelf(UTGData.UTGDataTemplateHandler,self)
  TGNetService.GetInstance():SendRequest(templateRequest)
end

function UTGData:UTGDataTemplateHandler(e)
  if e.Type == "RequestTemplate" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())


    ----Debugger.LogString(e.Content:ToString())

    local path = NTGResourceController.GetDataPath("GlobalData")
    local LocalE = e.Content:ToString()
    if Directory.Exists(path) and File.Exists(path .. "CacheData.ini") then
      NTGResourceController.WriteAllText(path.."CacheData.ini",LocalE)
    elseif  Directory.Exists(path) and File.Exists(path .. "CacheData.ini") == false then
      --Directory.CreateDirectory(path)
      NTGResourceController.WriteAllText(path.."CacheData.ini",LocalE)
    end

    
    if result == 1 then
      --角色template信息

      local roles = json.decode(e.Content:get_Item("Roles"):ToString())
      self.RolesData = {}
      if roles ~= nil then
             
        for k,v in pairs(roles) do
          self.RolesData[tostring(roles[k].Id)] = v
        end
      end
      --角色熟练度信息
      local roleProficiencys = json.decode(e.Content:get_Item("RoleProficiencys"):ToString())
      self.RoleProficiencysData = {}
      if roleProficiencys ~= nil then
        for k,v in pairs(roleProficiencys) do
          self.RoleProficiencysData[tostring(roleProficiencys[k].Id)] = v
        end
      end
      --装备信息
      local equips = json.decode(e.Content:get_Item("Equips"):ToString())
      self.EquipsData = {}
      if equips ~= nil then
        for k,v in pairs(equips) do
          self.EquipsData[tostring(equips[k].Id)] = v
          local Attr = {}
          local name = {}
          local value = {}
          for m,n in pairs(equips[k]) do
            if m == "HP" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "MP" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "PAtk" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "MAtk" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "PDef" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "MDef" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "MoveSpeed" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "PpenetrateValue" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "PpenetrateRate" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "MpenetrateValue" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "MpenetrateRate" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "AtkSpeed" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "CritRate" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "CritEffect" then
              table.insert(name,m)
              table.insert(value,n)
            elseif m == "PHpSteal" then
              table.insert(name,m)
              table.insert(value,n) 
            elseif m == "MHpSteal" then
              table.insert(name,m)
              table.insert(value,n) 
            elseif m == "CdReduce" then
              table.insert(name,m)
              table.insert(value,n) 
            elseif m == "Tough" then
              table.insert(name,m)
              table.insert(value,n) 
            elseif m == "HpRecover5s" then
              table.insert(name,m)
              table.insert(value,n) 
            elseif m == "MpRecover5s" then
              table.insert(name,m)
              table.insert(value,n)      
            end
          end
          for i = 1,#name do
            Attr[name[i]] = value[i]
          end
          self.EquipsData[tostring(equips[k].Id)]["Attr"] = Attr
        end



      end
      --物品信息
      local items = json.decode(e.Content:get_Item("Items"):ToString())
      self.ItemsData = {}
      if items ~= nil then
        for k,v in pairs(items) do
          self.ItemsData[tostring(items[k].Id)] = v
          if v.Type == 9 then 
            UTGDataTemporary.Instance().BigHornItemId = v.Id
          end
          if v.Type == 10 then 
            UTGDataTemporary.Instance().SmallHornItemId = v.Id  
          end
        end
      end
      --技能信息
      local skills = json.decode(e.Content:get_Item("Skills"):ToString())
      self.SkillsData = {}
      if skills ~= nil then
        for k,v in pairs(skills) do
          self.SkillsData[tostring(skills[k].Id)] = v
        end
      end
      --技能表现信息
      local skillBehaviours = json.decode(e.Content:get_Item("SkillBehaviours"):ToString())
      self.SkillBehavioursData = {}
      if skillBehaviours ~= nil then
        for k,v in pairs(skillBehaviours) do
          self.SkillBehavioursData[tostring(skillBehaviours[k].Id)] = v
        end
      end

      --芯片信息
      local runes = json.decode(e.Content:get_Item("Runes"):ToString())
      self.RunesData = {}
      if runes ~= nil then
        for k,v in pairs(runes) do
          self.RunesData[tostring(runes[k].Id)] = v
        end
      end
      --芯片组信息
      local runePages = json.decode(e.Content:get_Item("RunePages"):ToString())
      self.RunePagesData = {}
      if runePages ~= nil then
        for k,v in pairs(runePages) do
          self.RunePagesData[tostring(runePages[k].Id)] = v
        end
      end
      --芯片槽信息
      local runeSlots = json.decode(e.Content:get_Item("RuneSlots"):ToString())
      self.RuneSlotsData = {}
      if runeSlots ~= nil then
        for k,v in pairs(runeSlots) do
          self.RuneSlotsData[tostring(runeSlots[k].Id)] = v
        end
      end
      --章节信息
      local dramas = json.decode(e.Content:get_Item("Dramas"):ToString())
      self.DramasData = {}
      if dramas ~= nil then
        for k,v in pairs(dramas) do
          self.DramasData[tostring(dramas[k].Id)] = v
        end
      end
      --皮肤信息
      local skins = json.decode(e.Content:get_Item("Skins"):ToString())
      self.SkinsData = {}
      if skins ~= nil then
        for k,v in pairs(skins) do
          self.SkinsData[tostring(skins[k].Id)] = v
        end
      end
      --外部商城信息
      local shops = json.decode(e.Content:get_Item("Shops"):ToString())
      self.ShopsData = {}
      self.ShopsDataById = {}
      self.ShopsHeroData = {}
      self.ShopsSkinData = {}
      self.ShopsSaleData = {}
      if shops ~= nil then
        for k,v in pairs(shops) do
          if self.ShopsData[tostring(shops[k].CommodityId)] == nil then
            self.ShopsData[tostring(shops[k].CommodityId)] = {}
            table.insert(self.ShopsData[tostring(shops[k].CommodityId)],v)
          else
            table.insert(self.ShopsData[tostring(shops[k].CommodityId)],v)
          end
          self.ShopsDataById[tostring(shops[k].Id)] = v

          if shops[k].Category == 1 then
            table.insert(self.ShopsHeroData,v)
          elseif shops[k].Category == 2 then
            table.insert(self.ShopsSkinData,v)
          elseif shops[k].Category == 3 then
            table.insert(self.ShopsSaleData,v)
          end
        end
      end

      local partShops = json.decode(e.Content:get_Item("PartShops"):ToString())
      self.PartShopsData = {}
      self.PartShopsDataForOrder  = partShops
      if partShops ~= nil then
        for k,v in pairs(partShops) do
          self.PartShopsData[tostring(partShops[k].CommodityId)] = v
        end
      end

      local shopNews = json.decode(e.Content:get_Item("ShopNews"):ToString())
      self.ShopNewsData = {}
      if shopNews ~= nil then
        for k,v in pairs(shopNews) do
          self.ShopNewsData[tostring(shopNews[k].Id)] = v
        end
      end      

      local shopHots = json.decode(e.Content:get_Item("ShopHots"):ToString())
      self.ShopHotsData = {}
      if shopHots ~= nil then
        for k,v in pairs(shopHots) do
          self.ShopHotsData[tostring(shopHots[k].Id)] = v
        end
      end

      local shopPosts = json.decode(e.Content:get_Item("ShopPosts"):ToString())
      self.ShopPostsData = {}
      if shopPosts ~= nil then
        for k,v in pairs(shopPosts) do
          self.ShopPostsData[tostring(shopPosts[k].Id)] = v
        end
      end

      local shopDepreciations = json.decode(e.Content:get_Item("ShopDepreciations"):ToString())
      self.ShopDepreciationsData = {}
      if shopDepreciations ~= nil then
        for k,v in pairs(shopDepreciations) do
          self.ShopDepreciationsData[tostring(shopDepreciations[k].Id)] = v
        end
      end

      local shopTreasures = json.decode(e.Content:get_Item("ShopTreasures"):ToString())
      self.ShopTreasuresData = {}
      self.ShopTreasuresDataForOrder = {}
      self.ShopTreasuresDataForOrder = shopTreasures
      if shopTreasures ~= nil then
        for k,v in pairs(shopTreasures) do
          self.ShopTreasuresData[tostring(shopTreasures[k].Id)] = v
        end
      end

      local shopTreasureChests = json.decode(e.Content:get_Item("ShopTreasureChests"):ToString())
      self.ShopTreasureChestsData = {}
      if shopTreasureChests ~= nil then
        for k,v in pairs(shopTreasureChests) do
          self.ShopTreasureChestsData[tostring(shopTreasureChests[k].Id)] = v
        end
      end

      --小怪属性信息
      local creatures = json.decode(e.Content:get_Item("Creatures"):ToString())
      self.CreaturesData = {}
      if creatures ~= nil then
        for k,v in pairs(creatures) do
          self.CreaturesData[tostring(creatures[k].Id)] = v
        end
      end
      --小怪群组信息
      local creatureGroups = json.decode(e.Content:get_Item("CreatureGroups"):ToString())
      self.CreatureGroupsData = {}
      if creatureGroups ~= nil then
        for k,v in pairs(creatureGroups) do
          self.CreatureGroupsData[tostring(creatureGroups[k].Id)] = v
        end
      end
      --PVP等级信息
      local pvpLevels = json.decode(e.Content:get_Item("PVPLevels"):ToString())
      self.PVPLevelsData = {}
      if pvpLevels ~= nil then
        for k,v in pairs(pvpLevels) do
          self.PVPLevelsData[tostring(pvpLevels[k].Id)] = v
        end
      end
      --PVP升级信息
      local pvpLevelUps = json.decode(e.Content:get_Item("PVPLevelUps"):ToString())
      self.PVPLevelUpsData = {}
      local count = 0
      if pvpLevelUps ~= nil then
        for k,v in pairs(pvpLevelUps) do
          if v.Type > count then
            count = v.Type
          end
        end

        for i = 1,count do
          self.PVPLevelUpsData[tostring(i)] = {}
        end

        for k,v in pairs(pvpLevelUps) do
          self.PVPLevelUpsData[tostring(v.Type)][tostring(v.Level)] = v
        end

      end

      --PVP物品商店信息
      local pvpMalls = json.decode(e.Content:get_Item("PVPMalls"):ToString())
      self.PVPMallsData = {}
      if pvpMalls ~= nil then
        for k,v in pairs(pvpMalls) do
          self.PVPMallsData[tostring(pvpMalls[k].EquipId)] = v
        end
      end
      --角色成长信息
      local pvpRoleGrows = json.decode(e.Content:get_Item("PVPRoleGrows"):ToString())
      self.PVPRoleGrowsData = {}
      if pvpRoleGrows ~= nil then
        for k,v in pairs(pvpRoleGrows) do
          self.PVPRoleGrowsData[tostring(pvpRoleGrows[k].RoleId)] = v
        end
      end       

      --Source信息
      local source = json.decode(e.Content:get_Item("Source"):ToString())
      self.SourcesData = {}
      if source ~= nil then
        for k,v in pairs(source) do
          self.SourcesData[tostring(source[k].Id)] = v

        end
      end
      --PlayerSkill信息
      local playerskill = json.decode(e.Content:get_Item("PlayerSkills"):ToString())
      self.PlayerSkillData = {}
      if playerskill ~= nil then
        for k,v in pairs(playerskill) do
          self.PlayerSkillData[tostring(playerskill[k].Id)] = v
        end
      end
      --GodEquipConfigs信息
      local godequipconfigs = json.decode(e.Content:get_Item("GodEquipConfigs"):ToString())
      self.GodEquipConfigsData = {}
      if godequipconfigs ~= nil then
        for k,v in pairs(godequipconfigs) do
          self.GodEquipConfigsData[tostring(godequipconfigs[k].Id)] = v
        end
      end
      --PVP击杀目标会获得金币奖励
      local pvpKillStreak = json.decode(e.Content:get_Item("PVPKillStreak"):ToString())
      self.PVPKillStreaksData = {}
      if pvpKillStreak ~= nil then
        for k,v in pairs(pvpKillStreak) do
          self.PVPKillStreaksData[tostring(pvpKillStreak[k].Kill)] = pvpKillStreak[k]
        end
      end
      --玩家升级规则
      local playerLevelUp = json.decode(e.Content:get_Item("PlayerLevelUps"):ToString())
      self.PlayerLevelUpData = {}
      if playerLevelUp ~= nil then
        for k,v in pairs(playerLevelUp) do
          self.PlayerLevelUpData[tostring(playerLevelUp[k].Level)] = playerLevelUp[k]
        end
      end

      local grades = json.decode(e.Content:get_Item("Grades"):ToString())
      self.GradesData = {}
      if grades ~= nil then
        for k,v in pairs(grades) do
          self.GradesData[tostring(grades[k].Grade)] = grades[k]
        end
      end

      local seasons = json.decode(e.Content:get_Item("Seasons"):ToString())
      self.SeasonsData = {}
      if seasons ~= nil then
        for k,v in pairs(seasons) do
          self.SeasonsData[tostring(seasons[k].Id)] = seasons[k]
        end
      end
      
      --print(roles)
      --快捷信息
      local quickmes = json.decode(e.Content:get_Item("QuickMessages"):ToString())
      self.QuickMessagesData = {}
      if quickmes ~= nil then
        for k,v in pairs(quickmes) do
          self.QuickMessagesData[tostring(v.Id)] = v
        end
      end

      local mailInfos = json.decode(e.Content:get_Item("MailInfos"):ToString())
      self.MailInfosData = {}
      if mailInfos ~= nil  then
        for k,v in pairs(mailInfos) do
          self.MailInfosData[tostring(v.Id)] = v
        end
      end

      local battleHonors = json.decode(e.Content:get_Item("BattleHonors"):ToString())
      self.BattleHonorsData = {}
      if battleHonors ~= nil then
        for k,v in pairs(battleHonors) do
          self.BattleHonorsData[tostring(battleHonors[k].Id)] = battleHonors[k]
        end
      end

      local growups = json.decode(e.Content:get_Item("GrowUps"):ToString())
      self.GrowUpsData = {}
      if growups ~= nil  then
        for k,v in pairs(growups) do
          self.GrowUpsData[tostring(v.Id)] = v
        end
      end
      
      local growupchests = json.decode(e.Content:get_Item("GrowUpChests"):ToString())
      self.GrowUpChestsData = {}
      if growupchests ~= nil  then
        for k,v in pairs(growupchests) do
          self.GrowUpChestsData[tostring(v.Id)] = v
        end
      end

      local avatarFrame = json.decode(e.Content:get_Item("AvatarFrames"):ToString())
      self.AvatarFramesData = {}
      if avatarFrame ~= nil then
        for k,v in pairs(avatarFrame) do
          self.AvatarFramesData[tostring(avatarFrame[k].Id)] = avatarFrame[k]
        end
      end
      
      --赏金
      local bounties = json.decode(e.Content:get_Item("Bounties"):ToString())
      self.BountiesData = {}
      if bounties ~= nil  then
        for k,v in pairs(bounties) do
          if v.Category == 1 then UTGDataTemporary.instance.BountyMatchCoinTemplateId = v.Id end
          self.BountiesData[tostring(v.Id)] = v
        end
      end
      --掉落包
      local dropGroups = json.decode(e.Content:get_Item("DropGroups"):ToString())
      self.DropGroupsData = {}
      if dropGroups ~= nil  then
        for k,v in pairs(dropGroups) do
          self.DropGroupsData[tostring(v.Id)] = v
        end
      end
      --娱乐模式
      local entModes = json.decode(e.Content:get_Item("EntModes"):ToString())
      self.EntModesData = {}
      if entModes ~= nil  then
        for k,v in pairs(entModes) do
          self.EntModesData[tostring(v.Id)] = v
        end
      end
      -------------------------------------------------------------------------战队Begin--WYL
      --战队图标--
      local guildIcons = json.decode(e.Content:get_Item("GuildIcons"):ToString())
    
      self.GuildIconsData = {}
      self.GuildIconsDataArray = {}
      if guildIcons ~= nil then
        for k,v in pairs(guildIcons) do
          self.GuildIconsData[tostring(guildIcons[k].Id)] = guildIcons[k]
          table.insert(self.GuildIconsDataArray,v) 
          
        end
      end
      --战队评级--
      local guildLevels = json.decode(e.Content:get_Item("GuildLevels"):ToString())
      self.GuildLevelsData = {}
      if guildLevels ~= nil then
        for k,v in pairs(guildLevels) do
          self.GuildLevelsData[tostring(guildLevels[k].Level)] = guildLevels[k]
        end
      end
      ----
      local guildMemberLimits = json.decode(e.Content:get_Item("GuildMemberLimits"):ToString())
      self.GuildMemberLimitsData = {}
      if guildMemberLimits ~= nil then
        for k,v in pairs(guildMemberLimits) do
          self.GuildMemberLimitsData[tostring(guildMemberLimits[k].Size)] = guildMemberLimits[k]
        end
      end
      --战队职务权限--
      local guildPermissions = json.decode(e.Content:get_Item("GuildPermissions"):ToString())
      self.GuildPermissionsData = {}
      if guildPermissions ~= nil then
        for k,v in pairs(guildPermissions) do
          self.GuildPermissionsData[tostring(guildPermissions[k].Level)] = guildPermissions[k]
        end
      end
      --商店刷新需要的开销--
      local guildShopRefreshs = json.decode(e.Content:get_Item("GuildShopRefreshs"):ToString())
      self.GuildShopRefreshsData = {}
      if guildShopRefreshs ~= nil then
        for k,v in pairs(guildShopRefreshs) do
          self.GuildShopRefreshsData[tostring(guildShopRefreshs[k].Id)] = guildShopRefreshs[k]
        end
      end
      --战队星级--
      local guildStarLevels = json.decode(e.Content:get_Item("GuildStarLevels"):ToString())
      self.GuildStarLevelsData = {}
      if guildStarLevels ~= nil then
        for k,v in pairs(guildStarLevels) do
          self.GuildStarLevelsData[tostring(guildStarLevels[k].Level)] = guildStarLevels[k]
        end
      end
      --战队周排行奖励--
      local guildWeeklyRank  = json.decode(e.Content:get_Item("GuildWeeklyRanks"):ToString())
      self.GuildWeeklyRankData = {}
      if guildWeeklyRank ~= nil then
        for k,v in pairs(guildWeeklyRank) do
          self.GuildWeeklyRankData[tostring(guildWeeklyRank[k].EndRank   )] = guildWeeklyRank[k]
        end
      end

      --战队商店
      local guildShopRefresh = json.decode(e.Content:get_Item("GuildShopRefreshs"):ToString())
      self.GuildShopRefreshData = {}
      if guildShopRefresh ~= nil then
        for k,v in pairs(guildShopRefresh) do
          self.GuildShopRefreshData[tostring(guildShopRefresh[k].Count)] = guildShopRefresh[k]
        end
      end
      -------------------------------------------------------------------------战队End--
      

      --成长相关-------------------------------------------------------
      --等级任务
      local LevelQuestServer  = json.decode(e.Content:get_Item("LevelQuests"):ToString())
      self.LevelQuestByLevel = {}
      self.LevelQuestById = {}
      if LevelQuestServer ~= nil then
        for k,v in pairs(LevelQuestServer) do
          if self.LevelQuestByLevel[tostring(v.Level)] == nil then
            self.LevelQuestByLevel[tostring(v.Level)] = {}
            table.insert(self.LevelQuestByLevel[tostring(v.Level)],v)
          else
            table.insert(self.LevelQuestByLevel[tostring(v.Level)],v)
          end

          self.LevelQuestById[tostring(v.Id)] = v
        end      
      end

      --解锁功能
      local LevelFuncServer  = json.decode(e.Content:get_Item("FuncLocks"):ToString())
      self.LevelFunc = {}
      if LevelFuncServer ~= nil then
        for k,v in pairs(LevelFuncServer) do
          if self.LevelFunc[tostring(v.UnlockLevel)] == nil then
            self.LevelFunc[tostring(v.UnlockLevel)] = {}
            table.insert(self.LevelFunc[tostring(v.UnlockLevel)],v)
          else
            table.insert(self.LevelFunc[tostring(v.UnlockLevel)],v)
          end
        end      
      end

      for k,v in pairs(self.LevelFunc) do
        for k1,v1 in pairs(v) do
          if(v1.Type==5)then
            wanna=v.UnlockLevel
          end
        end
      end

      --我要金币符文英雄
      local GrowUpGuides  = json.decode(e.Content:get_Item("GrowUpGuides"):ToString())
      self.GrowUpGuideGold = {}
      self.GrowUpGuideRune = {}
      self.GrowUpGuideHero = {}
      if GrowUpGuides ~= nil then
        for k,v in pairs(GrowUpGuides) do
          if (v.Category == 1) then
            table.insert(self.GrowUpGuideGold,v)
          elseif (v.Category == 2) then
            table.insert(self.GrowUpGuideRune,v)
          elseif (v.Category == 3) then
            table.insert(self.GrowUpGuideHero,v)
          end
        end      
      end
      --成长相关end----------------------------------------------------

      --成就相关------------------------------------------------------------------------------------------------
      --成就奖杯
      local Achievements  = json.decode(e.Content:get_Item("Achievements"):ToString())
      self.AchievementsById = {}
      self.AchievementsFirst = {}
      self.AchievementsByType = {}
      if Achievements ~= nil then
        for k,v in pairs(Achievements) do
          self.AchievementsById[tostring(v.Id)] = v
          if (v.Level == 1) then
            self.AchievementsFirst[tostring(v.Id)] = v
          end
          if (self.AchievementsByType[tostring(v.Type)] == nil ) then
            self.AchievementsByType[tostring(v.Type)] = {}
            self.AchievementsByType[tostring(v.Type)][tostring(v.Level)] = v
          else
            self.AchievementsByType[tostring(v.Type)][tostring(v.Level)] = v
          end
        end      
      end

      --成就奖励
      local AchievementLevelUps  = json.decode(e.Content:get_Item("AchievementLevelUps"):ToString())
      self.AchievementLevelUps = {}
      self.AchievementLevelUpsWithAward = {}
      if AchievementLevelUps ~= nil then
        for k,v in pairs(AchievementLevelUps) do
          self.AchievementLevelUps[tostring(v.Level)] = v
          if (v.Rewards ~= nil and #v.Rewards > 0) then
             self.AchievementLevelUpsWithAward[tostring(v.Level)] = v
          end
        end      
      end

      --成就Template相关end---------------------------------------------------------------------------------------------

      --公告相关Template---------------------------------------------------------------------------
      local Announcements  = json.decode(e.Content:get_Item("Announcements"):ToString())
      self.Announcements = {}
      if Announcements ~= nil then
        for k,v in pairs(Announcements) do
          self.Announcements[tostring(v.Id)] = v
        end      
      end
      --公告相关Template  end---------------------------------------------------------------------------

      --SignIns
      local signIns  = json.decode(e.Content:get_Item("SignIns"):ToString())
      self.SignInsData = {}
      if signIns ~= nil then
        for k,v in pairs(signIns) do
          self.SignInsData[tostring(v.Day)] = v
        end      
      end


      end
    UTGData.LoadTemplate = true
    
    return true
  end
  return false
end

--********************
--获取PlayerDetail信息
--********************
function UTGData:UTGPlayerDetail(networkDelegate,networkDelegateSelf,networkDelegate1,networkDelegateSelf1)
  self.pdnetworkDelegate = networkDelegate
  self.pdnetworkDelegateSelf = networkDelegateSelf
  self.pdnetworkDelegate1 = networkDelegate1
  self.pdnetworkDelegateSelf1 = networkDelegateSelf1
  
  local playerDetailRequest = NetRequest.New()
  playerDetailRequest.Content = JObject.New(JProperty.New("Type","RequestPlayerDetail"))
  playerDetailRequest.Handler = TGNetService.NetEventHanlderSelf(UTGData.UTGPlayerDetailHandler,self)
  TGNetService.GetInstance():SendRequest(playerDetailRequest)
end

function UTGData:UTGPlayerDetailHandler(e)
  if e.Type == "RequestPlayerDetail" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then




      local player = json.decode(e.Content:get_Item("Player"):ToString())
      if player ~= nil then
        self.PlayerData = player
      end
      
      if self.pdnetworkDelegate ~= nil and self.pdnetworkDelegateSelf~=nil then
        self.pdnetworkDelegate(self.pdnetworkDelegateSelf)
        --self.pdnetworkDelegateSelf:pdnetworkDelegate()
      end
    elseif result == 0x0100 then
      if self.pdnetworkDelegate1 ~= nil and self.pdnetworkDelegateSelf~=nil then
        self.pdnetworkDelegate1(self.pdnetworkDelegateSelf1)
        --self.pdnetworkDelegateSelf:pdnetworkDelegate()
      end
      
    end
    return true
  end
  return false
end

--**************
--获取Config信息
--**************
function UTGData:UTGDataGetConfig(networkDelegate,networkDelegateSelf)
  self.configNetworkDelegate = networkDelegate
  self.configNetworkDelegateSelf = networkDelegateSelf
  
  UTGData.LoadConfig = false
  local configRequest = NetRequest.New()
  configRequest.Content = JObject.New(JProperty.New("Type","RequestConfig"))
  configRequest.Handler = TGNetService.NetEventHanlderSelf( UTGData.UTGDataGetConfigHandler,self)
  TGNetService.GetInstance():SendRequest(configRequest)
end

function UTGData:UTGDataGetConfigHandler(e)
  if e.Type == "RequestConfig" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then



      local config = json.decode(e.Content:get_Item("ConfigMap"):ToString())
      self.ConfigData = {}
      if config ~= nil then
        for k,v in pairs(config) do
          self.ConfigData[config[k].Name] = config[k]
        end
      end
      
      UTGData.LoadConfig = true
      
      if self.configNetworkDelegate ~= nil then
        self.configNetworkDelegateSelf:configNetworkDelegate()
      end 
    end
    return true
  end
  return false
end



--***************************
--获取自己申请过的战队Id : WYL
--***************************

function UTGData:MyselfApplyingGuildsRequest()    

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestMyselfApplyingGuilds")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.MyselfApplyingGuildsResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end

function UTGData:MyselfApplyingGuildsResponseHandler(e)

  if e.Type == "RequestMyselfApplyingGuilds" then
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
    
      self.ApplyingGuilds ={}  --[]int --申请了哪些战队的ID列表
      for k,v in pairs(data.ApplyingGuilds) do
        self.ApplyingGuilds[tostring(v)]=v
      end

    end

    return true;
  else
    return false;
  end

end
--***************************
--获取自己战队信息 : WYL (如果已经加入战队，没有加入第一次会Notify给GuildAPI)
--***************************
function UTGData:MyselfGuildDetailRequest()

  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestMyselfGuildDetail")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.MyselfGuildDetailResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end

function UTGData:MyselfGuildDetailResponseHandler(e)

  if e.Type == "RequestMyselfGuildDetail" then
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      self.MyselfGuild =data.Guild;
      --数据整理 for Action
      local members={};
      for k,v in pairs(self.MyselfGuild.Members) do
        members[tostring(v.Id)]=v;
      end
      self.MyselfGuild.Members=members;
      ----------------------------------红点--
      for k,v in pairs(self.MyselfGuild.Members) do
        if(v.PlayerId==UTGData.Instance().PlayerData.Id)then  --如果是自己
          
          if(v.FlagSignIn==true)then --并且已签到
            
          else  --可以签到，显示红点
            UTGDataOperator.Instance.battleGroupButtonNoticeII =true 
            if(UTGMainPanelAPI~=nil and UTGMainPanelAPI.Instance~=nil )then
             
              UTGMainPanelAPI.Instance:UpdateNotice()
            end
          end

          if(v.FlagShowNewApplication)then  --接受推送
            self:GuildApplicationListRequest(0,2) --申请列表数两>=1，显示红点
          end

          break;
        end
      end
      ----------------------------------------
     
    end

    return true;
  else
    return false;
  end

end
--***************************
--获取自己战队信息 : WYL (如果已经筹备，没有筹备第一次会Notify给GuildAPI)
--***************************
----------------------------------------------------------------------------------------------------------------筹备中--
function UTGData:MyselfPreparingGuildDetailRequest()  --由于调用及回调赋值时机需要高契合度所以写在本脚本中，随后的Notify更新也写在本脚本中
 
  if(UTGData.Instance().PlayerData.GuildStatus~=2)then return end  --如果没有筹备，退出

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestMyselfPreparingGuildDetail")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.MyselfPreparingGuildDetailResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function UTGData:MyselfPreparingGuildDetailResponseHandler(e)
  
  if e.Type == "RequestMyselfPreparingGuildDetail" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
        --Debugger.LogError("失败");
    elseif(data.Result==1)then   --data.PreparingGuild.PreparingGuildInfo  --data.PreparingGuild.Members 
        --Debugger.LogError("成功");
      --if(UTGData.Instance().MyselfPreparingGuildData==nil)then
        self.MyselfPreparingGuildData=data.PreparingGuild  --自己筹备中战队--数据存储
        local members={}
        for k,v in pairs(UTGData.Instance().MyselfPreparingGuildData.Members) do
          members[tostring(v.Id)]=v;
        end
        self.MyselfPreparingGuildData.Members=members
        --[[
        self:InitializeMyselfPreparingGuildDetailMembers(UTGData.Instance().MyselfPreparingGuildData)  --初始化自己战队成员
        self:InitializeMyselfPreparingGuildDetailInfo(UTGData.Instance().MyselfPreparingGuildData)  --初始化自己战队信息 --此中有跳转 --------------->> 
        --]]
    end
    return true;
  else
    return false;
  end
  
end

----------------------------------------------------------------------------------------------------------------申请列表--
function UTGData:GuildApplicationListRequest( beginIndex , length )   --索引，增量  Type：RequestGuildApplicationList

  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildApplicationList"),
                                  JProperty.New("BeginIndex", beginIndex ),
                                  JProperty.New("Length", length)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildApplicationListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function UTGData:GuildApplicationListResponseHandler(e)
 
  if e.Type == "RequestGuildApplicationList" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then  
      --Debugger.LogError("成功");  
      
      if(#data.ApplicationList>=1)then
        --红点，这里不成立也不要置成false，因为其他地方也会点亮它
        UTGDataOperator.Instance.battleGroupButtonNotice =true 
     
        if(UTGMainPanelAPI~=nil and UTGMainPanelAPI.Instance~=nil )then
          UTGMainPanelAPI.Instance:UpdateNotice()
        end
        if(GuildHaveAPI~=nil and GuildHaveAPI.Instance~=nil )then
          GuildHaveAPI.Instance.II2_ApplicationPoint.gameObject:SetActive(true)  --此界面的红点
        end

      end
      
    end
    return true;
  else
    return false;
  end
  
end

--***************************
--获取上周战队排行 : WYL
--***************************
function UTGData:GuildLastWeekRankRequest()   --RequestGuildLastWeekRank
  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出
  Debugger.LogError("S I")
  

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildLastWeekRank")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildLastWeekRankResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function UTGData:GuildLastWeekRankResponseHandler(e)
  Debugger.LogError("S I B")
  if e.Type == "RequestGuildLastWeekRank" then
    local data = json.decode(e.Content:ToString())
       
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      self.GuildLastWeekRank=data.Rank   --[]publiclogic.GuildRank
    end

    return true;
  else
    return false;
  end

end
--***************************
--获取本周战队排行 : WYL
--***************************
function UTGData:GuildWeekRankRequest()   --Type：RequestGuildWeekRank
  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出
  Debugger.LogError("S II")
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildWeekRank")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildWeekRankResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function UTGData:GuildWeekRankResponseHandler(e)
  Debugger.LogError("S II B")
  if e.Type == "RequestGuildWeekRank" then
    local data = json.decode(e.Content:ToString())
       
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      self.GuildWeekRank=data.Rank   --[]publiclogic.GuildRank
    end
    
    if GuildHaveAPI ~= nil and GuildHaveAPI.Instance ~= nil then
      GuildHaveAPI.Instance:InitializeMyselfGuildDetailInfoCoin()
    end

    return true;
  else
    return false;
  end

end
--***************************
--获取战队当前等级的赛季排行榜 : WYL
--***************************
function UTGData:GuildLevelSeasonRankRequest()   --RequestGuildLevelSeasonRank
  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出
  Debugger.LogError("S III")
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildLevelSeasonRank")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildLevelSeasonRankResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function UTGData:GuildLevelSeasonRankResponseHandler(e)
  Debugger.LogError("S III B")
  if e.Type == "RequestGuildLevelSeasonRank" then
    local data = json.decode(e.Content:ToString())
       
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      self.GuildLevelSeasonRank=data.Rank   --[]publiclogic.GuildRank
    end

    return true;
  else
    return false;
  end

end
--***************************
--获取战队赛季排行榜 : WYL
--***************************
function UTGData:GuildSeasonRankRequest()   --RequestGuildSeasonRank

  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出
  Debugger.LogError("S IV")

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildSeasonRank")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildSeasonRankResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function UTGData:GuildSeasonRankResponseHandler(e)
  Debugger.LogError("S IV B")
  if e.Type == "RequestGuildSeasonRank" then
    local data = json.decode(e.Content:ToString())
   
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      self.GuildSeasonRank=data.Rank   --[]publiclogic.GuildRank
    end

    return true;
  else
    return false;
  end

end
--***************************
--获取好友列表
--***************************
function UTGData:UTGDataGetFriendList()
  UTGData.LoadFriendList = false
  local friendListRequest = NetRequest.New()
  friendListRequest.Content = JObject.New(JProperty.New("Type","RequestFriendList"))
  friendListRequest.Handler = TGNetService.NetEventHanlderSelf( UTGData.UTGDataGetFriendListHandler,self)
  TGNetService.GetInstance():SendRequest(friendListRequest)  
end
function UTGData:UTGDataGetFriendListHandler(e)
  if e.Type == "RequestFriendList" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then



     
      local friends = json.decode(e.Content:get_Item("FriendList"):ToString())    
      self.FriendList = {}
      if friends ~= nil then
        for k,v in pairs(friends) do 
          self.FriendList[tostring(friends[k].PlayerId)] = friends[k]
        end
      end
      local forbidlist = json.decode(e.Content:get_Item("ForbidList"):ToString())    
      

      self.ForbidList = {}
      if forbidlist ~= nil then
        for k,v in pairs(forbidlist) do
          self.ForbidList[tostring(forbidlist[k].PlayerId)] = forbidlist[k]
        end
      end
      
      local friendsCandidateList = json.decode(e.Content:get_Item("FriendCandidateList"):ToString())
      self.FriendCandidateList = {}
      if friendsCandidateList ~= nil then
        for k,v in pairs(friendsCandidateList) do
          self.FriendCandidateList[tostring(v.PlayerId)] = v
        end
        UTGDataOperator.Instance.FriendNotice = true
      end

      --红点
      if(#friendsCandidateList~=0)then 
        UTGDataOperator.Instance.friendNotice =true
      else  
        UTGDataOperator.Instance.friendNotice =false
      end
      if(UTGMainPanelAPI~=nil and UTGMainPanelAPI.Instance~=nil )then 
        UTGMainPanelAPI.Instance:UpdateNotice()
      end


    end
    
    UTGData.LoadFriendList = true
    
    return true

  end 
  return false
end
--******************
--未读邮件
--******************
function UTGData:UnReadMail(networkDelegate,networkDelegateSelf)
  -- body
  self.unReadDelegate = networkDelegate
  self.unReadDelegateSelf = networkDelegateSelf
  local unReadRequest = NetRequest.New()
  unReadRequest.Content = JObject.New(JProperty.New("Type", "RequestUnreadMailCount"))
  unReadRequest.Handler = TGNetService.NetEventHanlderSelf(UTGData.UnReadMailHandler, self)
  TGNetService.GetInstance():SendRequest(unReadRequest)   
end
function UTGData:UnReadMailHandler(e)
  -- body
  if e.Type == "RequestUnreadMailCount" then
    local result = json.decode(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local friendCount = tonumber(json.decode(e.Content:get_Item("UnreadFriendMailCount"):ToString()))
      local systemCount = tonumber(json.decode(e.Content:get_Item("UnreadSystemMailCount"):ToString()))

      if friendCount == 0 and systemCount == 0 then
        UTGDataOperator.Instance.emailNotice = false
      else
        UTGDataOperator.Instance.emailNotice = true
      end
      if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
        UTGMainPanelAPI.Instance:UpdateNotice()
      end
    elseif result == 2 then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("获取未阅读邮件失败")
    end
    return true
  end
  return false
end
--******************
--获取邮件列表
--******************
function UTGData:UTGDataGetFriendMailList()
  -- body
  UTGData.LoadMailList = false
  local mailListRequest = NetRequest.New()
  mailListRequest.Content = JObject.New(JProperty.New("Type","RequestMailList"),
                                        JProperty.New("Category",1),
                                        JProperty.New("BeginIndex",0),
                                        JProperty.New("Length",5))
  mailListRequest.Handler = TGNetService.NetEventHanlderSelf( UTGData.UTGDataGetFriendMailListHandler,self)
  TGNetService.GetInstance():SendRequest(mailListRequest)    
end

function UTGData:UTGDataGetFriendMailListHandler(e)
  -- body
  if e.Type == "RequestMailList" then
    local result = tonumber(json.decode(e.Content:get_Item("Result"):ToString()))
    if result == 1 then
      self.FriendMailList = {}
      local mails = json.decode(e.Content:get_Item("MailList"):ToString())
      if mails ~= nil then
        UTGDataTemporary.Instance().FriendEmail = mails
        UTGDataTemporary.Instance().FriendEmailCount = #mails
        for k,v in pairs(mails) do
          self.FriendMailList[tostring(mails[k].Id)] = mails[k]
        end
      end
    elseif result == 3077 then
      self.FriendMailList = {}
      local mails = json.decode(e.Content:get_Item("MailList"):ToString())
      if mails ~= nil then
        UTGDataTemporary.Instance().FriendEmail = mails
        UTGDataTemporary.Instance().FriendEmailCount = #mails
        for k,v in pairs(mails) do
          self.FriendMailList[tostring(mails[k].Id)] = mails[k]
          if v.IsDrew == false then
            UTGDataOperator.Instance.emailNotice = true
          end
        end
      end      
    end
    return true
  end
  return false
end

function UTGData:UTGDataGetSystemMailList()
  -- body
  UTGData.LoadMailList = false
  local mailListRequest = NetRequest.New()
  mailListRequest.Content = JObject.New(JProperty.New("Type","RequestMailList"),
                                        JProperty.New("Category",2),
                                        JProperty.New("BeginIndex",0),
                                        JProperty.New("Length",5))
  mailListRequest.Handler = TGNetService.NetEventHanlderSelf( UTGData.UTGDataGetSystemMailListHandler,self)
  TGNetService.GetInstance():SendRequest(mailListRequest)    
end

function UTGData:UTGDataGetSystemMailListHandler(e)
  -- body
  if e.Type == "RequestMailList" then
    local result = tonumber(json.decode(e.Content:get_Item("Result"):ToString()))
    if result == 1 then
      self.SystemMailList = {}
      local mails = json.decode(e.Content:get_Item("MailList"):ToString())
      if mails ~= nil then
        UTGDataTemporary.Instance().SystemEmail = mails
        UTGDataTemporary.Instance().SystemEmailCount = #mails

        for k,v in pairs(mails) do
          self.SystemMailList[tostring(mails[k].Id)] = mails[k]
          if v.IsDrew == false then
            UTGDataOperator.Instance.emailNotice = true
          end
        end
      end
    elseif result == 3077 then
      self.SystemMailList = {}
      local mails = json.decode(e.Content:get_Item("MailList"):ToString())
      if mails ~= nil then
        UTGDataTemporary.Instance().SystemEmail = mails
        UTGDataTemporary.Instance().SystemEmailCount = #mails


        for k,v in pairs(mails) do
          self.SystemMailList[tostring(mails[k].Id)] = mails[k]
        end
      end      
    end
    return true
  end
  return false
end


--******************
--获取玩家赏金联赛信息
--******************
function UTGData:RequestPlayerBountyInfo()
  UTGData.LoadPlayerBountyInfo = false
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestPlayerBountyInfo"))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestPlayerBountyInfoHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end

function UTGData:RequestPlayerBountyInfoHandler(e)
  UTGData.LoadPlayerBountyInfo = true
  if e.Type =="RequestPlayerBountyInfo" then
    local data = json.decode(e.Content:get_Item("Bounties"):ToString())
    self.PlayerBountyInfos = {}
    for k,v in pairs(data) do
      self.PlayerBountyInfos[tostring(v.TemplateId)] = v
    end
    return true
  end
  return false
end

--******************
--获取PlayerDeck信息
--******************

function UTGData:UTGDataGetPlayerDeck()
  UTGData.LoadPlayerDeck = false
  local playerDeckRequest = NetRequest.New()
  playerDeckRequest.Content = JObject.New(JProperty.New("Type","RequestPlayerDeck"),
                                            JProperty.New("Category",0xffffffff))
  playerDeckRequest.Handler = TGNetService.NetEventHanlderSelf( UTGData.UTGDataGetPlayerDeckHandler,self)
  TGNetService.GetInstance():SendRequest(playerDeckRequest)   
end
function UTGData:UTGDataGetPlayerDeckHandler(e)
  if e.Type == "RequestPlayerDeck" then

    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      --roleDeck



      local roles = json.decode(e.Content:get_Item("Roles"):ToString())
      self.RolesDeck = {}
      self.RolesDeckData = {}
      if roles ~= nil then
        for k,v in pairs(roles) do
          self.RolesDeck[tostring(roles[k].Id)] = roles[k]
          self.RolesDeckData[tostring(roles[k].RoleId)] = roles[k]
          if v.IsOwn == false then
            if v.ExperienceCountDown > 0 then         
              UTGDataOperator.Instance.TryHero = {}
              table.insert(UTGDataOperator.Instance.TryHero,v.RoleId)
              table.insert(UTGDataOperator.Instance.TryHero,v.ExperienceCountDown)
              UTGDataOperator.Instance.TryHeroList[tostring(v.RoleId)] = UTGDataOperator.Instance.TryHero
            end
          end
        end
      end



      --skinDeck
      local skins = json.decode(e.Content:get_Item("Skins"):ToString())
      self.SkinsDeck = {}
      self.SkinsDeckData = {}
      if skins ~= nil then
        for k,v in pairs(skins) do
          self.SkinsDeck[tostring(skins[k].Id)] = skins[k]
          self.SkinsDeckData[tostring(skins[k].SkinId)] = skins[k]
          if v.IsOwn == false then
            if v.ExperienceCountDown > 0 then
              UTGDataOperator.Instance.TrySkin = {}
              table.insert(UTGDataOperator.Instance.TrySkin,v.SkinId)
              table.insert(UTGDataOperator.Instance.TrySkin,v.ExperienceCountDown)
              UTGDataOperator.Instance.TrySkinList[tostring(v.SkinId)] = UTGDataOperator.Instance.TrySkin
            end
          end
        end
      end
      
      --RunePageDeck
      local runePagesDeck = json.decode(e.Content:get_Item("RunePages"):ToString())
      self.RunePagesDeck = {}
      if runePagesDeck ~= nil then
        for k,v in pairs(runePagesDeck) do
          self.RunePagesDeck[tostring(runePagesDeck[k].Id)] = runePagesDeck[k]
        end
      end
      --RuneSlotDeck 
      local RuneSlotDeck = json.decode(e.Content:get_Item("RuneSlots"):ToString())
      self.RuneSlotsDeck = {}
      if RuneSlotDeck ~= nil then
        for k,v in pairs(RuneSlotDeck) do
          self.RuneSlotsDeck[tostring(RuneSlotDeck[k].Id)] = RuneSlotDeck[k]
        end
      end
      --RuneDeck 
      local RuneDeck = json.decode(e.Content:get_Item("Runes"):ToString())
      self.RunesDeck = {}
      if RuneDeck ~= nil then
        for k,v in pairs(RuneDeck) do
          self.RunesDeck[tostring(RuneDeck[k].RuneId)] = RuneDeck[k]
        end
      end
      --Items
      local item = json.decode(e.Content:get_Item("Items"):ToString())
      self.ItemsDeck = {}
      local count = 0
      if item ~= nil then
        for k,v in pairs(item) do
          self.ItemsDeck[tostring(item[k].ItemId)] = item[k]
          count = count + 1
        end
      end
      --PlayerSkills
      local playerskills = json.decode(e.Content:get_Item("PlayerSkills"):ToString())
      self.PlayerSkillDeckIds = {}
      if playerskills ~= nil then
        for k,v in pairs(playerskills) do
          --Debugger.LogError(k.." "..v)
          self.PlayerSkillDeckIds[tostring(v)] = v
        end
      end

      local playerSeason = json.decode(e.Content:get_Item("Seasons"):ToString())
      self.PlayerSeasonDeck = {}
      if playerSeason ~= nil then
        for k,v in pairs(playerSeason) do
          self.PlayerSeasonDeck[tostring(playerSeason[k].SeasonId)] = playerSeason[k]
        end
      end

      local playerGrade = json.decode(e.Content:get_Item("Grade"):ToString())
      self.PlayerGradeDeck = {}
      if playerGrade ~= nil then
        self.PlayerGradeDeck = playerGrade
      end

      local playerShop = json.decode(e.Content:get_Item("PlayerShop"):ToString())
      self.PlayerShopsDeck = {}
      if playerShop ~= nil then
        self.PlayerShopsDeck = playerShop
      end

      local playergrowup = json.decode(e.Content:get_Item("PlayerGrowUps"):ToString())
      self.PlayerGrowUpDeck = {}
      if playergrowup ~= nil then
        for k,v in pairs(playergrowup) do
          self.PlayerGrowUpDeck[tostring(v.Id)] = v
        end
      end
      
      --等级奖励
      local PlayerGrowUpDeckServer = json.decode(e.Content:get_Item("PlayerGrowUpDeck"):ToString())
      self.PlayerGrowUpProgressDeck = {}
      if PlayerGrowUpDeckServer ~= nil then
         self.PlayerGrowUpProgressDeck = PlayerGrowUpDeckServer
      end
      
      --等级任务
      local PlayerLevelQuestsServer =   json.decode(e.Content:get_Item("PlayerLevelQuests"):ToString())
      self.PlayerLevelQuestDeck = {}
      if PlayerLevelQuestsServer ~= nil then
         for k,v in pairs(PlayerLevelQuestsServer) do
          self.PlayerLevelQuestDeck[tostring(v.LevelQuestId)] = v
        end
      end
      
      --玩家获取
      local PlayerGainServer =  json.decode(e.Content:get_Item("PlayerGain"):ToString())
      self.PlayerGainDeck = {}
      if (PlayerGainServer ~= nil) then
        self.PlayerGainDeck = PlayerGainServer
      end
                                                            
      local playerAvatarFrame = json.decode(e.Content:get_Item("PlayerAvatarFrames"):ToString())
     
      self.PlayerAvatarFramesDeck = {}
      if playerAvatarFrame ~= nil then
        
        for k,v in pairs(playerAvatarFrame) do
        
          self.PlayerAvatarFramesDeck[tostring(v.AvatarFrameId)] = v
        end
      end

      --成就相关deck---------------------------------------------------------------------------
      --玩家当前成就等级，领取奖励信息
      local PlayerAchievementInfo =  json.decode(e.Content:get_Item("PlayerAchievementInfo"):ToString())
      self.PlayerAchievementInfoDeck = {}
      if (PlayerAchievementInfo ~= nil) then
        self.PlayerAchievementInfoDeck = PlayerAchievementInfo
      end

      --已经完成的成就
      local PlayerAchievements =  json.decode(e.Content:get_Item("PlayerAchievements"):ToString())
      self.PlayerAchievementsDeck = {}
      if (PlayerAchievements ~= nil) then
        for k,v in pairs(PlayerAchievements) do
          self.PlayerAchievementsDeck[tostring(v.AchievementId)] = v
        end
      end

      --成就的进度
      local PlayerAchievementProgress =  json.decode(e.Content:get_Item("PlayerAchievementProgresses"):ToString())
      self.PlayerAchievementProgressDeck = {}
      if (PlayerAchievementProgress ~= nil) then
        for k,v in pairs(PlayerAchievementProgress) do
          self.PlayerAchievementProgressDeck[tostring(v.Type)] = v
        end
      end

      --成就相关end----------------------------------------------------------------------------

      --公告相关deck ------------------------------------------------------------------------------
      local PlayerActivity =  json.decode(e.Content:get_Item("PlayerActivity"):ToString())
      self.PlayerActivityDeck = {}
      if (PlayerActivity ~= nil) then
        self.PlayerActivityDeck = PlayerActivity
      end
      --公告相关deck end----------------------------------------------------------------------------

      --活动deck---------------------------------------------------------------------------------
      local PlayerActivityQuests =  json.decode(e.Content:get_Item("PlayerActivityQuests"):ToString())
      self.PlayerActivityQuestDeck = {}
      if (PlayerActivityQuests ~= nil) then
        for k,v in pairs(PlayerActivityQuests) do
          self.PlayerActivityQuestDeck[tostring(v.ActivityQuestId)] = v
        end
      end
      --活动deck  end----------------------------------------------------------------------------
      UTGData.LoadPlayerDeck = true

      UTGDataOperator.Instance:CountPlayTime()
      
    end
    return true
  end
  return false 
end

function UTGData:UTGDataUpdatePlayerShopDeck()
  UTGData.LoadPlayerDeck = false
  local playerDeckRequest = NetRequest.New()
  playerDeckRequest.Content = JObject.New(JProperty.New("Type","RequestPlayerDeck"),
                                            JProperty.New("Category",0x0200))
  playerDeckRequest.Handler = TGNetService.NetEventHanlderSelf( UTGData.UTGDataUpdatePlayerShopDeckHandler,self)
  TGNetService.GetInstance():SendRequest(playerDeckRequest)   
end

function UTGData:UTGDataUpdatePlayerShopDeckHandler(e)
  -- body
  if e.Type == "RequestPlayerDeck" then

    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local playerShop = json.decode(e.Content:get_Item("PlayerShop"):ToString())
      self.PlayerShopsDeck = {}
      if playerShop ~= nil then
        self.PlayerShopsDeck = playerShop
      end      
    end
    return true
  end  
  return false
end


function UTGData:GetOtherData()
  -- body
  self:GetBattleLog()
  self:GetCurrentSeasonInfo()
  self:UTGDataGetFriendMailList()
  self:UTGDataGetSystemMailList()
  --self:GetPlayerBattleStats()
  self:MyselfApplyingGuildsRequest()  --WYL:获取已申请战队的ID
  self:MyselfGuildDetailRequest()       --WYL:获取自己战队信息，如果已加入战队
  self:MyselfPreparingGuildDetailRequest()
   
  self:UnReadMail()    --获取未阅读邮件个数
  --[[ --有变更，改为当时获取
  self:GuildSeasonRankRequest()  --获取战队赛季排行榜                 --self.GuildSeasonRank
  self:GuildLevelSeasonRankRequest()  --获取战队当前等级的赛季排行榜  --self.GuildLevelSeasonRank 
  self:GuildWeekRankRequest()   --获取本周战队排行                    --self.GuildWeekRank
  self:GuildLastWeekRankRequest()   --获取上周战队排行                --self.GuildLastWeekRank
  --]]
  

end

function UTGData:GetBattleLog()
    -- body
    local battleLogRequest = NetRequest.New()
    battleLogRequest.Content = JObject.New(JProperty.New("Type","RequestRecentGradeBattleLog"))
    battleLogRequest.Handler = TGNetService.NetEventHanlderSelf(UTGData.GetBattleLogHandler,self)
    TGNetService.GetInstance():SendRequest(battleLogRequest)
end

function UTGData:GetBattleLogHandler(e)
    -- body
    if e.Type == "RequestRecentGradeBattleLog" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then
        self.BattleLogs = json.decode(e.Content:get_Item("BattleLogs"):ToString())
        
      end
      return true
    end
    return false
end

function UTGData:GetCurrentSeasonInfo()
    -- body
    local seasonInfoRequest = NetRequest.New()
    seasonInfoRequest.Content = JObject.New(JProperty.New("Type","RequestCurrentSeasonInfo"))
    seasonInfoRequest.Handler = TGNetService.NetEventHanlderSelf(UTGData.GetCurrentSeasonInfoHandler,self)
    TGNetService.GetInstance():SendRequest(seasonInfoRequest)    
end 

function UTGData:GetCurrentSeasonInfoHandler(e)
   -- body
   if e.Type == "RequestCurrentSeasonInfo" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then
        self.CurrentSeasonInfo = json.decode(e.Content:get_Item("Season"):ToString())

        
      end
      return true
   end
   return false
end

--[[
function UTGData:GetPlayerBattleStats()
    -- body
    local battleStatsRequest = NetRequest.New()
    battleStatsRequest.Content = JObject.New(JProperty.New("Type","RequestPlayerBattleStats"))
    battleStatsRequest.Handler = TGNetService.NetEventHanlderSelf(UTGData.GetPlayerBattleStatsHandler)
    TGNetService.GetInstance():SendRequest(battleStatsRequest)    
end 

function UTGData:GetPlayerBattleStatsHandler(e)
   -- body
   if e.Type == "RequestPlayerBattleStats" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then
        self.PlayerBattleStats = json.decode(e.Content:get_Item("Stats"):ToString())   
      end
      return true
   end
   return false
end 
]]


--*******************************
--测试从本地ini中读取template信息
--*******************************
function UTGData:GetTemplateFromLocal()
  local path = NTGResourceController.GetDataPath("GlobalData")
  local LocalE = ""
  if Directory.Exists(path) and File.Exists(path .. "CacheData.ini") then
    localE = json.decode(NTGResourceController.ReadAllText(path .. "CacheData.ini"))
  end

  --角色信息
  local roles = localE.Roles
  self.RolesData = {}
  if roles ~= nil then        
    for k,v in pairs(roles) do
      self.RolesData[tostring(roles[k].Id)] = v
    end
  end
  --角色熟练度信息
  local roleProficiencys = localE.RoleProficiencys
  self.RoleProficiencysData = {}
  if roleProficiencys ~= nil then
    for k,v in pairs(roleProficiencys) do
      self.RoleProficiencysData[tostring(roleProficiencys[k].Id)] = v
    end
  end
  --装备信息
  local equips = localE.Equips
  self.EquipsData = {}
  if equips ~= nil then
    for k,v in pairs(equips) do
      self.EquipsData[tostring(equips[k].Id)] = v
      local Attr = {}
      local name = {}
      local value = {}
      for m,n in pairs(equips[k]) do
        if m == "HP" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "MP" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "PAtk" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "MAtk" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "PDef" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "MDef" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "MoveSpeed" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "PpenetrateValue" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "PpenetrateRate" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "MpenetrateValue" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "MpenetrateRate" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "AtkSpeed" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "CritRate" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "CritEffect" then
          table.insert(name,m)
          table.insert(value,n)
        elseif m == "PHpSteal" then
          table.insert(name,m)
          table.insert(value,n) 
        elseif m == "MHpSteal" then
          table.insert(name,m)
          table.insert(value,n) 
        elseif m == "CdReduce" then
          table.insert(name,m)
          table.insert(value,n) 
        elseif m == "Tough" then
          table.insert(name,m)
          table.insert(value,n) 
        elseif m == "HpRecover5s" then
          table.insert(name,m)
          table.insert(value,n) 
        elseif m == "MpRecover5s" then
          table.insert(name,m)
          table.insert(value,n)      
        end
      end
      for i = 1,#name do
        Attr[name[i]] = value[i]
      end
      self.EquipsData[tostring(equips[k].Id)]["Attr"] = Attr
    end



  end
  --物品信息
  local items = localE.Items
  self.ItemsData = {}
  if items ~= nil then
    for k,v in pairs(items) do
      self.ItemsData[tostring(items[k].Id)] = v
      if v.Type == 9 then 
        UTGDataTemporary.Instance().BigHornItemId = v.Id
      end
      if v.Type == 10 then 
        UTGDataTemporary.Instance().SmallHornItemId = v.Id  
      end
    end
  end

  --技能信息
  local skills = localE.Skills
  self.SkillsData = {}
  if skills ~= nil then
    for k,v in pairs(skills) do
      self.SkillsData[tostring(skills[k].Id)] = v
    end
  end

  --技能表现信息
  local skillBehaviours = localE.SkillBehaviours
  self.SkillBehavioursData = {}
  if skillBehaviours ~= nil then
    for k,v in pairs(skillBehaviours) do
      self.SkillBehavioursData[tostring(skillBehaviours[k].Id)] = v
    end
  end

  --芯片信息
  local runes = localE.Runes
  self.RunesData = {}
  if runes ~= nil then
    for k,v in pairs(runes) do
      self.RunesData[tostring(runes[k].Id)] = v
    end
  end
  --芯片组信息
  local runePages = localE.RunePages
  self.RunePagesData = {}
  if runePages ~= nil then
    for k,v in pairs(runePages) do
      self.RunePagesData[tostring(runePages[k].Id)] = v
    end
  end
  --芯片槽信息
  local runeSlots = localE.RuneSlots
  self.RuneSlotsData = {}
  if runeSlots ~= nil then
    for k,v in pairs(runeSlots) do
      self.RuneSlotsData[tostring(runeSlots[k].Id)] = v
    end
  end
  --章节信息
  local dramas = localE.Dramas
  self.DramasData = {}
  if dramas ~= nil then
    for k,v in pairs(dramas) do
      self.DramasData[tostring(dramas[k].Id)] = v
    end
  end
  --皮肤信息
  local skins = localE.Skins
  self.SkinsData = {}
  if skins ~= nil then
    for k,v in pairs(skins) do
      self.SkinsData[tostring(skins[k].Id)] = v
    end
  end
  --外部商城信息
  local shops = localE.Shops
  self.ShopsData = {}
  self.ShopsDataById = {}
  self.ShopsHeroData = {}
  self.ShopsSkinData = {}
  self.ShopsSaleData = {}
  if shops ~= nil then
    for k,v in pairs(shops) do
      if self.ShopsData[tostring(shops[k].CommodityId)] == nil then
        self.ShopsData[tostring(shops[k].CommodityId)] = {}
        table.insert(self.ShopsData[tostring(shops[k].CommodityId)],v)
      else
        table.insert(self.ShopsData[tostring(shops[k].CommodityId)],v)
      end
      self.ShopsDataById[tostring(shops[k].Id)] = v
      if shops[k].Category == 1 then
        table.insert(self.ShopsHeroData,v)
      elseif shops[k].Category == 2 then
        table.insert(self.ShopsSkinData,v)
      elseif shops[k].Category == 3 then
        table.insert(self.ShopsSaleData,v)
      end
    end
  end


  local partShops = localE.PartShops
  self.PartShopsData = {}
  self.PartShopsDataForOrder = partShops
  if partShops ~= nil then
    for k,v in pairs(partShops) do
      self.PartShopsData[tostring(partShops[k].CommodityId)] = v
    end
  end

  local shopNews = localE.ShopNews
  self.ShopNewsData = {}
  if shopNews ~= nil then
    for k,v in pairs(shopNews) do
      self.ShopNewsData[tostring(shopNews[k].Id)] = v
    end
  end      

  local shopHots = localE.ShopHots
  self.ShopHotsData = {}
  if shopHots ~= nil then
    for k,v in pairs(shopHots) do
      self.ShopHotsData[tostring(shopHots[k].Id)] = v
    end
  end

  local shopPosts = localE.ShopPosts
  self.ShopPostsData = {}
  if shopPosts ~= nil then
    for k,v in pairs(shopPosts) do
      self.ShopPostsData[tostring(shopPosts[k].Id)] = v
    end
  end

  local shopDepreciations = localE.ShopDepreciations
  self.ShopDepreciationsData = {}
  if shopDepreciations ~= nil then
    for k,v in pairs(shopDepreciations) do
      self.ShopDepreciationsData[tostring(shopDepreciations[k].Id)] = v
    end
  end

  local shopTreasures = localE.ShopTreasures
  self.ShopTreasuresData = {}
  if shopTreasures ~= nil then
    for k,v in pairs(shopTreasures) do
      self.ShopTreasuresData[tostring(shopTreasures[k].Id)] = v
    end
  end

  local shopTreasureChests = localE.ShopTreasureChests
  self.ShopTreasureChestsData = {}
  if shopTreasureChests ~= nil then
    for k,v in pairs(shopTreasureChests) do
      self.ShopTreasureChestsData[tostring(shopTreasureChests[k].Id)] = v
    end
  end

  --小怪属性信息
  local creatures = localE.Creatures
  self.CreaturesData = {}
  if creatures ~= nil then
    for k,v in pairs(creatures) do
      self.CreaturesData[tostring(creatures[k].Id)] = v
    end
  end
  --小怪群组信息
  local creatureGroups = localE.CreatureGroups
  self.CreatureGroupsData = {}
  if creatureGroups ~= nil then
    for k,v in pairs(creatureGroups) do
      self.CreatureGroupsData[tostring(creatureGroups[k].Id)] = v
    end
  end
  --PVP等级信息
  local pvpLevels = localE.PVPLevels
  self.PVPLevelsData = {}
  if pvpLevels ~= nil then
    for k,v in pairs(pvpLevels) do
      self.PVPLevelsData[tostring(pvpLevels[k].Id)] = v
    end
  end
  --PVP升级信息
  local pvpLevelUps = localE.PVPLevelUps
  self.PVPLevelUpsData = {}
  local count = 0
  if pvpLevelUps ~= nil then
    for k,v in pairs(pvpLevelUps) do
      if v.Type > count then
        count = v.Type
      end
    end

    for i = 1,count do
      self.PVPLevelUpsData[tostring(i)] = {}
    end

    for k,v in pairs(pvpLevelUps) do
      self.PVPLevelUpsData[tostring(v.Type)][tostring(v.Level)] = v
    end

  end

  --PVP物品商店信息
  local pvpMalls = localE.PVPMalls
  self.PVPMallsData = {}
  if pvpMalls ~= nil then
    for k,v in pairs(pvpMalls) do
      self.PVPMallsData[tostring(pvpMalls[k].EquipId)] = v
    end
  end
  --角色成长信息
  local pvpRoleGrows = localE.PVPRoleGrows
  self.PVPRoleGrowsData = {}
  if pvpRoleGrows ~= nil then
    for k,v in pairs(pvpRoleGrows) do
      self.PVPRoleGrowsData[tostring(pvpRoleGrows[k].RoleId)] = v
    end
  end       

  --Source信息
  local source = localE.Source
  self.SourcesData = {}
  if source ~= nil then
    for k,v in pairs(source) do
      self.SourcesData[tostring(source[k].Id)] = v
      --print("k,v " .. k.." "..v.Desc)
    end
  end
  --PlayerSkill信息
  local playerskill = localE.PlayerSkills
  self.PlayerSkillData = {}
  if playerskill ~= nil then
    for k,v in pairs(playerskill) do
      self.PlayerSkillData[tostring(playerskill[k].Id)] = v
    end
  end
  --GodEquipConfigs信息
  local godequipconfigs = localE.GodEquipConfigs
  self.GodEquipConfigsData = {}
  if godequipconfigs ~= nil then
    for k,v in pairs(godequipconfigs) do
      self.GodEquipConfigsData[tostring(godequipconfigs[k].Id)] = v
    end
  end
  --PVP击杀目标会获得金币奖励
  local pvpKillStreak = localE.PVPKillStreak
  self.PVPKillStreaksData = {}
  if pvpKillStreak ~= nil then
    for k,v in pairs(pvpKillStreak) do
      self.PVPKillStreaksData[tostring(pvpKillStreak[k].Kill)] = pvpKillStreak[k]
    end
  end
  --玩家升级规则
  local playerLevelUp = localE.PlayerLevelUps
  self.PlayerLevelUpData = {}
  if playerLevelUp ~= nil then
    for k,v in pairs(playerLevelUp) do
      self.PlayerLevelUpData[tostring(playerLevelUp[k].Level)] = playerLevelUp[k]
    end
  end

  local grades = localE.Grades
  self.GradesData = {}
  if grades ~= nil then
    for k,v in pairs(grades) do
      self.GradesData[tostring(grades[k].Grade)] = grades[k]
    end
  end

  local seasons = localE.Seasons
  self.SeasonsData = {}
  if seasons ~= nil then
    for k,v in pairs(seasons) do
      self.SeasonsData[tostring(seasons[k].Id)] = seasons[k]
    end
  end

  local quickmes = localE.QuickMessages 
  self.QuickMessagesData = {}
  if quickmes ~= nil then
    for k,v in pairs(quickmes) do
      self.QuickMessagesData[tostring(v.Id)] = v
    end
  end

  local mailInfos = localE.MailInfos
  self.MailInfosData = {}
  if mailInfos ~= nil  then
    for k,v in pairs(mailInfos) do
      self.MailInfosData[tostring(v.Id)] = v
    end
  end


  local battleHonors = localE.BattleHonors
  self.BattleHonorsData = {}
  if battleHonors ~= nil then
    for k,v in pairs(battleHonors) do
      self.BattleHonorsData[tostring(battleHonors[k].Id)] = battleHonors[k]
    end
  end

  local growups = localE.GrowUps 
  self.GrowUpsData = {}
  if growups ~= nil  then
    for k,v in pairs(growups) do
      self.GrowUpsData[tostring(v.Id)] = v
    end
  end
  
  local growupchests = localE.GrowUpChests
  self.GrowUpChestsData = {}
  if growupchests ~= nil  then
    for k,v in pairs(growupchests) do
      self.GrowUpChestsData[tostring(v.Id)] = v
    end
  end

  local avatarFrame = localE.AvatarFrames
  self.AvatarFramesData = {}
  if avatarFrame ~= nil then
    for k,v in pairs(avatarFrame) do
      self.AvatarFramesData[tostring(avatarFrame[k].Id)] = avatarFrame[k]
    end
  end
  --赏金联赛
  local bounty = localE.Bounties
  self.BountiesData = {}
  if bounty ~= nil then
    for k,v in pairs(bounty) do
      if v.Category == 1 then UTGDataTemporary.instance.BountyMatchCoinTemplateId = v.Id end
      self.BountiesData[tostring(bounty[k].Id)] = bounty[k]
    end
  end

  --掉落包
  local dropGroups = localE.DropGroups
  self.DropGroupsData = {}
  if dropGroups ~= nil then
    for k,v in pairs(dropGroups) do
      self.DropGroupsData[tostring(dropGroups[k].Id)] = dropGroups[k]
    end
  end

  --娱乐模式
  local entModes = localE.EntModes
  self.EntModesData = {}
  if entModes ~= nil  then
    for k,v in pairs(entModes) do
      self.EntModesData[tostring(v.Id)] = v
    end
  end

    -------------------------------------------------------------------------战队Begin--WYL
      --战队图标--
      local guildIcons = localE.GuildIcons
    
      self.GuildIconsData = {}
      self.GuildIconsDataArray = {}
      if guildIcons ~= nil then
        for k,v in pairs(guildIcons) do
          self.GuildIconsData[tostring(guildIcons[k].Id)] = guildIcons[k]
          table.insert(self.GuildIconsDataArray,v) 
          
        end
      end
      --战队评级--
      local guildLevels = localE.GuildLevels
      self.GuildLevelsData = {}
      if guildLevels ~= nil then
        for k,v in pairs(guildLevels) do
          self.GuildLevelsData[tostring(guildLevels[k].Level)] = guildLevels[k]
        end
      end
      --战队图标--
      local guildMemberLimits =localE.GuildMemberLimits
      self.GuildMemberLimitsData = {}
      if guildMemberLimits ~= nil then
        for k,v in pairs(guildMemberLimits) do
          self.GuildMemberLimitsData[tostring(guildMemberLimits[k].Size)] = guildMemberLimits[k]
        end
      end
      --战队职务权限--
      local guildPermissions = localE.GuildPermissions
      self.GuildPermissionsData = {}
      if guildPermissions ~= nil then
        for k,v in pairs(guildPermissions) do
          self.GuildPermissionsData[tostring(guildPermissions[k].Level)] = guildPermissions[k]
        end
      end
      --商店刷新需要的开销--
      local guildShopRefreshs = localE.GuildShopRefreshs
      self.GuildShopRefreshsData = {}
      if guildShopRefreshs ~= nil then
        for k,v in pairs(guildShopRefreshs) do
          self.GuildShopRefreshsData[tostring(guildShopRefreshs[k].Id)] = guildShopRefreshs[k]
        end
      end
      
      --战队星级--
      local guildStarLevels = localE.GuildStarLevels
      self.GuildStarLevelsData = {}
      if guildStarLevels ~= nil then
        for k,v in pairs(guildStarLevels) do
          self.GuildStarLevelsData[tostring(guildStarLevels[k].Level)] = guildStarLevels[k]
        end
      end
      --战队周排行奖励--
      local guildWeeklyRank  = localE.GuildWeeklyRanks
      self.GuildWeeklyRankData = {}
      if guildWeeklyRank ~= nil then
        for k,v in pairs(guildWeeklyRank) do
          self.GuildWeeklyRankData[tostring(guildWeeklyRank[k].EndRank   )] = guildWeeklyRank[k]
        end
      end

      --战队商店刷新消耗
      local guildShopRefresh = localE.GuildShopRefreshs
      self.GuildShopRefreshData = {}
      if guildShopRefresh ~= nil then
        for k,v in pairs(guildShopRefresh) do
          self.GuildShopRefreshData[tostring(guildShopRefresh[k].Count)] = guildShopRefresh[k]
        end
      end
      
      -------------------------------------------------------------------------战队End--


  --成长相关------------------------------------------------------------------------
  --成长任务
  local LevelQuestServer  = localE.LevelQuests
  self.LevelQuestByLevel = {}
  self.LevelQuestById = {}
  if LevelQuestServer ~= nil then
    for k,v in pairs(LevelQuestServer) do
      if self.LevelQuestByLevel[tostring(v.Level)] == nil then
        self.LevelQuestByLevel[tostring(v.Level)] = {}
        table.insert(self.LevelQuestByLevel[tostring(v.Level)],v)
      else
        table.insert(self.LevelQuestByLevel[tostring(v.Level)],v)
      end

      self.LevelQuestById[tostring(v.Id)] = v
    end      
  end

  --解锁功能
  local LevelFuncServer  = localE.FuncLocks 
  self.LevelFunc = {}
  if LevelFuncServer ~= nil then
    for k,v in pairs(LevelFuncServer) do
      if self.LevelFunc[tostring(v.UnlockLevel)] == nil then
        self.LevelFunc[tostring(v.UnlockLevel)] = {}
        table.insert(self.LevelFunc[tostring(v.UnlockLevel)],v)
      else
        table.insert(self.LevelFunc[tostring(v.UnlockLevel)],v)
      end
    end      
  end

  --我要金币等
  local GrowUpGuides  = localE.GrowUpGuides 
  --self.GrowUpGuide = {}
  self.GrowUpGuideGold = {}
  self.GrowUpGuideRune = {}
  self.GrowUpGuideHero = {}
  if GrowUpGuides ~= nil then
    for k,v in pairs(GrowUpGuides) do
      if (v.Category == 1) then
        table.insert(self.GrowUpGuideGold,v)
      elseif (v.Category == 2) then
        table.insert(self.GrowUpGuideRune,v)
      elseif (v.Category == 3) then
        table.insert(self.GrowUpGuideHero,v)
      end
    end      
  end

  --成长相关end---------------------------------------------------------------------

  --成就相关------------------------------------------------------------------------
  local Achievements  = localE.Achievements   
  self.AchievementsById = {}
  self.AchievementsFirst = {}
  self.AchievementsByType = {}
  if Achievements ~= nil then
    for k,v in pairs(Achievements) do
      self.AchievementsById[tostring(v.Id)] = v
      if (v.Level == 1) then
        self.AchievementsFirst[tostring(v.Id)] = v
      end
      if (self.AchievementsByType[tostring(v.Type)] == nil ) then
        self.AchievementsByType[tostring(v.Type)] = {}
        self.AchievementsByType[tostring(v.Type)][tostring(v.Level)] = v
      else
        self.AchievementsByType[tostring(v.Type)][tostring(v.Level)] = v
      end
    end      
  end

  --成就奖励
  local AchievementLevelUps  = localE.AchievementLevelUps
  self.AchievementLevelUps = {}
  self.AchievementLevelUpsWithAward = {}
  if AchievementLevelUps ~= nil then
    for k,v in pairs(AchievementLevelUps) do
      self.AchievementLevelUps[tostring(v.Level)] = v
      if (v.Rewards ~= nil and #v.Rewards > 0) then
         self.AchievementLevelUpsWithAward[tostring(v.Level)] = v
      end
    end      
  end

  --成就相关end---------------------------------------------------------------------

  --公告相关----------------------------------------------------------------------
  local Announcements  = localE.Announcements  
  self.Announcements = {}
  if Announcements ~= nil then
    for k,v in pairs(Announcements) do
      self.Announcements[tostring(v.Id)] = v
    end      
  end
  --公告相关end-------------------------------------------------------------------

  --SignIns
  local signIns  = localE.SignIns
  self.SignInsData = {}
  if signIns ~= nil then
    for k,v in pairs(signIns) do
      self.SignInsData[tostring(v.Day)] = v
    end      
  end

end

--*******************************
--判断当前是否为限免 通过id
--*******************************
function UTGData:IsLimitFreeDataById(id)
  if UTGDataTemporary.Instance().LimitedData ~=nil then 
    for k,v in pairs(UTGDataTemporary.Instance().LimitedData)  do
      if id == tonumber(v) then
        return true
      end
    end
  end
 return false
end
--*******************************
--获取自己拥有的role数据
--*******************************
function UTGData:GetOwnRoleData()
  local data = {}
  if self.RolesDeck~=nil then 
    for k,v in pairs(self.RolesDeck)  do
      if v.IsOwn == true then
        table.insert(data,self.RolesData[tostring(v.RoleId)])
      end
    end
  end
  local function SortById(a,b)
    return a.Id<b.Id
  end
  table.sort(data,SortById)
  return data
end

--*******************************
--获取RoleDeck 通过RoleId
--*******************************
function UTGData:GetRoleDeckByRoleId(id)
  if self.RolesDeck~=nil then 
    for k,v in pairs(self.RolesDeck)  do
      if id == v.RoleId then
      return v
      end
    end
  end
 return nil
end

--*******************************
--获取英雄的所有皮肤 通过roleid
--*******************************

function UTGData:GetSkinDataByRoleId(id)
  local skindata = {}
  --Debugger.LogError("skindata "..id)
  if self.SkinsData~=nil then 
    for k,v in pairs(self.SkinsData) do
      if v.RoleId == id then
        skindata[tostring(v.Id)] = v
      end
    end
  end
  return skindata
end

--*******************************
--判断皮肤是否为玩家所拥有皮肤
--*******************************

function UTGData:IsOwnSkinBySkinId(id)
  if self.SkinsDeck~=nil then 
    for k,v in pairs(self.SkinsDeck) do
      if v.SkinId == id and v.IsOwn == true then
        return true
      end
    end   
  end
  return false
end

--*******************************
--获取默认的召唤师技能 （skilldata）
--*******************************
function UTGData:GetDefaultPlayerSkill()
  local index = -1
  local skillid = 0
  if self.PlayerSkillData==nil then 
    --Debugger.LogError("没有PlayerSkillData    xxxxxxxxxxxxxxxxxxx")
  end
  for k,v in pairs(self.PlayerSkillData) do
    if index == -1 then
      index = tonumber(k)
      skillid = v.SkillId
    end
    if index > tonumber(k) then
      index = tonumber(k)
      skillid = v.SkillId
    end
  end    
  return self.SkillsData[tostring(skillid)]
end


--获取skill描述
function UTGData:GetSkillDescByParam(roleid,skillid,arg)
  arg = arg or {}
  local desc = ""
  local skilldata = self.SkillsData[tostring(skillid)]
  local roledata = self.RolesData[tostring(roleid)]
  local str = skilldata.Desc
  if #skilldata.DescParam > 0 then
    local ddLis = {}
    for i=1,#skilldata.DescParam do
      local dd = 0
      local skillBehaviourData = self.SkillBehavioursData[tostring(skilldata.DescParam[i][1])]
      --Debugger.LogError("tonumber(skilldata.DescParam[i][2]) = "..tonumber(skilldata.DescParam[i][2]))
      if tonumber(skilldata.DescParam[i][2]) ==1 then --物理伤害
        local patk = 0
        if arg.pAtk~=nil then 
          patk = tonumber(arg.pAtk)
        else
          patk = roledata.PAtk
        end
        dd = math.floor(patk*skillBehaviourData.PAtkAdd)
      elseif tonumber(skilldata.DescParam[i][2]) ==2 then --魔法伤害
        local matk = 0
        if arg.mAtk~=nil then 
          matk = tonumber(arg.mAtk)
        else
          matk = roledata.MAtk
        end
        dd = math.floor(matk*skillBehaviourData.MAtkAdd)
      elseif tonumber(skilldata.DescParam[i][2]) ==3 then--3：寒冰惩戒。参数一：固定值 参数二系数（伤害=固定值+等级*系数）例 20300011,3,740（参数一）,60（参数二）
        if arg.level == nil then Debugger.LogError("技能描述 缺少 level参数 ") end
        local fixed = tonumber(skilldata.DescParam[i][3])
        local param = tonumber(skilldata.DescParam[i][4])
        dd = math.floor(fixed+tonumber(arg.level)*param)
      end
      table.insert(ddLis,dd)
    end
    --Debugger.LogError("str="..str)
    if #ddLis == 1 then
      str = string.format(str,""..ddLis[1])
    elseif  #ddLis == 2 then
      str = string.format(str,""..ddLis[1],""..ddLis[2])
    elseif  #ddLis == 3 then
      str = string.format(str,""..ddLis[1],""..ddLis[2],""..ddLis[3])
    end
  end
  desc = str
  return desc
end

--*******************************
--工具类 方法
--*******************************

--string.split param：字符串，分割符
function UTGData:StringSplit(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
  local result = {}
  for match in (str..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return result
end
--获取字符串长度
function UTGData:StringLength(str)
  local len = #str;
  local left = len;
  local cnt = 0;
  local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
  while left ~= 0 do
    local tmp=string.byte(str,-left);
    local i=#arr;
    while arr[i] do
      if tmp>=arr[i] then left=left-i;break;end
      i=i-1;
    end
    cnt=cnt+1;
  end
  return cnt;
end

--获取剩余时间 retrun：秒（正/负） param：截止时间(服务器格式)
function UTGData:GetLeftTime(endTime)
  if endTime == nil then return nil end
  --Debugger.LogError(endTime)
  local dtNow = TGNetService.GetServerTime()
  --Debugger.LogError(dtNow)
  local pattern_go = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"--"2016-04-27T20:32:22+08:00",
  local pattern_datetime = "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)"--"4/25/2016 9:33:05 PM: 810131243",
  
  local year_go, month_go, day_go, hour_go, minute_go, seconds_go = tostring(endTime):match(pattern_go)
  local month_dt, day_dt, year_dt, hour_dt, minute_dt, seconds_dt = tostring(dtNow):match(pattern_datetime)
  hour_dt = tonumber(hour_dt)
  local ex_dt = tostring(dtNow):match("PM")
  if ex_dt ~= nil and hour_dt<12 then hour_dt = hour_dt+12 end
  --Debugger.LogError(ex_dt)

  local time_dt = os.time{year=year_dt, month=month_dt, day=day_dt, hour=hour_dt, min =minute_dt, sec=seconds_dt,isdst=false}--isdst表示是否夏令时 
  local time_go = os.time{year=year_go, month=month_go, day=day_go, hour=hour_go, min =minute_go, sec=seconds_go,isdst=false}
  --print(os.date("%M",time_dt),"  ",os.date("%M",time_go))
  --print(os.date("%j",time_dt),"  ",os.date("%j",time_go))

  return (time_go - time_dt)
end

--活动是否开启（赏金专用，其他模块慎用）
function UTGData:IsActivityOpen(startTimeStr,endTimeStr) 
  local result = {IsOpen = false,WaitSecond = 0}
  local dtNow = TGNetService.GetServerTime()
  local pattern_datetime = "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)"--"4/25/2016 9:33:05 PM: 810131243",
  local month_dt, day_dt, year_dt, hour_dt, minute_dt, seconds_dt = tostring(dtNow):match(pattern_datetime)
  hour_dt = tonumber(hour_dt)
  local ex_dt = tostring(dtNow):match("PM")
  if ex_dt ~= nil and hour_dt<12 then hour_dt = hour_dt+12 end
  local time_dt = os.time{year=year_dt, month=month_dt, day=day_dt, hour=hour_dt, min =minute_dt, sec=seconds_dt,isdst=false}

  local paramStart = self:StringSplit(startTimeStr," ")
  local seconds_start = tonumber(paramStart[1]) 
  local minute_start = tonumber(paramStart[2])
  local hour_start = tonumber(paramStart[3])
  local day_start = paramStart[4]
  local month_start = paramStart[5]
  local wday_start = paramStart[6]

  local paramEnd = self:StringSplit(endTimeStr," ")
  local seconds_end = tonumber(paramEnd[1]) 
  local minute_end = tonumber(paramEnd[2])
  local hour_end = tonumber(paramEnd[3])
  local day_end = paramEnd[4]
  local month_end = paramEnd[5]
  local wday_end = paramEnd[6]

  local startTime = nil
  local endTime = nil
  if wday_start~= "*" then 
    wday_start = tonumber(wday_start)
    wday_end = tonumber(wday_end)
    local wday_dt = os.date("%w",time_dt)
    wday_dt = tonumber(wday_dt)
    if wday_start == 0 then wday_start = 7 end
    if wday_end == 0 then wday_end = 7 end

    if wday_dt >= wday_start and wday_dt <= wday_end then
      result.IsOpen = true 
      return result
    end
  else
    if hour_end == 0 then hour_end = 24 end
    if hour_dt == 0 then hour_dt = 24 end
    if hour_dt > hour_start and hour_dt <= hour_end then 
      result.IsOpen = true
    elseif hour_dt < hour_start then 
      startTime = os.time{year=year_dt, month=month_dt, day=day_dt, hour=hour_start, min =0, sec=0,isdst=false}
      result.WaitSecond = startTime - time_dt
    elseif hour_dt >= hour_end then 
      startTime = os.time{year=year_dt, month=month_dt, day=day_dt+1, hour=hour_start, min =0, sec=0,isdst=false}
      result.WaitSecond = startTime - time_dt
    end
  end
  return result
end
