require "System.Global"

class("NewBattle15Ctrl")

local json = require "cjson"

function NewBattle15Ctrl:Awake(this)
    self.this = this
    self.modeInfosCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
    self.friendWindowCtrl = this.transforms[1]:GetComponent("NTGLuaScript")
    self.teamOneCtrl = this.transforms[2]:GetComponent("NTGLuaScript")
    self.teamTwoCtrl = this.transforms[3]:GetComponent("NTGLuaScript")
    self.startGameBtn = this.transforms[4]
    --self.backBtn = this.transforms[5]:GetComponent("UnityEngine.UI.Button")
    self.changeWindow = this.transforms[6]
    self.refuseBtn = this.transforms[7]
    self.agreedBtn = this.transforms[8]
    self.changeMsg = this.transforms[9]:GetComponent("UnityEngine.UI.Text")
    self.timer = this.transforms[10]:GetComponent("UnityEngine.UI.Text")
    self.zhanDuiBtn = this.transforms[11]

    self.gradeTip = this.transform:FindChild("Grade-Tip")

    self.RoomChangeHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnRoomChangeHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyRoomChange", self.RoomChangeHandler, 0)

    self.PartyChangeHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnPartyChangeHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyPartyChange", self.PartyChangeHandler, 0)

    --队伍/对手匹配开始通知 
    self.MergeMatchStartHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnMergeMatchStartHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyMergeMatchStart", self.MergeMatchStartHandler, 0)
    --匹配结果通知(如果匹配成功，则已经进行了Party合并)
    self.MatchResultHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnMatchResultHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyBattleMatchResult", self.MatchResultHandler, 0)

    --Room换位请求通知
    self.NotifyPosChangeReqHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnNotifyPosChangeReqHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyPosChangeReq", self.NotifyPosChangeReqHandler, 0)
    --Room换位失败通知
    self.NotifyPosChangeFailureHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnNotifyPosChangeFailureHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyPosChangeFailure", self.NotifyPosChangeFailureHandler, 0)

    --拒绝邀请通知
    self.NotifyRejectionHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnNotifyRejectionHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyRejection", self.NotifyRejectionHandler, 0)
    --被踢通知
    self.EvictionHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnEvictionHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyEviction", self.EvictionHandler, 0)
    --Party解散通知
    self.NotifyPartyDismissedHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnNotifyPartyDismissedHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyPartyDismissed", self.NotifyPartyDismissedHandler, 0)
    --征召数据 - 临时存储
    self.NotifyBattleDraftChangeHandler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.OnNotifyBattleDraftChangeHandler, self)
    TGNetService.GetInstance():AddEventHandler("NotifyBattleDraftChange", self.NotifyBattleDraftChangeHandler, 0)
end

function NewBattle15Ctrl:Start()
    self:Init()
end

