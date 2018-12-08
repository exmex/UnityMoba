require "System.Global"

class("ChangeSize")

function ChangeSize:Awake(this)
  self.this = this
end

function ChangeSize:Start()
  coroutine.start(ChangeSize.CS, self)
end

function ChangeSize:CS()
  local center = self.this.gameObject.transform.parent.parent.parent
  --while (true) do
    
    --coroutine.wait(0.1)
  --end
end

