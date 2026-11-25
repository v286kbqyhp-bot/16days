extends SceneTree

const Camp = preload("res://camp/expedition.gd")
const IDS = ["a", "b", "c"]
var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr(message)


func check_equipment_instances() -> void:
	var camp = Camp.create(IDS, ["spear-01", "spear-02"], ["crest-01", "crest-02"])
	check(camp.equip("a", "weapon", "spear-01") == OK, "first spear")
	check(camp.equip("b", "weapon", "spear-02") == OK, "second spear")
	var before: Dictionary = camp.loadout("b")
	check(camp.equip("b", "weapon", "spear-01") == ERR_ALREADY_IN_USE, "reject shared instance")
	check(camp.loadout("b") == before, "preserve previous spear")
	before.weapon = null
	check(camp.loadout("b").weapon == "spear-02", "loadout is a copy")
	check(camp.equip("b", "weapon", null) == OK, "remove second spear")
	check(camp.equip("b", "weapon", null) == OK, "repeat unequip")
	check(camp.loadout("a").weapon == "spear-01", "other instance unaffected")


func _initialize() -> void:
	check_equipment_instances()
	check(Camp.create(["a","a","b"], [], []) == null, "duplicate character")
	for size in range(1, 4):
		var camp = Camp.create(IDS, ["wa","wb","wc"], ["ca","cb","cc"])
		for id in IDS:
			check(camp.equip(id, "weapon", "w" + id) == OK, "equip weapon")
			check(camp.depart([id]) == ERR_UNCONFIGURED, "missing crest")
			check(camp.equip(id, "crest", "c" + id) == OK, "equip crest")
		for selection in [[], ["a","a"], ["a","x"], ["a","b","c","d"]]:
			check(camp.depart(selection) != OK, "reject invalid team")
			check(camp.party_snapshot().is_empty(), "atomic departure")
		check(camp.depart(IDS.slice(0, size)) == OK, "depart")
		var snapshot: Array = camp.party_snapshot()
		check(snapshot.size() == size, "selected party size")
		snapshot[0].weapon = null
		check(camp.party_snapshot()[0].weapon == "wa", "isolated snapshot")
		check(camp.equip("a","weapon",null) == ERR_LOCKED, "lock equipment")
		check(camp.depart(["a"]) == ERR_LOCKED, "lock party")
		check(camp.return_to_camp() == OK, "return")
		for slot in ["weapon", "crest"]:
			var item = camp.loadout("a")[slot]
			check(camp.equip("b", slot, item) == ERR_ALREADY_IN_USE, "item in use")
			check(camp.equip("b", slot, "missing") == ERR_DOES_NOT_EXIST, "unknown item")
			check(camp.equip("a", slot, null) == OK, "unequip")
			check(camp.depart(["a"]) == ERR_UNCONFIGURED, "incomplete loadout")
			check(camp.equip("b", slot, item) == OK, "transfer")
	print("Expedition test failures: ", failures)
	quit(1 if failures else 0)
