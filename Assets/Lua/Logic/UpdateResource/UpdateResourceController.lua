require "System.Global"

class("UpdateResourceController")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"

function UpdateResourceController:Awake(this)
  self.this = this
  self.processDesc = self.this.transforms[0]
  self.processNum = self.this.transforms[1]
  self.processBar = self.this.transforms[2]
  self.versionNum = self.this.transforms[3]
  self.updatingInfo = self.this.transforms[4]
  self.processBarTrans = self.this.transforms[6]
  self.testText = self.this.transforms[7]

  self.processDesc = self.processDesc:GetComponent(Text)
  self.processNum = self.processNum:GetComponent(Text)
  self.processBar = self.processBar:GetComponent(Slider)
  self.versionNum = self.versionNum:GetComponent(Text)  
  
  self.updatingSize = self.updatingInfo:Find("UpdateSize"):GetComponent("UnityEngine.UI.Text")
  self.updatingSpeed = self.updatingInfo:Find("DownLoadSpeed"):GetComponent("UnityEngine.UI.Text")
  
  self.gear1 = self.processBarTrans:Find("Gear")
  self.gear2 = self.processBarTrans:Find("Gear2")
  self.light1 = self.processBarTrans:Find("Fill Area/Fill/Light1")
  self.light2 = self.processBarTrans:Find("Fill Area/Fill/Light2")
  self.bg = self.processBarTrans:Find("Fill Area/Fill/Bg")
  self.star1 = self.processBarTrans:Find("Fill Area/Fill/Star1")
  self.star2 = self.processBarTrans:Find("Fill Area/Fill/Star2")
  self.star3 = self.processBarTrans:Find("Fill Area/Fill/Star3")
  
  
  self.updateType = {"正在为您检查资源包更新","正在为您下载更新资源包","正在为您解压资源包（过程不耗流量）","加载完毕，祝您游戏愉快"}
  --1 = "正在为您检查资源包更新"
  --2 = "正在为您下载更新资源包"
  --3 = "正在为您解压资源包（过程不耗流量）"
  --4 = "加载完毕，祝您游戏愉快"
  
  self.getSpeed = 0     --KB为单位
  self.getSliderValue = 0            --0到1之间的数字
  self.testSize = 480
  self.count = 0  
end

function UpdateResourceController:Start()
  --self.versionNum.text = "Ver 1.0.0"
  --self:ShowProcessDesc("Updating")
  --self:ShowUpdateInfo(1,self.testSize)
  --self:GetLoadingData(-1,0.1)
  self.bg:GetComponent(RectTrans).sizeDelta = Vector2.New(1,1)

end

function UpdateResourceController:GetLoadingData(speed,sliderValue)
  self.getSpeed = speed
  self.getSliderValue = sliderValue
  --print("speed " .. speed)
  self:DownLoadSpeed()
end

function UpdateResourceController:ShowUpdateInfo(updateType,size)
  --print(self.updateType[updateType])
  self.processDesc.text = self.updateType[updateType]
  if updateType == 2 then
    self.updatingInfo.gameObject:SetActive(true)
  else
    self.updatingInfo.gameObject:SetActive(false)
  end  
end

function UpdateResourceController:DownLoadSpeed()
  local speed = 0
  local sliderValue = 0  

      speed = self.getSpeed             --获取下载速度
      sliderValue = self.getSliderValue           --获取进度百分比

      if sliderValue > 1 then
        sliderValue = 1
      end
      
      if speed < 0 then 
        self.updatingSpeed.transform.gameObject:SetActive(false)
      else
        self.updatingSpeed.transform.gameObject:SetActive(true)
      end

      if (self.speedValid == nil and speed > 0) or (self.speedValid == true and self.count%10 == 0) then
        self.updatingSpeed.text = tostring(string.format("%.1f",speed)) .. "KB/s"
        self.speedValid = true
      end

      if self.speedValid then
        self.count = self.count + 1
      end

      self.processNum.text = math.floor(sliderValue * 100) .. "%"
      self.processBar.value = sliderValue       
   
end

function UpdateResourceController:TestText(str)
  -- body
  self.testText:GetComponent(Text).text = str
end

function UpdateResourceController:Test()
  
end



function UpdateResourceController:OnDestroy()
  self.this = nil
  self = nil
end
