extends Control
## 森林战场样片。世界按整数倍像素显示，视野随窗口扩展，地图名待作者确定。

signal return_requested

const BattleData = preload("res://battle/forest_battle_data.gd")
const ECONOMY = preload("res://economy/prototype.tres")
const CRYSTAL_ICON = preload("res://battle/art/icon_crystal_whole.png")
const PIXELATE_SHADER = preload("res://battle/battle_pixelate.gdshader")

const DESIGN_SIZE := Vector2(1280, 720)
const WORLD_SCALE := 2.0

enum ViewMode {
	DEPLOY, ## 战斗部署态：展示第 5-8 行允许部署区，支持点选队员换位部署
	COMBAT, ## 战斗行动与预告态：展示曼哈顿 3 格移动范围、地精红线攻击预告与 1 格推动预览
	PURE,   ## 纯美术场景审阅态：隐藏全部 UI 面板与棋盘线框，审阅干净像素场景与光影
}

@export var battle_world_scene: PackedScene = preload("res://battle/forest_battle_world.tscn")

var stage: Control
var world_view: SubViewport
var world_display: TextureRect
var pixel_scale := 2.0
var world_offset := Vector2.ZERO
var world
var overlay: Control
var header_bar: Control
var footer_bar: Control
var info_card: Panel
var title_label: Label
var objective_label: Label
var cell_title_label: Label
var cell_detail_label: Label
var status_banner: Label

var debug_controls_visible := false

var mode: int = ViewMode.COMBAT
var hovered_cell := Vector2i(-1, -1)
var selected_warden_idx := 0
var turn_number := 1
var max_turns := 5


