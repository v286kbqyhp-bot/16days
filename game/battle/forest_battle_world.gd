@tool
extends Node2D
## 640x360 等轴寒林前哨战场世界场景（@tool 支持在 Godot 2D 编辑器内直接预览完整 8x8 棋盘与单位）。

const DESIGN_WORLD_SIZE := Vector2(640.0, 360.0)
const BattleData = preload("res://battle/forest_battle_data.gd")
const FOG_SHADER = preload("res://battle/battle_fog.gdshader")
const LIT_SHADER = preload("res://battle/battle_lit_pixel.gdshader")

## 守望火盆呼吸波动幅度（能量倍率）：0 表示静止，0.08 表示在基准能量上下 8% 轻微跳动。
@export_range(0.0, 0.30, 0.01) var brazier_flicker_amplitude := 0.08
## 守望火盆摇曳频率（赫兹，每秒周期数）：控制两侧寒林篝火暖光的跳动节奏。
@export_range(0.4, 6.0, 0.1) var brazier_flicker_hz := 2.2
## 水晶采集器呼吸微光幅度（能量倍率）：控制工作中整晶核心的蓝青能量脉动。
@export_range(0.0, 0.30, 0.01) var crystal_pulse_amplitude := 0.10
## 水晶采集器脉动频率（赫兹，每秒周期数）。
@export_range(0.2, 4.0, 0.1) var crystal_pulse_hz := 1.1
## 草地燃烧火焰动画帧率（FPS，帧/秒）。
@export_range(1.0, 12.0, 0.5) var fire_anim_fps := 5.5

var data = BattleData.create_cold_woods()
var wardens: Array[Dictionary] = []
var goblins: Array[Dictionary] = []

## 迷雾从棋盘边界外多少格开始，0.15 表示保留约六分之一格清晰过渡。
@export_range(0.0, 2.0, 0.05) var fog_start_cells := 0.15
## 迷雾由薄到完全遮蔽的宽度（格），用于本轮视觉试样。
@export_range(1.0, 6.0, 0.1) var fog_width_cells := 3.0
## 雾流动速度（世界像素/秒）。
@export_range(0.0, 6.0, 0.1) var fog_speed := 1.2

var _textures: Dictionary = {}
var _mat_terrain: ShaderMaterial
var _mat_crystal: ShaderMaterial
var _mat_foliage: ShaderMaterial
var _mat_unlit: CanvasItemMaterial

var _tile_sprites: Dictionary = {}
var _fire_sprites: Dictionary = {}
var _fire_lights: Dictionary = {}
var _collector_sprites: Dictionary = {}
var _collector_lights: Dictionary = {}
var _chest_sprites: Dictionary = {}
var _emerge_sprites: Dictionary = {}
var _warden_sprites: Dictionary = {}
var _goblin_sprites: Dictionary = {}
var _brazier_lights: Array[PointLight2D] = []
var _light_grad_tex: GradientTexture2D
var _standalone_cam: Camera2D
var _elapsed := 0.0
var show_grid := true

@onready var _board_tiles: Node2D = $BoardTiles
@onready var _board_entities: Node2D = $BoardEntities
@onready var _dynamic_lights: Node2D = $DynamicLights
@onready var _brazier_nw: PointLight2D = $BrazierLightNW
@onready var _brazier_ne: PointLight2D = $BrazierLightNE


func _ready() -> void:
	_init_materials()
	_load_art_catalog()
	_build_continuous_ground()
	_brazier_lights.clear()
	if _brazier_nw:
		_brazier_lights.append(_brazier_nw)
	if _brazier_ne:
		_brazier_lights.append(_brazier_ne)
	reset_default_state()
	if not Engine.is_editor_hint():
		_setup_standalone_camera_if_needed()


