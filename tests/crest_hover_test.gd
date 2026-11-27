extends SceneTree
## 实际 GPU 检查悬停四角、鼠标移出复位、实例隔离和透明边界。
var failures := 0
var target: SubViewport

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func capture() -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	return target.get_texture().get_image()

func red_center(frame: Image) -> Vector2:
	var total := Vector2.ZERO
	var count := 0
	var bounds := frame.get_used_rect()
	for y in range(bounds.position.y,bounds.end.y):
		for x in range(bounds.position.x,bounds.end.x):
			var color := frame.get_pixel(x,y)
			if color.a > 0.9 and color.r > 0.9 and color.g < 0.1:
				total += Vector2(x+0.5,y+0.5)
				count += 1
	check(count > 0,"透视中心标记丢失")
	return total / maxf(count,1)

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("悬停检查需要真实 GPU 渲染")
		quit(1)
		return
	root.size = Vector2i(960,560)
	target = SubViewport.new()
	target.size = Vector2i(960,560)
	target.transparent_bg = true
	target.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(target)
	var component = load("res://art/crests/crest_hover_view.gd")
	var crest = component.new()
	crest.position = Vector2(532,107)
	crest.size = Vector2(336,336)
	target.add_child(crest)
	crest.set_process(false)
	var other = component.new()
	other.position = Vector2(82,107)
	other.size = Vector2(336,336)
	target.add_child(other)
	other.set_process(false)
	check(crest.glint != other.glint, "不同实例共享了动态材质")
	var capture_dir := OS.get_environment("CREST_CAPTURE_DIR")
	if capture_dir.is_empty(): capture_dir = "/tmp/crest-hover-check"
	DirAccess.make_dir_recursive_absolute(capture_dir)
	var frames: Array[PackedByteArray] = []
	for pointer in [Vector2(90,90),Vector2(246,90),Vector2(246,246),Vector2(90,246)]:
		crest.advance_motion(0.0,pointer)
		check(crest.hovered, "四角悬停未触发")
		check(float(crest.glint.get_shader_parameter("hovering")) == crest.hover_tilt, "悬停强度未传入材质")
		var frame := await capture()
		frame.save_png(capture_dir + "/corner_%d.png" % frames.size())
		for previous in frames:
			check(previous != frame.get_data(), "鼠标换角后画面没有变化")
		frames.append(frame.get_data())
		for x in range(frame.get_width()):
			check(frame.get_pixel(x,0).a == 0.0 and frame.get_pixel(x,559).a == 0.0, "倾斜冲出画面边界")
	check(not other.hovered and float(other.glint.get_shader_parameter("hovering")) == 0.0, "悬停污染另一实例")
	crest.advance_motion(0.0,Vector2(20,168),false)
	crest.advance_motion(0.0,Vector2(20,168))
	check(not crest.hovered, "外围仍触发悬停，热区没有缩小")
	# 拿起边界与放下边界不同：缓冲带内保留原状态，不能再次触发弹起。
	var enter_radius: float = 336.0 * crest.hotspot_radius_ratio
	var band_width := 12.0
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		var band_point: Vector2 = Vector2(168,168) + direction * (enter_radius + band_width*0.5)
		crest.advance_motion(0.0,band_point)
		check(not crest.hovered,"未拿起时缓冲带错误触发了悬停")
		for i in range(60): crest.advance_motion(1.0/60.0,Vector2(168,168))
		for i in range(8):
			crest.advance_motion(1.0/60.0,band_point+direction*(0.5 if i%2==0 else -0.5))
			check(crest.hovered,"已拿起时在缓冲带内提前放下")
			check(absf(crest.body.scale.x/7.0-1.05)<0.001,"缓冲带内重复触发拿起弹动")
		crest.advance_motion(0.0,Vector2(168,168)+direction*336.0)
		check(not crest.hovered,"越过放下边界后没有放下")
		crest.advance_motion(0.0,band_point)
		check(not crest.hovered,"放下后退回缓冲带又自动拿起")
	var max_scale := 0.0
	for i in range(24):
		crest.advance_motion(1.0/60.0,Vector2(246,246))
		max_scale = maxf(max_scale,crest.body.scale.x / 7.0)
		if i == 2:
			check(crest.body.scale.x / 7.0 > 1.05, "进入后未在 50ms 内快速弹起")
	check(max_scale > 1.052, "缩放缺少越过目标的小回弹")
	for i in range(120): crest.advance_motion(1.0/120.0,Vector2(168,168))
	check(absf(crest.body.scale.x / 7.0 - 1.05) < 0.001, "悬停放大未稳定到 5%")
	check(crest.body.position.x > 168.0 and crest.body.position.y < 168.0, "悬停没有向右上浮起")
	check(crest.shadow.position.x < 168.0 and crest.shadow.position.y > 168.0, "阴影没有留在左下")
	var fixed_center: Vector2 = crest.body.position
	for pointer in [Vector2(90,90),Vector2(246,90),Vector2(246,246),Vector2(90,246)]:
		for i in range(30): crest.advance_motion(1.0/60.0,pointer)
		check(crest.body.position.is_equal_approx(fixed_center), "改变鼠标方向推动了纹章中心")
	var raised := await capture()
	raised.save_png(capture_dir + "/raised.png")
	for i in range(120): crest.advance_motion(1.0/120.0,Vector2(-50,-50))
	check(not crest.hovered, "鼠标移出后仍保持悬停")
	check(float(crest.glint.get_shader_parameter("hovering")) == 0.0, "鼠标移出后透视未关闭")
	check(absf(crest.body.scale.x / 7.0 - 1.0) < 0.001, "鼠标移出后缩放未复位")
	check(crest.body.position.is_equal_approx(Vector2(168,168)), "移出后纹章未落回原位")
	var rotation_before: float = crest.body.rotation
	for i in range(60): crest.advance_motion(1.0/120.0,Vector2(-50,-50))
	check(absf(crest.body.rotation - rotation_before) > 0.001, "未悬停时轻晃没有继续")
	crest.advance_motion(0.01,Vector2(168,168),false)
	check(not crest.hovered, "窗口失去焦点后仍响应悬停")
	var idle := await capture()
	idle.save_png(capture_dir + "/idle.png")
	# 阴影同步放大，稳定后不受鼠标倾斜和时间轻晃影响。
	crest.body.hide()
	other.hide()
	var shadow_baseline := await capture()
	shadow_baseline.save_png(capture_dir + "/shadow_fixed.png")
	var shadow_position: Vector2 = crest.shadow.position
	for i in range(120): crest.advance_motion(1.0/120.0,Vector2(168,168))
	var shadow_enlarged := await capture()
	shadow_enlarged.save_png(capture_dir + "/shadow_enlarged.png")
	check(shadow_enlarged.get_used_rect().get_area() > shadow_baseline.get_used_rect().get_area(), "悬停时阴影未放大")
	check(absf(crest.shadow.scale.x / (7.0 * 0.99) - 1.05) < 0.001, "阴影未同步放大 5%")
	for pointer in [Vector2(90,90),Vector2(246,90),Vector2(246,246),Vector2(90,246)]:
		crest.advance_motion(0.1,pointer)
		var shadow_frame := await capture()
		check(shadow_frame.get_data() == shadow_enlarged.get_data(), "底面阴影受到鼠标透视影响")
		check(crest.shadow.position == shadow_position, "阴影中心受鼠标影响")
	var body_rotation_before: float = crest.body.rotation
	for i in range(60): crest.advance_motion(1.0/120.0,Vector2(168,168))
	check(absf(crest.body.rotation - body_rotation_before) > 0.001, "上层纹章没有继续轻晃")
	var after_sway := await capture()
	check(after_sway.get_data() == shadow_enlarged.get_data(), "阴影随轻晃发生变化")
	for i in range(120): crest.advance_motion(1.0/120.0,Vector2(-50,-50))
	check(absf(crest.shadow.scale.x / (7.0 * 0.99) - 1.0) < 0.001, "移出后阴影未恢复原大小")
	var restored := await capture()
	check(restored.get_data() == shadow_baseline.get_data(), "移出后阴影未恢复原轮廓")
	# 按 GPU 输出逐个检查真实彩图的所有外边界像素，覆盖弹起、回弹和稳定倾斜。
	crest.body.show()
	crest.shadow.hide()
	var boundary_samples := 0
	var boundary_misses := 0
	for age in [0.05,0.25,1.0]:
		crest.advance_motion(0.0,Vector2(-1000,-1000),false)
		for i in range(int(age*60)): crest.advance_motion(1.0/60.0,Vector2(168,168))
		for direction in [Vector2.RIGHT,Vector2(1,1).normalized(),Vector2.DOWN,Vector2(-1,1).normalized(),Vector2.LEFT,Vector2(-1,-1).normalized(),Vector2.UP,Vector2(1,-1).normalized()]:
			crest.advance_motion(0.0,Vector2(168,168)+direction*110.0)
			var outline := await capture()
			var bounds := outline.get_used_rect()
			var edge := Vector2.ZERO
			var furthest := -INF
			for y in range(bounds.position.y,bounds.end.y):
				for x in range(bounds.position.x,bounds.end.x):
					if outline.get_pixel(x,y).a <= 0.0: continue
					if outline.get_pixel(x-1,y).a > 0.0 and outline.get_pixel(x+1,y).a > 0.0 and outline.get_pixel(x,y-1).a > 0.0 and outline.get_pixel(x,y+1).a > 0.0: continue
					var local_point: Vector2 = Vector2(x+0.5,y+0.5)-crest.position
					boundary_samples += 1
					if not crest.contains_raised_crest(local_point): boundary_misses += 1
					if direction.dot(local_point) > furthest:
						furthest = direction.dot(local_point)
						edge = local_point
			crest.advance_motion(0.0,edge)
			check(crest.hovered,"鼠标位于实际渲染边界像素却提前放下")
			crest.advance_motion(0.0,Vector2(168,168))
			check(not crest.contains_raised_crest(Vector2(-100,-100)),"远离纹章仍在放下热区内")
	print("RAISED_BOUNDARY samples=%d misses=%d" % [boundary_samples,boundary_misses])
	check(boundary_samples > 10000 and boundary_misses == 0,"拿起后的热区没有完整覆盖实际 GPU 轮廓")
	# 测试专用白色平面＋红色中心，验证 GPU 实际按压方向及中心 UV，非游戏资产。
	var plane := Image.create(48,48,false,Image.FORMAT_RGBA8)
	plane.fill(Color.WHITE)
	for y in [23,24]:
		for x in [23,24]: plane.set_pixel(x,y,Color.RED)
	crest.body.texture = ImageTexture.create_from_image(plane)
	crest.body.show()
	crest.shadow.hide()
	crest.idle_rotation = 0.0
	crest.glint.set_shader_parameter("highlight_strength",0.0)
	for i in range(60): crest.advance_motion(1.0/60.0,Vector2(168,168))
	var pivot: Vector2 = crest.body.position
	crest.advance_motion(0.0,pivot)
	var flat := await capture()
	var flat_bounds := flat.get_used_rect()
	var flat_center := red_center(flat)
	for direction in [-1,1]:
		crest.advance_motion(0.0,pivot+Vector2(78*direction,0))
		var pressed := await capture()
		pressed.save_png(capture_dir + "/press_direction_%d.png" % direction)
		var bounds := pressed.get_used_rect()
		print("PRESS direction=%d flat=%s pressed=%s center_delta=%s" % [direction,flat_bounds,bounds,red_center(pressed)-flat_center])
		check((bounds.end.x-flat_bounds.end.x)*direction < -2,"指针侧未压下／对侧未翘起")
		check((bounds.position.x-flat_bounds.position.x)*direction < -2,"平面另一侧的透视方向错误")
		check(red_center(pressed).distance_to(flat_center) < 1.0,"GPU 透视使图案中心跟随鼠标移动")
	print("CREST_HOVER_TEST failures=%d renderer=%s" % [failures, RenderingServer.get_current_rendering_method()])
	quit(failures)