class BoardOverlay extends Control:
	var host

	func _draw() -> void:
		if host == null or host.world == null or host.mode == host.ViewMode.PURE:
			return
		draw_set_transform(host.world_offset, 0.0, Vector2.ONE * host.pixel_scale / WORLD_SCALE)
		var data = host.world.data
		# 1. 部署阶段：标出第 5-8 行合法部署格
		if host.mode == host.ViewMode.DEPLOY:
			for r in range(4, 8):
				for c in range(8):
					var cell := Vector2i(c, r)
					if data.is_deployable_cell(cell):
						var pts: PackedVector2Array = BattleData.cell_diamond_points(cell, WORLD_SCALE, 2.0)
						draw_colored_polygon(pts, Color(0.28, 0.85, 0.56, 0.22))
						_stroke_poly(pts, Color(0.46, 0.96, 0.68, 0.78), 2.0)

		# 2. 战斗行动阶段：选中角色的曼哈顿移动范围 + 地精攻击预告 + 推动 1 格箭头预览
		if host.mode == host.ViewMode.COMBAT:
			var move_cells: Array[Vector2i] = host.get_selected_move_cells()
			for mc in move_cells:
				var pts: PackedVector2Array = BattleData.cell_diamond_points(mc, WORLD_SCALE, 2.5)
				draw_colored_polygon(pts, Color(0.32, 0.72, 0.98, 0.20))
				_stroke_poly(pts, Color(0.52, 0.86, 1.0, 0.72), 2.0)

			# 地精行动预告（高对比珊瑚红方向线 + 目标受击框，参考《陷阵之志》）
			for g in host.world.goblins:
				var gcell: Vector2i = BattleData.parse_cell(g["cell"])
				var tcell: Vector2i = gcell + (g["target_dir"] as Vector2i)
				if BattleData.is_valid_cell(tcell):
					var p0: Vector2 = BattleData.cell_to_world(gcell) * WORLD_SCALE + Vector2(0, -8)
					var p1: Vector2 = BattleData.cell_to_world(tcell) * WORLD_SCALE
					var tpts: PackedVector2Array = BattleData.cell_diamond_points(tcell, WORLD_SCALE, 2.0)
					draw_colored_polygon(tpts, Color(0.96, 0.28, 0.24, 0.24))
					_stroke_poly(tpts, Color(1.0, 0.40, 0.32, 0.92), 2.5)
					draw_line(p0, p1, Color(1.0, 0.36, 0.28, 0.95), 3.0)
					_draw_arrow_head(p0, p1, Color(1.0, 0.46, 0.36, 1.0), 10.0)

			# D1 地精钻出预告外框（琥珀橙，与地洞区分）
			for ecell in data.emerge_cells:
				var epts: PackedVector2Array = BattleData.cell_diamond_points(ecell, WORLD_SCALE, 3.0)
				_stroke_poly(epts, Color(1.0, 0.68, 0.24, 0.90), 2.0)

			# 若悬停在选中角色相邻格，预览攻击受击格 + 沿方向推动 1 格箭头与碰撞提示
			var sel_cell: Vector2i = host.get_selected_warden_cell()
			if BattleData.is_valid_cell(sel_cell) and BattleData.is_valid_cell(host.hovered_cell):
				var delta: Vector2i = host.hovered_cell - sel_cell
				if abs(delta.x) + abs(delta.y) == 1:
					var push_to: Vector2i = host.hovered_cell + delta
					var hpts: PackedVector2Array = BattleData.cell_diamond_points(host.hovered_cell, WORLD_SCALE, 1.5)
					draw_colored_polygon(hpts, Color(1.0, 0.80, 0.24, 0.26))
					_stroke_poly(hpts, Color(1.0, 0.86, 0.32, 0.95), 2.5)
					if BattleData.is_valid_cell(push_to):
						var a0: Vector2 = BattleData.cell_to_world(host.hovered_cell) * WORLD_SCALE
						var a1: Vector2 = BattleData.cell_to_world(push_to) * WORLD_SCALE
						var blocked: bool = not data.is_walkable_for_unit(push_to, false) or host.has_any_unit_at(push_to)
						var pcol := Color(1.0, 0.42, 0.22, 0.98) if blocked else Color(1.0, 0.88, 0.34, 0.96)
						draw_line(a0, a1, pcol, 3.0)
						_draw_arrow_head(a0, a1, pcol, 11.0)
						if blocked:
							var bpts: PackedVector2Array = BattleData.cell_diamond_points(push_to, WORLD_SCALE, 4.0)
							_stroke_poly(bpts, Color(1.0, 0.38, 0.20, 0.95), 2.5)

		# 3. 选中队员高亮环
		var wc: Vector2i = host.get_selected_warden_cell()
		if BattleData.is_valid_cell(wc):
			var wpts: PackedVector2Array = BattleData.cell_diamond_points(wc, WORLD_SCALE, 1.0)
			_stroke_poly(wpts, Color(0.58, 0.96, 1.0, 0.96), 3.0)

		# 4. 鼠标悬停格高亮框
		if BattleData.is_valid_cell(host.hovered_cell):
			var pts_hover: PackedVector2Array = BattleData.cell_diamond_points(host.hovered_cell, WORLD_SCALE, 0.5)
			_stroke_poly(pts_hover, Color(1.0, 0.97, 0.82, 0.95), 2.5)

	func _stroke_poly(pts: PackedVector2Array, col: Color, width: float) -> void:
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_polyline(closed, col, width, false)

	func _draw_arrow_head(from_p: Vector2, to_p: Vector2, col: Color, sz: float) -> void:
		var dir := (to_p - from_p).normalized()
		var perp := Vector2(-dir.y, dir.x)
		var tip := to_p
		var p_left := tip - dir * sz + perp * (sz * 0.55)
		var p_right := tip - dir * sz - perp * (sz * 0.55)
		draw_colored_polygon(PackedVector2Array([tip, p_left, p_right]), col)


func _ready() -> void:
	clip_contents = true
	var backdrop_fill := ColorRect.new()
	backdrop_fill.name = "LetterboxBackdrop"
	backdrop_fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop_fill.color = Color("#0c161a")
	backdrop_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop_fill)

	stage = Control.new()
	stage.name = "BattleStage"
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.size = DESIGN_SIZE
	stage.theme = _battle_theme()
	add_child(stage)

	resized.connect(_fit_stage)
	_fit_stage()
	_build_world_viewport()
	_build_overlay()
	_build_hud()
	_refresh_hud()
	_fit_stage()