func _build_continuous_ground() -> void:
	var ground := Polygon2D.new()
	ground.name = "ContinuousForestGround"
	ground.polygon = PackedVector2Array([Vector2(-8192, -8192), Vector2(8192, -8192), Vector2(8192, 8192), Vector2(-8192, 8192)])
	ground.texture = _textures["tile_plain"]
	ground.material = _mat_terrain.duplicate()
	ground.material.set_shader_parameter(&"continuous_ground", true)
	ground.z_index = -10
	add_child(ground)
	var fog := Polygon2D.new()
	fog.name = "BoundaryFog"
	fog.polygon = ground.polygon
	var fog_material := ShaderMaterial.new()
	fog_material.shader = FOG_SHADER
	fog_material.set_shader_parameter(&"fog_start_cells", fog_start_cells)
	fog_material.set_shader_parameter(&"fog_width_cells", fog_width_cells)
	fog_material.set_shader_parameter(&"flow_speed", fog_speed)
	fog.material = fog_material
	fog.z_index = 100
	add_child(fog)


func _draw() -> void:
	if not show_grid:
		return
	# 浅格线仅覆盖可操作的 8×8 区域，与外围连续地面共用高度。
	for i in range(BattleData.GRID_SIZE + 1):
		var t := float(i) - 0.5
		var a := BattleData.ORIGIN_A1_CENTER + Vector2((t + 0.5) * 24.0, (t - 0.5) * 12.0)
		var b := a + Vector2(-192, 96)
		draw_line(a, b, Color(0.55, 0.57, 0.51, 0.17), 1.0)
		var c := BattleData.ORIGIN_A1_CENTER + Vector2((-0.5 - t) * 24.0, (t - 0.5) * 12.0)
		draw_line(c, c + Vector2(192, 96), Color(0.55, 0.57, 0.51, 0.17), 1.0)


func _setup_standalone_camera_if_needed() -> void:
	var vp := get_viewport()
	if vp == null or vp is SubViewport:
		return
	# 单独按 F6 运行世界场景时，按完整棋盘和边缘留白选择整数倍率。
	_standalone_cam = Camera2D.new()
	_standalone_cam.name = "StandaloneCamera"
	_standalone_cam.position = Vector2(320, 164)
	_standalone_cam.enabled = true
	add_child(_standalone_cam)
	vp.size_changed.connect(_fit_standalone_camera)
	_fit_standalone_camera()


func _fit_standalone_camera() -> void:
	if _standalone_cam == null:
		return
	var vp_size := get_viewport_rect().size
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return
	var z := maxf(1.0, floorf(minf(vp_size.x / 448.0, vp_size.y / 224.0)))
	_standalone_cam.zoom = Vector2.ONE * z


func _init_materials() -> void:
	_mat_terrain = ShaderMaterial.new()
	_mat_terrain.shader = LIT_SHADER
	_mat_terrain.set_shader_parameter(&"normal_strength", 1.15)
	_mat_terrain.set_shader_parameter(&"light_bands", 4)
	_mat_terrain.set_shader_parameter(&"specular_strength", 0.05)
	_mat_terrain.set_shader_parameter(&"specular_threshold", 0.92)
	_mat_terrain.set_shader_parameter(&"wrap_amount", 0.30)

	_mat_crystal = ShaderMaterial.new()
	_mat_crystal.shader = LIT_SHADER
	_mat_crystal.set_shader_parameter(&"normal_strength", 1.35)
	_mat_crystal.set_shader_parameter(&"light_bands", 4)
	_mat_crystal.set_shader_parameter(&"specular_strength", 0.32)
	_mat_crystal.set_shader_parameter(&"specular_threshold", 0.87)
	_mat_crystal.set_shader_parameter(&"wrap_amount", 0.30)

	_mat_foliage = ShaderMaterial.new()
	_mat_foliage.shader = LIT_SHADER
	_mat_foliage.set_shader_parameter(&"normal_strength", 1.20)
	_mat_foliage.set_shader_parameter(&"light_bands", 4)
	_mat_foliage.set_shader_parameter(&"specular_strength", 0.04)
	_mat_foliage.set_shader_parameter(&"specular_threshold", 0.92)
	_mat_foliage.set_shader_parameter(&"wrap_amount", 0.28)

	_mat_unlit = CanvasItemMaterial.new()
	_mat_unlit.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED

	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.35, 0.72, 1.0])
	grad.colors = PackedColorArray([
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0.62),
		Color(1, 1, 1, 0.20),
		Color(1, 1, 1, 0),
	])
	_light_grad_tex = GradientTexture2D.new()
	_light_grad_tex.gradient = grad
	_light_grad_tex.width = 256
	_light_grad_tex.height = 256
	_light_grad_tex.fill = GradientTexture2D.FILL_RADIAL
	_light_grad_tex.fill_from = Vector2(0.5, 0.5)
	_light_grad_tex.fill_to = Vector2(1.0, 0.5)