function NewBattle15Ctrl:Init()
    self.hasRoomOrParty = false

    self.matchIsStart = false

    self.partyCurrCount = 0

    --TGNetService.GetInstance():AddEventHandler("NotifyInvitation", TGNetServiceNetEventHanlderSelf( NewBattle15Ctrl.OnInvitationHandler),self, 0)



    local listener
    listener = NTGEventTriggerProxy.Get(self.startGameBtn.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(NewBattle15Ctrl.OnStartGameBtnClick, self)

    listener = NTGEventTriggerProxy.Get(self.zhanDuiBtn.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(NewBattle15Ctrl.OnZhanDuiBtnClick, self)

    listener = NTGEventTriggerProxy.Get(self.refuseBtn.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(NewBattle15Ctrl.OnRefuseBtnClick, self)

    listener = NTGEventTriggerProxy.Get(self.agreedBtn.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(NewBattle15Ctrl.OnAgreedBtnClick, self)
end

function NewBattle15Ctrl:OnZhanDuiBtnClick(...)
    local function CreatePanelAsync()
        local async = GameManager.CreatePanelAsync("SelfHideNotice")
        while async.Done == false do
            coroutine.step()
        end
        if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
        end
    end

    coroutine.start(CreatePanelAsync, self)
end

function NewBattle15Ctrl:OnNotifyPartyDismissedHandler(e)
    --Debugger.LogError("收到Party解散通知")
    --print("222222")
    if MatchingAPI ~= nil and MatchingAPI.Instance ~= nil then MatchingAPI.Instance:DestroySelf() end

    local function CreatePanelAsync()
        local async = GameManager.CreatePanelAsync("SelfHideNotice")
        while async.Done == false do
            coroutine.step()
        end
        if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("队伍解散")
        end
        NewBattle15API.Instance:DestroySelf()
    end

    coroutine.start(CreatePanelAsync, self)
end

function NewBattle15Ctrl:OnNotifyPosChangeFailureHandler(e)
    --Debugger.LogError("收到拒绝换位通知")

    local function CreatePanelAsync()
        local async = GameManager.CreatePanelAsync("SelfHideNotice")
        while async.Done == false do
            coroutine.step()
        end
        if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("被请求方拒绝换位")
        end
    end

    coroutine.start(CreatePanelAsync, self)

    return true
end

function NewBattle15Ctrl:OnNotifyRejectionHandler(e)
    --Debugger.LogError("收到邀请失败通知")
    local rejecterId = tonumber(e.Content:get_Item("RejecterId"):ToString())
    self:UpdateFriendInfo(rejecterId, 5)
    return true
end

--------------------------- 同意&拒绝按钮-------------------------
function NewBattle15Ctrl:OnRefuseBtnClick()
    local refuseRequest = NetRequest.New()
    refuseRequest.Content = JObject.New(JProperty.New("Type", "RequestAnswerPositionChange"),
        JProperty.New("Agree", false))
    refuseRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.RefuseHandler, self)
    TGNetService.GetInstance():SendRequest(refuseRequest)
end

function NewBattle15Ctrl:RefuseHandler(e)
    if e.Type == "RequestAnswerPositionChange" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            --Debugger.LogError("拒绝换位请求发送成功")
            self.changeWindow.gameObject:SetActive(false)
        end
        return true
    else
        return false
    end
end

function NewBattle15Ctrl:OnAgreedBtnClick()
    local agreedRequest = NetRequest.New()
    agreedRequest.Content = JObject.New(JProperty.New("Type", "RequestAnswerPositionChange"),
        JProperty.New("Agree", true))
    agreedRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.AgreedHandler, self)
    TGNetService.GetInstance():SendRequest(agreedRequest)
end

function NewBattle15Ctrl:AgreedHandler(e)
    if e.Type == "RequestAnswerPositionChange" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            --Debugger.LogError("同意换位请求发送成功")
            self.changeWindow.gameObject:SetActive(false)
        end
        return true
    else
        return false
    end
end

-----------------------------------------------------------------
function NewBattle15Ctrl:OnNotifyPosChangeReqHandler(e)
    --Debugger.LogError("房间换位请求通知")
    if e.Type == "NotifyPosChangeReq" then
        local pos = tonumber(e.Content:get_Item("RequesterPos"):ToString())
        local seconds = tonumber(e.Content:get_Item("Seconds"):ToString())
        --换位请求倒计时的剩余时间
        self.changeTime = seconds
        self.Coro_CountDown = coroutine.start(NewBattle15Ctrl.CountDown, self)
        self.changeWindow.gameObject:SetActive(true)
        self.changeMsg.text = pos .. "号位玩家请求与你换位"
        --local teamNo = tostring(e.RequesterTeam)
        --local changePlayerId = tostring(e.RequesterId)
        local selfBar
        if self.teamOneCtrl.self:GetPalyerBarByPlayerId(UTGData.Instance().PlayerData.Id) ~= nil then
            selfBar = self.teamOneCtrl.self:GetPalyerBarByPlayerId(UTGData.Instance().PlayerData.Id)
        else
            selfBar = self.teamTwoCtrl.self:GetPalyerBarByPlayerId(UTGData.Instance().PlayerData.Id)
        end
        self.changeWindow.transform.position = selfBar.transform.position
    end
    return true
end

function NewBattle15Ctrl:CountDown()
    self.timer.text = tostring(self.changeTime)
    while (true) do
        self.changeTime = self.changeTime - 1
        coroutine.wait(1)
        self.timer.text = tostring(self.changeTime)
        if self.changeTime <= 0 then
            self.changeWindow.gameObject:SetActive(false)
            break
        end
    end
end

function NewBattle15Ctrl:UpdateFriendInfo(playerId, status)
    self.friendWindowCtrl.self:UpdateFriendInfo(playerId, status)
end

function NewBattle15Ctrl:UpdateFriendList()
    -- body
    self.friendWindowCtrl.self:Init()
end

function NewBattle15Ctrl:OnEvictionHandler(e)
    --Debugger.LogError("收到被踢通知")
    if e.Type == "NotifyEviction" then

        local function CreatePanelAsync()
            local async = GameManager.CreatePanelAsync("SelfHideNotice")
            while async.Done == false do
                coroutine.step()
            end
            if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
                SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您被踢出房间")
                --UTGMainPanelAPI.Instance:ShowSelf() 
                NewBattle15API.Instance:DestroySelf()
            end
        end

        coroutine.start(CreatePanelAsync, self)
    end
    return true
end

function NewBattle15Ctrl:OnMergeMatchStartHandler(e)
    --Debugger.LogError("收到MergeMatchStart匹配通知")
    if e.Type == "NotifyMergeMatchStart" then

        local data = json.decode(e.Content:ToString())
        UTGDataOperator.Instance.matchTime = data.Seconds;

        if self.playerCount == 1 then
            self:StartMatch(true)
            return true
        end
        --由于不能再创建Party时立刻去拿现在玩家数所以在这里拿
        local partyCurrCount = self.teamOneCtrl.self:GetHeroCount()

        if partyCurrCount == self.partyMaxCount then
            self:StartMatch(true)
        else
            self:StartMatch(true)
        end
    end
    return true
end

function NewBattle15Ctrl:OnMatchResultHandler(e)
    --Debugger.LogError("收到匹配结果通知")
    if e.Type == "NotifyBattleMatchResult" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            local seconds = tonumber(e.Content:get_Item("Seconds"):ToString())
            local mainType = tonumber(e.Content:get_Item("BMainType"):ToString())
            local subType = tonumber(e.Content:get_Item("BSubType"):ToString())
            local teamB = json.decode(e.Content:get_Item("TeamB"):ToString())
            local teamA = json.decode(e.Content:get_Item("TeamA"):ToString())
            if teamB == nil or teamA == nil then
                --Debugger.LogError("没有party数据")
            end

            local selfplayerid = UTGData.Instance().PlayerData.Id
            local isOwnParty = false
            local selfPartyId = 0
            for i = 1, #teamB.Members do
                if teamB.Members[i].PlayerId == selfplayerid then
                    isOwnParty = true
                    break
                end
            end
            local selfPartyData = {}
            if isOwnParty == true then
                selfPartyData = teamB
                selfPartyId = teamB.Id
            else
                selfPartyData = teamA
                selfPartyId = teamA.Id
            end

            --Debugger.LogError("房间开始游戏成功")
            self:GoToHeroSelect(mainType, subType, seconds, selfPartyData)
        else
            --Debugger.LogError("房间开始游戏失败")
        end
        return true
    end
    return true
end

function NewBattle15Ctrl:OnNotifyBattleDraftChangeHandler(e)
    if e.Type == "NotifyBattleDraftChange" then
        UTGDataTemporary.Instance().DraftContent = e
        self:GoToDraftHeroSelect()
        return true
    end
    return true
end

--创建 征召界面
function NewBattle15Ctrl:GoToDraftHeroSelect()
    local function CreatePanelAsync()
        local async = GameManager.CreatePanelAsync("DraftHeroSelect")
        while async.Done == false do
            coroutine.step()
        end
        NewBattle15API.Instance:DestroySelf()
    end

    coroutine.start(CreatePanelAsync, self)
end

--创建 角色选择界面
function NewBattle15Ctrl:GoToHeroSelect(mainType, subType, seconds, partyData)
    local function CreatePanelAsync()
        local async = GameManager.CreatePanelAsync("PVPHeroSelect")
        while async.Done == false do
            coroutine.step()
        end
        if PVPHeroSelectAPI ~= nil and PVPHeroSelectAPI.Instance ~= nil then
            PVPHeroSelectAPI.Instance:SetParam(mainType, subType, seconds, partyData)
        end
        NewBattle15API.Instance:DestroySelf()
    end

    coroutine.start(CreatePanelAsync, self)
end

function NewBattle15Ctrl:GetMapNameBySubType(subType)
    local mapName = ""
    if subType == 10 then
        mapName = "红枫桥门"
    elseif subType == 30 then
        mapName = "拉法叶公路"
    elseif subType == 50 then
        mapName = "战争岛屿"
    elseif subType == 51 then
        mapName = "酒吧大乱斗"
    elseif subType == 52 then
        mapName = "战争岛屿-征召"
    elseif subType >= 60 and subType <= 66 then
        mapName = "战争岛屿"
    elseif subType == 80 then
        mapName = "克隆大作战"
    end
    return mapName
end

function NewBattle15Ctrl:OnRoomChangeHandler(e)
    if self.matchIsStart then return true end
    --Debugger.LogError("收到Room变化通知")
    if e.Type == "NotifyRoomChange" then
        local roomInfo = json.decode(e.Content:get_Item("RoomInfo"):ToString())
        --初始化聊天
        NewBattle15API.Instance:InitChat("15Room", { RoomId = roomInfo.Id })

        if self.hasRoomOrParty == false then
            local mapName = self:GetMapNameBySubType(roomInfo.BSubType)
            local count = roomInfo.MMaxCount / 2
            --Debugger.LogError("BSubType=="..roomInfo.BSubType)

            self:InitRoom(mapName, roomInfo.BMainType, count)
        end
        self.teamOneCtrl.self:UpdateTeam(roomInfo.Members, roomInfo.Owner, 2, roomInfo.BSubType)
        self.teamTwoCtrl.self:UpdateTeam(roomInfo.Members, roomInfo.Owner, 2, roomInfo.BSubType)

        if self.teamOneCtrl.self:GetHeroCount() > 0 and self.teamTwoCtrl.self:GetHeroCount() > 0 then
            self.canStartGame = true
            self.startGameBtn:GetComponent("UnityEngine.UI.Button").interactable = true
        else
            self.startGameBtn:GetComponent("UnityEngine.UI.Button").interactable = false
            self.canStartGame = false
        end

        if roomInfo.Owner ~= UTGData.Instance().PlayerData.Id then
            self.startGameBtn.gameObject:SetActive(false)
        else
            self.startGameBtn.gameObject:SetActive(true)
        end

        self.members = roomInfo.Members
    end
    return true
end

function NewBattle15Ctrl:UntilFriend()
    while (true) do
        coroutine.step()
        if (FriendWindowCtrl.Instance == nil and FriendWindowCtrl.Instance.Instance == nil) then

        else
            FriendWindowCtrl.Instance:Init()
            break
        end
    end
end

function NewBattle15Ctrl:OnPartyChangeHandler(e)
    if self.matchIsStart then return true end
    --Debugger.LogError("收到Party变化通知") 
    if e.Type == "NotifyPartyChange" then
        local partyInfo = json.decode(e.Content:get_Item("PartyInfo"):ToString())
        --初始化聊天
        if partyInfo.MMaxCount > 1 then
            NewBattle15API.Instance:InitChat("15Party", { PartyId = partyInfo.Id })
        end

        --征召模式
        local subType = partyInfo.BSubType
        if subType == 52 then
            UTGDataTemporary.Instance().DraftPartyContent = e
        end
        self:SetGradeTip(partyInfo.AllowGradeCategorys)
        if (self.canInitFirendList ~= false) then
            UTGData.Instance().currentAllowGradeCategorys = partyInfo.AllowGradeCategorys --标记当前可以邀请段位
            self.coroUntil2 = coroutine.start(self.UntilFriend, self)
            self.canInitFirendList = false
        end

        --party现在的人数
        self.partyCurrCount = #partyInfo.Members
        --party的最大人数
        self.partyMaxCount = partyInfo.MMaxCount

        self.members = partyInfo.Members

        if self.mainModeCode == 1 and self.partyMaxCount == 1 then return true end

        if self.hasRoomOrParty == false then
            local mapName = self:GetMapNameBySubType(partyInfo.BSubType)
            local count = partyInfo.MMaxCount

            if partyInfo.BSubType == 10 then
                return true
            end

            self:InitParty(mapName, partyInfo.BMainType, count)
        end

        self.teamOneCtrl.self:UpdateTeam(partyInfo.Members, partyInfo.Leader, 1)

        if partyInfo.Leader ~= UTGData.Instance().PlayerData.Id then
            self.startGameBtn.gameObject:SetActive(false)
        else
            self.startGameBtn.gameObject:SetActive(true)
        end

        return true
    end
    return false
end

function NewBattle15Ctrl:StartMatch(needOther)
    --[[local function CreatePanelAsync()
            local async = GameManager.CreatePanelAsync("Matching")
            while async.Done == false do
              coroutine.step()
            end
            if needOther == false and MatchingAPI.Instance ~= nil then MatchingAPI.Instance:CancelButtonControl(1) end
          end
    coroutine.start( CreatePanelAsync,self)]]
    --Debugger.LogError("needOther == "..tostring(needOther))
    self.matchIsStart = true

    GameManager.CreatePanel("Matching")
    if needOther == false and MatchingAPI ~= nil and MatchingAPI.Instance ~= nil then MatchingAPI.Instance:CancelButtonControl(0) end

    for i = 1, (GameManager.PanelRoot.transform.childCount - 1) do
        if (GameManager.PanelRoot.transform:GetChild(i - 1).name ~= "UTGMainPanel") then
            Object.Destroy(GameManager.PanelRoot.transform:GetChild(i - 1).gameObject)
        end
    end

    UTGMainPanelAPI.Instance:ShowSelf()
end

------------------------------ 开始游戏按钮----------------------------
function NewBattle15Ctrl:OnStartGameBtnClick()
    if self.subTypeCode == 52 then --征召必须满员
        for k, v in pairs(self.members) do
            if v.PlayerId <= 0 then
                GameManager.CreatePanel("SelfHideNotice")
                SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("无法开始游戏：征召模式人数未满不能开始游戏")
                return
            end
        end
    end

    if self.canStartGame == false then return end
    self.matchIsStart = true
    local startMatchRequest = NetRequest.New()
    if self.groupType == 1 then
        startMatchRequest.Content = JObject.New(JProperty.New("Type", "RequestStartMatch"))
        startMatchRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.StartMatchRequestHandler, self)
        TGNetService.GetInstance():SendRequest(startMatchRequest)
    end
    if self.groupType == 2 then
        startMatchRequest.Content = JObject.New(JProperty.New("Type", "RequestStartRoomBattle"))
        startMatchRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.StartRoomBattleHandler, self)
        TGNetService.GetInstance():SendRequest(startMatchRequest)
    end
