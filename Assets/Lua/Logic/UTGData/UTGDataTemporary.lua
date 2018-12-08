require "System.Global"

class("UTGDataTemporary")

function UTGDataTemporary.Instance()
  if UTGDataTemporary.instance == nil then
    UTGDataTemporary.instance = UTGDataTemporary.New()
  end
  return UTGDataTemporary.instance
end

function UTGDataTemporary:DraftData()
  self.DraftContent = nil
  self.DraftPartyContent = nil
  self.DraftData = nil
  self.DraftPartyData = nil
end
function UTGDataTemporary:GetInvitation()
  self.InviterId = 0
  self.InviterName = ""
  self.InviterIconFrame = ""
  self.GroupType = 0
  self.GroupId = 0
  self.GroupName = ""
  self.SubType = 0
  self.PartyInfo = {}
  self.RoomInfo = {} 
end

function UTGDataTemporary:SpecialIds()
  -- body
  self.SmallHornItemId = 0
  self.BigHornItemId = 0
  self.BountyMatchCoinTemplateId = 0
end

function UTGDataTemporary:StatusData()
  -- body
  self.GetNewType = ""
  self.PartShopType = "hero"
  self.BattleType = 1      --1：单人战斗（立刻退出战斗）   2：组队战斗（需投降）
  self.NewType = "New"    --永久："New"   体验类："Experience"
end

function UTGDataTemporary:RankNameColor()
  -- body
  self.rank1Top = {r = 211 ,g = 200 ,b = 248}
  self.rank1Bottom = {r = 119 ,g = 86 ,b = 231}
  self.rank2Top = {r = 170 ,g = 200 ,b = 219}
  self.rank2Bottom = {r = 92 ,g = 150 ,b = 180}
  self.rank3Top = {r = 220 ,g = 205 ,b = 137}
  self.rank3Bottom = {r = 188 ,g = 155 ,b = 37}
  self.rank4Top = {r = 159 ,g = 219 ,b = 248}
  self.rank4Bottom = {r = 75 ,g = 182 ,b = 245}
  self.rank5Top = {r = 211 ,g = 152 ,b = 246}
  self.rank5Bottom = {r = 173 ,g = 58 ,b = 231}
  self.rank6Top = {r = 255 ,g = 249 ,b = 101}
  self.rank6Bottom = {r = 255 ,g = 171 ,b = 0}  
end

function UTGDataTemporary:RuneDataInit()
  self.RunePageID = -1
  self.shopPageID = -1 --µ±Ç°µÚ¼¸¸öÉÌµêµÄÒ³Ç©ÊÇ¼¤»îµÄ£¬´Ó1¿ªÊ¼
end

function UTGDataTemporary:SaveData()
  -- body
  self.LimitedData = ""
end

