require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"

class("PlayerDataAPI")
local json = require "cjson"
----------------------------------------------------
function PlayerDataAPI:Awake(this)
    self.this = this
    -------------------------------------
    PlayerDataAPI.Instance = self;
    -------------------------------------
    self.prefab = self.this.transform:FindChild("PopChangeCell/Right/Left/Cell").gameObject
    self:SetParam()
end

----------------------------------------------------
function PlayerDataAPI:Start()

    --self:PlayerBattleStatsRequest(0 ) 
    self:ChangeFrame()
end

function PlayerDataAPI:Init(playerId)

    if (playerId == 0) then
        self.buttonChangeCell:SetActive(true)
        self.buttonChangeName:SetActive(true)
    else
        self.buttonChangeCell:SetActive(false)
        self.buttonChangeName:SetActive(false)
    end

    self.targetID = playerId;
    self:PlayerBattleStatsRequest(playerId)
end

function PlayerDataAPI:Show()

    local canvasGroup = self.this.gameObject:GetComponent("CanvasGroup")
    canvasGroup.alpha = 1;
    canvasGroup.blocksRaycasts = true;
end

----------------------------------------------------
function PlayerDataAPI:OnDestroy()
    coroutine.stop(self.coro_PlayerBattleStats)

    ------------------------------------
    PlayerDataAPI.Instance = nil;
    ------------------------------------
    self.this = nil
    self = nil
end

function PlayerDataAPI:Instantiate(prefab, parent)
    local go = GameObject.Instantiate(prefab);
    go.transform:SetParent(parent);
    go.transform.localScale = Vector3.one;
    go.transform.localPosition = Vector3.zero;
    go.gameObject:SetActive(true);
    return go;
end

function PlayerDataAPI:ChangeFrame()
    for i = 1, self.Page0.childCount do
        GameObject.Destroy(self.Page0:GetChild(i - 1).gameObject)
    end
    for i = 1, self.Page1.childCount do
        GameObject.Destroy(self.Page1:GetChild(i - 1).gameObject)
    end
    for i = 1, self.Page2.childCount do
        GameObject.Destroy(self.Page2:GetChild(i - 1).gameObject)
    end
    for i = 1, self.Page3.childCount do
        GameObject.Destroy(self.Page3:GetChild(i - 1).gameObject)
    end
    for i = 1, self.Page4.childCount do
        GameObject.Destroy(self.Page4:GetChild(i - 1).gameObject)
    end
    ----------------------------------- 深拷贝+排序--
    self.templateAvatarFrames = UITools.CopyTab(UTGData.Instance().AvatarFramesData);
    local tempTable = {}
    for k, v in pairs(self.templateAvatarFrames) do
        table.insert(tempTable, v)
    end
    table.sort(tempTable, function(a, b) return tonumber(a.Id) < tonumber(b.Id) end)
    self.templateAvatarFrames = tempTable
    ------------------------------------------------
    for k, v in pairs(self.templateAvatarFrames) do
        ------------------------------------------ 默认赋值右侧--
        if (UTGData.Instance().PlayerData.AvatarFrameId == v.Id) then
            self.frameIcon.sprite = UITools.GetSprite("frameicon", v.Icon);
            self.frameName.text = v.Name
            if (v.IsForever == true) then
                self.frameTime.text = "使用期限:永久使用"
            else
                self.frameTime.text = "使用期限:非永久使用"
            end
            self.frameQualification.text = v.Desc


            local listener = NTGEventTriggerProxy.Get(self.frameButtonUse) --事件
            listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
                self:ChangePlayerAvatarFrameRequest(v.Id)
            end, self)

            if (UTGData.Instance().PlayerAvatarFramesDeck[tostring(v.Id)] == nil or UTGData.Instance().PlayerData.AvatarFrameId == v.Id) then --如果没解锁
                self.frameQualificationGO:SetActive(true)
                self.frameButtonUse:SetActive(false);
            else
                self.frameQualificationGO:SetActive(false)
                self.frameButtonUse:SetActive(true);
            end
        end
        ------------------------------------------ 左侧分页赋值--


        local go = self:Instantiate(self.prefab, self.Page0)

        go.transform:FindChild("Icon"):GetComponent("Image").sprite = UITools.GetSprite("frameicon", v.Icon); --图片



        UITools.GetLuaScript(go, "Logic.UICommon.UIClick"):RegisterClickDelegate(self,
            function()

                self.frameIcon.sprite = UITools.GetSprite("frameicon", v.Icon);
                self.frameName.text = v.Name
                if (v.IsForever == true) then
                    self.frameTime.text = "使用期限:永久使用"
                else
                    self.frameTime.text = "使用期限:非永久使用"
                end
                self.frameQualification.text = v.Desc

                local listener = NTGEventTriggerProxy.Get(self.frameButtonUse) --事件
                listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
                    self:ChangePlayerAvatarFrameRequest(v.Id)
                end, self)

                if (UTGData.Instance().PlayerAvatarFramesDeck[tostring(v.Id)] == nil or UTGData.Instance().PlayerData.AvatarFrameId == v.Id) then --如果没解锁
                    self.frameQualificationGO:SetActive(true)
                    self.frameButtonUse:SetActive(false);
                else
                    self.frameQualificationGO:SetActive(false)
                    self.frameButtonUse:SetActive(true);
                end
            end)

        if (UTGData.Instance().PlayerData.AvatarFrameId == v.Id) then --是否使用中
            go.transform:FindChild("Used").gameObject:SetActive(true);
        else
            go.transform:FindChild("Used").gameObject:SetActive(false);
        end

        if (UTGData.Instance().PlayerAvatarFramesDeck[tostring(v.Id)] == nil) then --是否解锁
            go.transform:FindChild("Lock").gameObject:SetActive(true);
        else
            go.transform:FindChild("Lock").gameObject:SetActive(false);
        end

        ---------------------------------------------------------
        if (v.Type ~= 0) then
            local go;
            if (v.Type == 1) then
                go = self:Instantiate(self.prefab, self.Page1)
            elseif (v.Type == 2) then
                go = self:Instantiate(self.prefab, self.Page2)
            elseif (v.Type == 3) then
                go = self:Instantiate(self.prefab, self.Page3)
            elseif (v.Type == 4) then
                go = self:Instantiate(self.prefab, self.Page4)
            end

            go.transform:FindChild("Icon"):GetComponent("Image").sprite = UITools.GetSprite("frameicon", v.Icon); --图片




            UITools.GetLuaScript(go, "Logic.UICommon.UIClick"):RegisterClickDelegate(self,
                function()

                    self.frameIcon.sprite = UITools.GetSprite("frameicon", v.Icon);
                    self.frameName.text = v.Name
                    if (v.IsForever == true) then
                        self.frameTime.text = "使用期限:永久使用"
                    else
                        self.frameTime.text = "使用期限:非永久使用"
                    end
                    self.frameQualification.text = v.Desc

                    local listener = NTGEventTriggerProxy.Get(self.frameButtonUse) --事件
                    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
                        self:ChangePlayerAvatarFrameRequest(v.Id)
                    end, self)

                    if (UTGData.Instance().PlayerAvatarFramesDeck[tostring(v.Id)] == nil or UTGData.Instance().PlayerData.AvatarFrameId == v.Id) then --如果没解锁
                        self.frameQualificationGO:SetActive(true)
                        self.frameButtonUse:SetActive(false);
                    else
                        self.frameQualificationGO:SetActive(false)
                        self.frameButtonUse:SetActive(true);
                    end
                end)

            if (UTGData.Instance().PlayerData.AvatarFrameId == v.Id) then --是否使用中
                go.transform:FindChild("Used").gameObject:SetActive(true);
            else
                go.transform:FindChild("Used").gameObject:SetActive(false);
            end

            if (UTGData.Instance().PlayerAvatarFramesDeck[tostring(v.Id)] == nil) then --是否解锁
                go.transform:FindChild("Lock").gameObject:SetActive(true);
            else
                go.transform:FindChild("Lock").gameObject:SetActive(false);
            end
        end
        ---------------------------------------------------------
    end