end


--邀请好友 段位tip
function NewBattle15Ctrl:SetGradeTip(categoryIds)
    if self.initSetGradeTip then return end
    categoryIds = categoryIds or {}
    if #categoryIds == 0 then return end
    local nameStr = ""
    for i = 1, #categoryIds do
        for k, v in pairs(UTGData.Instance().GradesData) do
            if v.Category == categoryIds[i] then
                nameStr = nameStr .. v.CategoryName
                if i ~= #categoryIds then
                    nameStr = nameStr .. ","
                end
                break
            end
        end
    end
    local str = string.format("组队段位：<color=#29F3F3FF>%s</color> 好友组队", nameStr)
    self.gradeTip.gameObject:SetActive(true)
    self.gradeTip:FindChild("Text"):GetComponent("UnityEngine.UI.Text").text = str
    self.initSetGradeTip = true
end

function NewBattle15Ctrl:StartMatchRequestHandler(e)
    --Debugger.LogError("收到开始匹配响应")
    if e.Type == "RequestStartMatch" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 521 then
            --self:StartMatch(false)
            --Debugger.LogError("Party等待Match")
        end
        if result == 520 then
            --self:StartMatch(true)
            --Debugger.LogError("Party等待Merge")
        end
        self.matchIsStart = false
        return true
    else
        --Debugger.LogError("开始匹配失败")
        return false
    end
