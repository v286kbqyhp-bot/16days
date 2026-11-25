extends Resource

# The Inspector can edit these tables directly. Currency outputs are whole grams.
@export_group("Collection and tax")
@export var full_yield_g: int = 30
@export var all_destroyed_ratio: float = 0.07
@export var retreat_ratio: float = 0.5
@export var tax_base_g: int = 10
@export var yield_growth: float = 1.0
@export var tax_growth: float = 1.0

@export_group("Camp")
@export var interest_step_g: int = 5
@export var interest_gain_g: int = 1
@export var interest_cap_g: int = 5
@export var warning_percent: int = 80
@export var redemption_multiplier: float = 1.1

@export_group("Prices")
@export var base_prices_g: Dictionary[String, int] = {}
@export var price_growth: float = 1.0
@export var resale_ratio: float = 0.5
@export var rune_install_g: int = 1
@export var rune_remove_g: int = 1

@export_group("Reward budget")
@export var victory_draws: int = 2
@export var defeat_draws: int = 1
@export var objective_coins: int = 1
@export var map_chest_coins: int = 1


func tax_g(stage: int) -> int:
	return roundi(tax_base_g * pow(tax_growth, stage - 1))


func harvest_g(stage: int, surviving: int, deployed: int, retreated: bool) -> int:
	assert(stage >= 1 and deployed > 0 and surviving >= 0 and surviving <= deployed)
	var full := full_yield_g * pow(yield_growth, stage - 1)
	if surviving == 0:
		return roundi(full * all_destroyed_ratio)
	var yield_g := full * surviving / deployed
	if retreated:
		yield_g *= retreat_ratio
	return roundi(yield_g)


func interest_g(principal_g: int) -> int:
	assert(principal_g >= 0 and interest_step_g > 0)
	return mini(floori(float(principal_g) / interest_step_g) * interest_gain_g, interest_cap_g)


func needs_warning(balance_after_g: int, next_tax_g: int, warned_this_visit: bool) -> bool:
	return not warned_this_visit and balance_after_g * 100 < next_tax_g * warning_percent


func price_g(key: String, stage: int, item_multiplier: float = 1.0) -> int:
	assert(base_prices_g.has(key) and stage >= 1 and item_multiplier >= 0)
	return roundi(base_prices_g[key] * item_multiplier * pow(price_growth, stage - 1))


func resale_g(valuation_g: int) -> int:
	return floori(valuation_g * resale_ratio)


func redeem_g(shop_price_g: int) -> int:
	return ceili(shop_price_g * redemption_multiplier - 0.000001)