end

------------------------------------------ 设置参数--
function PlayerDataAPI:SetParam()

    self.powerButtons = {}
    self.powerButtons["ButtonAddFriend"] = self.this.transform:FindChild("Right/1/Right/ButtonAddFriend").gameObject
    self.powerButtons["ButtonLeaderDemise"] = self.this.transform:FindChild("Right/1/Right/PowerButtons/ButtonLeaderDemise").gameObject
    self.powerButtons["ButtonAppointViceLeader"] = self.this.transform:FindChild("Right/1/Right/PowerButtons/ButtonAppointViceLeader").gameObject
    self.powerButtons["ButtonAppointCommander"] = self.this.transform:FindChild("Right/1/Right/PowerButtons/ButtonAppointCommander").gameObject
    self.powerButtons["ButtonKickMember"] = self.this.transform:FindChild("Right/1/Right/PowerButtons/ButtonKickMember").gameObject
    -------------------- 换头像框--

    self.frameIcon = self.this.transform:FindChild("PopChangeCell/Right/Right/Icon"):GetComponent("Image");
    self.frameName = self.this.transform:FindChild("PopChangeCell/Right/Right/Name"):GetComponent("Text");
    self.frameTime = self.this.transform:FindChild("PopChangeCell/Right/Right/DeadLine"):GetComponent("Text");
    self.frameQualificationGO = self.this.transform:FindChild("PopChangeCell/Right/Right/Qualification").gameObject
    self.frameQualification = self.this.transform:FindChild("PopChangeCell/Right/Right/Qualification"):GetComponent("Text");
    self.frameButtonUse = self.this.transform:FindChild("PopChangeCell/Right/Right/ButtonUse").gameObject;

    self.Page0 = self.this.transform:FindChild("PopChangeCell/Right/Left/ScrollView1/Viewport/Content")
    self.Page1 = self.this.transform:FindChild("PopChangeCell/Right/Left/ScrollView2/Viewport/Content")
    self.Page2 = self.this.transform:FindChild("PopChangeCell/Right/Left/ScrollView3/Viewport/Content")
    self.Page3 = self.this.transform:FindChild("PopChangeCell/Right/Left/ScrollView4/Viewport/Content")
    self.Page4 = self.this.transform:FindChild("PopChangeCell/Right/Left/ScrollView5/Viewport/Content")


    local listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("PopChangeCell/Left/Mask/ScrollRect/Menu/Button1").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        UITools.GetLuaScript(self.Page0:GetChild(0).gameObject, "Logic.UICommon.UIClick"):ExecuteClickDelegate()
        for i = 1, self.Page0.childCount do
            self.Page0:GetChild(i - 1).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = false
        end
        self.Page0:GetChild(0).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = true
    end, self)
    listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("PopChangeCell/Left/Mask/ScrollRect/Menu/Button2").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        UITools.GetLuaScript(self.Page1:GetChild(0).gameObject, "Logic.UICommon.UIClick"):ExecuteClickDelegate()
        for i = 1, self.Page1.childCount do
            self.Page1:GetChild(i - 1).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = false
        end
        self.Page1:GetChild(0).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = true
    end, self)
    listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("PopChangeCell/Left/Mask/ScrollRect/Menu/Button3").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        UITools.GetLuaScript(self.Page2:GetChild(0).gameObject, "Logic.UICommon.UIClick"):ExecuteClickDelegate()
        for i = 1, self.Page2.childCount do
            self.Page2:GetChild(i - 1).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = false
        end
        self.Page2:GetChild(0).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = true
    end, self)
    listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("PopChangeCell/Left/Mask/ScrollRect/Menu/Button4").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        UITools.GetLuaScript(self.Page3:GetChild(0).gameObject, "Logic.UICommon.UIClick"):ExecuteClickDelegate()
        for i = 1, self.Page3.childCount do
            self.Page3:GetChild(i - 1).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = false
        end
        self.Page3:GetChild(0).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = true
    end, self)
    listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("PopChangeCell/Left/Mask/ScrollRect/Menu/Button5").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        UITools.GetLuaScript(self.Page4:GetChild(0).gameObject, "Logic.UICommon.UIClick"):ExecuteClickDelegate()
        for i = 1, self.Page4.childCount do
            self.Page4:GetChild(i - 1).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = false
        end
        self.Page4:GetChild(0).gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = true
    end, self)
    --[[
      Debugger.LogError("-------------------------1--------------------------");
      for k,v in pairs(UTGData.Instance().AvatarFramesData) do
        Debugger.LogError(v.Id      );
        Debugger.LogError(v.Name              );
        Debugger.LogError(v.Type              );
        Debugger.LogError(v.Icon              );
        Debugger.LogError(v.IsForever         );
        Debugger.LogError(v.Desc              );
      end
      Debugger.LogError("-------------------------2--------------------------");
      for k,v in pairs(UTGData.Instance().PlayerAvatarFramesDeck) do
        Debugger.LogError(v.Id        );
        Debugger.LogError(v.PlayerId                    );
        Debugger.LogError(v.AvatarFrameId               );
        Debugger.LogError(v.EndTime                     );
        
      end
      --]]

    ---------------- 修改名字按钮--
    --[[移出
    self.inputField=self.this.transform:FindChild("PopChangeName/Center/Pop/InputField");
  
    self.buttonChangeNameEnter = self.this.transform:FindChild("PopChangeName/Center/Pop/Button").gameObject; 
    local listener = NTGEventTriggerProxy.Get(self.buttonChangeNameEnter)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( 
                function ()
  
                  self:ChangePlayerNameRequest( ) 
                end,self
                )
    --]]
    -------------------- 关闭按钮--
    self.buttonClose = self.this.transform:FindChild("ButtonClose").gameObject;
    local listener = NTGEventTriggerProxy.Get(self.buttonClose)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        Object.Destroy(self.this.gameObject)
        --[[
              local canvasGroup=self.this.transform:GetComponent("CanvasGroup");
        canvasGroup.alpha=0;
        canvasGroup.blocksRaycasts =false;   
        --]]
    end, self)
    --------------------------- 1--
    self.playerFrame = self.this.transform:FindChild("Right/1/TopLeft/Cell"):GetComponent("Image");
    self.playerIcon = self.this.transform:FindChild("Right/1/TopLeft/Icon"):GetComponent("Image");
    self.playerName = self.this.transform:FindChild("Right/1/TopLeft/Name"):GetComponent("Text");
    self.playerLevel = self.this.transform:FindChild("Right/1/TopLeft/Level"):GetComponent("Text");

    self.BattleCount = self.this.transform:FindChild("Right/1/BottomLeft/BattleCount"):GetComponent("Text");
    self.WinnerRate = self.this.transform:FindChild("Right/1/BottomLeft/WinnerRate"):GetComponent("Text");
    self.RoleCount = self.this.transform:FindChild("Right/1/BottomLeft/RoleCount"):GetComponent("Text");
    self.SkinCount = self.this.transform:FindChild("Right/1/BottomLeft/SkinCount"):GetComponent("Text");
    self.GuildName = self.this.transform:FindChild("Right/1/BottomLeft/GuildName").gameObject
    self.GuildPosition = self.this.transform:FindChild("Right/1/BottomLeft/GuildPosition").gameObject
    self.NoGuild = self.this.transform:FindChild("Right/1/BottomLeft/NoGuild").gameObject

    self.buttonRule1 = self.this.transform:FindChild("Right/1/TopLeft/ButtonRule").gameObject;
    local listener = NTGEventTriggerProxy.Get(self.buttonRule1)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        GameManager.CreatePanel("PageText")
        PageTextAPI.instance:Init("规则", "<size=26><color=#CCCDDF><color=#EF9B02>基本资料</color>\n计算除人机对战、房间模式以及活动玩法之外的场次和胜率\n\n<color=#EF9B02>对战资料</color>\n荣誉累计和场次、胜率均不包括人机对战和房间模式。\n\n<color=#EF9B02>常用姬神</color>\n记录<color=#EF9B02>已拥有的姬神</color>的使用场次、胜率以及姬神熟练度（不计算人机对战和房间模式）</color></size>")
    end, self)
    self.buttonChangeCell = self.this.transform:FindChild("Right/1/Right/ButtonChangeCell").gameObject;
    local listener = NTGEventTriggerProxy.Get(self.buttonChangeCell)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()

        self.this.transform:FindChild("PopChangeCell").gameObject:SetActive(true);
    end, self)

    self.buttonChangeName = self.this.transform:FindChild("Right/1/Right/ButtonChangeName").gameObject;
    local listener = NTGEventTriggerProxy.Get(self.buttonChangeName)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        GameManager.CreatePanel("ChangeName")
        --PlayerDataAPI.Instance:InitNoticeForSelfHideNotice("发送好友请求成功")
        --self.this.transform:FindChild("PopChangeName").gameObject:SetActive(true);
    end, self)

    --------------------------- 2--
    self.WinnerMvp = self.this.transform:FindChild("Right/2/Left/WinnerMvp"):GetComponent("Text");
    self.LoserMvp = self.this.transform:FindChild("Right/2/Left/LoserMvp"):GetComponent("Text");
    self.Legendary = self.this.transform:FindChild("Right/2/Left/Legendary"):GetComponent("Text");
    self.PentaKill = self.this.transform:FindChild("Right/2/Left/PentaKill"):GetComponent("Text");
    self.QuadraKill = self.this.transform:FindChild("Right/2/Left/QuadraKill"):GetComponent("Text");
    self.TripleKill = self.this.transform:FindChild("Right/2/Left/TripleKill"):GetComponent("Text");

    self.BattleCount1 = self.this.transform:FindChild("Right/2/Right/1V1"):GetComponent("Text");
    self.WinnerRate1 = self.this.transform:FindChild("Right/2/Right/1V1WinnerRate"):GetComponent("Text");
    self.WinnerRate1Bar = self.this.transform:FindChild("Right/2/Right/1V1Scrollbar"):GetComponent("Image");
    self.BattleCount3 = self.this.transform:FindChild("Right/2/Right/3V3"):GetComponent("Text");
    self.WinnerRate3 = self.this.transform:FindChild("Right/2/Right/3V3WinnerRate"):GetComponent("Text");
    self.WinnerRate3Bar = self.this.transform:FindChild("Right/2/Right/3V3Scrollbar"):GetComponent("Image");
    self.BattleCount5 = self.this.transform:FindChild("Right/2/Right/5V5"):GetComponent("Text");
    self.WinnerRate5 = self.this.transform:FindChild("Right/2/Right/5V5WinnerRate"):GetComponent("Text");
    self.WinnerRate5Bar = self.this.transform:FindChild("Right/2/Right/5V5Scrollbar"):GetComponent("Image");
    self.BattleCount7 = self.this.transform:FindChild("Right/2/Right/Scuffle"):GetComponent("Text");
    self.WinnerRate7 = self.this.transform:FindChild("Right/2/Right/ScuffleWinnerRate"):GetComponent("Text");
    self.WinnerRate7Bar = self.this.transform:FindChild("Right/2/Right/ScuffleScrollbar"):GetComponent("Image");
    --------------------------- 3--
    self.Honor1 = self.this.transform:FindChild("Right/3/Left/ToggleGroup/Toggle1")
    self.Honor2 = self.this.transform:FindChild("Right/3/Left/ToggleGroup/Toggle2")
    self.Honor3 = self.this.transform:FindChild("Right/3/Left/ToggleGroup/Toggle3")
    self.Honor4 = self.this.transform:FindChild("Right/3/Left/ToggleGroup/Toggle4")
    self.Honor5 = self.this.transform:FindChild("Right/3/Left/ToggleGroup/Toggle5")
    self.Honor6 = self.this.transform:FindChild("Right/3/Left/ToggleGroup/Toggle6")
    self.Honors = {}
    table.insert(self.Honors, self.Honor1)
    table.insert(self.Honors, self.Honor2)
    table.insert(self.Honors, self.Honor3)
    table.insert(self.Honors, self.Honor4)
    table.insert(self.Honors, self.Honor5)
    table.insert(self.Honors, self.Honor6)

    self.HonorIcon = self.this.transform:FindChild("Right/3/Right/Icon"):GetComponent("Image");
    self.HonorName = self.this.transform:FindChild("Right/3/Right/Name"):GetComponent("Text");
    self.HonorNumber = self.this.transform:FindChild("Right/3/Right/Number"):GetComponent("Text");
    self.HonorDesc = self.this.transform:FindChild("Right/3/Right/Desc"):GetComponent("Text");
    self.HonorButtonUse = self.this.transform:FindChild("Right/3/Right/ButtonUse").gameObject
    self.HonorButtonUseBlack = self.this.transform:FindChild("Right/3/Right/ButtonUseBlack").gameObject
    self.HonorButtonUsed = self.this.transform:FindChild("Right/3/Right/ButtonUsed").gameObject
    self.HonorButtonBrowse = self.this.transform:FindChild("Right/3/Right/ButtonBrowse").gameObject

    --------------------------- 4--
    local content = self.this.transform:FindChild("Right/4/Left/ScrollView/Viewport/Content");
    self.tableHero = {}
    for i = 1, 10, 1 do
        table.insert(self.tableHero, content:GetChild(i - 1));
    end

    self.buttonRule4 = self.this.transform:FindChild("Right/4/Right/ButtonRule").gameObject;
    local listener = NTGEventTriggerProxy.Get(self.buttonRule4)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        GameManager.CreatePanel("PageText")
        PageTextAPI.instance:Init("规则", "<size=26><color=#CCCDDF><color=#EF9B02>基本资料</color>\n计算除人机对战、房间模式以及活动玩法之外的场次和胜率\n\n<color=#EF9B02>对战资料</color>\n荣誉累计和场次、胜率均不包括人机对战和房间模式。\n\n<color=#EF9B02>常用姬神</color>\n记录<color=#EF9B02>已拥有的姬神</color>的使用场次、胜率以及姬神熟练度（不计算人机对战和房间模式）</color></size>")
    end, self)
    --------------------------- 5--
    self.CreditNumber = self.this.transform:FindChild("Right/5/Left/Num");
    self.CreditStar = self.this.transform:FindChild("Right/5/Left/Star");

    self.buttonRule5 = self.this.transform:FindChild("Right/5/Right/ButtonRule").gameObject;
    local listener = NTGEventTriggerProxy.Get(self.buttonRule5)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
        GameManager.CreatePanel("PageText")
        PageTextAPI.instance:Init("信誉积分", "<size=26><color=#CCCDDF><color=#FFFFFF>游戏信誉积分规则</color>\n1、指挥官的初始分数都是满分<color=#EF9B02>100分</color>\n\n2、您的<color=#EF9B02>违规行为</color>\n会扣除一定的信誉积分，请注意：\n多人对战中，<color=#EF9B02>挂机</color>（ 包括人机），每次扣除<color=#EF9B02>2~5分</color>；\n多人对战中，如果被其他<color=#EF9B02>玩家举报</color>，而且系统判定该次举报为有效举报时，将会扣除<color=#EF9B02>3分</color>；\n多人对战中，如果同时被其他<color=#EF9B02>多名玩家同时举报 </color>，并且经系统判定该次举报为有效举报时，将会额外扣除<color=#EF9B02>3分</color>；\n匹配成功时，<color=#EF9B02>不点击确定</color>，每次扣除<color=#EF9B02>1分</color>，并且暂时<color=#EF9B02>无法加入匹配队列</color>。\n\n3、您在对战中<color=#EF9B02>表现良好</color>，可以恢复信誉积分，请加油：\n<color=#EF9B02>正常完成一局多人对战</color>，无论输赢每局增加<color=#EF9B02>1分</color>。\n如果您在对战过程中出现违规行为，将会收到扣分处罚！\n\n4、如果信誉积分低于 <color=#EF9B02>70分</color>，将<color=#EF9B02>禁止参加排位赛</color>！\n\n5、信誉积分会让您获得<color=#EF9B02>信誉评级</color>，不同的分数对应不同的评级：\n80~100分评级为<color=#EF9B02>优</color>\n60~79分评级为<color=#EF9B02>良 </color>\n0~59分评级为<color=#EF9B02>差</color>\n希望各位指挥官加油努力，创造和谐友爱的游戏环境！</color></size>")
    end, self)
