require "System.Global"
--装备商店中的装备线路径
UIShopEquipGroup = {}
----------------------------------------------------
function UIShopEquipGroup:New(o)
  local o = o or {}
  setmetatable(o, UIShopEquipGroup)
  UIShopEquipGroup.__index = UIShopEquipGroup
  return o
end
----------------------------------------------------
function UIShopEquipGroup:Awake(this) 
  self.this = this  

  self.dragPrefab=self.this.transforms[3];
  self.lineHPrefab=self.this.transforms[4];
  self.lineVPrefab=self.this.transforms[5];
  self.content=self.this.transforms[6]:GetComponent("UnityEngine.UI.LayoutElement");
  
  --[[
  self.drops={
    self.this.transforms[0]:GetChild(0),
    self.this.transforms[0]:GetChild(1),
    self.this.transforms[0]:GetChild(2),
    self.this.transforms[0]:GetChild(3),
    self.this.transforms[0]:GetChild(4),
    self.this.transforms[0]:GetChild(5),
  
    }
  --]]
       
  --[[
  self.drags=
    {
      {
        self.this.transforms[1]:GetChild(0):GetChild(0),
        self.this.transforms[1]:GetChild(0):GetChild(1),
        self.this.transforms[1]:GetChild(0):GetChild(2),
        self.this.transforms[1]:GetChild(0):GetChild(3),
        self.this.transforms[1]:GetChild(0):GetChild(4) 
      },
       {
        self.this.transforms[1]:GetChild(1):GetChild(0),
        self.this.transforms[1]:GetChild(1):GetChild(1),
        self.this.transforms[1]:GetChild(1):GetChild(2),
        self.this.transforms[1]:GetChild(1):GetChild(3),
        self.this.transforms[1]:GetChild(1):GetChild(4) 
      },
       {
        self.this.transforms[1]:GetChild(2):GetChild(0),
        self.this.transforms[1]:GetChild(2):GetChild(1),
        self.this.transforms[1]:GetChild(2):GetChild(2),
        self.this.transforms[1]:GetChild(2):GetChild(3),
        self.this.transforms[1]:GetChild(2):GetChild(4) 
      }
    }
    --]]
--[[
    --横向线路径
    self.LinesH=
    {
      {
         self.this.transforms[2]:GetChild(0):GetChild(0),
         self.this.transforms[2]:GetChild(0):GetChild(1),
         self.this.transforms[2]:GetChild(0):GetChild(2),
         self.this.transforms[2]:GetChild(0):GetChild(3),
         self.this.transforms[2]:GetChild(0):GetChild(4)
      },
      {
         self.this.transforms[2]:GetChild(1):GetChild(0),
         self.this.transforms[2]:GetChild(1):GetChild(1),
         self.this.transforms[2]:GetChild(1):GetChild(2),
         self.this.transforms[2]:GetChild(1):GetChild(3),
         self.this.transforms[2]:GetChild(1):GetChild(4)
      },
        {
         self.this.transforms[2]:GetChild(2):GetChild(0),
         self.this.transforms[2]:GetChild(2):GetChild(1),
         self.this.transforms[2]:GetChild(2):GetChild(2),
         self.this.transforms[2]:GetChild(2):GetChild(3),
         self.this.transforms[2]:GetChild(2):GetChild(4)
      },
        {
         self.this.transforms[2]:GetChild(3):GetChild(0),
         self.this.transforms[2]:GetChild(3):GetChild(1),
         self.this.transforms[2]:GetChild(3):GetChild(2),
         self.this.transforms[2]:GetChild(3):GetChild(3),
         self.this.transforms[2]:GetChild(3):GetChild(4)
      }
      
    }
    --]]
    
      self.LinesH={{},{},{},{}};
   --纵向线路径
   --[[
    self.LinesV=
    {
      {
         self.this.transforms[2]:GetChild(4):GetChild(0),
         self.this.transforms[2]:GetChild(4):GetChild(1),
         self.this.transforms[2]:GetChild(4):GetChild(2),
         self.this.transforms[2]:GetChild(4):GetChild(3),
      },
      {
         self.this.transforms[2]:GetChild(5):GetChild(0),
         self.this.transforms[2]:GetChild(5):GetChild(1),
         self.this.transforms[2]:GetChild(5):GetChild(2),
         self.this.transforms[2]:GetChild(5):GetChild(3),
      }
    }
    --]]
    
     self.LinesV={{},{}};
    
    
    self.drags={{},{},{}};
    --self:InitDrags(8,8,8)--测试用
    