end

function NewBattle15Ctrl:StartRoomBattleHandler(e)
    --Debugger.LogError("收到Room开始游戏响应")
    if e.Type == "RequestStartRoomBattle" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            --Debugger.LogError("Room开始游戏成功")
        end
        --Debugger.LogError("Room开始游戏失败")
        self.matchIsStart = false
        return true
    else
        return false
    end
end

----------------------------------------------------------------------
function NewBattle15Ctrl:OnBackBtnClick()
    local reqType
    if self.groupType == 1 then reqType = "RequestLeaveParty" end
    if self.groupType == 2 then reqType = "RequestLeaveRoom" end

    local leaveTeamRequest = NetRequest.New()
    leaveTeamRequest.Content = JObject.New(JProperty.New("Type", reqType))
    leaveTeamRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.LeaveTeamHandler, self)
    TGNetService.GetInstance():SendRequest(leaveTeamRequest)

    NewBattle15API.Instance:DestroySelf()
end

function NewBattle15Ctrl:LeaveTeamHandler(e)
    --Debugger.LogError("收到离开队伍响应")

    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
        --Debugger.LogError("离开队伍成功")
        return true
    end
    --Debugger.LogError("离开队伍失败")
    return false
end


function NewBattle15Ctrl:InitRoom(mapName, mainModeCode, playerCount)
    self.hasRoomOrParty = true
    self.groupType = 2
    self.modeInfosCtrl.self:ShowModeInfo(mapName, mainModeCode, playerCount)
    self.teamOneCtrl.self:InitRoomGame(playerCount)
    self.teamTwoCtrl.self:InitRoomGame(playerCount)
    NewBattle15API.Instance:SetPanelActive(true)