func _pair_tex(key: String) -> CanvasTexture:
	var ct := CanvasTexture.new()
	ct.diffuse_texture = load("res://battle/art/%s_albedo.png" % key)
	ct.normal_texture = load("res://battle/art/%s_normal.png" % key)
	return ct


func _load_art_catalog() -> void:
	for key in [
		"tile_plain",
		"tile_grass",
		"tile_grass_burning",
		"tile_water",
		"tile_rock_intact",
		"tile_rock_cracked",
		"tile_sand",
		"tile_pit",
		"collector_working",
		"collector_complete",
		"collector_destroyed",
		"prop_chest_closed",
		"prop_chest_open",
		"unit_warden_sword",
		"unit_warden_bow",
		"unit_warden_staff",
		"unit_goblin_raider",
	]:
		_textures[key] = _pair_tex(key)
	_textures["fx_tile_fire_f1"] = load("res://battle/art/fx_tile_fire_f1.png")
	_textures["fx_tile_fire_f2"] = load("res://battle/art/fx_tile_fire_f2.png")
	_textures["marker_goblin_emerge"] = load("res://battle/art/marker_goblin_emerge.png")


func has_paired_normal(key: String) -> bool:
	var tex = _textures.get(key)
	return tex is CanvasTexture and tex.diffuse_texture != null and tex.normal_texture != null


func reset_default_state() -> void:
	data.reset_cold_woods()
	wardens.clear()
	for w in BattleData.DEFAULT_WARDENS:
		wardens.append(w.duplicate(true))
	goblins.clear()
	for g in BattleData.DEFAULT_GOBLINS:
		goblins.append(g.duplicate(true))
	rebuild_board()