func _fit_stage() -> void:
	if stage == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	stage.scale = Vector2.ONE * factor
	stage.position = (size - DESIGN_SIZE * factor) * 0.5
	if world_view == null or world_display == null:
		return
	# 世界像素保持整数倍率。余出的窗口面积扩展视野，余数像素从外沿裁去。
	var hud_top := 86.0 * factor + 8.0
	var available_height := maxf(1.0, size.y - hud_top - 16.0)
	# 棋盘 384×192 加角色和边界留白，按可用区域选最大的完整整数倍率。
	pixel_scale = maxf(1.0, floorf(minf(size.x / 448.0, available_height / 224.0)))
	world_view.size = Vector2i(ceil(size / pixel_scale))
	var focus := Vector2(size.x * 0.5, hud_top + available_height * 0.5)
	var origin := (focus / pixel_scale - Vector2(320, 164)).floor()
	world_view.canvas_transform = Transform2D(0.0, origin)
	world_offset = origin * pixel_scale
	world_display.size = Vector2(world_view.size) * pixel_scale
	if overlay != null:
		overlay.size = size
		overlay.queue_redraw()
	hovered_cell = Vector2i(-1, -1)
	if cell_title_label != null:
		_refresh_cell_inspector()


func screen_to_cell(point: Vector2) -> Vector2i:
	return BattleData.world_to_cell((point - world_offset) / pixel_scale)


func world_to_screen(point: Vector2) -> Vector2:
	return point * pixel_scale + world_offset


func _build_world_viewport() -> void:
	world_view = SubViewport.new()
	world_view.name = "ForestViewport"
	world_view.size = Vector2i(640, 360)
	world_view.disable_3d = true
	world_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(world_view)

	world = battle_world_scene.instantiate()
	world_view.add_child(world)

	world_display = TextureRect.new()
	var display := world_display
	display.name = "WorldDisplay"
	display.position = Vector2.ZERO
	display.size = DESIGN_SIZE
	display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	display.texture = world_view.get_texture()
	display.stretch_mode = TextureRect.STRETCH_SCALE
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var pix_mat := ShaderMaterial.new()
	pix_mat.shader = PIXELATE_SHADER
	pix_mat.set_shader_parameter(&"vignette_strength", 0.0)
	display.material = pix_mat
	display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(display)
	move_child(display, stage.get_index())


func _build_overlay() -> void:
	overlay = BoardOverlay.new()
	overlay.name = "TacticalOverlay"
	overlay.host = self
	overlay.size = DESIGN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_PASS
	overlay.gui_input.connect(_on_board_gui_input)
	overlay.mouse_exited.connect(_clear_hover)
	add_child(overlay)
	move_child(overlay, stage.get_index())


func _build_hud() -> void:
	header_bar = Control.new()
	header_bar.size = Vector2(DESIGN_SIZE.x, 86)
	header_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(header_bar)

	var top_card := _make_panel(header_bar, Rect2(20, 14, 680, 62))
	title_label = _make_label(top_card, Rect2(14, 6, 652, 26), "", 19, Color("#f2ebd9"))
	objective_label = _make_label(top_card, Rect2(14, 34, 652, 22), "", 14, Color("#9fd4de"))

	var right_status := _make_panel(header_bar, Rect2(952, 14, 308, 62))
	var p_icon := TextureRect.new()
	p_icon.position = Vector2(12, 16)
	p_icon.size = Vector2(28, 28)
	p_icon.texture = CRYSTAL_ICON
	p_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	p_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	right_status.add_child(p_icon)
	status_banner = _make_label(right_status, Rect2(48, 8, 248, 46), "", 15, Color("#f2ebd9"))
	status_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	info_card = _make_panel(stage, Rect2(968, 526, 292, 114))
	cell_title_label = _make_label(info_card, Rect2(14, 8, 264, 24), "", 18, Color("#ffe394"))
	cell_detail_label = _make_label(info_card, Rect2(14, 34, 264, 72), "", 14, Color("#d4e0e8"))
	cell_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	footer_bar = Control.new()
	footer_bar.visible = false
	footer_bar.position = Vector2(0, 652)
	footer_bar.size = Vector2(DESIGN_SIZE.x, 68)
	footer_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(footer_bar)

	var bar_bg := _make_panel(footer_bar, Rect2(20, 4, 1240, 52))
	var actions := [
		["部署态", _set_mode.bind(ViewMode.DEPLOY)],
		["战斗/预告态", _set_mode.bind(ViewMode.COMBAT)],
		["纯场景(H)", _toggle_pure_view],
		["草地燃烧", _demo_toggle_fire],
		["撞击石块", _demo_hit_rock],
		["采集器状态", _demo_cycle_collectors],
		["开启宝箱", _demo_toggle_chest],
		["天空浮空", _demo_toggle_airborne],
		["重置战场", _demo_reset],
	]
	var x_cursor := 12.0
	for item in actions:
		var btn := _make_button(bar_bg, Rect2(x_cursor, 8, 126, 36), item[0])
		btn.pressed.connect(item[1])
		x_cursor += 135.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_H:
			_toggle_pure_view()
		elif event.keycode == KEY_F1:
			debug_controls_visible = not debug_controls_visible
			footer_bar.visible = debug_controls_visible and mode != ViewMode.PURE
		elif event.keycode == KEY_R:
			_demo_reset()


