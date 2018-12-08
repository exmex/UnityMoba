require "System.Global"

UIItems = {}

--UIItems.itemList={}; 
--UIItems.prefabMain={};
---------------------------------------------------
function UIItems:New(o)
  local o = o or {}
  setmetatable(o, UIItems)
  UIItems.__index = UIItems
  return o
end
----------------------------------------------------
function UIItems:Awake(this) 
  self.this = this  
--实例化并访问实例的例子
  --local test = UIItems.New()
  --test.xxx = 2
  --yyy = UIItems.New()

   ----------------------变量区-----------------------
  self.scrollRect={};
  self.gridLayoutGroup={};
  self.gridLayoutGroupChild={};
  
  self.pageDirection=0;     --书页横向、纵向
  self.boolInterval=true;   --是否根据页码 生成空的框
  
  self.xMax=2;
  self.yMax=3;
  
  self.spriteInterval=0;    --Image填充空白区域的图片
  self.prefabMain={}  ;     --GameObject
  
  self.itemList={};
  self.starList={};        
  
  self.prefabToogle={};     --GameObject;
  self.f=0;                 --对应Bar的值
  self.toggleList={};
  self.toogleParent={}      --Transform;
  self.toggleInterval=60;   --Toggle间距
  self.indexDrag={};        --手指滑动适配到的索引
  self.pageMax={};          --码的分母
  --self.pagination={}；    --Text
  -----------------------------------------------------
  self.scrollRect = self.this.gameObject:GetComponent("ScrollRect");
  
  if(self.this.transforms[0]~=nil)then
    self.prefabMain=self.this.transforms[0].gameObject; 
  end
  if(self.this.transforms[1]~=nil)then
    self.spriteInterval=self.this.transforms[1].gameObject; end
  if(self.this.transforms[2]~=nil)then
    self.prefabToogle=self.this.transforms[2].gameObject; end
  if(self.this.transforms[3]~=nil)then
    self.toogleParent=self.this.transforms[3]; end
    
  if(self.this.transforms[4]~=nil)then
    self.starParent=self.this.transforms[4];
    for i=1,self.this.transform.childCount,1 do
        table.insert(self.starList,self.this.transform:GetChild(i-1));
    end
  end
end
-----------------------------------------------------
function UIItems:Start()
  
  --self:ResetItemsSimple(5);  
  --self:ResetItemsCurrency(15);
  --self:ResetStars(5)
end
----------------------------------------------------
function UIItems:OnDestroy()
  

  
  self.this = nil
  self = nil
