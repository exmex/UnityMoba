--require "System.Wrap"        
tolua.loadassembly("UnityEngine")

--custom
JObject = Newtonsoft.Json.Linq.JObject
JProperty = Newtonsoft.Json.Linq.JProperty
NetRequest = TGNetService.NetRequest

--system
Directory = System.IO.Directory
File = System.IO.File

object			= System.Object
Type			= System.Type
Object          = UnityEngine.Object
GameObject 		= UnityEngine.GameObject
Transform 		= UnityEngine.Transform
MonoBehaviour 	= UnityEngine.MonoBehaviour
Component		= UnityEngine.Component
Application		= UnityEngine.Application
SystemInfo		= UnityEngine.SystemInfo
Screen			= UnityEngine.Screen
Camera			= UnityEngine.Camera
Material 		= UnityEngine.Material
Renderer 		= UnityEngine.Renderer

Input			= UnityEngine.Input
KeyCode			= UnityEngine.KeyCode
AudioClip		= UnityEngine.AudioClip
AudioSource		= UnityEngine.AudioSource
Physics			= UnityEngine.Physics
Light			= UnityEngine.Light
RenderSettings  = UnityEngine.RenderSettings
MeshRenderer	= UnityEngine.MeshRenderer
TouchPhase 		= UnityEngine.TouchPhase

function class(classname, supername, supermodule)  
    _G[classname] = {}
    _G[classname].classname = classname
    
    if supermodule ~= nil then
      require(supermodule)
    end
    
    if _G[supername] ~= nil then      
      setmetatable(_G[classname], _G[supername])
      _G[supername].__index = _G[supername]    
    end    

    _G[classname].New = function(o)
      local o = o or {}
      setmetatable(o, _G[classname])
      _G[classname].__index = _G[classname]
      return o
    end
end

function IsNil(uobj)
	return uobj == nil or uobj:Equals(nil)
end
