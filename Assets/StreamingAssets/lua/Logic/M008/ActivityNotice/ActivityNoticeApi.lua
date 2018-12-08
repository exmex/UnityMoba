require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("ActivityNoticeApi")
local Data = UTGData.Instance()
function ActivityNoticeApi:Awake(this) 
  self.this = this
  ActivityNoticeApi.Instance = self

  self.Root = this.transforms[0]

end

function ActivityNoticeApi:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
  self:HideSelf()
end

function ActivityNoticeApi:Init()

end

function ActivityNoticeApi:OnDestroy()
  self.this = nil
  ActivityNoticeApi.Instance = nil
  self = nil
end

--是否已经读了 ，读了返回true
function ActivityNoticeApi:isNoticeHaveRead(id)
  local ret = false
  for i,v in pairs(Data.PlayerActivityDeck.ReadAnnouncements) do
    if (id == v) then
      ret = true
      break
    end
  end
  return ret
end

--是否全部读了，全读了返回true
function ActivityNoticeApi:isAllNoticeHaveRead()
  local ret = true
  for i,v in pairs(Data.Announcements) do
    if (self:isNoticeHaveRead(v.Id) == false) then
      ret = false
      break
    end
  end
  return ret
end

function ActivityNoticeApi:redNoticeUpdate(args)
  self.ctrl.self:redNoticeUpdate()
end

function ActivityNoticeApi:destroy(args)
  Object.Destroy(self.this.transform.gameObject)
end

function ActivityNoticeApi:redActiUpdate(num)
  self.ctrl.self:redActiUpdate(num)
end

function ActivityNoticeApi:ShowSelf()
  self.Root.localPosition = Vector3.zero
end

function ActivityNoticeApi:HideSelf()
  self.Root.transform.localPosition = Vector3.New(0,1000,0)
end
