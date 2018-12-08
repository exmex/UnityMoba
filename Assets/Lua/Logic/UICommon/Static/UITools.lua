--require "Logic.UICommon.Static.UITools"

UITools = {}
----------------------------------------------------
function UITools.GetSprite(bundleName, assetName)
    assetName = tostring(assetName)
    local prefab; --GameObject
    prefab = NTGResourceController.Instance:LoadAsset(bundleName, assetName, "UnityEngine.Sprite");
    if (prefab == nil) then
        --Debugger.LogError("未能从AssetBundle加载到资源")--"未能在AssetBundle:"+bundleName +"中加载到Prefab:"+assetName)
        Debugger.LogError("未能在AssetBundle:" .. bundleName .. "中加载到Prefab:" .. assetName)
        print("未能在AssetBundle:" .. bundleName .. "中加载到Prefab:" .. assetName)
        return nil;
    else
        --return (prefab:GetComponent("SpriteRenderer").sprite);
        return (prefab);
    end
end

function UITools.GetSpriteBattle(bundleName, assetName)
    --只缓存战斗用的图，由于是静态数据战斗完需要--清理写在UIBattleAPI的OnDestroy中了

    if (UITools.Sprites == nil) then
        UITools.Sprites = {}
    end
    if (UITools.Sprites[bundleName] == nil) then
        UITools.Sprites[bundleName] = {}
        UITools.Sprites[bundleName][assetName] = UITools.GetSprite(bundleName, assetName)
    elseif (UITools.Sprites[bundleName][assetName] == nil) then
        UITools.Sprites[bundleName][assetName] = UITools.GetSprite(bundleName, assetName)
    else
    end
    return UITools.Sprites[bundleName][assetName]
end

--------------------------- 在目标物体上，按路径返回lua脚本-------------------------
function UITools.GetLuaScript(target, path)

    local table = target:GetComponents(NTGLuaScript.GetType("NTGLuaScript"));
    local needScript;
    local flag = false;
    for i = 1, table.Length, 1 do
        if (table[i - 1].luaScript == path) then
            needScript = table[i - 1].self;
            flag = true;
        end
    end
    if (flag == false) then
        return nil;
    else
        return needScript;
    end
end

------------------------- 对表深拷贝---------------------------
function UITools.CopyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = UITools.CopyTab(v)
        end
    end
    return tab
end

------------------------- 返回字符宽度：一个中文为2-----------------------
--[[
function UITools.WidthOfString(text)

  local str = text
  local lenInByte = #str                                    
  local width = 0
  local i=1
  while (i<=lenInByte) do
      local curByte = string.byte(str, i)
      local byteCount = 1;
      if curByte>0 and curByte<=127 then
          byteCount = 1
      elseif curByte>=192 and curByte<223 then
          byteCount = 2
      elseif curByte>=224 and curByte<239 then
          byteCount = 3
      elseif curByte>=240 and curByte<=247 then                                
          byteCount = 4
      end
       
      local char = string.sub(str, i, i+byteCount-1)
      i = i + byteCount -1
      if byteCount == 1 then
          width = width + 1
      else
          width = width + 2                     
      end
      i=i+1;
  end
   
  return width
  
end
--]]
-------------------------------------------------------------------------
-- @brief 切割字符串，并用“...”替换尾部
-- @param sName:要切割的字符串
-- @return nMaxCount，字符串上限,中文字为2的倍数
-- @param nShowCount：显示英文字个数，中文字为2的倍数,可为空
-- @note 函数实现：截取字符串一部分，剩余用“...”替换
function UITools.GetShortName(sName, nMaxCount, nShowCount)
    if sName == nil or nMaxCount == nil then
        return
    end
    local sStr = sName
    local tCode = {}
    local tName = {}
    local nLenInByte = #sStr
    local nWidth = 0
    if nShowCount == nil then
        nShowCount = nMaxCount - 3
    end
    for i = 1, nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0;
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        end
        local char = nil
        if byteCount > 0 then
            char = string.sub(sStr, i, i + byteCount - 1)
            i = i + byteCount - 1
        end
        if byteCount == 1 then
            nWidth = nWidth + 1
            table.insert(tName, char)
            table.insert(tCode, 1)

        elseif byteCount > 1 then
            nWidth = nWidth + 2
            table.insert(tName, char)
            table.insert(tCode, 2)
        end
    end

    if nWidth > nMaxCount then
        local _sN = ""
        local _len = 0
        for i = 1, #tName do
            _sN = _sN .. tName[i]
            _len = _len + tCode[i]
            if _len >= nShowCount then
                break
            end
        end
        sName = _sN .. "..."
    end
    return sName
