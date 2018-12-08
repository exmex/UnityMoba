
LoginUtils = {}

function LoginUtils.ConnectToLoginServer(serverIp, serverPort, connectHandler, connectHandlerSelf)
  
  if LoginUtils.netService == nil then
      LoginUtils.netService = TGNetService.GetInstance()
  end
  
  if LoginUtils.netService:IsRunning() then
      LoginUtils.netService = TGNetService.NewInstance()
  end
  
  if connectHandler ~= nil then
    if connectHandlerSelf ~= nil then
      LoginUtils.netService:AddEventHandler("Connect", TGNetService.NetEventHanlderSelf(connectHandler, connectHandlerSelf), 0)
    else
      LoginUtils.netService:AddEventHandler("Connect", TGNetService.NetEventHanlder(connectHandler), 0)
    end  
  end
  
  LoginUtils.netService:Start(serverIp, serverPort)
  GameManager.NetDispatcherHost:StartCoroutine(LoginUtils.netService:NetEventDispatcher())
end

function LoginUtils.ConnectToGameServer(serverIp, serverPort, connectHandler, connectHandlerSelf, disconnectHandler, disconnectHandlerSelf)
  
  if LoginUtils.netService == nil then
      LoginUtils.netService = TGNetService.GetInstance()
  end
  
  if LoginUtils.netService:IsRunning() then
      LoginUtils.netService = TGNetService.NewInstance()
  end
  
  if connectHandler ~= nil then
      LoginUtils.netService:AddEventHandler("Connect", TGNetService.NetEventHanlderSelf(connectHandler, connectHandlerSelf), 0)
  end
  
  if disconnectHandler ~= nil then
      LoginUtils.netService:AddEventHandler("Disconnect", TGNetService.NetEventHanlderSelf(disconnectHandler, disconnectHandlerSelf), 0)
  end
  
  
  
  LoginUtils.netService:Start(serverIp, serverPort)
  GameManager.NetDispatcherHost:StartCoroutine(LoginUtils.netService:NetEventDispatcher())
  
end
