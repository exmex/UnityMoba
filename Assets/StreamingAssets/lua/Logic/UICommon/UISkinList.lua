require "System.Global"

UISkinList= {}
---------------------------------------------------------------------
function UISkinList:New(o)
  local o = o or {}
  setmetatable(o, UISkinList)
  UISkinList.__index = UISkinList
  return o
end
---------------------------------------------------------------------
function UISkinList:Awake(this) 
  self.this = this  
  
  self.skinList={};
  self.standardInterval=60; --默认标准距离
  self.scaling = 1;         --缩放比例会递减0.1f
  self.directionRight=true;
  
  self.coroTable={}
end
---------------------------------------------------------------------
function UISkinList:Start()
  

  
  
  --self:GetSkinList();
  --self:SetSkinsLayer();
  --self:SetSkinsPosition();
  
  
  
end
---------------------------------------------------------------------
function UISkinList:Update()
  
end
---------------------------------------------------------------------  
function UISkinList:OnDestroy()
  for k,v in pairs(self.coroTable) do
    coroutine.stop(v)
  end
  
  self.this = nil
  self = nil
end

function UISkinList:GetSkinList()--获取同级UIItems生成的Skin
  
  for i=1,#(self.skinList),1 do
    Object.Destroy( self.skinList[i]); --删除GameObject
  end
  self.skinList={};   
  
  
  for i=1,self.this.transform.childCount,1 do
    table.insert(self.skinList,self.this.transform:GetChild(i-1));
  end
  
end

---------------------------------------------------------------------
function UISkinList:MoveLeft()
    print("MoveLeft")
  if(#self.skinList==0)then 
    return;
  end
  
  
  for k,v in pairs(self.coroTable) do
    coroutine.stop(v)
  end
 
  local tempT=self.skinList[1];
  table.remove(self.skinList,1);
  table.insert(self.skinList,tempT);
  
  self:SetSkinsPosition();
  self:SetSkinsLayer();   
end
---------------------------------------------------------------------
function UISkinList:MoveRight()
    print("MoveRight")
  if(#self.skinList==0)then 
    return;
  end
  
 
  for k,v in pairs(self.coroTable) do
    coroutine.stop(v)
  end
  
  local tempT=self.skinList[#self.skinList];
  table.remove(self.skinList);
  table.insert(self.skinList,1,tempT);
  
  self:SetSkinsPosition();
  self:SetSkinsLayer();   
  
end
---------------------------------------------------------------------
function UISkinList:SetSkinsLayer()

  for i=1,#self.skinList,1 do
    self.skinList[i]:SetSiblingIndex(#self.skinList-i);
  end

end
---------------------------------------------------------------------
function UISkinList:SetSkinsPosition()

  for i=1,#self.skinList,1 do
    table.insert(
                  self.coroTable,
                  coroutine.start( UISkinList.LerpPos, self, self.skinList[i],  Vector3.New((self.standardInterval * i) * self.scaling, 0, 0)   )
                )
    table.insert(
                  self.coroTable,   
                  coroutine.start( UISkinList.LerpScale, self,self.skinList[i], Vector3.one * self.scaling)
                )
   
     
   self.skinList[i]:GetComponent("CanvasGroup").alpha = self.scaling;
 
   
   self.scaling=self.scaling-0.1;
  end
  self.scaling = 1;
  
end
---------------------------------------------------------------------
function UISkinList:SetSkinsPositionSoon()
  
  for i=1,#self.skinList,1 do
    self.skinList[i].localPosition = Vector3.New((self.standardInterval * i) *  self.scaling , 0, 0);
    self.skinList[i].localScale = Vector3.one * self.scaling;
    self.skinList[i]:GetComponent("CanvasGroup").alpha = self.scaling;
    self.scaling=self.scaling-0.1;
  end 
  self.scaling = 1;
  
end

---------------------------------------------------------------------
function UISkinList:LerpPos(currentT, nextPos)  --Transform,Vector3
  
  while(true)do
    
    if(currentT)then
  
      currentT.localPosition = Vector3.Lerp(currentT.localPosition, nextPos, 0.05);
      --currentT.localPosition = Vector3.Slerp(Vector3.one, nextPos, 0.05);
    end
    
    coroutine.step();
    
    if(currentT and math.abs(currentT.localPosition.x - nextPos.x)< 0.01)then
      break;
    end
    
  end
  
 
end
---------------------------------------------------------------------

function UISkinList:LerpScale(currentT, nextScale)   --Transform,Vector3

  while(true)do
    if(currentT)then
      currentT.localScale = Vector3.Lerp(currentT.localScale, nextScale, 0.05);
    end
    coroutine.step();
    if(currentT and math.abs(currentT.localScale.x - nextScale.x)< 0.01)then
      break;
    end
  end

end

