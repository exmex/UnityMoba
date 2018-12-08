require "System.Global"
require "Logic.UTGData.UTGData"

class("NoticeController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"

function NoticeController:Awake(this)
  self.this = this
  
  self.noticeFrame = self.this.transforms[0]
  
  --提示框标题
  self.noticeTitle = self.noticeFrame:Find("Title-image/Title-label")
  
  --提示信息1
  self.noticeInfo = self.noticeFrame:Find("TextPanel/NoticeInfo")
  
  --提示信息2
  self.noticeInfo2 = self.noticeFrame:Find("TextPanel/NoticeInfo2")
  
  --button类型1
  self.buttonType1 = self.noticeFrame:Find("ButtonType1")
  self.button = self.noticeFrame:Find("ButtonType1/ButtonMid")

  --button类型2
  self.buttonType2 = self.noticeFrame:Find("ButtonType2")
  self.buttonLeftInType2 = self.buttonType2:Find("ButtonLeft")
  self.buttonRightInType2 = self.buttonType2:Find("ButtonRight")

  --button类型3
  self.buttonType3 = self.noticeFrame:Find("ButtonType3")
  self.buttonLongInType3 = self.buttonType3:Find("ButtonLong")
  self.buttonShortYellow = self.buttonType3:Find("ButtonShortYellow")

  --button类型4
  self.buttonType4 = self.noticeFrame:Find("ButtonType4")
  self.buttonLongInType4 = self.buttonType4:Find("ButtonLong")
  self.buttonShortBlue = self.buttonType4:Find("ButtonShortBlue")

  --ImagePanel
  self.imagePanel = self.noticeFrame:Find("ImagePanel")

  self.closeButton = self.noticeFrame:Find("CloseButton")

  self.tip = self.noticeFrame:Find("ItemTip")
  self.camera = GameObject.Find("GameLogic"):GetComponent("Camera")
  self.fx = self.noticeFrame:Find("R51140310")

  self.subItem = {}
  for i = 1,5 do
    table.insert(self.subItem,self.imagePanel:GetChild(i-1))
  end

  local listener = NTGEventTriggerProxy.Get(self.closeButton.gameObject)
  local callback = function(self, e)
    self:DestroySelf()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)

  self.closeButton.gameObject:SetActive(false)


  
end

function NoticeController:Start()

end

function NoticeController:InitNotice(title,info1,showInfo2,info2,buttonType,showImage)  --title:string  info1:string  showInfo2:bool  info2:string  
                                                                --buttonType:int---1:显示一个 2：显示两个 3：显示一长一短（黄色短按钮）4：显示一长一短（蓝色短按钮） 0:不显示
                                                                --showImage:true/false
  --初始化
  self.noticeTitle:GetComponent(Text).text = ""
  self.noticeInfo:GetComponent(Text).text = ""
  self.noticeInfo2:GetComponent(Text).text = ""
  self.buttonType1.gameObject:SetActive(false)
  self.buttonType2.gameObject:SetActive(false)
  self.buttonType3.gameObject:SetActive(false)
  self.buttonType4.gameObject:SetActive(false)
  
  --实现

  self.noticeTitle:GetComponent(Text).text = title
  self.noticeInfo:GetComponent(Text).text = info1
  if showInfo2 == true then
    self.noticeInfo2:GetComponent(Text).text = info2
  else
    self.noticeInfo2:GetComponent(Text).text = ""
  end
  --print("asdfasdfasdf0.6")
  if buttonType == 0 then
    self.buttonType1.gameObject:SetActive(false)
    self.buttonType2.gameObject:SetActive(false)
    self.buttonType3.gameObject:SetActive(false)
    self.buttonType4.gameObject:SetActive(false)
  elseif buttonType == 1 then
    self.buttonType1.gameObject:SetActive(true)
    self.buttonType2.gameObject:SetActive(false)
    self.buttonType3.gameObject:SetActive(false)
    self.buttonType4.gameObject:SetActive(false)
  elseif buttonType == 2 then
    self.buttonType1.gameObject:SetActive(false)
    self.buttonType2.gameObject:SetActive(true)
    self.buttonType3.gameObject:SetActive(false)
    self.buttonType4.gameObject:SetActive(false)
  elseif buttonType == 3 then
    self.buttonType1.gameObject:SetActive(false)
    self.buttonType2.gameObject:SetActive(false)
    self.buttonType3.gameObject:SetActive(true)
    self.buttonType4.gameObject:SetActive(false)
  elseif buttonType == 4 then   
    self.buttonType1.gameObject:SetActive(false)
    self.buttonType2.gameObject:SetActive(false)
    self.buttonType3.gameObject:SetActive(false)
    self.buttonType4.gameObject:SetActive(true)
  end

  if showImage == true then
    self.imagePanel.gameObject:SetActive(true)
  else
    self.imagePanel.gameObject:SetActive(false)
  end
