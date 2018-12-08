require "System.Global"

class("ModeInfosCtrl")

function ModeInfosCtrl:Awake(this)
  self.this = this
  self.newBattle15Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.pic1V1 = this.transforms[1]
  self.pic3V3 = this.transforms[2]
  self.pic5V5 = this.transforms[3]
  self.picRenJi = this.transforms[4]
  self.picZuDui = this.transforms[5]
  self.picPaiWei = this.transforms[6]
  self.mapName = this.transforms[7]
end

function ModeInfosCtrl:Start()
  self:Init()
end

function ModeInfosCtrl:Init()
  
end

function ModeInfosCtrl:ShowModeInfo(mapName, mainModeCode, playerCount)
  self.pic1V1.gameObject:SetActive(false)
  self.pic3V3.gameObject:SetActive(false)
  self.pic5V5.gameObject:SetActive(false)
  self.picRenJi.gameObject:SetActive(false)
  self.picZuDui.gameObject:SetActive(false)
  self.mapName:GetComponent("UnityEngine.UI.Text").text = mapName
  if mainModeCode == 1 or mainModeCode == 2 or mainModeCode == 4 then
    self.picZuDui.gameObject:SetActive(true)
  end
  if mainModeCode == 3 then
    self.picRenJi.gameObject:SetActive(true)
  end
  if mainModeCode == 5 then --排位
    self.picPaiWei.gameObject:SetActive(true)
  end
  if playerCount == 1 then
    self.pic1V1.gameObject:SetActive(true)
    return
  end
  if playerCount == 3 then
    self.pic3V3.gameObject:SetActive(true)
    return
  end
  if playerCount == 5 then
    self.pic5V5.gameObject:SetActive(true)
    return
  end
end













function ModeInfosCtrl:OnDestroy()
  self.this = nil
  self = nil
end