end
function UIShopEquipGroup:InitDrags(num1,num2,num3)
  
  for i,v in pairs(self.drags) do
    for i1,v1 in pairs(v) do
      Object.Destroy(v1); --删除GameObject
    end
  end
  self.drags={{},{},{}};   --清空Table
  
  for i,v in pairs(self.LinesH) do
    for i1,v1 in pairs(v) do
      Object.Destroy(v1); --删除GameObject
    end
  end
  self.LinesH={{},{},{},{}};
  
   for i,v in pairs(self.LinesV) do
    for i1,v1 in pairs(v) do
      Object.Destroy(v1); --删除GameObject
    end
  end
  self.LinesV={{},{}};
  ------------------------------------------------------------
  local t= {num1,num2,num3} 
  local maxNum = math.max(unpack(t))
  self.content.preferredHeight=maxNum*100;--设置ScrollRect中容器Content的高度
  
    --根据参数生成Drag可拖拽购买的商品
    --[[
    for i=1,3,1 do
      for j=1,num,1 do
        local go=GameObject.Instantiate(self.dragPrefab.gameObject);
        go.transform:SetParent(self.this.transforms[1]:GetChild(i-1));
        go.transform.localScale = Vector3.one; 
        go.transform.localPosition = Vector3.New(0, -100*(j-1), 0);
        go.gameObject:SetActive(true);
        table.insert(self.drags[i],go);
      end
    end--]]
    
      
     
      for j=1,num1,1 do
        local go=GameObject.Instantiate(self.dragPrefab.gameObject);
        go.transform:SetParent(self.this.transforms[1]:GetChild(1-1));
        go.transform.localScale = Vector3.one; 
        go.transform.localPosition = Vector3.New(0, -100*(j-1), 0);
        go.gameObject:SetActive(true);
         go.transform.name=1 .. j;
        table.insert(self.drags[1],go);
        
                --注册方法进UIClick脚本，由于自带的OnPointClick不能作为触发条件
        local callback = function() --function(a,b) --如果要传的方法定义在外面 方法内并不会跟有对应数值 就需要注册方法的时候 把参数也传进去，但是在被注册方法的脚本执行时也要做相应的修改，影响通用性  
          self:OnPointerDown(go)
        end
        local uiClick=UITools.GetLuaScript(go,"Logic.UICommon.UIClick");  
        uiClick:RegisterClickDelegate(self,callback)  --方法注册  
        
      end
    
 
      for j=1,num2,1 do
        local go=GameObject.Instantiate(self.dragPrefab.gameObject);
        go.transform:SetParent(self.this.transforms[1]:GetChild(2-1));
        go.transform.localScale = Vector3.one; 
        go.transform.localPosition = Vector3.New(0, -100*(j-1), 0);
        go.gameObject:SetActive(true);
               go.transform.name=2 .. j;
        table.insert(self.drags[2],go);
        
                --注册方法进UIClick脚本，由于自带的OnPointClick不能作为触发条件
        local callback = function()
          self:OnPointerDown(go)
        end
        local uiClick=UITools.GetLuaScript(go,"Logic.UICommon.UIClick");  
        uiClick:RegisterClickDelegate(self,callback)    --方法注册  
        
      end
    
    
      for j=1,num3,1 do
        local go=GameObject.Instantiate(self.dragPrefab.gameObject);
        go.transform:SetParent(self.this.transforms[1]:GetChild(3-1));
        go.transform.localScale = Vector3.one; 
        go.transform.localPosition = Vector3.New(0, -100*(j-1), 0);
        go.gameObject:SetActive(true);
        go.transform.name=3 .. j;
        table.insert(self.drags[3],go);
        
        --注册方法进UIClick脚本，由于自带的OnPointClick不能作为触发条件
        local callback = function() 
          self:OnPointerDown(go)
        end
        local uiClick=UITools.GetLuaScript(go,"Logic.UICommon.UIClick");  
        uiClick:RegisterClickDelegate(self,callback)  --方法注册  
    
      end
   

      

      
      
      

    

 --因为刚好生需要用到的线麻烦 按最大行数生成 忽略不用的就好了
    
     for i=1,4,1 do
      for j=1,maxNum ,1 do
       
         local go=GameObject.Instantiate(self.lineHPrefab.gameObject);
        
        go.transform:SetParent(self.this.transforms[2]:GetChild(i-1));
        if(i==1 or i==3)then
          go.transform.localScale = Vector3.one; 
        else
          go.transform.localScale = Vector3.New(-1,1,1); 
        end
        go.transform.localPosition = Vector3.New(0, -100*(j-1), 0);
                go.transform.name=i .. j;
        --go.gameObject:SetActive(true);
        table.insert(self.LinesH[i],go);
      end
    end

        for i=1,2,1 do
      for j=1,maxNum -1,1 do
       local go=GameObject.Instantiate(self.lineVPrefab.gameObject);
        go.transform:SetParent(self.this.transforms[2]:GetChild(i-1+4));
        go.transform.localScale = Vector3.one; 
        go.transform.localPosition = Vector3.New(0, -100*(j-1), 0);
            go.transform.name=i .. j;
        --go.gameObject:SetActive(true);
        table.insert(self.LinesV[i],go);
      end
    end
   
    
    
    