func _clear_hover() -> void:
	hovered_cell = Vector2i(-1, -1)
	_refresh_cell_inspector()
	overlay.queue_redraw()


func _on_board_gui_input(event: InputEvent) -> void:
	if world == null:
		return
	if event is InputEventMouseMotion:
		var cell := screen_to_cell(event.position)
		if cell != hovered_cell:
			hovered_cell = cell
			_refresh_cell_inspector()
			overlay.queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := screen_to_cell(event.position)
		if not BattleData.is_valid_cell(cell):
			return
		# 点选守望队员
		for i in range(world.wardens.size()):
			if BattleData.parse_cell(world.wardens[i]["cell"]) == cell:
				selected_warden_idx = i
				_refresh_hud()
				overlay.queue_redraw()
				return
		# 部署阶段可点击合法空格直接调整选中队员占位
		if mode == ViewMode.DEPLOY and world.data.is_deployable_cell(cell) and not has_any_unit_at(cell):
			world.wardens[selected_warden_idx]["cell"] = BattleData.format_cell(cell)
			world.refresh_visual_states()
			_refresh_hud()
			overlay.queue_redraw()
		elif mode == ViewMode.COMBAT:
			var move_cells := get_selected_move_cells()
			if move_cells.has(cell):
				world.wardens[selected_warden_idx]["cell"] = BattleData.format_cell(cell)
				# 若踩到 A8 宝箱格，自动演示开启宝箱
				if world.data.chest_cells.get(cell, false):
					world.data.chest_cells[cell] = false
				world.refresh_visual_states()
				_refresh_hud()
				overlay.queue_redraw()


func get_selected_warden_cell() -> Vector2i:
	if world == null or selected_warden_idx < 0 or selected_warden_idx >= world.wardens.size():
		return Vector2i(-1, -1)
	return BattleData.parse_cell(world.wardens[selected_warden_idx]["cell"])


func has_any_unit_at(cell: Vector2i) -> bool:
	for w in world.wardens:
		if BattleData.parse_cell(w["cell"]) == cell:
			return true
	for g in world.goblins:
		if BattleData.parse_cell(g["cell"]) == cell:
			return true
	return world.data.collectors.has(cell) and world.data.collectors[cell] != BattleData.CollectorState.DESTROYED


func get_selected_move_cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if world == null or world.wardens.is_empty():
		return out
	var w: Dictionary = world.wardens[selected_warden_idx]
	if w.get("downed", false):
		return out
	var start := BattleData.parse_cell(w["cell"])
	var max_steps: int = w.get("move", 3)
	var airborne: bool = w.get("airborne", false)

	var dist := {start: 0}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		var d: int = dist[cur]
		if d >= max_steps:
			continue
		for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nxt: Vector2i = cur + dir
			if dist.has(nxt) or not BattleData.is_valid_cell(nxt):
				continue
			if not world.data.is_walkable_for_unit(nxt, airborne):
				continue
			# 敌方地精阻挡移动，友方角色可穿过但不可停留
			var enemy_block := false
			for g in world.goblins:
				if BattleData.parse_cell(g["cell"]) == nxt:
					enemy_block = true
					break
			if enemy_block:
				continue
			dist[nxt] = d + 1
			queue.append(nxt)
			if not has_any_unit_at(nxt):
				out.append(nxt)
	return out