end

function NewBattle15Ctrl:InitParty(mapName, mainModeCode, playerCount)
    if mainModeCode == 1 and playerCount == 1 then return end
    self.hasRoomOrParty = true
    self.groupType = 1
    self.modeInfosCtrl.self:ShowModeInfo(mapName, mainModeCode, playerCount)
    self.teamOneCtrl.self:InitPartyGame(playerCount)
    self.teamTwoCtrl.gameObject:SetActive(false)
    if playerCount ~= 1 then
        NewBattle15API.Instance:SetPanelActive(true)
    end
end

--mainModeCode == 4是room模式
--groupType == 2 是room模式
function NewBattle15Ctrl:CreateRoom(mapName, playerCount, subTypeCode)
    self.mapName = mapName
    self.playerCount = playerCount
    self.mainModeCode = 4
    self.subTypeCode = subTypeCode
    --NewBattle15API.Instance:SetPanelActive(true)

    local startMatchRequest = NetRequest.New()
    startMatchRequest.Content = JObject.New(JProperty.New("Type", "RequestCreateRoom"),
        JProperty.New("BSubType", subTypeCode))
    startMatchRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.CreateRoomHandler, self)
    TGNetService.GetInstance():SendRequest(startMatchRequest)
end

function NewBattle15Ctrl:CreateRoomHandler(e)
    if e.Type == "RequestCreateRoom" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            self.coroUntil1 = coroutine.start(self.UntilFriend, self)
            --Debugger.LogError("创建Room成功")
            return true
        end
        --Debugger.LogError("创建Room失败")
    end
    return true
