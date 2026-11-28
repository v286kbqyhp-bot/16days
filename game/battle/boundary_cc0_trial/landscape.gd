@tool
extends Node2D
## 独立地景；无玩法占位物、地形物件、水晶、角色或战斗 UI。
## 光幕高度为原生像素；显示按当前整数倍率放大。
@export_range(4.0,24.0,1.0) var boundary_rear_height := 22.0
@export_range(2.0,16.0,1.0) var boundary_front_height := 9.0
@export_range(0.0,1.0,0.01) var boundary_rear_strength := 0.85
@export_range(0.0,1.0,0.01) var boundary_front_strength := 0.28
func _ready() -> void:
	var ground := Polygon2D.new()
	ground.name = "ContinuousGround"
	ground.z_index = -10
	ground.polygon = PackedVector2Array([Vector2(-8192,-8192),Vector2(8192,-8192),Vector2(8192,8192),Vector2(-8192,8192)])
	var mat := ShaderMaterial.new()
	mat.shader = load("res://battle/boundary_cc0_trial/patch_ground.gdshader")
	for key in ["dirt","grass","stone"]:
		mat.set_shader_parameter(key+"_tex",load("res://battle/source_ground_trial/"+key+".png"))
	mat.set_shader_parameter("blend_breakup",load("res://battle/source_ground_trial/blend_breakup.png"))
	# 残砖按片区和零散残片布局，不连成道路。
	var slabs := Image.create(12,12,false,Image.FORMAT_R8)
	slabs.fill(Color.BLACK)
	var slab_cells := [Vector2i(1,2),Vector2i(1,3),Vector2i(2,2),Vector2i(2,3),Vector2i(2,4),
		Vector2i(4,0),Vector2i(4,1),Vector2i(5,1),Vector2i(5,2),
		Vector2i(5,5),Vector2i(6,5),Vector2i(6,6),Vector2i(7,5),
		Vector2i(0,5),Vector2i(4,7)]
	for i in range(slab_cells.size()):
		var c: Vector2i = slab_cells[i]
		var coverage := 0.6 if i >= 13 else 1.0
		slabs.set_pixel(c.x+2,c.y+2,Color(coverage,0,0,1))
	mat.set_shader_parameter("stone_regions",ImageTexture.create_from_image(slabs))
	ground.material = mat
	add_child(ground)
	_build_exterior_flowers()
	_build_laser_boundary()
	var grass_layer := Node2D.new()
	grass_layer.name = "ExteriorGrass"
	grass_layer.z_index = -2
	add_child(grass_layer) # 按作者要求暂为空，等待长条草造型确认。

func _build_exterior_flowers() -> void:
	var layer := Node2D.new()
	layer.name = "ExteriorFlowers"
	layer.z_index = -1
	add_child(layer)
	# 格内 [-0.5,7.5]² 不放装饰。未来由关卡状态指定草/花。
	# 片区形状和距离不同，不沿整个棋盘均匀围一圈。
	var groups := [
		[Vector2(-1.10,2.10),[Vector2(0,0),Vector2(-.12,.25),Vector2(.05,.46),Vector2(-.24,.60)],0],
		[Vector2(-1.03,5.00),[Vector2(0,0),Vector2(-.16,.16)],1],
		[Vector2(3.40,-1.05),[Vector2(0,0),Vector2(.20,-.16),Vector2(.43,.03),Vector2(.58,-.20),Vector2(.78,-.08)],2],
		[Vector2(8.12,2.70),[Vector2(0,0),Vector2(.12,.20),Vector2(-.03,.41)],0],
		[Vector2(2.40,8.14),[Vector2(0,0),Vector2(.19,.10),Vector2(.47,-.03),Vector2(.59,.15)],1],
	]
	for group in groups:
		for i in range(group[1].size()):
			var p: Vector2 = group[0]+group[1][i]
			assert(p.x < -.7 or p.x > 7.7 or p.y < -.7 or p.y > 7.7)
			var spr := Sprite2D.new()
			spr.name = "OutsideFlower"
			spr.set_meta("ground_cell",p)
			var shape: int = [4,2,3,1,0][i%5]
			spr.texture = load("res://battle/boundary_cc0_trial/flowers-v7/flower-%d-%d.png" % [shape,group[2]])
			var mat := CanvasItemMaterial.new()
			mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
			spr.material = mat
			spr.centered = false
			spr.offset = Vector2(-8,-10)
			spr.position = (Vector2(320,80)+Vector2((p.x-p.y)*24,(p.x+p.y)*12)).round()
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			layer.add_child(spr)
			_validate_exterior_pixels(spr)

func _validate_exterior_pixels(spr: Sprite2D) -> void:
	# 不只检查根部：每个可见像素都不得投进8×8棋盘。
	var image := spr.texture.get_image()
	if image.is_compressed():
		image.decompress()
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a < .1:
				continue
			var delta := spr.position+spr.offset+Vector2(x+.5,y+.5)-Vector2(320,80)
			var cell := Vector2((delta.x/24.+delta.y/12.)*.5,(-delta.x/24.+delta.y/12.)*.5)
			assert(cell.x < -.5 or cell.x > 7.5 or cell.y < -.5 or cell.y > 7.5,"Exterior vegetation overlaps board")


func _build_laser_boundary() -> void:
	var white_image := Image.create(1,1,false,Image.FORMAT_RGBA8)
	white_image.fill(Color.WHITE)
	var white := ImageTexture.create_from_image(white_image)
	# 8×8 外沿：格心 -0.5 到 7.5，四角分别上、右、下、左。
	var corners := PackedVector2Array([Vector2(320,68),Vector2(512,164),Vector2(320,260),Vector2(128,164)])
	var rear := Node2D.new()
	rear.name = "LaserBoundaryRear"
	rear.z_index = -3
	add_child(rear)
	var front := Node2D.new()
	front.name = "LaserBoundaryFront"
	front.z_index = 30
	add_child(front)
	for i in range(4):
		var a := corners[i]
		var b := corners[(i+1)%4]
		var is_front := i in [1,2]
		var strength := boundary_front_strength if is_front else boundary_rear_strength
		var height := boundary_front_height if is_front else boundary_rear_height
		var layer := front if is_front else rear
		var wall := Polygon2D.new()
		wall.name = "Curtain%d" % i
		wall.texture = white
		wall.polygon = PackedVector2Array([a,b,b-Vector2(0,height),a-Vector2(0,height)])
		wall.uv = PackedVector2Array([Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)])
		wall.material = _laser_material(strength,false,a.distance_to(b),height)
		layer.add_child(wall)
		var halo := Polygon2D.new()
		halo.name = "GroundGlow%d" % i
		halo.texture = white
		var normal := (b-a).normalized().orthogonal()*2.5
		halo.polygon = PackedVector2Array([a-normal,b-normal,b+normal,a+normal])
		halo.uv = PackedVector2Array([Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)])
		halo.material = _laser_material(strength,true,a.distance_to(b),height)
		layer.add_child(halo)

func _laser_material(strength: float,ground: bool,length_px: float,height: float) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://battle/boundary_cc0_trial/laser_boundary.gdshader")
	mat.set_shader_parameter("strength",strength)
	mat.set_shader_parameter("ground_glow",ground)
	mat.set_shader_parameter("edge_length",length_px)
	mat.set_shader_parameter("wall_height",height)
	return mat
