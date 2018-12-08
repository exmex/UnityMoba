require "System.Global"

class("GiftSkinController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

local json = require "cjson"

function GiftSkinController:Awake(this)
	-- body
	self.this = this
	self.giftInfo = self.this.transforms[0]
	self.giftSkinPanel = self.this.transform.parent
	self.inputArea = self.giftInfo:Find("SearchFriend/inputFrame/InputField")
	self.skinIcon1 = self.giftInfo:Find("Mask/HeroIcon")
	self.ticketNum = self.giftInfo:Find("PayTicket/PayNum")

  self.textSkinName = self.giftInfo:FindChild("Mask/Text")
  self.textRule = self.giftInfo:FindChild("Text")
  self.strRule = "<color=#FDA625FF>5级</color>以上可以赠送好友皮肤，赠送前<color=#FDA625FF>请确认好友没有该皮肤</color>，重复获得已有皮肤会转化成皮肤碎片"
  self.firendTrans = {}
end

function GiftSkinController:Start()
	-- body
end

function GiftSkinController:InitGiftSkin(skinId)
  self.shopData = Data.ShopsData[tostring(skinId)][1]
  local price = self.shopData.VoucherPrice

	self.shopId = self.shopData.Id
	--print("gggggggggg " .. Data.ShopsData[tostring(skinId)][1].Id)

  --初始化界面
  self.textRule:GetComponent("UnityEngine.UI.Text").text = self.strRule
  local temp = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/FriendList/Grid")
  for i = 2,temp.childCount  do
    GameObject.Destroy(temp:GetChild(i-1).gameObject)
  end
  self.inputArea:GetComponent("UnityEngine.UI.InputField").text = ""

  self.giftSkinPanel.gameObject:SetActive(true)

  self.skinIcon1:GetComponent(Image).sprite = UITools.GetSprite("portrait",Data.SkinsData[tostring(skinId)].Portrait)   --获取皮肤头像
  self.textSkinName:GetComponent(Text).text = Data.SkinsData[tostring(skinId)].Name
  self.ticketNum:GetComponent(Text).text = price

  local listener = NTGEventTriggerProxy.Get(self.giftSkinPanel:Find("BuyHeroFrame/CancelButton").gameObject)
  local callback13 = function(self, e)
    self:DestroySelf()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13,self)

  listener = NTGEventTriggerProxy.Get(self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/Button").gameObject)
  local callback1 = function(self, e)
    self:SearchFriend()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1,self)

  --初始化列表
  local resultList = {}
  for k,v in pairs(Data.FriendList) do
    table.insert(resultList,Data.FriendList[k])
  end
  self:ShowSearchFriendResult(resultList)
end

function GiftSkinController:SearchFriend()
  local keyWord = self.inputArea:GetComponent("UnityEngine.UI.InputField").text
  local resultList = {}
  for k,v in pairs(Data.FriendList) do
    if string.find(Data.FriendList[k].Name,keyWord) ~= nil then
      table.insert(resultList,Data.FriendList[k])
    end
  end
  if #resultList == 0 then
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("未能找到符合条件的好友")
    end
  end

  self:ShowSearchFriendResult(resultList)

end

function GiftSkinController:ShowSearchFriendResult(resultList)
  for k,v in pairs(self.firendTrans) do
    v.gameObject:SetActive(false)
  end
  -- body
  local temp = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/FriendList/Grid/Friend1")
  for i = 1,#resultList do
    local go = self.firendTrans[tostring(resultList[i].Id)]
    if go~=nil then 
      go.gameObject:SetActive(true) 
    else
      go = GameObject.Instantiate(temp.gameObject)
      self.firendTrans[tostring(resultList[i].Id)] = go
      --print(":aaaaaaaaaaaaaaaaaaaaaa")
      go:SetActive(true)
      go.transform.parent = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/FriendList/Grid")
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.zero
      --print("resultList[i].Avatar " .. resultList[i].Avatar)
      go.transform:Find("Image"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",resultList[i].Avatar)
      --print("resultList[i].Name " .. resultList[i].Name)
      go.transform:Find("PlayerName"):GetComponent(Text).text = resultList[i].Name
      local listener = NTGEventTriggerProxy.Get(go.transform:Find("GiftButton").gameObject)
      local callback13 = function(self, e)
        --print("赠送成功")
        self:GiftSkin(self.shopId,3,resultList[i].Id)
      end
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13,self)
    end
  end
end

function GiftSkinController:GiftSkin(skinShopId,buyType,friendId,networkDelegate,networkDelegateSelf)
	-- body
	self.giftSkinDelegate = networkDelegate
	self.giftSkinDelegateSelf = networkDelegateSelf
	local giftSkinRequest = NetRequest.New()
	giftSkinRequest.Content = JObject.New(JProperty.New("Type", "RequestGiveFriendSkinGift"),
										JProperty.New("ShopId",skinShopId),
										JProperty.New("PayType",buyType),
										JProperty.New("FriendId",friendId))
	giftSkinRequest.Handler = TGNetService.NetEventHanlderSelf(GiftSkinController.GiftSkinHandler,self)
	TGNetService.GetInstance():SendRequest(giftSkinRequest)		
end

function GiftSkinController:GiftSkinHandler(e)
	-- body
	if e.Type == "RequestGiveFriendSkinGift" then
		local result = json.decode(e.Content:get_Item("Result"):ToString())
		if result == 1 then
        GameManager.CreatePanel("SelfHideNotice")
	      if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
	        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("赠送成功")
	      end			
	    elseif result == 2821 then
	      local dialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
	      dialog:InitNoticeForNeedConfirmNotice("提示", "点券不足", false, 2)
	      dialog:TwoButtonEvent("取消",dialog.DestroySelf, self,
	                              "购买点券", dialog.DestroySelfWithNotice, self)
      elseif result == 280 then
        GameManager.CreatePanel("SelfHideNotice")
        if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您尚未达到5级，无法赠送皮肤")
        end         
	  	else
        GameManager.CreatePanel("SelfHideNotice")
	      if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
	        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("赠送失败")
	      end	  		
		end
		return true
	end
	return false
end

function GiftSkinController:DestroySelf()
	-- body
	GameObject.Destroy(self.this.transform.parent.gameObject)
end

function GiftSkinController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end