end

function NoticeController:HideCloseButton(isHide)
  -- body
  if ifHide == true then
    self.closeButton.gameObject:SetActive(false)
  else
    self.closeButton.gameObject:SetActive(true)
  end
end

function NoticeController:ImagePanelControl(list)
  -- body
  --print("asdfasdfasdf1")
  for i = 1,#list do
    local itemName = ""
    local itemNum = 0
    local itemDesc = ""
    self.subItem[i].gameObject:SetActive(true)

    if list[i].IsRare ~= nil then
      --print("IsRare " .. tostring(list[i].IsRare))
      if list[i].IsRare == true then
          local btn = self.subItem[i]:Find("R51140550"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
          for k = 0,btn.Length - 1 do
            self.subItem[i]:Find("R51140550"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
          end       
      else
        self.subItem[i]:Find("R51140550").gameObject:SetActive(false)
      end
    else
      self.subItem[i]:Find("R51140550").gameObject:SetActive(false)
    end

    --print("asdfasdfasdf2 " .. list[i].Type)
    if list[i].Type == 4 then
     -- print("asdfasdfasdf3 ")
      local itemData = Data.ItemsData[tostring(list[i].Id)]
      itemName = Data.ItemsData[tostring(list[i].Id)].Name
      if Data.ItemsData[tostring(list[i].Id)].Type == 8 then
        self.subItem[i]:Find("HeroExpIcon").gameObject:SetActive(true)
        self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(list[i].Id)].Icon)
        itemDesc = Data.ItemsData[tostring(itemData.Id)].Desc
        if Data.ItemsDeck[tostring(list[i].Id)] ~= nil then
          itemNum = Data.ItemsDeck[tostring(list[i].Id)].Amount
        else
          itemNum = 0
        end
      elseif Data.ItemsData[tostring(list[i].Id)].Type == 7 then
        self.subItem[i]:Find("SkinExpIcon").gameObject:SetActive(true)
        self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(list[i].Id)].Icon)
        itemDesc = Data.ItemsData[tostring(itemData.Id)].Desc
        if Data.ItemsDeck[tostring(list[i].Id)] ~= nil then
          itemNum = Data.ItemsDeck[tostring(list[i].Id)].Amount
        else
          itemNum = 0
        end
      elseif Data.ItemsData[tostring(list[i].Id)].Type == 13 then
        self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(list[i].Id)].Icon)
        itemDesc = itemData.Desc
        itemNum = Data.PlayerData.Coin .. "个"
      elseif Data.ItemsData[tostring(list[i].Id)].Type == 14 then
        self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(list[i].Id)].Icon)
        itemDesc = itemData.Desc
        itemNum = Data.PlayerData.Coin .. "个"
      elseif Data.ItemsData[tostring(list[i].Id)].Type == 15 then
        self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(list[i].Id)].Icon)
        itemDesc = itemData.Desc
        itemNum = Data.PlayerData.Exp
      elseif Data.ItemsData[tostring(list[i].Id)].Type == 17 then
        self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(list[i].Id)].Icon)
        itemDesc = itemData.Desc
        itemNum = Data.PlayerData.RunePiece .. "个"       
      else
        self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(list[i].Id)].Icon)
        if Data.ItemsDeck[tostring(list[i].Id)]~= nil then
          itemNum = Data.ItemsDeck[tostring(list[i].Id)].Amount
        else
          itemNum = 0
        end
        itemDesc = itemData.Desc   
      end
      self.subItem[i]:GetComponent(Image).sprite = UITools.GetSprite("icon",Data.ItemsData[tostring(list[i].Id)].Quality)
      self.subItem[i]:Find("Name"):GetComponent(Text).text = Data.ItemsData[tostring(list[i].Id)].Name
    elseif list[i].Type == 3 then
      self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",Data.RunesData[tostring(list[i].Id)].Icon)
      self.subItem[i]:Find("Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(73,84.4)
      self.subItem[i]:GetComponent(Image).sprite = UITools.GetSprite("icon",Data.RunesData[tostring(list[i].Id)].Level)
      self.subItem[i]:Find("Name"):GetComponent(Text).text = Data.RunesData[tostring(list[i].Id)].Name
      itemName = Data.RunesData[tostring(list[i].Id)].Name
      if Data.RunesDeck[tostring(list[i].Id)]~= nil then
        itemNum = Data.RunesDeck[tostring(list[i].Id)].Amount
      else
        itemNum = 0
      end
      local attrs = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",list[i].Id)
      local str = ""
      for i = 1,#attrs do
        if i == #attrs then
          str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr
        else
          str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr .. "\n"
        end
      end
      itemDesc = str  
    elseif list[i].Type == 1 then
      --print(list[i].Type .. " " .. list[i].Id)
      self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",
                                                      Data.SkinsData[tostring(Data.RolesData[tostring(list[i].Id)].Skin)].Icon)
      self.subItem[i]:GetComponent(Image).sprite = UITools.GetSprite("icon",4)
      self.subItem[i]:Find("Name"):GetComponent(Text).text = Data.RolesData[tostring(list[i].Id)].Name
      itemName = Data.RolesData[tostring(list[i].Id)].Name
      itemNum = 1
      itemDesc = Data.RolesData[tostring(list[i].Id)].Desc
    elseif list[i].Type == 2 then
      self.subItem[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.SkinsData[tostring(list[i].Id)].Icon)
      self.subItem[i]:GetComponent(Image).sprite = UITools.GetSprite("icon",4)
      self.subItem[i]:Find("Name"):GetComponent(Text).text = Data.SkinsData[tostring(list[i].Id)].Name
      itemName = Data.SkinsData[tostring(list[i].Id)].Name
      itemDesc = Data.SkinsData[tostring(list[i].Id)].Desc
      ItemNum = 1
    end
    self.subItem[i]:Find("Text"):GetComponent(Text).text = list[i].Amount

    local listener = NTGEventTriggerProxy.Get(self.subItem[i]:Find("Mask/Icon").gameObject)
    local callback = function(self,e)
      self:ShowTipsControl(itemName,itemNum,itemDesc)
    end
    listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)

    listener = NTGEventTriggerProxy.Get(self.subItem[i]:Find("Mask/Icon").gameObject)
    local callback1 = function(self,e)
      self.tip.gameObject:SetActive(false)
    end
    listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)    

  end
