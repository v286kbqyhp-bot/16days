extends RefCounted
## 关卡 1「寒林前哨」战场盘面数据、等轴坐标换算与地形/采集器状态规则（试算·对齐关卡设计文档）。

const GRID_SIZE := 8

## 640x360 世界坐标系下的单格 2:1 等轴半宽（像素）：单格顶面菱形宽 48 px。
const TILE_HALF_W := 24.0
## 640x360 世界坐标系下的单格 2:1 等轴半高（像素）：单格顶面菱形高 24 px。
const TILE_HALF_H := 12.0
## A1（col=0, row=0）格心在 640x360 视口中的世界坐标（像素）。
const ORIGIN_A1_CENTER := Vector2(320.0, 80.0)

enum Terrain {
	PLAIN, ## 普通地（.）：可通行，地精仅从普通地钻出
	GRASS, ## 草地（"）：可通行，可被点燃进入持续燃烧
	WATER, ## 水地（~）：可通行，陆地单位停留附加潮湿并消除燃烧
	ROCK,  ## 石地（#）：阻挡移动，碰撞 1 次裂纹，2 次碎裂变回普通地
	SAND,  ## 沙地（:）：后续关卡扩展地形
	PIT,   ## 地洞（O）：后续关卡扩展地形
}

enum CollectorState {
	WORKING,
	COMPLETE,
	DESTROYED,
}

## 关卡 1「寒林前哨」候选 8x8 地图（行 1-8 自北向南，列 A-H 自西向东，试算）。
const COLD_WOODS_ROWS := [
	'. " " . . # . .',
	'. . . . " " . .',
	'# . ~ ~ . . . #',
	'. . ~ . . C . .',
	'. C . . # . . "',
	'. . . . . . C .',
	'" " . # . . . .',
	'$ . . . . " " .',
]

## 首战默认参战小队展示站位（位于允许部署的第 5-8 行可通行空格，试算）。
const DEFAULT_WARDENS := [
	{"id": "warden_1", "name": "守卫·长剑", "weapon": "weapon_sword", "crest": "crest_common", "cell": "C6", "hp": 3, "max_hp": 3, "move": 3, "airborne": false, "downed": false},
	{"id": "warden_2", "name": "猎手·长弓", "weapon": "weapon_bow", "crest": "crest_sky", "cell": "E6", "hp": 2, "max_hp": 2, "move": 3, "airborne": false, "downed": false},
	{"id": "warden_3", "name": "学者·法杖", "weapon": "weapon_staff", "crest": "crest_warden", "cell": "F7", "hp": 2, "max_hp": 2, "move": 3, "airborne": false, "downed": false},
]

## 首战「寒林前哨」开局在场地精（掠 B2、掠 G2）与 T1 地面钻出预告（掠 D1）（试算）。
const DEFAULT_GOBLINS := [
	{"id": "goblin_1", "name": "掠夺地精", "type": "goblin_raider", "cell": "B2", "hp": 3, "max_hp": 3, "move": 3, "target_dir": Vector2i(0, 1)},
	{"id": "goblin_2", "name": "掠夺地精", "type": "goblin_raider", "cell": "G2", "hp": 3, "max_hp": 3, "move": 3, "target_dir": Vector2i(0, 1)},
]
const DEFAULT_EMERGE_CELLS := ["D1"]

var terrain_grid: Array = []
var burning_cells: Dictionary = {} ## Vector2i -> bool
var rock_damage: Dictionary = {}   ## Vector2i -> int (0=完好, 1=裂纹, >=2 已碎为普通地)
var collectors: Dictionary = {}    ## Vector2i -> CollectorState
var chest_cells: Dictionary = {}   ## Vector2i -> bool (true=未开启, false=已开启)
var emerge_cells: Dictionary = {}  ## Vector2i -> bool


static func create_cold_woods():
	var data = new()
	data.reset_cold_woods()
	return data


func reset_cold_woods() -> void:
	terrain_grid.clear()
	burning_cells.clear()
	rock_damage.clear()
	collectors.clear()
	chest_cells.clear()
	emerge_cells.clear()

	for r in range(GRID_SIZE):
		var tokens := String(COLD_WOODS_ROWS[r]).split(" ", false)
		var row_arr: Array[int] = []
		for c in range(GRID_SIZE):
			var sym := tokens[c]
			var cell := Vector2i(c, r)
			match sym:
				".":
					row_arr.append(Terrain.PLAIN)
				'"':
					row_arr.append(Terrain.GRASS)
				"~":
					row_arr.append(Terrain.WATER)
				"#":
					row_arr.append(Terrain.ROCK)
					rock_damage[cell] = 0
				":":
					row_arr.append(Terrain.SAND)
				"O":
					row_arr.append(Terrain.PIT)
				"C":
					row_arr.append(Terrain.PLAIN)
					collectors[cell] = CollectorState.WORKING
				"$":
					row_arr.append(Terrain.PLAIN)
					chest_cells[cell] = true
				_:
					row_arr.append(Terrain.PLAIN)
		terrain_grid.append(row_arr)

	for code in DEFAULT_EMERGE_CELLS:
		emerge_cells[parse_cell(code)] = true