end
----------------------------------------------------
function UIShopEquipGroup:Start()

end
----------------------------------------------------
function UIShopEquipGroup:OnDestroy()
  
  self.this = nil
  self = nil
end
----------------------------------------------------
function UIShopEquipGroup:OnPointerDown(GO)

  for i=1,#self.LinesH,1 do
    for j=1,#self.LinesH[i],1 do
      self.LinesH[i][j].gameObject:SetActive(false);
    end
  end
  
  for i=1,#self.LinesV,1 do
    for j=1,#self.LinesV[i],1 do
      self.LinesV[i][j].gameObject:SetActive(false);
    end
  end
  
  local go=GO-- UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject; --eventData.pointPress

  self:DrawLeft(go);
  self:DrawRight(go);
  
end
-----------------------------------------------------------------------------
function UIShopEquipGroup:DrawLeft(go)
                 
  
  local data=go:GetComponent("NTGLuaScript").self;
  

  

  

  
  
    
  if(data.lIds~=nil)then  --如果左节点不为空  
    
    local currentFatherIndex = tonumber(go.transform.parent.name) --获得当前所在组别索引
    --获得选中单位在组中的位置
    local currentChildIndex = 0;
    for i=1,#self.drags[currentFatherIndex],1 do
      if(go.name==self.drags[currentFatherIndex][i].name)then
           currentChildIndex = i;
      end
    end      
         
               
         
    for i=1,#data.lIds,1 do --对于每一个左节点
      for j=1,#self.drags[currentFatherIndex - 1] ,1 do  --在前一组别中找出它的索引  
    
        if(data.lIds[i]==self.drags[currentFatherIndex - 1][j]:GetComponent("NTGLuaScript").self.selfId) then
       
          if (self.drags[currentFatherIndex - 1][j]:GetComponent("NTGLuaScript").self.lIds~=nil) then
           
            self:DrawLeft(self.drags[currentFatherIndex - 1][j].gameObject);--递归，结束条件：没有左节点
          end
          --显示对应前置节点j的右连线
           
          self.LinesH[2 * currentFatherIndex - 3][j].gameObject:SetActive(true);
          --显示当前节点的左连线
           
          self.LinesH[2 * currentFatherIndex - 2][currentChildIndex].gameObject:SetActive(true);
          --显示高度差的连线 
          for y = 1,math.abs(j - currentChildIndex),1 do
            self.LinesV[currentFatherIndex - 1][math.min(j, currentChildIndex) + y-1].gameObject:SetActive(true);
          end
        end
      end
    end
  end
  
end
--------------------------------------------------------------------------------------
function UIShopEquipGroup:DrawRight(go)
  --Debugger.LogError("进入绘制→节点函数");
    local data=go:GetComponent("NTGLuaScript").self;
  if(data.rIds~=nil)then  --如果右节点不为空
    local currentFatherIndex = tonumber(go.transform.parent.name) --获得当前所在组别索引
    --获得选中单位在组中的位置
    local currentChildIndex = 0;
    for i=1,#self.drags[currentFatherIndex],1 do
      if(go.name==self.drags[currentFatherIndex][i].name)then
           currentChildIndex = i;
  --Debugger.LogError("当前节点索引" .. currentFatherIndex .. "," ..  currentChildIndex );
      end
    end
    for i=1,#data.rIds,1 do --对于每一个右节点
      for j=1,#self.drags[currentFatherIndex + 1] ,1 do  --在前一组别中找出它的索引
        
        if(data.rIds[i]==self.drags[currentFatherIndex + 1][j]:GetComponent("NTGLuaScript").self.selfId)then
  --Debugger.LogError("即将判断→节点" .. (currentFatherIndex + 1) .. j);
          if(self.drags[currentFatherIndex + 1][j]:GetComponent("NTGLuaScript").self.rIds~=nil)then
  --Debugger.LogError("成功判断→节点" .. (currentFatherIndex + 1) .. j);
            self:DrawRight(self.drags[currentFatherIndex + 1][j].gameObject);--递归，结束条件：没有左节点
               
          end
          --显示对应前置节点j的右连线
        
          self.LinesH[2 * currentFatherIndex-1][currentChildIndex].gameObject:SetActive(true);
          --显示当前节点的左连线
    
          self.LinesH[2 * currentFatherIndex][j].gameObject:SetActive(true);
          --显示高度差的连线 
          for y = 1,math.abs(j - currentChildIndex),1 do
            self.LinesV[currentFatherIndex ][math.min(j, currentChildIndex) + y-1].gameObject:SetActive(true);
          end
        end
      end
    end
  end
  
end

