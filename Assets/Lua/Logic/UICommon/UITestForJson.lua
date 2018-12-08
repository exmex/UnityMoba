


require "System.Global"
--lua标准模板
UITestForJson = {}
----------------------------------------------------
function UITestForJson:New(o)
  local o = o or {}
  setmetatable(o, UITestForJson)
  UITestForJson.__index = UITestForJson
  return o
end
----------------------------------------------------
function UITestForJson:Awake(this) 
  self.this = this  

end
----------------------------------------------------
function UITestForJson:Start()
  
  UITools.Test();
  
local cjson = require "cjson"
local sampleJson = [[
                      { 
                        "age":"23",
                        "testArray":{"array":[8,9,11,14,25]},
                        "Himi":"himigame.com"
                      }
                   ]];
--解析json字符串
local data = cjson.decode(sampleJson);
--打印json字符串中的age字段
Debugger.LogError(data["age"]);
--打印数组中的第一个值(lua默认是从0开始计数)
Debugger.LogError(data["testArray"]["array"][1]); 

end
----------------------------------------------------
function UITestForJson:OnDestroy()
  
  self.this = nil
  self = nil
end