static func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GRID_SIZE and cell.y >= 0 and cell.y < GRID_SIZE


static func parse_cell(code: String) -> Vector2i:
	var clean := code.strip_edges().to_upper()
	if clean.length() != 2:
		return Vector2i(-1, -1)
	var col := clean.unicode_at(0) - "A".unicode_at(0)
	var row := clean.unicode_at(1) - "1".unicode_at(0)
	var cell := Vector2i(col, row)
	return cell if is_valid_cell(cell) else Vector2i(-1, -1)


static func format_cell(cell: Vector2i) -> String:
	if not is_valid_cell(cell):
		return "--"
	return String.chr("A".unicode_at(0) + cell.x) + str(cell.y + 1)


static func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(
		ORIGIN_A1_CENTER.x + float(cell.x - cell.y) * TILE_HALF_W,
		ORIGIN_A1_CENTER.y + float(cell.x + cell.y) * TILE_HALF_H
	)


static func world_to_cell(world_pos: Vector2) -> Vector2i:
	var dx := (world_pos.x - ORIGIN_A1_CENTER.x) / TILE_HALF_W
	var dy := (world_pos.y - ORIGIN_A1_CENTER.y) / TILE_HALF_H
	var col := floori((dx + dy) * 0.5 + 0.5)
	var row := floori((dy - dx) * 0.5 + 0.5)
	var cell := Vector2i(col, row)
	if not is_valid_cell(cell):
		return Vector2i(-1, -1)
	var center := cell_to_world(cell)
	var l1 := absf(world_pos.x - center.x) / TILE_HALF_W + absf(world_pos.y - center.y) / TILE_HALF_H
	return cell if l1 <= 1.0 else Vector2i(-1, -1)


static func cell_diamond_points(cell: Vector2i, scale_factor: float = 1.0, inset_px: float = 0.0) -> PackedVector2Array:
	var c := cell_to_world(cell) * scale_factor
	var hw := TILE_HALF_W * scale_factor - inset_px * 2.0
	var hh := TILE_HALF_H * scale_factor - inset_px
	return PackedVector2Array([
		Vector2(c.x, c.y - hh),
		Vector2(c.x + hw, c.y),
		Vector2(c.x, c.y + hh),
		Vector2(c.x - hw, c.y),
	])


func get_terrain(cell: Vector2i) -> int:
	assert(is_valid_cell(cell))
	return terrain_grid[cell.y][cell.x]


func terrain_name_zh(cell: Vector2i) -> String:
	match get_terrain(cell):
		Terrain.PLAIN:
			return "普通地"
		Terrain.GRASS:
			return "草地（燃烧中）" if burning_cells.get(cell, false) else "草地"
		Terrain.WATER:
			return "水地（附加潮湿/灭火）"
		Terrain.ROCK:
			var hits: int = rock_damage.get(cell, 0)
			return "石地（已裂纹 1/2）" if hits == 1 else "石地（阻挡/可撞碎）"
		Terrain.SAND:
			return "沙地"
		Terrain.PIT:
			return "地洞"
	return "未知地形"


## 寒林前哨初始允许部署格：第 5-8 行（row 4..7）中除石地与水晶采集器外的普通地/草地格。
func is_deployable_cell(cell: Vector2i) -> bool:
	if not is_valid_cell(cell) or cell.y < 4:
		return false
	if collectors.has(cell):
		return false
	var t := get_terrain(cell)
	return t == Terrain.PLAIN or t == Terrain.GRASS


func is_walkable_for_unit(cell: Vector2i, airborne: bool = false) -> bool:
	if not is_valid_cell(cell):
		return false
	if collectors.has(cell) and collectors[cell] != CollectorState.DESTROYED:
		return false
	var t := get_terrain(cell)
	if t == Terrain.ROCK:
		return false
	if t == Terrain.PIT and not airborne:
		return false
	return true


## 石地碰撞判定：第 1 次碰撞出现裂纹，第 2 次碰撞碎裂并在本次出征中转为普通地形。
func collide_rock(cell: Vector2i) -> bool:
	if not is_valid_cell(cell) or get_terrain(cell) != Terrain.ROCK:
		return false
	var hits: int = rock_damage.get(cell, 0) + 1
	if hits >= 2:
		terrain_grid[cell.y][cell.x] = Terrain.PLAIN
		rock_damage.erase(cell)
		return true
	rock_damage[cell] = hits
	return false


func set_grass_burning(cell: Vector2i, burning: bool) -> void:
	if is_valid_cell(cell) and get_terrain(cell) == Terrain.GRASS:
		if burning:
			burning_cells[cell] = true
		else:
			burning_cells.erase(cell)


func surviving_collectors() -> int:
	var alive := 0
	for cell in collectors:
		if collectors[cell] != CollectorState.DESTROYED:
			alive += 1
	return alive


## 已对齐战斗流程画板与作者确认规则：场上采集器全部被毁时立刻结束本场战斗回营（按全毁比例 7% 结算）。
func should_end_battle_from_collectors() -> bool:
	return not collectors.is_empty() and surviving_collectors() == 0
