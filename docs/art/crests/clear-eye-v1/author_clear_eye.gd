extends RefCounted
## 作者指定中央像素小人结印、周围吹风，青绿色背景沿用旧稿方向。
func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	var out := root+"/docs/art/crests/clear-eye-v1/"
	var b = load("res://author_pins.gd").new()
	var maps = load("res://author_common.gd").new()
	maps.source = root+"/docs/art/crests/source/"
	var original: Array = maps.read_color_layers()
	var base: Image = original[0].duplicate()
	var rim: Image = original[1].duplicate()
	for y in range(48):
		for x in range(48):
			if base.get_pixel(x,y).a > 0: base.set_pixel(x,y,Color("598d7e"))
			if rim.get_pixel(x,y).a > 0:
				match rim.get_pixel(x,y).to_html(false):
					"c3d3c5": rim.set_pixel(x,y,Color("c9e1c8"))
					"9db5ae": rim.set_pixel(x,y,Color("94bca7"))
					"78938f": rim.set_pixel(x,y,Color("416c60"))
					_: rim.set_pixel(x,y,Color("294c46"))
	# 底端补齐像素属于下缘暗部，不能随底色重染。
	for x in range(20,28): rim.set_pixel(x,46,Color("294c46"))
	# 背后风纹绕过头肩，使用几条有间断的弧线表达吹动方向。
	b.im = b.blank()
	b.poly([[8,21],[7,18],[8,15],[11,12],[16,10],[22,9],[31,9],[37,11],[40,14],[40,17],[38,19],[34,20],[30,19],[35,18],[37,16],[37,14],[34,12],[28,11],[21,11],[15,12],[11,14],[9,17]],Color("acd0b3"))
	b.poly([[8,18],[9,15],[12,12],[18,10],[29,9],[35,10],[38,12],[39,14],[37,13],[34,12],[29,11],[20,11],[14,13],[11,15]],Color("edf1d8"))
	b.stroke([[31,17],[34,18],[37,17]],Color("edf1d8"),1)
	b.poly([[9,25],[11,23],[16,22],[19,22],[15,24],[12,25],[11,27],[12,29],[10,28]],Color("acd0b3"))
	var rear_wind: Image = b.im
	# 躯干及站姿。服装用中性的深灰青色，使手势与风纹保持清楚。
	b.im = b.blank()
	b.poly([[21,18],[27,18],[30,20],[31,24],[29,27],[28,30],[29,33],[31,37],[27,38],[25,34],[24,32],[22,35],[21,38],[17,38],[19,33],[20,29],[18,25],[17,22],[18,20]],Color("203d40"))
	b.poly([[21,19],[26,19],[28,21],[28,25],[27,29],[25,31],[22,30],[20,26],[19,22]],Color("496e70"))
	b.poly([[21,20],[23,20],[22,25],[23,29],[21,28],[20,24]],Color("78988e"))
	b.poly([[26,20],[28,22],[27,28],[25,30],[24,28],[26,25]],Color("2e5057"))
	b.poly([[21,29],[24,30],[22,34],[20,37],[18,37],[20,33]],Color("41636a"))
	b.poly([[25,30],[27,30],[28,34],[30,37],[27,37],[25,33]],Color("36555f"))
	b.box(18,37,4,1,Color("182f35"))
	b.box(27,37,4,1,Color("182f35"))
	var clothes: Image = b.im
	# 头部和颈部。
	b.im = b.blank()
	b.poly([[22,11],[27,11],[28,13],[28,16],[26,18],[23,18],[21,16],[21,13]],Color("a77b5c"))
	b.poly([[22,12],[26,12],[27,14],[27,16],[25,17],[23,16],[22,14]],Color("f0c99a"))
	b.box(23,17,3,2,Color("c49a74"))
	b.box(23,18,2,1,Color("e0b78a"))
	var head: Image = b.im
	b.im = b.blank()
	b.poly([[21,12],[21,10],[23,9],[27,9],[29,11],[28,14],[27,14],[26,12],[23,12],[22,14],[21,15],[20,13]],Color("233c3b"))
	b.stroke([[22,11],[24,10],[26,10]],Color("52736a"),1)
	b.box(23,14,1,1,Color("493f38"))
	b.box(26,14,1,1,Color("493f38"))
	var hair: Image = b.im
	# 两肘向外、前臂收向胸前，避免把手势画成普通抱胸。
	b.im = b.blank()
	b.poly([[19,20],[21,21],[20,23],[23,25],[22,28],[18,25],[17,23]],Color("203d40"))
	b.poly([[19,21],[20,22],[19,23],[22,25],[22,26],[19,24],[18,23]],Color("90a89a"))
	b.poly([[28,20],[30,21],[31,24],[28,27],[25,27],[25,24],[28,23]],Color("203d40"))
	b.poly([[29,21],[30,23],[28,25],[26,26],[26,24],[28,23]],Color("648681"))
	var arms: Image = b.im
	# 结印手单独一层：两指向上，另一只手横握在下，肤色中线分开指节。
	b.im = b.blank()
	b.poly([[23,20],[25,20],[25,23],[27,23],[27,25],[25,27],[23,26],[21,25],[21,23],[23,23]],Color("9e7255"))
	b.box(23,20,1,4,Color("f8d9ac"))
	b.box(24,20,1,4,Color("dab084"))
	b.box(22,24,4,1,Color("f0c99a"))
	b.box(23,25,3,1,Color("dab084"))
	b.box(25,23,1,1,Color("f8d9ac"))
	var hands: Image = b.im
	# 前景风从腿前扫过，避开脸和双手，并在两侧逐渐收细。
	b.im = b.blank()
	b.poly([[5,31],[7,32],[12,32],[20,31],[29,29],[36,26],[39,23],[40,21],[41,23],[40,26],[37,28],[31,31],[22,33],[13,34],[8,34]],Color("acd0b3"))
	b.poly([[7,32],[13,32],[21,30],[29,28],[36,25],[39,22],[40,21],[39,25],[36,27],[29,30],[21,32],[13,33],[8,33]],Color("edf1d8"))
	b.poly([[10,37],[14,38],[21,38],[29,36],[35,33],[37,31],[37,33],[34,36],[29,38],[21,40],[15,40],[11,38]],Color("acd0b3"))
	b.stroke([[16,39],[22,39],[29,37],[33,35]],Color("edf1d8"),1)
	var front_wind: Image = b.im
	var layers := [["圆盘_青绿底色",base],["圆盘_高光阴影",rim],["风_后方环绕",rear_wind],["小人_躯干与双腿",clothes],["小人_脸与颈",head],["小人_头发与五官",hair],["小人_收拢双臂",arms],["小人_胸前结印双手",hands],["风_前景掠过",front_wind]]
	for i in range(2,layers.size()):
		for y in range(48):
			for x in range(48):
				if base.get_pixel(x,y).a == 0 or rim.get_pixel(x,y).a > 0: layers[i][1].set_pixel(x,y,Color.TRANSPARENT)
	var project = b.project_from_layers("清风纹章_小人结印与风_待审",layers)
	assert(OpenSave.save_pxo_file(out+"crest_clear_eye_color.pxo",false,project))
	var flat: Image = b.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(out+"crest_clear_eye_color.png") == OK)
	flat.resize(480,480,Image.INTERPOLATE_NEAREST)
	assert(flat.save_png(out+"crest_clear_eye_review.png") == OK)
	print("CLEAR_EYE_V1_SAVED: character hand seal and surrounding wind; teal backdrop")