func rebuild_board() -> void:
	for child in _board_tiles.get_children():
		child.free()
	for child in _board_entities.get_children():
		child.free()
	for child in _dynamic_lights.get_children():
		child.free()

	_tile_sprites.clear()
	_fire_sprites.clear()
	_fire_lights.clear()
	_collector_sprites.clear()
	_collector_lights.clear()
	_chest_sprites.clear()
	_emerge_sprites.clear()
	_warden_sprites.clear()
	_goblin_sprites.clear()

	for depth in range(BattleData.GRID_SIZE * 2 - 1):
		for col in range(BattleData.GRID_SIZE):
			var row := depth - col
			if row < 0 or row >= BattleData.GRID_SIZE:
				continue
			var cell := Vector2i(col, row)
			var spr := Sprite2D.new()
			spr.name = "Tile_" + BattleData.format_cell(cell)
			spr.material = _mat_terrain.duplicate()
			spr.material.set_shader_parameter(&"trim_lower_skirt", true)
			spr.material.set_shader_parameter(&"tile_center", BattleData.cell_to_world(cell))
			spr.position = BattleData.cell_to_world(cell)
			spr.z_index = depth * 2
			_board_tiles.add_child(spr)
			_tile_sprites[cell] = spr
			_refresh_single_tile(cell)

	for cell in data.emerge_cells:
		var m := Sprite2D.new()
		m.name = "Emerge_" + BattleData.format_cell(cell)
		m.material = _mat_unlit
		m.texture = _textures["marker_goblin_emerge"]
		m.position = BattleData.cell_to_world(cell) + Vector2(0, -1)
		m.z_index = (cell.x + cell.y) * 2 + 1
		_board_entities.add_child(m)
		_emerge_sprites[cell] = m

	for cell in data.chest_cells:
		var cs := Sprite2D.new()
		cs.name = "Chest_" + BattleData.format_cell(cell)
		cs.material = _mat_crystal
		cs.position = BattleData.cell_to_world(cell)
		cs.offset = Vector2(0, -6)
		cs.z_index = (cell.x + cell.y) * 2 + 2
		_board_entities.add_child(cs)
		_chest_sprites[cell] = cs

	for cell in data.collectors:
		var col_spr := Sprite2D.new()
		col_spr.name = "Collector_" + BattleData.format_cell(cell)
		col_spr.material = _mat_crystal
		col_spr.position = BattleData.cell_to_world(cell)
		col_spr.offset = Vector2(0, -13)
		col_spr.z_index = (cell.x + cell.y) * 2 + 2
		_board_entities.add_child(col_spr)
		_collector_sprites[cell] = col_spr

		var clight := PointLight2D.new()
		clight.name = "CollectorLight_" + BattleData.format_cell(cell)
		clight.position = BattleData.cell_to_world(cell) + Vector2(0, -8)
		clight.color = Color("#5ce1f2")
		clight.energy = 0.42
		clight.texture = _light_grad_tex
		clight.texture_scale = 0.55
		clight.height = 28.0
		_dynamic_lights.add_child(clight)
		_collector_lights[cell] = clight

	for w in wardens:
		var ws := Sprite2D.new()
		ws.name = w["id"]
		ws.material = _mat_foliage
		ws.texture = _weapon_unit_texture(w["weapon"])
		_board_entities.add_child(ws)
		_warden_sprites[w["id"]] = ws

	for g in goblins:
		var gs := Sprite2D.new()
		gs.name = g["id"]
		gs.material = _mat_foliage
		gs.texture = _textures["unit_goblin_raider"]
		_board_entities.add_child(gs)
		_goblin_sprites[g["id"]] = gs

	refresh_visual_states()


func _weapon_unit_texture(weapon_id: String) -> Texture2D:
	match weapon_id:
		"weapon_bow":
			return _textures["unit_warden_bow"]
		"weapon_staff":
			return _textures["unit_warden_staff"]
		_:
			return _textures["unit_warden_sword"]


func _refresh_single_tile(cell: Vector2i) -> void:
	var spr: Sprite2D = _tile_sprites.get(cell)
	if spr == null:
		return
	var t: int = data.get_terrain(cell)
	spr.visible = t != BattleData.Terrain.PLAIN
	spr.offset = Vector2.ZERO
	match t:
		BattleData.Terrain.PLAIN:
			spr.texture = _textures["tile_plain"]
		BattleData.Terrain.GRASS:
			if data.burning_cells.get(cell, false):
				spr.texture = _textures["tile_grass_burning"]
			else:
				spr.texture = _textures["tile_grass"]
		BattleData.Terrain.WATER:
			spr.texture = _textures["tile_water"]
		BattleData.Terrain.ROCK:
			spr.offset = Vector2(0, -6)
			var hits: int = data.rock_damage.get(cell, 0)
			spr.texture = _textures["tile_rock_cracked"] if hits >= 1 else _textures["tile_rock_intact"]
		BattleData.Terrain.SAND:
			spr.texture = _textures["tile_sand"]
		BattleData.Terrain.PIT:
			spr.texture = _textures["tile_pit"]

	var burning: bool = (t == BattleData.Terrain.GRASS and data.burning_cells.get(cell, false))
	if burning and not _fire_sprites.has(cell):
		var fs := Sprite2D.new()
		fs.material = _mat_unlit
		fs.texture = _textures["fx_tile_fire_f1"]
		fs.position = BattleData.cell_to_world(cell) + Vector2(0, -6)
		fs.z_index = (cell.x + cell.y) * 2 + 3
		_board_entities.add_child(fs)
		_fire_sprites[cell] = fs

		var fl := PointLight2D.new()
		fl.position = BattleData.cell_to_world(cell) + Vector2(0, -6)
		fl.color = Color("#ff8a3d")
		fl.energy = 0.52
		fl.texture = _light_grad_tex
		fl.texture_scale = 0.50
		fl.height = 24.0
		_dynamic_lights.add_child(fl)
		_fire_lights[cell] = fl
	elif not burning and _fire_sprites.has(cell):
		_fire_sprites[cell].free()
		_fire_sprites.erase(cell)
		_fire_lights[cell].free()
		_fire_lights.erase(cell)