func _set_mode(next_mode: int) -> void:
	mode = next_mode
	var show_ui := mode != ViewMode.PURE
	header_bar.visible = show_ui
	info_card.visible = show_ui
	footer_bar.visible = show_ui and debug_controls_visible
	world.show_grid = show_ui
	world.queue_redraw()
	_refresh_hud()
	overlay.queue_redraw()


func _toggle_pure_view() -> void:
	_set_mode(ViewMode.COMBAT if mode == ViewMode.PURE else ViewMode.PURE)


func _demo_toggle_fire() -> void:
	var sample_grass := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(4, 1), Vector2i(7, 4)]
	var turn_on: bool = world.data.burning_cells.is_empty()
	for c in sample_grass:
		world.data.set_grass_burning(c, turn_on)
	world.refresh_visual_states()
	_refresh_hud()


func _demo_hit_rock() -> void:
	# 依次演示寒林前哨石块（E5, D7, A3, F1, H3）：完好 -> 裂纹 -> 碎裂变普通地
	for code in ["E5", "D7", "A3", "F1", "H3"]:
		var c := BattleData.parse_cell(code)
		if world.data.get_terrain(c) == BattleData.Terrain.ROCK:
			world.data.collide_rock(c)
			break
	world.refresh_visual_states()
	_refresh_hud()
	overlay.queue_redraw()


func _demo_cycle_collectors() -> void:
	var cells := [BattleData.parse_cell("B5"), BattleData.parse_cell("F4"), BattleData.parse_cell("G6")]
	var alive: int = world.data.surviving_collectors()
	if alive == 3:
		world.data.collectors[cells[0]] = BattleData.CollectorState.DESTROYED
	elif alive == 2:
		for c in cells:
			world.data.collectors[c] = BattleData.CollectorState.DESTROYED
	else:
		for c in cells:
			world.data.collectors[c] = BattleData.CollectorState.WORKING
	world.refresh_visual_states()
	_refresh_hud()
	overlay.queue_redraw()


func _demo_toggle_chest() -> void:
	var c := BattleData.parse_cell("A8")
	world.data.chest_cells[c] = not world.data.chest_cells.get(c, true)
	world.refresh_visual_states()
	_refresh_hud()


func _demo_toggle_airborne() -> void:
	var w: Dictionary = world.wardens[selected_warden_idx]
	w["airborne"] = not w.get("airborne", false)
	world.refresh_visual_states()
	_refresh_hud()
	overlay.queue_redraw()


func _demo_reset() -> void:
	world.reset_default_state()
	if mode == ViewMode.PURE:
		_set_mode(ViewMode.COMBAT)
	else:
		_refresh_hud()
		overlay.queue_redraw()


func _refresh_hud() -> void:
	if world == null:
		return
	var phase_str := "战斗部署（可点选第 5-8 行绿框调位）" if mode == ViewMode.DEPLOY else "第 %d/%d 回合 · 玩家行动与敌方预告" % [turn_number, max_turns]
	title_label.text = "关卡 1   |   " + phase_str
	objective_label.text = "主要目标：保护水晶采集器完成 5 回合采集（试算）  ·  附加目标：击败 5 只地精（+1 枚强化硬币）"

	var alive: int = world.data.surviving_collectors()
	var est_yield: int = ECONOMY.harvest_g(1, alive, 3, false)
	if world.data.should_end_battle_from_collectors():
		status_banner.text = "采集器 0/3（全毁！）\n立刻结束回营 · 保底回收 %d g" % est_yield
		status_banner.modulate = Color("#ff8a75")
	else:
		status_banner.text = "采集器存活：%d/3 台\n预计带回粉尘：%d g（税额 %d g）" % [alive, est_yield, ECONOMY.tax_g(1)]
		status_banner.modulate = Color("#f2ebd9")

	_refresh_cell_inspector()


