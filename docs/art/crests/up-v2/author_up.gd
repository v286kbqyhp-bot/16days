extends RefCounted
## 作者已选黄橙放射背景，要求红色 UP 有高光、暗部和立体感。
func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	var out := root+"/docs/art/crests/up-v2/"
	var b = load("res://author_pins.gd").new()
	var maps = load("res://author_common.gd").new()
	maps.source = root+"/docs/art/crests/source/"
	var original: Array = maps.read_color_layers()
	var base: Image = original[0].duplicate()
	var rim: Image = original[1].duplicate()
	for y in range(48):
		for x in range(48):
			if base.get_pixel(x,y).a > 0: base.set_pixel(x,y,Color("f5ce58"))
			if rim.get_pixel(x,y).a > 0:
				match rim.get_pixel(x,y).to_html(false):
					"c3d3c5": rim.set_pixel(x,y,Color("fff3bc"))
					"9db5ae": rim.set_pixel(x,y,Color("efc75f"))
					"78938f": rim.set_pixel(x,y,Color("bb7d2c"))
					_: rim.set_pixel(x,y,Color("76512a"))
	# 参考作者选定的 Yellow Rays：只保留黄与橙两个放射色块。
	b.im = b.blank()
	for i in range(8):
		var a := TAU*float(i)/8.0-PI/16.0
		var z := a+PI/8.0
		b.poly([[24,24],[24+64*cos(a),24+64*sin(a)],[24+64*cos(z),24+64*sin(z)]],Color("e9ac35"))
	var rays: Image = b.im
	for y in range(48):
		for x in range(48):
			if base.get_pixel(x,y).a == 0 or rim.get_pixel(x,y).a > 0: rays.set_pixel(x,y,Color.TRANSPARENT)
	b.im = b.blank()
	var red := Color("e73840")
	b.poly([[10,16],[13,16],[13,28],[15,30],[18,30],[20,28],[20,16],[23,16],[23,29],[19,33],[14,33],[10,29]],red)
	b.box(27,16,3,17,red)
	b.box(30,16,6,3,red)
	b.box(35,18,3,7,red)
	b.box(30,24,6,3,red)
	var letters: Image = b.im
	var depth: Image = b.blank()
	var union: Image = letters.duplicate()
	for y in range(1,45):
		for x in range(1,45):
			if letters.get_pixel(x,y).a > 0:
				for d in [Vector2i(0,1),Vector2i(1,1),Vector2i(1,2)]:
					depth.set_pixel(x+d.x,y+d.y,Color("781e32"))
					union.set_pixel(x+d.x,y+d.y,red)
	var outline: Image = b.blank()
	for y in range(1,47):
		for x in range(1,47):
			if union.get_pixel(x,y).a > 0:
				for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					if union.get_pixel(x+d.x,y+d.y).a == 0: outline.set_pixel(x+d.x,y+d.y,Color("381926"))
	# 正面倒角：高光与暗部分层，不依赖烘焙扫光。
	var light: Image = b.blank()
	var shade: Image = b.blank()
	for y in range(1,47):
		for x in range(1,47):
			if letters.get_pixel(x,y).a == 0: continue
			if letters.get_pixel(x,y+1).a == 0: shade.set_pixel(x,y,Color("a62135"))
			elif letters.get_pixel(x+1,y).a == 0: shade.set_pixel(x,y,Color("bc283b"))
			if letters.get_pixel(x,y-1).a == 0: light.set_pixel(x,y,Color("ff9980"))
			elif letters.get_pixel(x-1,y).a == 0: light.set_pixel(x,y,Color("fa6257"))
	var layers := [["圆盘_明黄底色",base],["背景_橙色放射纹",rays],["圆盘_配套高光阴影",rim],["UP_单像素外描边",outline],["UP_右下侧面厚度",depth],["UP_红色正面",letters],["UP_倒角暗部",shade],["UP_左上倒角高光",light]]
	var project = b.project_from_layers("UP纹章_立体红字与放射背景_待审",layers)
	assert(OpenSave.save_pxo_file(out+"crest_up_color.pxo",false,project))
	var flat: Image = b.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(out+"crest_up_color.png") == OK)
	flat.resize(480,480,Image.INTERPOLATE_NEAREST)
	assert(flat.save_png(out+"crest_up_review.png") == OK)
	print("UP_V2_SAVED: approved ray background direction; shaded dimensional red UP draft")