end
----------------------------------------------------
function UIItems:ResetItemsSimple(num)  --简易生成道具
  --for i,v in ipairs()

  for i=1,#(self.itemList),1 do
    Object.Destroy( self.itemList[i]); --删除GameObject
        --清空table
    --itemList[i]=nil;    --清空table
  end
  self.itemList={};   
  
  for i=1,num,1 do        --x轴方向列数
    local go; --print(#(self.itemList));
    if(#(self.itemList)<num)then
     
    go=GameObject.Instantiate(self.prefabMain);
    go.transform:SetParent(self.this.transform);
    go.transform.localScale = Vector3.one; 
    go.transform.localPosition = Vector3.zero;
    go.gameObject:SetActive(true);
    table.insert(self.itemList,go);
    end
  end
end
function UIItems:ResetItemsCurrency(num)  --通用生成道具

  self.gridLayoutGroup=self.this.transform:FindChild("GridLayoutGroup"):GetComponent("GridLayoutGroup");
  local gridLayoutGroupChild=self.this.transform:FindChild("GridLayoutGroup/GridLayoutGroup").gameObject;
  
  if(self.prefabToogle) then 
    self:ResetTogglesCurrency(num);
  end
  
  for k,v in pairs(self.itemList) do --删除GO，清空table
    Object.Destroy(v);
  end
  self.itemList={};
  
  local pageList={};
  local zMax; --需要的页数
  if(num==0)then
    zMax=1;
  else
    zMax=math.ceil(num/(self.xMax * self.yMax));  --向上取整
  end
  
  if(gridLayoutGroupChild)then--如果子Group存在
    for i=1,zMax,1 do
      local go;
      go=GameObject.Instantiate(gridLayoutGroupChild);
      go.transform:SetParent(self.gridLayoutGroup.transform);
      go.transform.localScale = Vector3.one; 
      go.transform.localPosition = Vector3.New(go.transform.localPosition.x, go.transform.localPosition.y, 0);
      go.gameObject:SetActive(true);
      table.insert(pageList,go);
    end
  end

  local page;
  for z=1,zMax,1 do
    page=pageList[z];
    for y=1,self.yMax,1 do --y轴方向行数
      
      for x=1,self.xMax,1 do --x轴方向列数
        local go;
        if(#self.itemList<num)then
           
          go=GameObject.Instantiate(self.prefabMain);
          go.transform:SetParent(page.transform);
          go.transform.localScale = Vector3.one; 
          go.transform.localPosition =  Vector3.New(go.transform.localPosition.x, go.transform.localPosition.y, 0);
          go.gameObject:SetActive(true);
          table.insert(self.itemList,go);
          
          listener = NTGEventTriggerProxy.Get(go);
          listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( UIItems.OnBeginDrag,self);
          listener.onDrag= listener.onDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf( UIItems.OnDrag,self);
          listener.onEndDrag= listener.onEndDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf( UIItems.OnEndDrag,self);
          
        elseif(self.boolInterval)then
          go=GameObject.Instantiate(self.spriteInterval.gameObject);
          go.transform:SetParent(page.transform);
          go.transform.localScale = Vector3.one; 
          go.transform.localPosition = Vector3.New(go.transform.localPosition.x, go.transform.localPosition.y, 0);
          go.gameObject:SetActive(true);
          --table.insert(pageList,go);
          listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( UIItems.OnBeginDrag,self);
          listener.onDrag= listener.onDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf( UIItems.OnDrag,self);
          listener.onEndDrag= listener.onEndDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf( UIItems.OnEndDrag,self);
        end 
      end
    end
  end 
  
  if(self.scrollRect)then
    if(self.gridLayoutGroup.startAxis == UnityEngine.UI.GridLayoutGroup.Axis.Horizontal)then
      self.scrollRect.horizontalNormalizedPosition = 0;
    else
      self.scrollRect.verticalNormalizedPosition = 1;
    end
  end  
end
-----------------------------------------------------
function UIItems:ResetTogglesCurrency(num) 
  --由于UGUI的组件可以整理对齐 ，所以之前排列的那部分代码也就删了，for由三层变为一层
  for k,v in pairs(self.toggleList) do --删除GO，清空table
    Object.Destroy(v);
  end
  self.toggleList={};
  
  local zMax; --需要的页数
  if(num==0)then
    zMax=1;
  else
    zMax=math.ceil(num/(self.xMax * self.yMax));  --向上取整
  end
  
  self.pageMax=zMax;
  
  for i=1,zMax,1 do
    local go;
    go=GameObject.Instantiate(self.prefabToogle); --需要赋值
    go.transform:SetParent(self.toogleParent);
    go.transform.localScale = Vector3.one; 
    go.transform.localPosition = Vector3.New(self.toggleInterval * (i-1) - (zMax-1) * self.toggleInterval / 2, 0, 0); 
    --print(go.transform.localPosition )
    go.gameObject:SetActive(true);
    table.insert(self.toggleList,go);
    
    local uiToogle=go:GetComponent("UnityEngine.UI.Toggle");
    if (i == 1)then
      uiToogle.isOn = true;--设置第一个Toggle值为True
    end
 
    ----为Toggle添加点击事件，设置Rect的位置 ，Toggle在OnPointDown时生效，要取Toggle的值需要Click时执行
    listener = NTGEventTriggerProxy.Get(go)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.SetPosition,self)
    
    
  end
end
------------------------------------------------------
function UIItems:SetPosition(e) --设置Rect的位置
  if(#self.toggleList>1)then
  
    for i=1,#self.toggleList,1 do
      if(self.toggleList[i]:GetComponent("UnityEngine.UI.Toggle").isOn)then
        self.f=(i-1)/(#self.toggleList-1);
      
        if(self.co~=nil)then
          coroutine.stop(self.co)
        end
        self.co = coroutine.start( UIItems.Lerp ,self)
        
      end
    end
    
  end
end
------------------------------------------------------
function UIItems:Lerp() 
  

    if(self.gridLayoutGroup.startAxis == UnityEngine.UI.GridLayoutGroup.Axis.Horizontal)then
      
      while(self.scrollRect.horizontalNormalizedPosition ~= self.f) do
        self.scrollRect.horizontalNormalizedPosition=math.lerp(self.scrollRect.horizontalNormalizedPosition, self.f, Time.deltaTime * 5) 
        if(math.abs(self.scrollRect.horizontalNormalizedPosition - self.f)<0.001)then
          self.scrollRect.horizontalNormalizedPosition =self.f
        end
        coroutine.step()
      end
      
    else
      
      while(self.scrollRect.verticalNormalizedPosition ~= self.f) do
        self.scrollRect.verticalNormalizedPosition=math.lerp(self.scrollRect.verticalNormalizedPosition, self.f, Time.deltaTime * 5) 
        if(math.abs(self.scrollRect.verticalNormalizedPosition - self.f)<0.001)then
          self.scrollRect.verticalNormalizedPosition =self.f
        end
        coroutine.step()
      end
      
    end
end
------------------------------------------------------
--[[
  listener = NTGEventTriggerProxy.Get(self.this.gameObject);
  listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( UIDragScrollRect.OnBeginDrag,self);
  listener.onDrag= listener.onDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf( UIDragScrollRect.OnDrag,self);
  listener.onEndDrag= listener.onEndDrag+ NTGEventTriggerProxy.PointerEventDelegateSelf( UIDragScrollRect.OnEndDrag,self);
--松开手指后缓动到标准位置
--]]
function UIItems:OnBeginDrag(eventData)
  coroutine.stop(self.co)  --目前就一个，结束掉一个就好
  --self.this:StopAllCoroutines();
end
function UIItems:OnDrag(eventData) 
end
function UIItems:OnEndDrag(eventData)  --松开手指后缓动到标准位置
    
  local scrollValue=0;
  --if(self.scrollRect)
  if(self.gridLayoutGroup.startAxis == UnityEngine.UI.GridLayoutGroup.Axis.Horizontal)then
    scrollValue= self.scrollRect.horizontalNormalizedPosition;
  else
    scrollValue = self.scrollRect.verticalNormalizedPosition;
  end
  
  local T={};
  for i=1,#self.toggleList,1 do
    
    local t; 
    if(#self.toggleList==1)then
      t=0;
    else
      t=(i-1)/(#self.toggleList-1);
    end
    table.insert(T,t);
  end
  
  if(#T>1)then
  
    for m=1,#T,1 do
      if(m~=1 and m~=#T)then
        
        if(  scrollValue>(T[m-1]+T[m])/2 and scrollValue<=(T[m]+T[m+1])/2 )then
         
          self.toggleList[m]:GetComponent("UnityEngine.UI.Toggle").isOn=true;
          self.indexDrag=m;--赋给当前页码
            
          self:SetPosition();
        end
        
      elseif(m==1)then
        
        if(scrollValue <= (T[m] + T[m + 1]) / 2)then
          self.toggleList[m]:GetComponent("UnityEngine.UI.Toggle").isOn=true;
          self.indexDrag=m;--赋给当前页码
           
          self:SetPosition();
        end
        
      elseif(m==#T)then
        
          if (scrollValue > (T[m - 1] + T[m]) / 2)then
            self.toggleList[m]:GetComponent("UnityEngine.UI.Toggle").isOn=true;
            self.indexDrag=m;--赋给当前页码
            
            self:SetPosition();
          end
        
      end
    
    end
  
  end
end
--[[ coroutine需要存起来再全部结束 还没写
----------------------------------------------下一页--翻页按钮没测过，如果有问题应该是C#转lua起始索引差别引起的
function UIItems:NextPage() 
  self.this:StopAllCoroutines();
  if(self.this.gameObject.activeInHierarchy)then
    if( self.indexDrag < #self.toggleList - 1 )then
      self.indexDrag=self.indexDrag+1;
      self.toggleList[self.indexDrag].GetComponent("UnityEngine.UI.Toggle").isOn= true;--拖拽索引的下一页
    end
  end
  self:SetPosition(nil) --设置Rect的位置
end
----------------------------------------------上一页--
function UIItems:PreviousPage() 
  self.this:StopAllCoroutines();
  if(self.this.gameObject.activeInHierarchy)then
    if( self.indexDrag >0 )then
      self.indexDrag=self.indexDrag-1;
      self.toggleList[self.indexDrag].GetComponent("UnityEngine.UI.Toggle").isOn= true;
    end
  end
  self:SetPosition(nil) --设置Rect的位置
end
--------------------------------------------设置页码--
function UIItems:SetPagination()
  self.pagination.text = ( self.indexDrag + 1) + "/" + self.pageMax;
end
--]]
------------------------------------------------------
function UIItems:ResetStars(amount)
  
  for i=1,#self.starList,1 do
    
    if(i<=amount)  then
      self.starList[i].gameObject:SetActive(true);
    else
      self.starList[i].gameObject:SetActive(false);
    end
    
  end
end
  -------------------------库函数---------------------------
  --itemList[#itemList+1]="a" --向数组中添加元素
  --table.insert(itemList,2,"aa") --插入（系统提供）
  --table.insert(itemList,"aa") --添加到末尾（系统提供）
  
  --table.remove(itemList,2) --删除键为2的元素（系统提供）
  --table.remove(itemList) --删除最后一个元素（系统提供）
  
  --table.sort(itemList) --排序一般用不到，有重载
  --table.concat
  --table.maxn(t) 返回最大键
  --table.foreachi(表，function（i，v）)
  --table.foreach(表，function（i，v）)
  --table.getn(t) --返回元素个数
  --table.setn(t,个数)--设置元素个数
  --泛型for
  --days={"s","s","s"}
  --for k,v in pairs(days) do
  --print(k .. ":" .. v)
  --end
  
  --string.format(,)
  --print(os.date("今天是%B%d日%A"))
  --今天是三月10日星期一
  --temp=os.date("*t",os.time())
  --for k,v in pairs(temp) do--以表的形式构造返回时间
  --  print(k,v)
  --  end
 

  --print（...）
  --tostring（？）
  --tonumber（？）
  --type（？）
  --rawset（表 ，键 ，值） --更改值 返回表指针
  --rawget（表 ，键 ）--键为数字的表的值
  --rawequal（1,2）--比较大小

  --dofile(xxx.lua)
  --next(表，1) --返回下一个键2和对应的值-- 数字键
  --pairs（t）--可返回nil
  --ipairs（t）--
  
  --Debugger.LogError("Lines之后")
   ---------------------------------------------------------







