request "System.Global"

class("GetNewControl")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

local json = require "cjson"

function GetNewControl:Awake(this)
	-- body
	self.this = this
end

function GetNewControl:Init(getType,id)
	-- body
	if getType == "Role" then
		self.this.transform:Find("GetNewTitle/Title"):GetComponent(Text).text = "恭喜你获得了新姬神"
		self.this.transform:Find("GetNewNameFrame/Text"):GetComponent(Text).text = Data.RolesData[tostring(id)].Name
	elseif getType == "Skin" then
		self.this.transform:Find("GetNewTitle/Title"):GetComponent(Text).text = "恭喜你获得了新皮肤"
		self.this.transform:Find("GetNewNameFrame/Text"):GetComponent(Text).text = Data.SkinsData[tostring(id)].Name
	end
end

function GetNewControl:InitModel(id)
	-- body
	--[[
  local tempo = self.leftInfoPanel
  tempo:Find("RawEvent").gameObject:SetActive(true)

  tempo:Find("Model/Root/Root").transform.localRotation = Quaternion.identity
  for i=1,tempo:Find("Model/Root/Root").childCount do
    GameObject.Destroy(tempo:Find("Model/Root/Root"):GetChild(i-1).gameObject)
  end


  local model = GameObject.Instantiate(NTGResourceController.Instance:LoadAsset("skin"..tostring(Data.SkinsData[tostring(Data.RolesDeckData[tostring(heroId)].Skin)].Resource),
                                                                        tostring(Data.SkinsData[tostring(Data.RolesDeckData[tostring(heroId)].Skin)].Resource))) 
  model.gameObject:SetActive(true)

  local btn = model.transform:GetComponentsInChildren("UnityEngine.Renderer")
  for k = 0,btn.Length - 1 do
    model.transform:GetComponentsInChildren("UnityEngine.Renderer")[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
  end

  model.transform.parent = tempo:FindChild("Model/Root/Root")
  model.transform.localPosition = Vector3.zero
  model.transform.localRotation = Quaternion.identity
  model.transform.localScale = Vector3.one
  self.modelAnimator = model:GetComponent("UnityEngine.Animator")
  self.modelAnimator:SetTrigger("show")	
  ]]
end

function GetNewControl:OnDestroy()
	-- body
	self.this = nil 
	self = nil
end