end

--mainModeCode == 1是party模式
--groupType == 1是party模式
--param mapName:地图名字，playerCount：玩家数量，mainType：模式type，difficulty：如果是人机，需要难度type
function NewBattle15Ctrl:CreateParty(mapName, playerCount, subTypeCode, mainType, difficulty)
    print(mapName, " ", playerCount, " ", subTypeCode, " ", mainType, " ", difficulty)
    self.mapName = mapName
    self.playerCount = playerCount
    self.mainModeCode = mainType
    self.subTypeCode = subTypeCode
    difficulty = difficulty or 0
    self:CreatePartyRequest(self.mainModeCode, self.subTypeCode, difficulty)
end

function NewBattle15Ctrl:CreatePartyRequest(mainType, subType, difficulty)
    difficulty = difficulty or 0

    --JProperty.New("BDifficulty", difficulty)
    local startMatchRequest = NetRequest.New()
    startMatchRequest.Content = JObject.New(JProperty.New("Type", "RequestCreateParty"),
        JProperty.New("BMainType", mainType),
        JProperty.New("BSubType", subType),
        JProperty.New("BDifficulty", difficulty))
    startMatchRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.CreatePartyHandler, self)
    TGNetService.GetInstance():SendRequest(startMatchRequest)
end

function NewBattle15Ctrl:CreatePartyHandler(e)
    if (PVPPanelCtrl ~= nil and PVPPanelCtrl.Instance ~= nil) then
        PVPPanelCtrl.Instance:Reset();
    end
    if (ComputerPanelCtrl ~= nil and ComputerPanelCtrl.Instance ~= nil) then
        ComputerPanelCtrl.Instance:Reset();
    end

    --Debugger.LogError("收到Party创建响应") 
    if e.Type == "RequestCreateParty" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            --Debugger.LogError("Party创建成功") 
            return true
        end
    end
    --Debugger.LogError("Party创建失败") 
    return true
