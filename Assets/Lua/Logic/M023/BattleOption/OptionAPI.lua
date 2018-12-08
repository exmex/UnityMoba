require "System.Global"

class("OptionAPI")

function OptionAPI:Awake(this)
	-- body
	self.this = this
	self.optionControl = self.this.transforms[0]:GetComponent("NTGLuaScript")
	OptionAPI.Instance = self
end

function OptionAPI:Start()
	-- body
end

function OptionAPI:RoleOutLine(delegate)
	-- body
	self.optionControl.self:RoleOutLine(delegate)
end

function OptionAPI:ShowFPS(delegate)
	-- body
	self.optionControl.self:ShowFPS(delegate)
end

function  OptionAPI:GameInput(delegate)
	-- body
	self.optionControl.self:GameInput(delegate)
end

function OptionAPI:CameraHeight(delegate)
	-- body
	self.optionControl.self:CameraHeight(delegate)
end

function OptionAPI:CameraHeightOutSide(delegate)	--主界面设置窗口使用
	-- body
	self.optionControl.self:CameraHeightOutSide(delegate)	
end

function  OptionAPI:CameraMove(delegate)
	-- body
	self.optionControl.self:CameraMove(delegate)
end

function OptionAPI:TargetLock(delegate)
	-- body
	self.optionControl.self:TargetLock(delegate)
end

function OptionAPI:UseSkill(delegate)
	-- body
	self.optionControl.self:UseSkill(delegate)
end

function OptionAPI:TargetSelect(delegate)
	-- body
	self.optionControl.self:TargetSelect(delegate)
end

function OptionAPI:ShowDiskPosition(delegate)
	-- body
	self.optionControl.self:ShowDiskPosition(delegate)
end

function OptionAPI:CancelSkill(delegate)
	-- body
	self.optionControl.self:CancelSkill(delegate)
end

function OptionAPI:DoDiskS(delegate)
	-- body
	self.optionControl.self:DoDiskS(delegate)
end

function OptionAPI:GameMusic(delegate)
	-- body
	self.optionControl.self:GameMusic(delegate)
end

function OptionAPI:GameAudio(delegate)
	-- body
	self.optionControl.self:GameAudio(delegate)
end

function OptionAPI:Speak(delegate)
	-- body
	self.optionControl.self:Speak(delegate)
end

function OptionAPI:DoCameraSiensitivityOnValueChanged(delegate)
	-- body
	self.optionControl.self:DoCameraSiensitivityOnValueChanged(delegate)
end

function OptionAPI:DoMusicVolumn(delegate)
	-- body
	self.optionControl.self:DoMusicVolumn(delegate)
end

function OptionAPI:DoAudioVolumn(delegate)
	-- body
	self.optionControl.self:DoAudioVolumn(delegate)
end

function OptionAPI:DoSpeakVolumn(delegate)
	-- body
	self.optionControl.self:DoSpeakVolumn(delegate)
end

function OptionAPI:HighQShow(delegate)
	-- body
	self.optionControl.self:HighQShow(delegate)
end

function OptionAPI:GraphicsQ(delegate)
	-- body
	self.optionControl.self:GraphicsQ(delegate)
end

function OptionAPI:ParticleQ(delegate)
	-- body
	self.optionControl.self:ParticleQ(delegate)
end

function OptionAPI:OpenPanel()
	-- body
	self.optionControl.self:OpenPanel()
end

function  OptionAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	OptionAPI.Instance = nil
end