end

------------------------------------------------------------------
function UITools.WidthOfString(sName, nMaxCount, nShowCount)
    if sName == nil or nMaxCount == nil then
        return
    end
    local sStr = sName
    local tCode = {}
    local tName = {}
    local nLenInByte = #sStr
    local nWidth = 0
    if nShowCount == nil then
        nShowCount = nMaxCount - 3
    end
    for i = 1, nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0;
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        end
        local char = nil
        if byteCount > 0 then
            char = string.sub(sStr, i, i + byteCount - 1)
            i = i + byteCount - 1
        end
        if byteCount == 1 then
            nWidth = nWidth + 1
            table.insert(tName, char)
            table.insert(tCode, 1)

        elseif byteCount > 1 then
            nWidth = nWidth + 2
            table.insert(tName, char)
            table.insert(tCode, 2)
        end
    end

    if nWidth > nMaxCount then
        local _sN = ""
        local _len = 0
        for i = 1, #tName do
            _sN = _sN .. tName[i]
            _len = _len + tCode[i]
            if _len >= nShowCount then
                break
            end
        end
        sName = _sN .. "..."
    end
    return nWidth
end

------------------------------------------------------------------
function UITools.GetStringTime(t) --与当前时间差 输出格式00:00:00

    local T = UTGData.Instance():GetLeftTime(t)
    T = math.abs(T);
    local day = math.floor(T / 86400) --以天数为单位取整 
    local hour = math.floor(T % 86400 / 3600) --以小时为单位取整 
    local min = math.floor(T % 86400 % 3600 / 60) --以分钟为单位取整 
    local seconds = math.floor(T % 86400 % 3600 % 60 / 1) --以秒为单位取整 
    ----------------------------------------------------------------------------
    local hS;
    if (hour < 10) then
        hS = "0" .. hour;
    else
        hS = hour;
    end
    local mS;
    if (min < 10) then
        mS = "0" .. min;
    else
        mS = min;
    end
    if (seconds < 10) then
        sS = "0" .. seconds;
    else
        sS = seconds;
    end
    hS = day * 24 + hS
    return hS .. ":" .. mS .. ":" .. sS;
end

------------------------------------------------------------------
function UITools.GetStringTimeII(t) --与当前时间差 输出格式00:00

    local T = UTGData.Instance():GetLeftTime(t)
    T = math.abs(T);
    local day = math.floor(T / 86400) --以天数为单位取整 
    local hour = math.floor(T % 86400 / 3600) --以小时为单位取整 
    local min = math.floor(T % 86400 % 3600 / 60) --以分钟为单位取整 
    local seconds = math.floor(T % 86400 % 3600 % 60 / 1) --以秒为单位取整 
    ----------------------------------------------------------------------------
    local hS;
    if (hour < 10) then
        hS = "0" .. hour;
    else
        hS = hour;
    end
    local mS;
    if (min < 10) then
        mS = "0" .. min;
    else
        mS = min;
    end
    --[[
    if(seconds<10)then
        sS= "0" .. seconds;
    else
        sS= seconds;
    end
    --]]
    hS = day * 24 + hS
    return hS .. ":" .. mS;
end