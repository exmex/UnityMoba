--author zx
class("PageTextBattleRuleCtrl")

function PageTextBattleRuleCtrl:Awake(this)
  self.this = this
  self.txttitle = "对战规则"
    self.txtcontent = "<size=32><color=#e4e4f0>一、 挂机逃跑惩罚：</color></size>\n<size=26><color=#D4D4D4>1、指挥官在多人对战中，两分钟内未对姬神进行有效操作，系统将判断为挂机行为；\n2、若指挥官回到游戏，表现良好，将取消挂机行为的判定；\n3、若指挥官直接退出游戏，系统将判断为逃跑行为；\n4、挂机逃跑将不予发放结算奖励，且将被系统记录，严重者将受到官网公示，甚至封号处理；</color></size><size=32><color=#e4e4f0>\n二、游戏中不良行为的惩罚：</color></size>\n<size=26><color=#D4D4D4>为了维护良好的游戏环境，我们会对游戏中表现出不良行为的玩家进行惩罚。另外，我们也欢迎所有的玩家都对不良行为进行举报。良好的游戏氛围是大家共同努力的结果。\n以下行为将会受到惩罚：\n1、故意退出、逃跑；\n2、恶意挂机、不参与游戏；\n3、消极比赛，而遭到举报；\n4、使用外挂等姬神游戏平衡的软件‘\n5、在游戏中发布虚假信息；发表设计政治、法令等信息；\n6、冒充官方人员进行诈骗；</color></size>"..
    "<size=32><color=#e4e4f0>\n三、关于大区和匹配：</color></size><size=26><color=#D4D4D4>\n游戏中实行<color=#f8ac07>全区匹配</color>的机制。\n1、游戏中会分几个大区\n2、每个大区内，各有多个小区\n3、玩家可以匹配到同一大区，不同小区的玩家，即便不在同一小区的玩家，也可以互加好友、一起开黑！</color></size>"..
    "<size=32><color=#e4e4f0>\n四、断线重连：</color></size><size=26><color=#D4D4D4>\n游戏局内断线重连机制，若玩家在游戏中不慎掉线，在<color=#f8ac07>该局游戏结束前</color>再次进入游戏会自动重连；如遇掉线，请尽快检查网络、重启游戏回到战斗中吧！</color></size>" 
  coroutine.start(PageTextBattleRuleCtrl.CreateMainPanelMov,self) 
  end

--加载界面
function PageTextBattleRuleCtrl:CreateMainPanelMov()
  local result = GameManager.CreatePanelAsync("PageText")
  while result.Done~= true do
    --print("deng")
    coroutine.wait(0.05) 
  end
  
  PageTextAPI.instance:Init(self.txttitle,self.txtcontent)
  GameObject.Destroy(self.this.gameObject)
end


function PageTextBattleRuleCtrl:OnDestroy()
  self.this = nil
  self = nil
end