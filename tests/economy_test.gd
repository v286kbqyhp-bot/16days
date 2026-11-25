extends SceneTree

const BASE = preload("res://economy/prototype.tres")
var failures := 0


func check(condition: bool, label: String) -> void:
	if not condition:
		printerr(label)
		failures += 1


func _initialize() -> void:
	# Exercise fixed inputs on a private copy so editing the live balance doesn't break tests.
	var b = BASE.duplicate()
	b.full_yield_g = 30
	b.tax_base_g = 10
	b.tax_growth = 1.2
	b.all_destroyed_ratio = 0.07
	b.retreat_ratio = 0.5
	b.price_growth = 1.5
	b.base_prices_g["rune"] = 4
	check(b.tax_g(2) == 12, "stage tax growth")
	check(b.price_g("rune", 2) == 6, "stage price growth")
	check(b.harvest_g(1, 2, 3, false) == 20, "ordinary harvest")
	check(b.harvest_g(1, 2, 3, true) == 10, "early retreat")
	check(b.harvest_g(1, 0, 3, true) == 2, "total loss paid only once")
	b.interest_step_g = 5
	b.interest_gain_g = 1
	b.interest_cap_g = 5
	check(b.interest_g(4) == 0 and b.interest_g(5) == 1 and b.interest_g(30) == 5, "interest")
	b.warning_percent = 80
	check(b.needs_warning(7, 10, false) and not b.needs_warning(8, 10, false), "threshold")
	check(not b.needs_warning(7, 10, true), "one warning per visit")
	b.redemption_multiplier = 1.1
	check(b.redeem_g(10) == 11 and b.redeem_g(6) == 7, "redemption")
	print("Economy test failures: ", failures)
	quit(1 if failures else 0)
