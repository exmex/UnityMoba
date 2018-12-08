
class("UIJoyStick")
----------------------------------------------------
function UIJoyStick:Awake(this) 
  self.this = this  
  
  -------------------------------------
  --self.y=GameObject.Find("PanelRoot"):GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.y;
  --self.camera=GameObject.Find("GameLogic"):GetComponent("Camera");
  self.tStick = self.this.transform;
  self.tCenter=self.this.transforms[0];--传进来
  self.Collider=self.this.transforms[1];--传进来
 
  self.range=self.this.floats[0];--传进来
  self.inputAxis= Vector2.zero;
  --self.offset =  Vector3.New( -Screen.width/2, Screen.height/2, 0);
  self.canMoveCenter=false

  self.camera=GameObject.Find("GameLogic"):GetComponent("Camera");
  self.y=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.y
  self.x=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.x
  self.offset =  Vector3.New( -self.x/2, self.y/2, 0);--对应锚点左下角
  self.wash= self.x /self.y;



  --self.canBeAssign=true;
  
  if(tostring(Application.platform) == tostring(UnityEngine.RuntimePlatform.Android) or tostring(Application.platform) == tostring(UnityEngine.RuntimePlatform.IPhonePlayer))then
    self.isMobileDevice =true
  else
    self.isMobileDevice =false
  end
   
  self.coTable={}
end
----------------------------------------------------
function UIJoyStick:OnEnable()
   
end
------------------------------------------------------
function UIJoyStick:Start()

  local listener = NTGEventTriggerProxy.Get(self.Collider.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
         function ()
            --[[
            if(self.isMobileDevice ==true)then
                          local flag=false;
                          --if(self.canBeAssign==true)then
                                        for i=1 , #UIBattleAPI.lastFingerIds,1 do
                                          if(UIBattleAPI.lastFingerIds[i]~=Input.touches[i-1].fingerId)then
                                            self.touch=Input.touches[i-1]   
                                            flag=true
                                            break
                                          end
                                        end
                                        if(flag==false)then self.touch=Input.touches[Input.touches.Length-1]    end
                            --self.canBeAssign=false
                          --end
            end
            --]]
            --------------------------------------------------
            if(self.isMobileDevice == true)then
                  for i=1,Input.touchCount,1 do
                    --if(self.canBeAssign==true)then
                      if (Input.GetTouch(i-1).phase == 0)then  --Began
                        --self.canBeAssign=false
                        if(Input.GetTouch(i-1).position.x>self.x-524)then  -- and Input.GetTouch(i-1).position.y>self.y-484
                          self.touch=Input.GetTouch(i-1)  --Debugger.LogError("0Began")
                        end
                      elseif (Input.GetTouch(i-1).phase == 1)then  --Moved
                        --Debugger.LogError("1Moved")
                      elseif (Input.GetTouch(i-1).phase == 2)then  --Stationary
                        --Debugger.LogError("2Stationary")
                      elseif (Input.GetTouch(i-1).phase == 3)then  --Ended
                        --Debugger.LogError("3Ended")
                      elseif (Input.GetTouch(i-1).phase == 4)then  --Canceled
                        --Debugger.LogError("4Canceled")
                      end
                    --end
                  end
                  
            end
            --------------------------------------------------
          end,self
         );
  listener = NTGEventTriggerProxy.Get(self.Collider.gameObject);
  listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
         function ()
             --self.canvasGroup.alpha=1;
             --self.JoyStickIIIShadow.alpha=0
             self.co =coroutine.start( self.MoniUpdate,self)
             table.insert(self.coTable,self.co );
          end,self
         );
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
         function ()
             --self.canvasGroup.alpha=0;
             --self.JoyStickIIIShadow.alpha=1
             
             --self.this:StopCoroutine(  self.co  )
             for k,v in pairs(self.coTable) do
               coroutine.stop(v)
             end
     
             self.tStick.localPosition=self.tCenter.localPosition
             self.inputAxis= Vector2.zero;

             --self.canBeAssign=true
          end,self
         );
  


end
----------------------------------------------------
function UIJoyStick:OnDestroy() 
  for k,v in pairs(self.coTable) do
               coroutine.stop(v)
             end

  ------------------------------------
  self.this = nil
  self = nil
end
-------------------------------------------------------
function UIJoyStick:MouseToUIposition(mousePosition) --Input.mousePosition
    
   

    local screenPos = self.camera:ScreenToViewportPoint(mousePosition);
 
    return Vector3.New((screenPos.x - 0.5) * self.y * self.wash, (screenPos.y - 0.5) * self.y, 0);
  
end
---------------------------------------------------------------------------
function UIJoyStick:MoniUpdate()

  local pos;
  while(true) do
    --[[
    if (self.canMoveCenter==true and Input.GetMouseButtonDown(0))then
      self.tCenter.localPosition=self:MouseToUIposition(Input.mousePosition)+self.offset ;
    end
    --]]
    local mouseUiPos;
    if(self.isMobileDevice ==true)then
      for i=1,Input.touches.Length,1 do
        if(self.touch.fingerId==Input.touches[i-1].fingerId)then
          pos=Input.touches[i-1].position
        end
      end
      mouseUiPos=self:MouseToUIposition(pos); 
    else
      mouseUiPos=self:MouseToUIposition(Input.mousePosition); 
    end
    
    --鼠标屏幕坐标转换为 中心点在屏幕中心的父物体的局部坐标
    --以上计算结果为鼠标位置相对于屏幕中心的局部坐标，所以让摇杆Stick的父物体（锚点设置）为右下角时，
    --此局部坐标需要向左上加半个屏幕宽高的偏移量作为右下角的局部坐标，才能视觉上摇杆Stick的局部坐标和鼠标位置相同
    local stickUsualLocalPos = mouseUiPos + self.offset;
    local dis = Vector3.Distance(stickUsualLocalPos, self.tCenter.localPosition);--鼠标到圆盘中心的距离
    
    if(dis<=self.range)then
      self.tStick.localPosition = stickUsualLocalPos;
    else
      self.tStick.localPosition= self.tCenter.localPosition + ( stickUsualLocalPos - self.tCenter.localPosition )* self.range/dis;--所需加的向量 / range = 中心到鼠标指针的向量 / dis  
    end
      
    --给轴赋值，赋值给Vector2，适应之前外部的使用习惯 
    local v=(self.tStick.localPosition - self.tCenter.localPosition) / self.range;
    self.inputAxis.x = v.x;
    self.inputAxis.y = v.y;     
    
    coroutine.step() 
  end  
    
end