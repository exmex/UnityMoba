require "System.Global"
--注释：测试用，给Lines赋值
UITestForLines = {}
----------------------------------------------------
function UITestForLines:New(o)
  local o = o or {}
  setmetatable(o, UITestForLines)
  UITestForLines.__index = UITestForLines
  return o
end
----------------------------------------------------
function UITestForLines:Awake(this) 
  self.this = this  

 
end
----------------------------------------------------
function UITestForLines:Start()
  
  

self.drags=
    {
      {
        self.this.transforms[0]:GetChild(0):GetChild(0):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(0):GetChild(1):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(0):GetChild(2):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(0):GetChild(3):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(0):GetChild(4):GetComponent("NTGLuaScript").self
      },
       {
        self.this.transforms[0]:GetChild(1):GetChild(0):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(1):GetChild(1):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(1):GetChild(2):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(1):GetChild(3):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(1):GetChild(4):GetComponent("NTGLuaScript").self 
      },
       {
        self.this.transforms[0]:GetChild(2):GetChild(0):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(2):GetChild(1):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(2):GetChild(2):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(2):GetChild(3):GetComponent("NTGLuaScript").self,
        self.this.transforms[0]:GetChild(2):GetChild(4):GetComponent("NTGLuaScript").self 
      }
    }
     self.drags[1][1].selfId=11;
 self.drags[1][1].lIds =nil; --{}  --List<string>
 self.drags[1][1].rIds ={22};

 self.drags[2][2].selfId=22;
 self.drags[2][2].lIds ={11}; --{}  --List<string>
 self.drags[2][2].rIds ={33};
  
  self.drags[3][3].selfId=33;
 self.drags[3][3].lIds ={22}; --{}  --List<string>
 self.drags[3][3].rIds =nil;
  
end
----------------------------------------------------
function UITestForLines:OnDestroy()
  
  self.this = nil
  self = nil
end