end

function NewBattle15Ctrl:InviteMember(playerId)
    local inviteMemberRequest = NetRequest.New()
    inviteMemberRequest.Content = JObject.New(JProperty.New("Type", "RequestInvite"),
        JProperty.New("GroupType", self.groupType),
        JProperty.New("Invitee", playerId))
    inviteMemberRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.InviteMemberHandler, self)
    TGNetService.GetInstance():SendRequest(inviteMemberRequest)
end

function NewBattle15Ctrl:InviteMemberHandler(e)
    --Debugger.LogError("收到邀请请求响应")
    if e.Type == "RequestInvite" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            --Debugger.LogError("邀请请求发送成功")
        elseif result == 0x0803 then
            GameManager.CreatePanel("SelfHideNotice")
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您的好友排位赛并未开启！")
            --Debugger.LogError("当前不在任何赛季中")  
        elseif result == 0x0111 then
            GameManager.CreatePanel("SelfHideNotice")
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您的好友排位赛并未开启！")
            --Debugger.LogError("玩家等级不够")  
        elseif result == 0x0112 then
            GameManager.CreatePanel("SelfHideNotice")
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您的好友排位赛并未开启！")
            --Debugger.LogError("玩家英雄不足")  
        elseif result == 0x030d then
            GameManager.CreatePanel("SelfHideNotice")
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该玩家段位不在范围内")
            --Debugger.LogError("要邀请玩家的玩家段位相差太大")  
        elseif result == 0x0311 then
            GameManager.CreatePanel("SelfHideNotice")
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该玩家可用姬神少于12个")
        end
        return true
    else
        return false
    end
end

function NewBattle15Ctrl:KickMember(teamNo, pos)
    local evicteeId
    if self.groupType == 1 then
        evicteeId = self.members[pos].PlayerId
    end
    if self.groupType == 2 then
        if teamNo == 1 then
            evicteeId = self.members[pos].PlayerId
        end
        if teamNo == 2 then
            evicteeId = self.members[(#self.members / 2) + pos].PlayerId
        end
    end
    local kickBtnRequest = NetRequest.New()
    kickBtnRequest.Content = JObject.New(JProperty.New("Type", "RequestKickMember"),
        JProperty.New("GroupType", self.groupType),
        JProperty.New("EvicteeID", evicteeId),
        JProperty.New("EvicteeTeam", teamNo),
        JProperty.New("EvicteePos", pos))
    kickBtnRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.KickMemberHandler, self)
    TGNetService.GetInstance():SendRequest(kickBtnRequest)
end

function NewBattle15Ctrl:KickMemberHandler(e)
    --Debugger.LogError("踢人请求响应")
    if e.Type == "RequestAnswerInvitation" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            --Debugger.LogError("踢人请求发送成功")
        end
    end
    return true
end

function NewBattle15Ctrl:ChangePos(teamNo, pos)
    local changePosRequest = NetRequest.New()
    changePosRequest.Content = JObject.New(JProperty.New("Type", "RequestChangePosition"),
        JProperty.New("DstTeam", teamNo),
        JProperty.New("DstPos", pos))
    changePosRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.ChangePosHandler, self)
    TGNetService.GetInstance():SendRequest(changePosRequest)
end