end

---------------------------------- 获取玩家玩家资料--
function PlayerDataAPI:PlayerBattleStatsRequest(playerId)

    local request = NetRequest.New()
    request.Content = JObject.New(JProperty.New("Type", "RequestPlayerBattleStats"),
        JProperty.New("PlayerId", playerId))
    request.Handler = TGNetService.NetEventHanlderSelf(self.PlayerBattleStatsResponseHandler, self)
    TGNetService.GetInstance():SendRequest(request)
end

--------------------------------------------------
function PlayerDataAPI:PlayerBattleStatsResponseHandler(e)
    if e.Type == "RequestPlayerBattleStats" then
        --self.coro = NTGLuaCoroutine.New(self,self.PlayerBattleStatsResponseHandlerCoro,e)
        --self.this:StopCoroutine(v)
        self.coro_PlayerBattleStats = coroutine.start(self.PlayerBattleStatsResponseHandlerCoro, self, e)
        --self.this:StopAllCoroutines()

        --self:PlayerBattleStatsResponseHandlerCoro(e)
        return true;
    else
        return false;
    end
end

function PlayerDataAPI:UpdatePlayerName()
    self.playerName.text = UTGData.Instance().PlayerData.Name
end

function PlayerDataAPI:UpdatePlayerFrame()
    self.playerFrame.sprite = UITools.GetSprite("frameicon", UTGData.Instance().AvatarFramesData[tostring(UTGData.Instance().PlayerData.AvatarFrameId)].Icon);