func refresh_visual_states() -> void:
	for col in range(BattleData.GRID_SIZE):
		for row in range(BattleData.GRID_SIZE):
			_refresh_single_tile(Vector2i(col, row))

	for cell in _chest_sprites:
		var closed: bool = data.chest_cells.get(cell, true)
		_chest_sprites[cell].texture = _textures["prop_chest_closed" if closed else "prop_chest_open"]

	for cell in _collector_sprites:
		var st: int = data.collectors.get(cell, BattleData.CollectorState.WORKING)
		var spr: Sprite2D = _collector_sprites[cell]
		var lgt: PointLight2D = _collector_lights[cell]
		match st:
			BattleData.CollectorState.WORKING:
				spr.texture = _textures["collector_working"]
				lgt.visible = true
				lgt.color = Color("#5ce1f2")
			BattleData.CollectorState.COMPLETE:
				spr.texture = _textures["collector_complete"]
				lgt.visible = true
				lgt.color = Color("#96f7ff")
			BattleData.CollectorState.DESTROYED:
				spr.texture = _textures["collector_destroyed"]
				lgt.visible = false

	for w in wardens:
		var ws: Sprite2D = _warden_sprites.get(w["id"])
		if ws == null:
			continue
		var c := BattleData.parse_cell(w["cell"])
		ws.position = BattleData.cell_to_world(c)
		ws.z_index = (c.x + c.y) * 2 + 2
		var downed: bool = w.get("downed", false)
		var airborne: bool = w.get("airborne", false)
		ws.offset = Vector2(0, -16 if airborne else (-7 if downed else -10))
		ws.rotation_degrees = -72.0 if downed else 0.0
		ws.modulate = Color(0.68, 0.62, 0.66, 0.92) if downed else Color(1, 1, 1, 1)

	for g in goblins:
		var gs: Sprite2D = _goblin_sprites.get(g["id"])
		if gs == null:
			continue
		var c := BattleData.parse_cell(g["cell"])
		gs.position = BattleData.cell_to_world(c)
		gs.offset = Vector2(0, -10)
		gs.z_index = (c.x + c.y) * 2 + 2


func _process(delta: float) -> void:
	_elapsed += delta
	var frame_idx := int(floor(_elapsed * fire_anim_fps)) % 2
	if _textures.has("fx_tile_fire_f1"):
		var fire_tex: Texture2D = _textures["fx_tile_fire_f1" if frame_idx == 0 else "fx_tile_fire_f2"]
		for cell in _fire_sprites:
			_fire_sprites[cell].texture = fire_tex
			if _fire_lights.has(cell):
				_fire_lights[cell].energy = 0.50 + sin(_elapsed * TAU * 3.1 + float(cell.x)) * 0.08

	for i in range(_brazier_lights.size()):
		var bl := _brazier_lights[i]
		var wave := sin(_elapsed * TAU * brazier_flicker_hz + float(i) * 1.7) * 0.65 + sin(_elapsed * TAU * brazier_flicker_hz * 2.3) * 0.35
		bl.energy = 0.72 * (1.0 + wave * brazier_flicker_amplitude)

	for cell in _collector_lights:
		var cl: PointLight2D = _collector_lights[cell]
		if cl.visible:
			cl.energy = 0.42 * (1.0 + sin(_elapsed * TAU * crystal_pulse_hz + float(cell.y)) * crystal_pulse_amplitude)

	for w in wardens:
		if w.get("airborne", false) and not w.get("downed", false):
			var ws: Sprite2D = _warden_sprites.get(w["id"])
			if ws:
				ws.offset.y = -16.0 + round(sin(_elapsed * 3.2) * 1.4)
