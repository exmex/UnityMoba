require "System.Global"

class("NormalResourceAPI")

function  NormalResourceAPI:Awake(this)
	-- body
	self.this = this
	self.nrControl = self.this.transforms[0]:GetComponent("NTGLuaScript")
	NormalResourceAPI.Instance = self

end

function NormalResourceAPI:Start()

end
--
function  NormalResourceAPI:GoToPosition(name)
	-- body
	self.nrControl.self:GoToPosition(name)
end
--控制显示模式  1：只显示横条	2：只显示资源面板及tips		3.既显示横条，也显示资源面板及tips
function  NormalResourceAPI:ShowControl(num)
	-- body
	self.nrControl.self:ShowControl(num)
end

--初始化横条信息，包括面板名称、返回按钮事件、规则按钮事件
function  NormalResourceAPI:InitTop(funself,fun,funself1,fun1,text)
	-- body
	self.nrControl.self:TopPanelInfo(funself,fun,funself1,fun1,text)
end

--初始化资源面板及tips
--showType = 1 显示芯片资源			= 0 不显示芯片资源
function  NormalResourceAPI:InitResource(showType)
	-- body
	self.nrControl.self:ResourceInfo(showType)
end

--三个type任意填，均为string类型，可填内容为"Text"（标题）、"Button"（规则按钮）、"Bar"（顶部背景条）
function NormalResourceAPI:HideSom(type1,type2,type3)
	-- body
	self.nrControl.self:HideSom(type1,type2,type3)
end

--三个type任意填，均为string类型，可填内容为"Text"（标题）、"Button"（规则按钮）、"Bar"（顶部背景条）
function NormalResourceAPI:ShowSom(type1,type2,type3)
	-- body
	self.nrControl.self:ShowSom(type1,type2,type3)
end

--更新资源
function  NormalResourceAPI:UpdateResource()
	-- body
	self.nrControl.self:UpdateResource()
end

function NormalResourceAPI:SetToHigh()
	-- body
	self.nrControl.self:SetToHigh()
end


function  NormalResourceAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	NormalResourceAPI.Instance = nil
end