end

function PlayerDataAPI:PlayerBattleStatsResponseHandlerCoro(e)
    if (self.this == nil or self.this.gameObject == nil) then return end
    if e.Type == "RequestPlayerBattleStats" then

        local data = json.decode(e.Content:ToString())

        if (data.Result == 0) then
            --- -Debugger.LogError("失败");
        elseif (data.Result == 1) then
            --- -Debugger.LogError("成功");
            ----------------------------- 1--
            self.playerIcon.sprite = UITools.GetSprite("roleicon", data.Stats.PlayerIcon); --玩家头像
            self.playerFrame.sprite = UITools.GetSprite("frameicon", UTGData.Instance().AvatarFramesData[tostring(data.Stats.PlayerIconFrameId)].Icon);
            --Debugger.LogError(type( data.Stats.AvatarFrameId ))  
            self.playerName.text = data.Stats.PlayerName --玩家名称
            self.playerLevel.text = "LV." .. data.Stats.PlayerLevel --玩家等级

            self.BattleCount.text = "共" .. data.Stats.E.BattleCount .. "场" --除人机以及开房间模式以外，总共场数
            if (data.Stats.E.BattleCount == 0) then
                self.WinnerRate.text = "0%"
            else
                self.WinnerRate.text = math.floor(100 * (data.Stats.E.WinnerCount / data.Stats.E.BattleCount)) .. "%"
            end
            --除人机以及开房间模式以外，胜率(省略%，精确到小数点后两位)
            self.RoleCount.text = "姬神" .. data.Stats.RoleCount .. "个" --拥有姬神的数量
            self.SkinCount.text = "皮肤" .. data.Stats.SkinCount .. "个" --拥有皮肤的数量

            if (data.Stats.GuildName == "") then
                self.NoGuild:SetActive(true)
                self.GuildName.gameObject:SetActive(false)
                self.GuildPosition.gameObject:SetActive(false)
            else
                self.NoGuild:SetActive(false)
                self.GuildName.gameObject:SetActive(true)
                self.GuildPosition.gameObject:SetActive(true)
                self.GuildName.text = data.Stats.GuildName --战队名(为空则没有加入战队)
                self.GuildPosition.text = data.Stats.GuildPosition --战队身份
            end


            ----------------------------- 2--
            self.WinnerMvp.text = data.Stats.T.WinnerMvp .. "次" --int // 胜方MVP
            self.LoserMvp.text = data.Stats.T.LoserMvp .. "次" --int // 败方MVP
            self.Legendary.text = data.Stats.T.Legendary .. "次" --int // 超神
            self.PentaKill.text = data.Stats.T.PentaKill .. "次" --int // 五杀
            self.QuadraKill.text = data.Stats.T.QuadraKill .. "次" --int // 四杀
            self.TripleKill.text = data.Stats.T.TripleKill .. "次" --int // 三杀

            for k, v in pairs(data.Stats.TypeBattles) do
                if (v.BattleType == 1) then
                    self.BattleCount1.text = v.BattleCount .. "场" --1v1   
                    if (v.BattleCount ~= 0) then
                        self.WinnerRate1.text = math.floor(100 * (v.WinnerCount / v.BattleCount)) .. "%"
                        self.WinnerRate1Bar.fillAmount = v.WinnerCount / v.BattleCount
                    end
                elseif (v.BattleType == 3) then
                    self.BattleCount3.text = v.BattleCount .. "场" --1v1   
                    if (v.BattleCount ~= 0) then
                        self.WinnerRate3.text = math.floor(100 * (v.WinnerCount / v.BattleCount)) .. "%"
                        self.WinnerRate3Bar.fillAmount = v.WinnerCount / v.BattleCount
                    end
                elseif (v.BattleType == 5) then
                    self.BattleCount5.text = v.BattleCount .. "场" --1v1   
                    if (v.BattleCount ~= 0) then
                        self.WinnerRate5.text = math.floor(100 * (v.WinnerCount / v.BattleCount)) .. "%"
                        self.WinnerRate5Bar.fillAmount = v.WinnerCount / v.BattleCount
                    end
                elseif (v.BattleType == 7) then
                    self.BattleCount7.text = v.BattleCount .. "场" --1v1   
                    if (v.BattleCount ~= 0) then
                        self.WinnerRate7.text = math.floor(100 * (v.WinnerCount / v.BattleCount)) .. "%"
                        self.WinnerRate7Bar.fillAmount = v.WinnerCount / v.BattleCount
                    end
                end
            end

            ----------------------------- 3--
            --[[
          data.Stats.TypeHonors[1] --王者之尊    
          data.Stats.TypeHonors[2] --无畏之盾 
          data.Stats.TypeHonors[3] --庇护之光
          data.Stats.TypeHonors[4] --破军之矛 
          data.Stats.TypeHonors[5] --富可敌国
          data.Stats.TypeHonors[6] --杀戮之影      
            --]]




            self.tableCopy = UITools.CopyTab(data.Stats.TypeHonors);

            table.sort(self.tableCopy,
                function(a, b)

                    local OrderA;
                    for k, v in pairs(UTGData.Instance().BattleHonorsData) do
                        if (a.HonorType == v.Type) then
                            OrderA = v.Order;
                            break;
                        end
                    end

                    local OrderB;
                    for k, v in pairs(UTGData.Instance().BattleHonorsData) do
                        if (b.HonorType == v.Type) then
                            OrderB = v.Order;
                            break;
                        end
                    end

                    return OrderA < OrderB;
                end)





            local i = 0;
            for k, v in pairs(self.tableCopy) do
                i = i + 1;
                local num;
                local icon;
                local desc;
                local name;
                local k = i;
                local honorId = v.HonorId;
                if (v.HonorId == 0) then
                    for k1, v1 in pairs(UTGData.Instance().BattleHonorsData) do
                        if (v1.Type == v.HonorType and v1.Level == 1) then
                            num = v.Count .. "/" .. v1.Unlock;
                            self.Honors[i]:FindChild("Text"):GetComponent("Text").text = num;
                            desc = v1.Desc;
                            name = v1.Name;
                        end
                    end

                    icon = UITools.GetSprite("honoricon", "HaveNo");
                    self.Honors[i]:FindChild("Icon"):GetComponent("Image").sprite = icon;



                else



                    for k1, v1 in pairs(UTGData.Instance().BattleHonorsData) do
                        if (v.HonorId == v1.Id) then
                            --v1.Type   v1.Level
                            for k2, v2 in pairs(UTGData.Instance().BattleHonorsData) do
                                if (v2.Type == v1.Type and v2.Level == v1.Level + 1) then
                                    num = v.Count .. "/" .. v2.Unlock;
                                    self.Honors[i]:FindChild("Text"):GetComponent("Text").text = num;
                                    break;
                                end
                            end
                        end
                    end

                    icon = UITools.GetSprite("honoricon", UTGData.Instance().BattleHonorsData[tostring(v.HonorId)].Icon);
                    self.Honors[i]:FindChild("Icon"):GetComponent("Image").sprite = icon;



                    desc = UTGData.Instance().BattleHonorsData[tostring(v.HonorId)].Desc;
                    name = UTGData.Instance().BattleHonorsData[tostring(v.HonorId)].Name;
                end

                local listener = NTGEventTriggerProxy.Get(self.Honors[i].gameObject)
                listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()

                    self.HonorIcon.sprite = icon;
                    self.HonorName.text = name;
                    self.HonorNumber.text = num;
                    self.HonorDesc.text = desc;

                    if (self.targetID == 0) then
                        if (honorId == 0) then
                            self.HonorButtonUse:SetActive(false); self.HonorButtonUsed:SetActive(false); self.HonorButtonBrowse:SetActive(false); self.HonorButtonUseBlack:SetActive(true);
                        else
                            if (data.Stats.E.HonorInUse == 0 or data.Stats.E.HonorInUse ~= k) then
                                self.HonorButtonUse:SetActive(true); self.HonorButtonUsed:SetActive(false); self.HonorButtonBrowse:SetActive(false); self.HonorButtonUseBlack:SetActive(false);
                                local listener = NTGEventTriggerProxy.Get(self.HonorButtonUse)
                                listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(function()
                                    self:ChangeUsingBattleHonorRequest(k) --honorType 
                                end, self);
                            else
                                self.HonorButtonUse:SetActive(false); self.HonorButtonUsed:SetActive(true); self.HonorButtonBrowse:SetActive(false); self.HonorButtonUseBlack:SetActive(false);
                            end
                        end
                    else
                        self.HonorButtonUse:SetActive(false); self.HonorButtonUsed:SetActive(false); self.HonorButtonBrowse:SetActive(true); self.HonorButtonUseBlack:SetActive(false);
                    end
                end, self)

                -----------------------------
                if (data.Stats.E.HonorInUse == 0) then --最开始并没有使用中的勋章
                    if (v.HonorType == 1) then --默认填入第一种类型
                        self.HonorIcon.sprite = icon;
                        self.HonorName.text = name;
                        self.HonorNumber.text = num;
                        self.HonorDesc.text = desc;
                        self.HonorButtonUse:SetActive(false); self.HonorButtonUsed:SetActive(false); self.HonorButtonBrowse:SetActive(false); self.HonorButtonUseBlack:SetActive(true);

                        --for i=1,#self.Honors do
                        --    self.Honors[i].gameObject:GetComponent("UnityEngine.UI.Toggle").isOn=false
                        --end
                        self.Honors[1].gameObject:GetComponent("UnityEngine.UI.Toggle").isOn = true
                    end
                end
                if (data.Stats.E.HonorInUse == i) then
                    self.Honors[i]:FindChild("Used").gameObject:SetActive(true);

                    self.HonorIcon.sprite = icon;
                    self.HonorName.text = name;
                    self.HonorNumber.text = num;
                    self.HonorDesc.text = desc;
                    self.HonorButtonUse:SetActive(false); self.HonorButtonUsed:SetActive(true); self.HonorButtonBrowse:SetActive(false); self.HonorButtonUseBlack:SetActive(false); --这里不需要注册事件，使用中本来就不能按
                else
                    self.Honors[i]:FindChild("Used").gameObject:SetActive(false);
                end
                -----------------------------
            end
            ----------------------------- 4--

            table.sort(data.Stats.UsualRoles, function(a, b) return tonumber(a.BattleCount) > tonumber(b.BattleCount) end)
            local n = 0;
            for k, v in pairs(data.Stats.UsualRoles) do

                n = n + 1;
                if (n > 10) then break; end
                self.tableHero[n].gameObject:SetActive(true);
                self.tableHero[n]:FindChild("BattleCount"):GetComponent("Text").text = tostring(v.BattleCount)
                self.tableHero[n]:FindChild("WinnerRate"):GetComponent("Text").text = math.floor(100 * (v.WinnerCount / v.BattleCount)) .. "%"

                self.tableHero[n]:FindChild("IconMask/Icon"):GetComponent("Image").sprite =
                UITools.GetSprite("portrait", UTGData.Instance().SkinsData[tostring(UTGData.Instance().RolesData[tostring(v.RoleId)].Skin)].Portrait);

                self.tableHero[n]:FindChild("Name"):GetComponent("Text").text = UTGData.Instance().RolesData[tostring(v.RoleId)].Name;

                --熟练度            
                if (v.ProficiencyId == 0) then
                    self.tableHero[n]:FindChild("Proficiency"):GetComponent("Image").sprite =
                    UITools.GetSprite("icon", "Ishuliandu-1");
                else
                    self.tableHero[n]:FindChild("Proficiency"):GetComponent("Image").sprite =
                    UITools.GetSprite("icon", "Ishuliandu-" .. UTGData.Instance().RoleProficiencysData[tostring(v.ProficiencyId)].Quality);
                end
            end
            ----------------------------- 5--

            local s = tostring(data.Stats.E.Credit); --数字        --int // 信誉积分

            local length = #s
            for i = 1, 3, 1 do
                if (i <= length) then
                    self.CreditNumber:GetChild(i - 1):GetComponent("Image").sprite = UITools.GetSprite("ranknum", string.sub(s, i, i));
                    self.CreditNumber:GetChild(i - 1).gameObject:SetActive(true);
                else
                    self.CreditNumber:GetChild(i - 1).gameObject:SetActive(false);
                end
            end
            if (data.Stats.E.Credit >= 0 and data.Stats.E.Credit < 60) then --星星
                self.CreditStar:GetChild(0).gameObject:SetActive(true);
                self.CreditStar:GetChild(1).gameObject:SetActive(false);
                self.CreditStar:GetChild(2).gameObject:SetActive(false);
            elseif (data.Stats.E.Credit >= 60 and data.Stats.E.Credit < 80) then
                self.CreditStar:GetChild(0).gameObject:SetActive(true);
                self.CreditStar:GetChild(1).gameObject:SetActive(true);
                self.CreditStar:GetChild(2).gameObject:SetActive(false);
            elseif (data.Stats.E.Credit >= 80 and data.Stats.E.Credit <= 100) then
                self.CreditStar:GetChild(0).gameObject:SetActive(true);
                self.CreditStar:GetChild(1).gameObject:SetActive(true);
                self.CreditStar:GetChild(2).gameObject:SetActive(true);
            end
            --------------------------------
            --[[待用
        data.Stats.VipLevel            --int    // 玩家VIP等级
        data.Stats.HonorInUse          --int // 使用中的荣耀勋章的类型
        data.Stats.CurrentWinningCount --int // 当前连胜场数（不包括人机和开房间模式）
        data.Stats.EverMaxWinningCount --int // 最大连胜场数（不包括人机和开房间模式
        --]]

            --[[待用
            data.Stats.Survivor   --int // 死亡最少
            data.Stats.DPS        --int // 输出最多
            data.Stats.Assist     --int // 助攻最多
            data.Stats.Killer     --int // 杀人最多
            data.Stats.Tank       --int // 承受伤害最多
            data.Stats.Rusher     --int // 推塔最多
            data.Stats.Rich       --int // 金币最多
            data.Stats.Deserter   --int // 逃跑
            --]]
        end

        --return true;
    else

        --return false; 
    end
    self:Show()
