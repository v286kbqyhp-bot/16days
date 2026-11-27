extends RefCounted
## 在 Pixelorama 1.2.4 原生环境制作。复用作者圆盘，独立绘制双翼与单像素明暗边。
var out: String

func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	assert(not root.is_empty())
	out = root + "/docs/art/crests/sky-v1/"
	var maps = load("res://author_common.gd").new()
	maps.source = root + "/docs/art/crests/source/"
	maps.output = out
	var source: Array = maps.read_color_layers()
	var b = load("res://author_pins.gd").new()
	b.im = b.blank()
	# 沿上一批天空纹章的双翼／中央菱形方向重新整理羽翼轮廓。
	b.poly([[7,11],[10,12],[15,16],[18,20],[22,23],[23,27],[21,33],[18,33],[15,30],[12,27],[10,23],[9,18]],Color("e4e6d8"))
	var left: Image = b.im
	var wings: Image = b.blank()
	for y in range(48):
		for x in range(24):
			if left.get_pixel(x,y).a > 0:
				wings.set_pixel(x,y,left.get_pixel(x,y))
				wings.set_pixel(47-x,y,left.get_pixel(x,y))
	# 两条羽片叠压暗面，只在已有翼面内着色；不污染圆盘。
	b.im = b.blank()
	b.poly([[9,17],[15,23],[21,27],[22,30],[18,28],[13,24],[10,21]],Color("bec8b3"))
	b.poly([[11,24],[16,28],[21,30],[21,33],[18,32],[14,29]],Color("99aa96"))
	for y in range(48):
		for x in range(24):
			if b.im.get_pixel(x,y).a > 0 and wings.get_pixel(x,y).a > 0:
				wings.set_pixel(x,y,b.im.get_pixel(x,y))
				wings.set_pixel(47-x,y,b.im.get_pixel(x,y))
	var outline: Image = b.blank()
	for y in range(1,47):
		for x in range(1,47):
			if wings.get_pixel(x,y).a == 0: continue
			var edge := false
			for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
				if wings.get_pixel(x+d.x,y+d.y).a == 0: edge = true
			if edge:
				var c := Color("99aa96")
				if wings.get_pixel(x,y-1).a == 0: c = Color("bec8b3")
				if y >= 26 and wings.get_pixel(x,y+1).a == 0: c = Color("627d70")
				outline.set_pixel(x,y,c)
	b.im = b.blank()
	b.poly([[23.5,20],[27,25],[23.5,31],[20,25]],Color("99aa96"))
	b.poly([[23.5,21],[25.5,25],[23.5,28],[21.5,25]],Color("e4e6d8"))
	b.poly([[23.5,25],[25.5,25],[23.5,29],[21.5,25]],Color("bec8b3"))
	var center: Image = b.im
	var layers := [["底盘_作者定稿",source[0]],["高光阴影_作者定稿",source[1]],["双翼_羽片明暗",wings],["双翼_单像素明暗边",outline],["中央菱形",center]]
	var project = b.project_from_layers("天空纹章_样稿",layers)
	assert(OpenSave.save_pxo_file(out+"crest_sky_color.pxo",false,project))
	var full: Image = maps.composite([source[0],source[1],wings,outline,center])
	assert(full.save_png(out+"crest_sky_color.png") == OK)
	var normal := Image.load_from_file(root+"/game/art/crests/template_disc_normal.png")
	var mask := Image.load_from_file(root+"/game/art/crests/template_disc_highlight_mask.png")
	var motif: Image = maps.composite([wings,outline,center])
	var motif_normal: Image = b.blank()
	var motif_mask: Image = b.blank()
	for y in range(48):
		for x in range(48):
			if motif.get_pixel(x,y).a == 0: continue
			var c := motif.get_pixel(x,y).to_html(false)
			var n := Vector3(-0.18,0.30,0.94)
			match c:
				"bec8b3": n = Vector3(-0.10,0.10,0.99)
				"99aa96": n = Vector3(-0.35,-0.28,0.90)
				"627d70": n = Vector3(0.0,-0.60,0.80)
			if x > 23: n.x = -n.x
			motif_normal.set_pixel(x,y,maps.normal_color(n))
			motif_mask.set_pixel(x,y,Color(0.72,0.72,0.72,1.0))
	var normal_project = b.project_from_layers("天空纹章_法线",[["圆盘_已确认模板",normal],["双翼与中央切面",motif_normal]])
	assert(OpenSave.save_pxo_file(out+"crest_sky_normal.pxo",false,normal_project))
	var mask_project = b.project_from_layers("天空纹章_扫光遮罩",[["圆盘_已确认模板",mask],["双翼反光",motif_mask]])
	assert(OpenSave.save_pxo_file(out+"crest_sky_highlight_mask.pxo",false,mask_project))
	assert(maps.composite([normal,motif_normal]).save_png(out+"crest_sky_normal.png") == OK)
	assert(maps.composite([mask,motif_mask]).save_png(out+"crest_sky_highlight_mask.png") == OK)
	# 无平滑缩放，仅供当前对话审阅。
	full.resize(384,384,Image.INTERPOLATE_NEAREST)
	assert(full.save_png(out+"crest_sky_review.png") == OK)
	print("SKY_SAVED: 5 color layers; native normal/mask projects; confirmed disc preserved")
