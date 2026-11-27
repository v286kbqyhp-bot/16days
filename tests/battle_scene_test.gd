extends SceneTree

const BATTLE_PREVIEW = preload("res://battle/battle_preview.tscn")
const BattleData = preload("res://battle/forest_battle_data.gd")
const ECONOMY = preload("res://economy/prototype.tres")

var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_check_cold_woods_data()

	var preview = BATTLE_PREVIEW.instantiate()
	root.add_child(preview)
	var world = preview.world
	check(preview.world_view != null and preview.world_view.size == Vector2i(ceil(preview.size / preview.pixel_scale)),
		"battlefield sizes the pixel SubViewport to cover the window")
	check(world != null and world._tile_sprites.size() == 64,
		"forest world instantiates all 64 isometric tiles")

	for key in [
		"tile_plain", "tile_grass", "tile_grass_burning", "tile_water",
		"tile_rock_intact", "tile_rock_cracked", "collector_working",
		"collector_complete", "collector_destroyed", "prop_chest_closed",
		"prop_chest_open", "unit_warden_sword", "unit_warden_bow",
		"unit_warden_staff", "unit_goblin_raider"
	]:
		check(world.has_paired_normal(key), "paired albedo+normal bound for " + key)

	# 交互状态切换验证：草地燃烧、石块二次碎裂、采集器全毁终局与宝箱开启
	preview._demo_toggle_fire()
	check(world.data.burning_cells.has(BattleData.parse_cell("B1")) and world._fire_sprites.size() == 4,
		"igniting grass spawns flame sprites and warm point lights")

	var e5 := BattleData.parse_cell("E5")
	preview._demo_hit_rock()
	check(world.data.get_terrain(e5) == BattleData.Terrain.ROCK and world.data.rock_damage.get(e5, 0) == 1,
		"first rock collision cracks E5 boulder")
	preview._demo_hit_rock()
	check(world.data.get_terrain(e5) == BattleData.Terrain.PLAIN,
		"second rock collision shatters E5 into plain terrain")

	preview._demo_cycle_collectors()
	check(world.data.surviving_collectors() == 2 and not world.data.should_end_battle_from_collectors(),
		"losing one collector keeps battle active")
	preview._demo_cycle_collectors()
	check(world.data.surviving_collectors() == 0 and world.data.should_end_battle_from_collectors(),
		"losing all collectors triggers immediate battle end")

	preview._demo_toggle_chest()
	check(world.data.chest_cells[BattleData.parse_cell("A8")] == false,
		"A8 bonus chest opens cleanly")

	preview._demo_reset()
	check(world.data.surviving_collectors() == 3 and world.data.get_terrain(e5) == BattleData.Terrain.ROCK,
		"reset restores initial Cold Woods Outpost layout")

	print("Battle scene test failures: ", failures)
	quit(1 if failures else 0)


func _check_cold_woods_data() -> void:
	var d = BattleData.create_cold_woods()

	# 64 格坐标与等轴拾取双向一致
	for r in range(BattleData.GRID_SIZE):
		for c in range(BattleData.GRID_SIZE):
			var cell := Vector2i(c, r)
			var code := BattleData.format_cell(cell)
			check(BattleData.parse_cell(code) == cell, "cell code round-trip " + code)
			var wpos := BattleData.cell_to_world(cell)
			check(BattleData.world_to_cell(wpos) == cell, "isometric center pick " + code)

	check(BattleData.world_to_cell(Vector2(20, 20)) == Vector2i(-1, -1), "outside forest margin is not a board cell")

	# 核对寒林前哨关键坐标（B5/F4/G6 采集器，A8 宝箱，D1 普通地钻出点，C3/D3/C4 水地）
	for col_code in ["B5", "F4", "G6"]:
		var cc := BattleData.parse_cell(col_code)
		check(d.collectors.has(cc), "collector placed at " + col_code)
		check(not d.is_deployable_cell(cc), "collector cell is not deployable " + col_code)

	check(d.chest_cells.get(BattleData.parse_cell("A8"), false) == true, "bonus chest placed at A8")
	var d1 := BattleData.parse_cell("D1")
	check(d.emerge_cells.has(d1) and d.get_terrain(d1) == BattleData.Terrain.PLAIN,
		"D1 emerge telegraph sits on plain terrain")

	for water_code in ["C3", "D3", "C4"]:
		check(d.get_terrain(BattleData.parse_cell(water_code)) == BattleData.Terrain.WATER,
			"water stream tile at " + water_code)

	check(d.is_deployable_cell(BattleData.parse_cell("C6")), "row 6 plain cell is deployable")
	check(not d.is_deployable_cell(BattleData.parse_cell("C2")), "row 2 north zone is not deployable")
	check(not d.is_deployable_cell(BattleData.parse_cell("E5")), "rock cell E5 is not deployable")
	check(ECONOMY.harvest_g(1, 0, 3, false) == 2, "all-destroyed collector harvest matches prototype 7% rule")


func check(condition: bool, label: String) -> void:
	if not condition:
		printerr(label)
		failures += 1