end

-------------------------------------- 使用荣耀勋章--
function PlayerDataAPI:ChangeUsingBattleHonorRequest(honorType)
    --Debugger.LogError(tostring(honorType))
    local request = NetRequest.New()
    request.Content = JObject.New(JProperty.New("Type", "RequestChangeUsingBattleHonor"),
        JProperty.New("HonorType", honorType))
    request.Handler = TGNetService.NetEventHanlderSelf(self.ChangeUsingBattleHonorResponseHandler, self)
    TGNetService.GetInstance():SendRequest(request)
end

----------------------------------------------------
function PlayerDataAPI:ChangeUsingBattleHonorResponseHandler(e)

    if e.Type == "RequestChangeUsingBattleHonor" then

        local data = json.decode(e.Content:ToString())

        if (data.Result == 0) then
            --- -Debugger.LogError("失败");
        elseif (data.Result == 1) then
            --Debugger.LogError("使用荣耀勋章成功");
            self:PlayerBattleStatsRequest(self.targetID)
        end

        return true;
    else
        return false;
    end
end

--[[
------------------------------------------修改名字--
function PlayerDataAPI:ChangePlayerNameRequest( ) 
  
  if(self.inputField:GetComponent("UnityEngine.UI.InputField").text == "" )then
    GameManager.CreatePanel("Hint");
    HintAPI.Instance:Hint( "请输入名字");
    return;
  end
  if( UITools.WidthOfString(self.inputField:GetComponent("UnityEngine.UI.InputField").text,0)>12 )then
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("名字最长为6个中文字或12个英文字");
    return;
  end
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestChangePlayerName"),
                                  JProperty.New("NewName",self.inputField:GetComponent("UnityEngine.UI.InputField").text)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ChangePlayerNameResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end


--]]
---------------------------------------- 更换头像框--
function PlayerDataAPI:ChangePlayerAvatarFrameRequest(avatarFrameId)

    local request = NetRequest.New()
    request.Content = JObject.New(JProperty.New("Type", "RequestChangePlayerAvatarFrame"),
        JProperty.New("AvatarFrameId", avatarFrameId))
    request.Handler = TGNetService.NetEventHanlderSelf(self.ChangePlayerAvatarFrameResponseHandler, self)
    TGNetService.GetInstance():SendRequest(request)
end

----------------------------------------------------
function PlayerDataAPI:ChangePlayerAvatarFrameResponseHandler(e)

    if e.Type == "RequestChangePlayerAvatarFrame" then

        local data = json.decode(e.Content:ToString())
        --Debugger.LogError(data.Result)
        if (data.Result == 0) then
            --- -Debugger.LogError("失败");
        elseif (data.Result == 1) then
            GameManager.CreatePanel("Hint");
            HintAPI.Instance:Hint("修改头像框成功");
        end

        return true;
    else
        return false;
    end
end

----------------------------------------------------
function PlayerDataAPI:ShowButton(buttonString, fuc, obj)
    --[[
    for k,v in pairs(self.powerButtons) do
      v:SetActive(false)
    end
    --]]
    self.powerButtons[buttonString]:SetActive(true)


    local listener = NTGEventTriggerProxy.Get(self.powerButtons[buttonString]) --事件
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(fuc, obj)
end