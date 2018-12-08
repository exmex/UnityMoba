require "System.Global"

class("FriendWindowCtrl")

function FriendWindowCtrl:Awake(this)
  self.this = this
  FriendWindowCtrl.Instance=self;
  self.newBattle15Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.barTemp = this.transforms[1]
  self.barsRoot = this.transforms[2]
end

function FriendWindowCtrl:Start()
  self:Init()
end

function FriendWindowCtrl:Init() 
  self.friendList = UTGData.Instance().FriendList
  self.friendBars = {} 
  self:ShowFriendList(self.friendList) 
end

function FriendWindowCtrl:ShowFriendList(friendList)
  if friendList == nil then 
    self.barTemp.gameObject:SetActive(false)
    return 
  end
  
  for i = 1,self.barsRoot.childCount do
      GameObject.Destroy(self.barsRoot:GetChild(i-1).gameObject)
  end
  
  for k,v in pairs(friendList) do  -- Debugger.LogError(#UTGData.Instance().currentAllowGradeCategorys)
    if v.Status ~= 0 then
      local go = GameObject.Instantiate(self.barTemp.gameObject)
      go:SetActive(true)
      go.transform:SetParent(self.barsRoot)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.zero 
      
      local canInvite=false 
      --nil是Room不需要限制  0个约定好普通模式费排位没有限制
      if(UTGData.Instance().currentAllowGradeCategorys==nil or #UTGData.Instance().currentAllowGradeCategorys==0)then
        canInvite=true
      else
        for kI,vI in pairs(UTGData.Instance().currentAllowGradeCategorys) do --Debugger.LogError(v.BattleRank) Debugger.LogError(vI) 
          if(v.BattleRank==vI)then
            canInvite=true
            break
          end
        end
      end
      
      
      go.transform:GetComponent("NTGLuaScript").self:SetBar(v.Status, v.Name, v.PlayerId, v.Avatar,v.AvatarFrameId,canInvite)
     
      table.insert(self.friendBars, go:GetComponent("NTGLuaScript").self)
    end
  end
  for k,v in pairs(friendList) do   
    if v.Status == 0 then
      local go = GameObject.Instantiate(self.barTemp.gameObject)
      go:SetActive(true)
      go.transform:SetParent(self.barsRoot)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.zero
      
      local canInvite=false 
      --nil是Room不需要限制  0个约定好普通模式费排位没有限制
      if(UTGData.Instance().currentAllowGradeCategorys==nil or #UTGData.Instance().currentAllowGradeCategorys==0)then
        canInvite=true
      else
        for kI,vI in pairs(UTGData.Instance().currentAllowGradeCategorys) do --Debugger.LogError(v.BattleRank) Debugger.LogError(vI) 
          if(v.BattleRank==vI)then
            canInvite=true
            break
          end
        end
      end
  
      go.transform:GetComponent("NTGLuaScript").self:SetBar(v.Status, v.Name, v.PlayerId, v.Avatar,v.AvatarFrameId,canInvite)
      table.insert(self.friendBars, go:GetComponent("NTGLuaScript").self)
    end
  end
  self.barTemp.gameObject:SetActive(false)
end

function FriendWindowCtrl:UpdateFriendInfo(playerId, status) 
--[[
  for k,v in ipairs(self.friendBars) do
    if v.playerId == playerId then
      v:SetBar(status)
      return
    end
  end
]]
  self.friendList = UTGData.Instance().FriendList
  local friendListOnLine = {}
  local friendListOffLine = {}
  for k,v in pairs(self.friendList) do
    if v.Status ~= 0 then
      table.insert(friendListOnLine,v)
    else
      table.insert(friendListOffLine,v)
    end
  end



  local count = 0
  for i = 1,#self.friendBars do
    for k = #friendListOnLine,1,-1 do
      if friendListOnLine[k].Status ~= 0 then

        local canInvite=false 
        --nil是Room不需要限制  0个约定好普通模式费排位没有限制
        if(UTGData.Instance().currentAllowGradeCategorys==nil or #UTGData.Instance().currentAllowGradeCategorys==0)then
          canInvite=true
        else
          for kI,vI in pairs(UTGData.Instance().currentAllowGradeCategorys) do --Debugger.LogError(v.BattleRank) Debugger.LogError(vI) 
            if(friendListOnLine[k].BattleRank==vI)then
              canInvite=true
              break
            end
          end
        end
  
        self.friendBars[i]:SetBar(friendListOnLine[k].Status,friendListOnLine[k].Name,friendListOnLine[k].PlayerId,friendListOnLine[k].Avatar,friendListOnLine[k].AvatarFrameId,canInvite)
        table.remove(friendListOnLine,k)
        count = count + 1
        break
      end
    end
  end
  
  for i = count+1,#self.friendBars do
    for k = #friendListOffLine,1,-1 do
      if friendListOffLine[k].Status == 0 then

        local canInvite=false 
        --nil是Room不需要限制  0个约定好普通模式费排位没有限制
        if(UTGData.Instance().currentAllowGradeCategorys==nil or #UTGData.Instance().currentAllowGradeCategorys==0)then
          canInvite=true
        else
          for kI,vI in pairs(UTGData.Instance().currentAllowGradeCategorys) do --Debugger.LogError(v.BattleRank) Debugger.LogError(vI) 
            if(friendListOffLine[k].BattleRank==vI)then
              canInvite=true
              break
            end
          end
        end

        self.friendBars[i]:SetBar(friendListOffLine[k].Status,friendListOffLine[k].Name,friendListOffLine[k].PlayerId,friendListOffLine[k].Avatar,friendListOffLine[k].AvatarFrameId,canInvite)
        table.remove(friendListOffLine,k)
        break
      end
    end
  end


end 

function FriendWindowCtrl:InviteFriend(playerId)
  self.newBattle15Ctrl.self:InviteMember(playerId)
end

function FriendWindowCtrl:OnDestroy()
  self.this = nil
  self = nil
end