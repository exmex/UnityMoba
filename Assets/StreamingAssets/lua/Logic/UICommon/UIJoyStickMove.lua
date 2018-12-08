
class("UIJoyStickMove")
----------------------------------------------------
function UIJoyStickMove:Awake(this) 
  self.this = this  
  
  -------------------------------------
  
  self.tStick = self.this.transform;
  self.tCenter=self.this.transforms[0];--传进来
  self.JoyStickIIIShadow=self.this.transforms[1]:GetComponent("CanvasGroup")--.alpha 
  self.Collider=self.this.transforms[2].gameObject--碰撞出现区域
  self.Arrow=self.this.transforms[3]--箭头
  self.range=self.this.floats[0];--传进来
  self.inputAxis= Vector2.zero;
  self.canTouch=false;

  self.canMoveCenter=true  --是否可以移动中心基准点
  self.canvasGroup=self.tCenter.parent:GetComponent("CanvasGroup")--.alpha 
  
  --self.canBeAssign=true;
  self.touch={}

  if(tostring(Application.platform) == tostring(UnityEngine.RuntimePlatform.Android) or tostring(Application.platform) == tostring(UnityEngine.RuntimePlatform.IPhonePlayer))then
    self.isMobileDevice =true
  else
    self.isMobileDevice =false
  end

  self.coTable={}
end
----------------------------------------------------
function UIJoyStickMove:OnEnable()

  
  

 
end
------------------------------------------------------
function UIJoyStickMove:Start()

   

  local listener = NTGEventTriggerProxy.Get(self.Collider);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
         function ()
              --[[
              if(self.isMobileDevice == true)then
                local flag=false;
                --if(self.canBeAssign==true)then
                  --Debugger.LogError(  #UIBattleAPI.lastFingerIds)
                  for i=1 , #UIBattleAPI.lastFingerIds,1 do
                    --Debugger.LogError("LastId" .. i .. ":" .. UIBattleAPI.lastFingerIds[i])  Debugger.LogError("CurrentId" .. i .. ":" .. Input.touches[i-1].fingerId)
                    if(UIBattleAPI.lastFingerIds[i]~=Input.touches[i-1].fingerId)then
                      self.touch=Input.touches[i-1]   --Debugger.LogError(true)
                      flag=true
                      break
                    end
                    
                  end
                  if(flag==false)then self.touch=Input.touches[Input.touches.Length-1]    end
                  --self.canBeAssign=false
                --end
              end
              --]]
              ----------------------------------------------
              if(self.isMobileDevice == true)then
                  for i=1,Input.touchCount,1 do
                    --if(self.canBeAssign==true)then
                      if (Input.GetTouch(i-1).phase == 0)then  --Began
                        --self.canBeAssign=false
                        if(Input.GetTouch(i-1).position.x<=524 and Input.GetTouch(i-1).position.y<=484)then
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
              ----------------------------------------------

              
          
             self.canvasGroup.alpha=1;
             self.JoyStickIIIShadow.alpha=0
             if(self.canMoveCenter==true)then
              local tempX;local tempY;
             --[[ --Ipad比例值
                tempX=math.clamp( self:MouseToUIposition(Input.mousePosition).x ,self.x  * (-0.355),self.x  * (-0.236) )--将局部坐标进行约束
                tempY=math.clamp( self:MouseToUIposition(Input.mousePosition).y ,self.y * (-0.316),self.y * (-0.149) )--将局部坐标进行约束
             --]]
             --安卓比例值
               if(self.isMobileDevice == true)then
                     --[[
                      local pos;
                      for i=1,Input.touches.Length,1 do
                        if(self.touch.fingerId==Input.touches[i-1].fingerId)then
                          pos=Input.touches[i-1].position
                        end
                      end--]] 
                 tempX=Mathf.Clamp( self:MouseToUIposition(self.touch.position).x ,self.x  * (-0.378125),self.x  * (-0.2734375) )--将局部坐标进行约束
                 tempY=Mathf.Clamp( self:MouseToUIposition(self.touch.position).y ,self.y * (-0.285),self.y * (-0.1) )--将局部坐标进行约束
               else
                 tempX=Mathf.Clamp( self:MouseToUIposition(Input.mousePosition).x ,self.x  * (-0.378125),self.x  * (-0.2734375) )--将局部坐标进行约束
                 tempY=Mathf.Clamp( self:MouseToUIposition(Input.mousePosition).y ,self.y * (-0.285),self.y * (-0.1) )--将局部坐标进行约束
               end
             self.tCenter.localPosition=Vector3.New(tempX,tempY,0)+self.offset ;
             
             end

             self.co  =coroutine.start( self.MoniStick,self)
             table.insert(self.coTable,self.co );
          end,self
         );
  
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
         function ()
             self.canvasGroup.alpha=0;
             self.JoyStickIIIShadow.alpha=1
             --self.this:StopCoroutine(  self.co  )  
             --这里只Stop一个是不行的，因为有可能有两次Down事件，就产生两个协程在同事运行，而Up只停掉了最后被存在self.co 里的那个，还剩下一个仍在运行，所以也不要麻烦的去存储多个引用逐一停掉，直接干脆StopAll
             
             for k,v in pairs(self.coTable) do
               coroutine.stop(v)
             end
             self.inputAxis= Vector2.zero;

             --self.canBeAssign=true
          end,self
         );

  self.camera=GameObject.Find("GameLogic"):GetComponent("Camera");

  self.y=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.y
  self.x=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.x
  self.offset =  Vector3.New( self.x/2, self.y/2, 0);--对应锚点左下角
  self.wash= self.x /self.y;
--[[--CanvasScaler错误
  self.y=GameObject.Find("PanelRoot"):GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.y;
  self.x=GameObject.Find("PanelRoot"):GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.x;
  self.offset =  Vector3.New( self.x/2, self.y/2, 0);--对应锚点左下角
  self.wash= self.x /self.y;
--]]

  --[[--屏幕宽高错误
  self.y=Screen.height   Debugger.LogError(Screen.height);
  self.x=Screen.width    Debugger.LogError(Screen.width);
  self.offset =  Vector3.New( self.x/2, self.y/2, 0);--对应锚点左下角
  self.wash= self.x /self.y;
  --]]
end
----------------------------------------------------
function UIJoyStickMove:OnDestroy() 
  for k,v in pairs( self.coTable) do
    coroutine.stop(v)
  end
 

  ------------------------------------
  self.this = nil
  self = nil
end
-------------------------------------------------------
function UIJoyStickMove:MouseToUIposition(mousePosition) --Input.mousePosition
    
    
    
    

    local screenPos = self.camera:ScreenToViewportPoint(mousePosition);
 
    return Vector3.New((screenPos.x - 0.5) * self.y * self.wash, (screenPos.y - 0.5) * self.y, 0);
  
end

---------------------------------------------------------------------------
function UIJoyStickMove:MoniStick()
  
  local pos;
  while(true) do
    local mouseUiPos
    if(self.isMobileDevice == true)then
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
    
    -------------------------控制箭头指向--------------------------
 
    if(  self.inputAxis.x==0 and self.inputAxis.y==0 )then     
      if(self.Arrow.gameObject.activeSelf==true)then      
        self.Arrow.gameObject:SetActive(false);     
      end
    else     
      if(self.Arrow.gameObject.activeSelf==false)then     
        self.Arrow.gameObject:SetActive(true);       
      end
      self.Arrow.eulerAngles=Vector3.New(0, 0, 180 / 3.14 * math.atan2(self.inputAxis.y, self.inputAxis.x));      
       
    end
    
    ---------------------------------------------------
    coroutine.step() 
  end  
   
end