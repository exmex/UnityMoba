--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
require "Logic.UTGData.UTGDataTemporary"
class("BreakRuneGetPieceAPI")
local json = require "cjson"

function BreakRuneGetPieceAPI:Awake(this)
  self.this = this
  BreakRuneGetPieceAPI.Instance = self
  
  local listener = {}
  listener = NTGEventTriggerProxy.Get(this.transforms[0].gameObject)--确认 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BreakRuneGetPieceAPI.ClickClosePanel,self) 

  self.rootPanel = this.transforms[1]
  self.rootPanel.gameObject:SetActive(false)
  self.txtNum = this.transforms[2]:GetComponent("UnityEngine.UI.Text")
  self.allNum =0

 end

function BreakRuneGetPieceAPI:Start()
    --临时代码
  local model = self.rootPanel
  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
  end
  
end

function BreakRuneGetPieceAPI:SetParamBy67(runeid)
  self.chipNum = UTGData.Instance().RunesData[tostring(runeid)].DecomposePiece
  self:NetBreakRune(runeid)
end

--显示领取成功UI
function BreakRuneGetPieceAPI:ShowUI(allnum)
  allnum = allnum or self.allNum
  self.rootPanel.gameObject:SetActive(true)
  self.txtNum.text = ""..allnum
end

--网络 分解
function BreakRuneGetPieceAPI:NetBreakRune(runeid)
	local request = NetRequest.New()
    request.Content = JObject.New(JProperty.New("Type","RequestDecomposeRune"),JProperty.New("RuneId",runeid))
    request.Handler = TGNetService.NetEventHanlderSelf(BreakRuneGetPieceAPI.NetBreakRuneHandler,self)
    TGNetService.GetInstance():SendRequest(request)
end

function BreakRuneGetPieceAPI:NetBreakRuneHandler(e)
  if e.Type == "RequestDecomposeRune" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result ==1 then 
    	self.allNum  = self.allNum + self.chipNum
    end
    return true
  end
  return false
end


--关闭面板
function BreakRuneGetPieceAPI:ClickClosePanel()
	Object.Destroy(self.this.gameObject)
end

function BreakRuneGetPieceAPI:OnDestroy()
  self.this = nil
  self = nil
  BreakRuneGetPieceAPI.Instance = nil
end