--[[function NewBattle15Ctrl:AcceptInviation()
  local acceptInviationRequest = NetRequest.New()
  acceptInviationRequest.Content = JObject.New(JProperty.New("Type","RequestAnswerInvitation"),
                                      JProperty.New("GroupType", self.inviteGroupType),
                                      JProperty.New("GroupId", self.inviteGroupId),
                                      JProperty.New("Agree", 1),
                                      JProperty.New("Inviter", self.inviteId))
  acceptInviationRequest.Handler = TGNetService.NetEventHanlderSelf( NewBattle15Ctrl.AcceptInviationHandler,self)
  TGNetService.GetInstance():SendRequest(acceptInviationRequest)
  NoticeAPI.Instance:DestroySelf()
end]]

--[[function NewBattle15Ctrl:AcceptInviationHandler(e)
  if e.Type == "RequestAnswerInvitation" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      Debugger.LogError("同意邀请请求发送成功")
    end
  end
  return true
end]]

function NewBattle15Ctrl:RefusedInviation()
    local refusedInviationRequest = NetRequest.New()
    refusedInviationRequest.Content = JObject.New(JProperty.New("Type", "RequestAnswerInvitation"),
        JProperty.New("GroupType", self.inviteGroupType),
        JProperty.New("GroupId", self.inviteGroupId),
        JProperty.New("Agree", 0),
        JProperty.New("Inviter", self.inviteId))
    refusedInviationRequest.Handler = TGNetService.NetEventHanlderSelf(NewBattle15Ctrl.RefusedInviationHandler, self)
    TGNetService.GetInstance():SendRequest(refusedInviationRequest)
    NoticeAPI.Instance:DestroySelf()
end

function NewBattle15Ctrl:RefusedInviationHandler(e)
    --Debugger.LogError("拒绝邀请请求响应")
    if e.Type == "RequestAnswerInvitation" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            --Debugger.LogError("拒绝邀请请求发送成功")
        end
    end
    return true
end

function NewBattle15Ctrl:ChangePosHandler(e)
    --Debugger.LogError("换位请求响应")
    if e.Type == "RequestChangePosition" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 775 then
            --Debugger.LogError("等待对方答复")
        end
        if result == 772 then

            local function CreatePanelAsync()
                local async = GameManager.CreatePanelAsync("SelfHideNotice")
                while async.Done == false do
                    coroutine.step()
                end
                if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
                    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("你正处于换位中")
                end
            end

            coroutine.start(CreatePanelAsync, self)
        end

        if result == 773 then
            local function CreatePanelAsync()
                local async = GameManager.CreatePanelAsync("SelfHideNotice")
                while async.Done == false do
                    coroutine.step()
                end
                if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
                    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("对方正处于换位中")
                end
            end

            coroutine.start(CreatePanelAsync, self)
        end
    end
    return true
end

function NewBattle15Ctrl:OnDestroy()
    if (self.coroUntil1 ~= nil) then
        coroutine.stop(self.coroUntil1)
    end
    if (self.coroUntil2 ~= nil) then
        coroutine.stop(self.coroUntil2)
    end
    if (self.Coro_CountDown ~= nil) then
        coroutine.stop(self.Coro_CountDown)
    end

    self.hasRoomOrParty = false

    TGNetService.GetInstance():RemoveEventHander("NotifyRoomChange", self.RoomChangeHandler)
    TGNetService.GetInstance():RemoveEventHander("NotifyPartyChange", self.PartyChangeHandler)
    TGNetService.GetInstance():RemoveEventHander("NotifyBattleMatchResult", self.MatchResultHandler)
    TGNetService.GetInstance():RemoveEventHander("NotifyMergeMatchStart", self.MergeMatchStartHandler)
    TGNetService.GetInstance():RemoveEventHander("NotifyEviction", self.EvictionHandler)
    TGNetService.GetInstance():RemoveEventHander("NotifyPartyDismissed", self.NotifyPartyDismissedHandler)
    TGNetService.GetInstance():RemoveEventHander("NotifyPosChangeReq", self.NotifyPosChangeReqHandler)
    TGNetService.GetInstance():RemoveEventHander("NotifyRejection", self.NotifyRejectionHandler)
    TGNetService.GetInstance():RemoveEventHander("NotifyPosChangeFailure", self.NotifyPosChangeFailureHandler)
    TGNetService.GetInstance():RemoveEventHander("NotifyBattleDraftChange", self.NotifyBattleDraftChangeHandler)

    self.this = nil

    self.changeMsg.font = nil
    self.timer.font = nil

    self = nil
end