end

function NoticeController:ShowNoticeInfo2(text)
  self.noticeInfo2:GetComponent(Text).text = text
end

function NoticeController:ButtonEventType1(buttonName,func,funcSelf)
  self.button:Find("Text"):GetComponent(Text).text = buttonName
  local listener = NTGEventTriggerProxy.Get(self.button.gameObject)
  local callback = function(self, e)
    func(funcSelf)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)  
end

function NoticeController:ButtonEventType2(buttonNameA,funcA,funASelf,buttonNameB,funcB,funBSelf)
  self.buttonLeftInType2:Find("Text"):GetComponent(Text).text = buttonNameA
  local listener = NTGEventTriggerProxy.Get(self.buttonLeftInType2.gameObject)
  local callback = function(self, e)
    funcA(funASelf)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self) 


  self.buttonRightInType2:Find("Text"):GetComponent(Text).text = buttonNameB
  local listener1 = NTGEventTriggerProxy.Get(self.buttonRightInType2.gameObject)
  local callback1 = function(self, e)
    funcB(funBSelf)
  end
  listener1.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)
end


function NoticeController:ButtonEventType3(payType,price,buttonNameA,funcA,funASelf,buttonNameB,funcB,funBSelf)
  local resourceName = ""
  if payType == 1 then
    resourceName = "Coin"
  elseif payType == 2 then
    resourceName = "Gem"
  elseif payType == 3 then
    resourceName = "Voucher"
  end
  if price == nil then
    price = 0
  end
  --print("asdfasdfasdf0.7")
  self.buttonLongInType3:Find("Image"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",resourceName)
  --print("asdfasdfasdf0.8")
  self.buttonLongInType3:Find("Price"):GetComponent(Text).text = price

  --print("abcabcabc")
  self.buttonLongInType3:Find("Text"):GetComponent(Text).text = buttonNameA
  local listener = NTGEventTriggerProxy.Get(self.buttonLongInType3.gameObject)
  local callback = function(self, e)
    funcA(funASelf)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self) 


  self.buttonShortYellow:Find("Text"):GetComponent(Text).text = buttonNameB
  local listener1 = NTGEventTriggerProxy.Get(self.buttonShortYellow.gameObject)
  local callback1 = function(self, e)
    funcB(funBSelf)
  end
  listener1.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)

end


