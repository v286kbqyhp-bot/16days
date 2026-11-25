extends Resource

## 营地经济规则。调数值时打开 prototype.tres；粉尘按整克结算。
@export_group("采集与税收")
## 全保收入（g，试算）：第一阶段所有采集器都保住时，全队一趟共采到多少粉尘。
@export var full_yield_g: int = 30
## 采集器全毁时保留的比例（试算）。0.07 表示保留全保收入的 7%，调大能减轻全毁损失。
@export var all_destroyed_ratio: float = 0.07
## 全队濒死提前回营时保留的比例（试算）。先按存活采集器算收入，再乘这个数；若采集器全毁，只算全毁收益。
@export var retreat_ratio: float = 0.5
## 基础税额（g，试算）：第一阶段每次回营要交多少。调高后，税后可用于成长的粉尘会减少。
@export var tax_base_g: int = 10
## 采集收入的阶段倍率（试算）。1 表示各阶段相同；1.1 表示每进一个阶段，全保收入比上一阶段多 10%。
@export var yield_growth: float = 1.0
## 税额的阶段倍率（试算）。1 表示税额固定；1.2 表示每进一个阶段税额增长 20%。
@export var tax_growth: float = 1.0

@export_group("利息与储备提醒、赎回")
## 计息门槛（g）：本金每存满多少克算一份利息。必须大于 0；门槛越高，同样的本金赚得越少。
@export var interest_step_g: int = 5
## 每份利息（g）：本金每满一个计息门槛，就发这么多克。当前规则是每满 5 g 得 1 g。
@export var interest_gain_g: int = 1
## 利息上限（g）：一次回营最多能领多少利息。
@export var interest_cap_g: int = 5
## 消费提醒线（百分数）：填 80 表示 80%。若下次税额是 10 g，消费后剩 7 g 会提醒，剩 8 g 直接成交。每次回营最多提醒一次。
@export var warning_percent: int = 80
## 纹章赎回倍率：用该纹章的商店售价乘此数。1.1 表示加价 10%，最后向上取整克。
@export var redemption_multiplier: float = 1.1

@export_group("营地价格")
## 第一阶段的品类基价（g，试算）。coin＝强化硬币，rune＝符文，common_crest＝普通纹章，legendary_crest＝传奇纹章，weapon_craft＝制作武器的费用。
@export var base_prices_g: Dictionary[String, int] = {}
## 价格的阶段倍率（试算）。1 表示各阶段同价；大于 1 时，商品和武器制作费用随阶段上涨。
@export var price_growth: float = 1.0
## 出售回收比例（试算）。0.5 表示卖出时收回估值的一半，零头向下取整克。
@export var resale_ratio: float = 0.5
## 装符文手续费（g，试算）：每装一枚收取的粉尘。
@export var rune_install_g: int = 1
## 完整拆卸手续费（g，试算）：花粉尘取回符文；免费清除会销毁符文。
@export var rune_remove_g: int = 1

@export_group("关卡奖励")
## 胜利时抽取关卡奖励的次数（试算）。调大可多抽几次，具体物品由关卡奖池决定。
@export var victory_draws: int = 2
## 失败时抽取关卡奖励的次数（试算）。与胜利抽数一起调节胜败收益差距。
@export var defeat_draws: int = 1
## 附加任务奖励（枚，试算）：完成一项有硬币奖励的任务，基础发放多少枚强化硬币。
@export var objective_coins: int = 1
## 地图额外宝箱奖励（枚，试算）：打开一只装有硬币的额外宝箱，基础发放多少枚强化硬币。
@export var map_chest_coins: int = 1


## 计算指定阶段的应缴税额，第一阶段直接使用基础税额。
func tax_g(stage: int) -> int:
	return roundi(tax_base_g * pow(tax_growth, stage - 1))


## 结算采集收入。例如部署 3 台、保住 2 台，正常回营可拿全保收入的三分之二。
func harvest_g(stage: int, surviving: int, deployed: int, retreated: bool) -> int:
	assert(stage >= 1 and deployed > 0 and surviving >= 0 and surviving <= deployed)
	var full := full_yield_g * pow(yield_growth, stage - 1)
	if surviving == 0:
		return roundi(full * all_destroyed_ratio)
	var yield_g := full * surviving / deployed
	if retreated:
		yield_g *= retreat_ratio
	return roundi(yield_g)


## 按传入的本金结息，先算完整份数，再限制总利息。本金的取值时点由结算流程决定。
func interest_g(principal_g: int) -> int:
	assert(principal_g >= 0 and interest_step_g > 0)
	return mini(floori(float(principal_g) / interest_step_g) * interest_gain_g, interest_cap_g)


## 检查此次消费是否触发提示，用成交后的余额与下次税额比较。
func needs_warning(balance_after_g: int, next_tax_g: int, warned_this_visit: bool) -> bool:
	return not warned_this_visit and balance_after_g * 100 < next_tax_g * warning_percent


## 计算商品售价或武器制作费：品类基价 × 单品倍率 × 阶段倍率，四舍五入到整克。
func price_g(key: String, stage: int, item_multiplier: float = 1.0) -> int:
	assert(base_prices_g.has(key) and stage >= 1 and item_multiplier >= 0)
	return roundi(base_prices_g[key] * item_multiplier * pow(price_growth, stage - 1))


## 根据物品估值计算卖出所得粉尘。
func resale_g(valuation_g: int) -> int:
	return floori(valuation_g * resale_ratio)


## 根据纹章商店售价计算赎回费用，向上取整时扣除微小的浮点误差。
func redeem_g(shop_price_g: int) -> int:
	return ceili(shop_price_g * redemption_multiplier - 0.000001)