func _refresh_cell_inspector() -> void:
	if world == null:
		return
	var cell := hovered_cell if BattleData.is_valid_cell(hovered_cell) else get_selected_warden_cell()
	if not BattleData.is_valid_cell(cell):
		cell_title_label.text = "盘面快览（悬停棋盘格查看）"
		cell_detail_label.text = "按 H 可隐藏全部界面纯看森林像素场景；按 R 重置初始盘面。"
		return

	var code := BattleData.format_cell(cell)
	cell_title_label.text = "格位 %s · %s" % [code, world.data.terrain_name_zh(cell)]
	var lines: Array[String] = []
	if world.data.collectors.has(cell):
		var st: int = world.data.collectors[cell]
		lines.append("单位：水晶采集器（%s）" % ("工作中·1 HP" if st == BattleData.CollectorState.WORKING else ("采集完成" if st == BattleData.CollectorState.COMPLETE else "已被摧毁")))
	if world.data.chest_cells.has(cell):
		lines.append("道具：林间额外宝箱（%s）" % ("未开启 · 停留得 1 枚强化硬币" if world.data.chest_cells[cell] else "已开启"))
	if world.data.emerge_cells.has(cell):
		lines.append("预告：本回合末地下地精从此格钻出（站人可阻挡并受 1 伤）")
	for w in world.wardens:
		if BattleData.parse_cell(w["cell"]) == cell:
			lines.append("我方：%s  HP %d/%d  移动 %d%s" % [w["name"], w["hp"], w["max_hp"], w["move"], " [空中]" if w.get("airborne", false) else ""])
	for g in world.goblins:
		if BattleData.parse_cell(g["cell"]) == cell:
			var tgt := cell + (g["target_dir"] as Vector2i)
			lines.append("敌方：%s  HP %d/%d  预告攻击 -> %s" % [g["name"], g["hp"], g["max_hp"], BattleData.format_cell(tgt)])
	if lines.is_empty():
		lines.append("当前空格 · " + ("部署阶段允许落位" if world.data.is_deployable_cell(cell) else "北侧交战区"))
	cell_detail_label.text = "\n".join(lines)


func _battle_theme() -> Theme:
	var th := Theme.new()
	var sys_font := SystemFont.new()
	sys_font.font_names = PackedStringArray(["PingFang SC", "Heiti SC", "Microsoft YaHei", "SimHei", "Noto Sans CJK SC"])
	sys_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	th.default_font = sys_font
	th.default_font_size = 16
	return th


func _make_panel(parent: Control, rect: Rect2) -> Panel:
	var p := Panel.new()
	p.position = rect.position
	p.size = rect.size
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.13, 0.18, 0.88)
	sb.border_color = Color(0.32, 0.50, 0.58, 0.92)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(3)
	p.add_theme_stylebox_override(&"panel", sb)
	parent.add_child(p)
	return p


func _make_label(parent: Control, rect: Rect2, txt: String, fsize: int, col: Color) -> Label:
	var lb := Label.new()
	lb.position = rect.position
	lb.size = rect.size
	lb.text = txt
	lb.add_theme_font_size_override(&"font_size", fsize)
	lb.add_theme_color_override(&"font_color", col)
	parent.add_child(lb)
	return lb


func _make_button(parent: Control, rect: Rect2, txt: String) -> Button:
	var b := Button.new()
	b.position = rect.position
	b.size = rect.size
	b.text = txt
	b.add_theme_font_size_override(&"font_size", 15)
	b.add_theme_color_override(&"font_color", Color("#f4ebd9"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#203642")
	normal.border_color = Color("#4f7b8c")
	normal.set_border_width_all(2)
	normal.border_width_bottom = 4
	normal.set_corner_radius_all(3)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#2b4959")
	hover.border_color = Color("#7fd4e6")

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("#182830")
	pressed.border_width_bottom = 2
	pressed.content_margin_top = 2

	b.add_theme_stylebox_override(&"normal", normal)
	b.add_theme_stylebox_override(&"hover", hover)
	b.add_theme_stylebox_override(&"pressed", pressed)
	parent.add_child(b)
	return b