function NoticeController:ButtonEventType4(payType,price,buttonNameA,funcA,funASelf,buttonNameB,funcB,funBSelf)
  local resourceName = ""
  if payType == 1 then
    resourceName = "Coin"
  elseif payType == 2 then
    resourceName = "Gem"
  elseif payType == 3 then
    resourceName = "Voucher"
  end
  if price == nil then
    price = 0
  end
  self.buttonLongInType4:Find("Image"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",resourceName)
  self.buttonLongInType4:Find("Price"):GetComponent(Text).text = price

  self.buttonLongInType4:Find("Text"):GetComponent(Text).text = buttonNameA
  local listener = NTGEventTriggerProxy.Get(self.buttonLongInType4.gameObject)
  local callback = function(self, e)
    funcA(funASelf)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self) 


  self.buttonShortBlue:Find("Text"):GetComponent(Text).text = buttonNameB
  local listener1 = NTGEventTriggerProxy.Get(self.buttonShortBlue.gameObject)
  local callback1 = function(self, e)
    funcB(funBSelf)
  end
  listener1.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)
end

function NoticeController:DestroySelf()
  table.remove(UTGDataOperator.Instance.Dialog,#UTGDataOperator.Instance.Dialog)
  GameObject.Destroy(self.this.transform.parent.gameObject)
end

function NoticeController:ShowTipsControl(itemName,ownNum,desc)
  -- body
  self.tip.gameObject:SetActive(true)
  local pos = self.camera:ScreenToWorldPoint(Input.mousePosition)
  --local pos = Input.mousePosition
  self.tip.position = Vector3.New(pos.x,pos.y,0)
  self.tip.localPosition = Vector3.New(self.tip.localPosition.x,self.tip.localPosition.y,0)
  self.tip:Find("Panel/ItemName"):GetComponent(Text).text = itemName
  self.tip:Find("Panel2/Own/OwnNum"):GetComponent(Text).text = ownNum
  self.tip:Find("Desc"):GetComponent(Text).text = desc
end

function NoticeController:RankInvitation(invitorName,invitorIcon,invitorFrame,invitorGrade,invitorDes)
  -- body
  self.noticeFrame:Find("TextPanel").gameObject:SetActive(false)
  self.noticeFrame:Find("Panel").gameObject:SetActive(true)

  self.noticeFrame:Find("Panel/InvitorName"):GetComponent(Text).text = invitorName
  self.noticeFrame:Find("Panel/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",invitorIcon)
  --print("asdfasdf " .. invitorFrame)
  self.noticeFrame:Find("Panel/Icon/IconFrameSingle"):GetComponent(Image).sprite = UITools.GetSprite("frameicon",Data.AvatarFramesData[tostring(invitorFrame)].Icon)
  --self.noticeFrame:Find("From"):GetComponent(Text).text = "（来自好友）"
  self.noticeFrame:Find("Panel/RankName"):GetComponent(Text).text = Data.GradesData[tostring(invitorGrade)].Title
  self.noticeFrame:Find("Panel/RankIcon"):GetComponent(Image).sprite = UITools.GetSprite("rankicon-" .. Data.GradesData[tostring(invitorGrade)].IconMain,
                                                        Data.GradesData[tostring(invitorGrade)].IconMain .. "-little")
  if invitorGrade == 18000001 or invitorGrade == 18000002 or invitorGrade == 18000003 then
    local rankColor1Top = UTGDataTemporary.Instance().rank1Top
    local rankColor1Bottom = UTGDataTemporary.Instance().rank1Bottom
    --print("color = " .. rankColor1Top.r .. " " .. rankColor1Top.g .. " " .. rankColor1Top.b)
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").topColor = Color.New(rankColor1Top.r/255,rankColor1Top.g/255,rankColor1Top.b/255,255)
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").bottomColor = Color.New(rankColor1Bottom.r/255,rankColor1Bottom.g/255,rankColor1Bottom.b/255,1)
  elseif invitorGrade == 18000004 or invitorGrade == 18000005 or invitorGrade == 18000006 then
    local rankColor2Top = UTGDataTemporary.Instance().rank2Top
    local rankColor2Bottom = UTGDataTemporary.Instance().rank2Bottom
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").topColor = Color.New(rankColor2Top.r/255,rankColor2Top.g/255,rankColor2Top.b/255,1)
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").bottomColor = Color.New(rankColor2Bottom.r/255,rankColor2Bottom.g/255,rankColor2Bottom.b/255,1)
  elseif invitorGrade == 18000007 or invitorGrade == 18000008 or invitorGrade == 18000009 then
    local rankColor3Top = UTGDataTemporary.Instance().rank3Top
    local rankColor3Bottom = UTGDataTemporary.Instance().rank3Bottom
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").topColor = Color.New(rankColor3Top.r/255,rankColor3Top.g/255,rankColor3Top.b/255,1)
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").bottomColor = Color.New(rankColor3Bottom.r/255,rankColor3Bottom.g/255,rankColor3Bottom.b/255,1)
  elseif invitorGrade == 18000010 or invitorGrade == 18000011 or invitorGrade == 18000012 then
    local rankColor4Top = UTGDataTemporary.Instance().rank4Top
    local rankColor4Bottom = UTGDataTemporary.Instance().rank4Bottom
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").topColor = Color.New(rankColor4Top.r/255,rankColor4Top.g/255,rankColor4Top.b/255,1)
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").bottomColor = Color.New(rankColor4Bottom.r/255,rankColor4Bottom.g/255,rankColor4Bottom.b/255,1)
  elseif invitorGrade == 18000013 or invitorGrade == 18000014 or invitorGrade == 18000015 then
    local rankColor5Top = UTGDataTemporary.Instance().rank5Top
    local rankColor5Bottom = UTGDataTemporary.Instance().rank5Bottom
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").topColor = Color.New(rankColor5Top.r/255,rankColor5Top.g/255,rankColor5Top.b/255,1)
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").bottomColor = Color.New(rankColor5Bottom.r/255,rankColor5Bottom.g/255,rankColor5Bottom.b/255,1)
  elseif invitorGrade == 18000016 or invitorGrade == 18000017 then
    local rankColor6Top = UTGDataTemporary.Instance().rank6Top
    local rankColor6Bottom = UTGDataTemporary.Instance().rank6Bottom
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").topColor = Color.New(rankColor6Top.r/255,rankColor6Top.g/255,rankColor6Top.b/255,1)
    self.noticeFrame:Find("Panel/RankName"):GetComponent("UITextGradient").bottomColor = Color.New(rankColor6Bottom.r/255,rankColor6Bottom.g/255,rankColor6Bottom.b/255,1)
  end

  self.noticeFrame:Find("Panel/Message"):GetComponent(Text).text = invitorDes

end

function NoticeController:FxControl(isShow)
  if isShow == true then
    self.fx.gameObject:SetActive(isShow)
    local btn = self.fx:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,btn.Length - 1 do
      self.fx:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
    end

    local fx = self.fx:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
    for k = 0,fx.Length - 1 do
      fx[k]:Play()
    end
  end    
end

function NoticeController:DoShowByStep(count)
  -- body
  self.coroutine_showbystep =  coroutine.start(NoticeController.ShowByStep,self,count)
end

function NoticeController:SetTextToCenter()
  -- body
  self.noticeFrame:Find("TextPanel").localPosition = Vector3.New(0,39,0)
end

function NoticeController:ShowByStep(count)
  -- body
  for i = 1,5 do
    self.subItem[i].gameObject:SetActive(false)
  end

  if count == 5 then
    local time = 0
    while time < 5 do
      time = time + 1
      self.subItem[time].gameObject:SetActive(true)
      self.subItem[time]:Find("R51140540").gameObject:SetActive(true)
      local btn = self.subItem[time]:Find("R51140540"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
      for k = 0,btn.Length - 1 do
        self.subItem[time]:Find("R51140540"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
      end
      local fx = self.subItem[time]:Find("R51140540"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
      for k = 0,fx.Length - 1 do
        fx[k]:Play()
      end
      coroutine.wait(0.5)
    end
  elseif count == 1 then
    local time = 0
    while time < 1 do
      time = time + 1
      self.subItem[time].gameObject:SetActive(true)
      local btn = self.subItem[time]:Find("R51140540"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
      for k = 0,btn.Length - 1 do
        self.subItem[time]:Find("R51140540"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
      end


      self.subItem[time]:Find("R51140540").gameObject:SetActive(true)
      local fx = self.subItem[time]:Find("R51140540"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
      for k = 0,fx.Length - 1 do
        fx[k]:Play()
      end
      coroutine.wait(0.5)
    end
  end
  self.coroutine_showbystep = nil 
end

function NoticeController:DestroySelfWithNotice()
  -- body
  GameManager.CreatePanel("SelfHideNotice")
  if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在建设中")
  end
  table.remove(UTGDataOperator.Instance.Dialog,#UTGDataOperator.Instance.Dialog)
  Object.Destroy(self.this.transform.parent.gameObject)  
end



function NoticeController:OnDestroy()
  if self.coroutine_showbystep~=nil then coroutine.stop(self.coroutine_showbystep) end
  self.this = nil
  self = nil
end



