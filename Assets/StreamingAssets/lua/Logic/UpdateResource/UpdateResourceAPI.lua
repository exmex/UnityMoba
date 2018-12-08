require "System.Global"

class("UpdateResourceAPI")

function UpdateResourceAPI:Awake(this)
	-- body
	self.this = this
	self.updateResourceControl = self.this.transforms[0]
	UpdateResourceAPI.Instance = self
	self.this.transform.localPosition = Vector3.New(0,0,0)
	--self.this.transform:GetComponent("UnityEngine.RectTransform").sizeDelta = Vector2.New(1280,720)
end

function UpdateResourceAPI:Start()
	-- body
end

function UpdateResourceAPI:GetLoadingData(speed,sliderValue)
	-- body
	self.updateResourceControl:GetComponent("NTGLuaScript").self:GetLoadingData(speed,sliderValue)
end

function UpdateResourceAPI:ShowUpdateInfo(updateType,size)
	-- body
	self.updateResourceControl:GetComponent("NTGLuaScript").self:ShowUpdateInfo(updateType,size)
end

function UpdateResourceAPI:DebugText(str)
	-- body
	self.updateResourceControl:GetComponent("NTGLuaScript").self:TestText(str)
end