extends RefCounted
## Pixelorama 1.2.4 原生分层静态样稿：依据作者蓝天白云／侧坐天使参考。
## 仅供人工审阅；不生成法线，不替换正式游戏资产。
var out: String

func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	assert(not root.is_empty())
	out = root+"/docs/art/crests/sky-v2/"
	var maps = load("res://author_common.gd").new()
	maps.source = root+"/docs/art/crests/source/"
	var original: Array = maps.read_color_layers()
	var b = load("res://author_pins.gd").new()
	var base: Image = original[0].duplicate()
	var rim: Image = original[1].duplicate()
	for y in range(48):
		for x in range(48):
			if base.get_pixel(x,y).a > 0: base.set_pixel(x,y,Color("159cf2"))
			if rim.get_pixel(x,y).a > 0:
				match rim.get_pixel(x,y).to_html(false):
					"c3d3c5": rim.set_pixel(x,y,Color("91dfff"))
					"9db5ae": rim.set_pixel(x,y,Color("46bbfa"))
					"78938f": rim.set_pixel(x,y,Color("167dc8"))
					_: rim.set_pixel(x,y,Color("07539d"))
	# 云朵以数个大块面陪衬，不沿整个圆盘铺满。与天空和天使分层。
	b.im = b.blank()
	b.poly([[5,17],[6,17],[6,14],[8,14],[8,12],[10,12],[10,10],[14,10],[14,11],[16,11],[16,13],[18,13],[18,15],[21,15],[21,16],[23,16],[23,20],[20,20],[20,21],[7,21],[7,20],[5,20]],Color("f5fcff"))
	b.poly([[4,20],[8,18],[11,18],[13,15],[16,15],[18,17],[22,17],[24,19],[21,21],[15,22],[8,22]],Color("bcdfee"))
	b.poly([[6,20],[10,20],[12,19],[14,20],[19,19],[22,19],[20,21],[13,22],[6,22]],Color("83bbdc"))
	b.poly([[28,14],[30,14],[30,11],[32,11],[32,9],[33,9],[33,8],[36,8],[36,9],[38,9],[38,11],[40,11],[40,13],[42,13],[42,15],[43,15],[43,18],[38,19],[31,18],[28,18]],Color("f5fcff"))
	b.poly([[28,16],[32,15],[33,13],[36,13],[38,15],[42,15],[43,18],[38,19],[33,18],[28,18]],Color("bcdfee"))
	b.poly([[34,18],[37,17],[40,17],[42,16],[43,18],[38,19]],Color("83bbdc"))
	var clouds: Image = b.im
	# 参考人物左侧上举的大翼，保留整体轮廓、羽片间的一像素间隙。
	b.im = b.blank()
	b.poly([[15,6],[18,8],[20,12],[21,17],[20,23],[20,30],[18,35],[14,36],[11,32],[9,26],[9,20],[11,13]],Color("1e344c"))
	b.poly([[15,8],[16,9],[14,15],[13,23],[14,29],[16,33],[14,34],[11,29],[10,23],[12,15]],Color("355e78"))
	b.poly([[16,11],[18,13],[17,20],[16,25],[18,31],[17,34],[14,29],[14,23]],Color("527c91"))
	b.poly([[18,16],[20,18],[19,25],[20,29],[18,33],[17,29],[17,24]],Color("83a8b5"))
	b.poly([[12,17],[13,16],[12,24],[14,30],[14,32],[11,27],[11,22]],Color("223f58"))
	var wing: Image = b.im
	# 肤色：头部、低头的颈肩、胸腹、抬起的手臂和弯曲的腿。
	b.im = b.blank()
	b.poly([[21,13],[25,12],[27,14],[27,17],[25,20],[22,18],[20,16]],Color("cc8c58"))
	b.poly([[22,14],[25,13],[26,14],[26,17],[24,18],[22,17]],Color("f5d39a"))
	b.poly([[21,18],[24,19],[25,23],[24,27],[26,31],[24,34],[18,32],[16,28],[16,23],[18,20]],Color("dba26a"))
	b.poly([[18,21],[21,20],[23,22],[23,26],[21,29],[18,28],[17,25]],Color("f1c78c"))
	b.poly([[22,23],[24,23],[23,28],[25,31],[22,32],[20,29]],Color("b8764d"))
	# 抬臂横在脸前，末端相扣；不额外加入光环或武器。
	b.poly([[18,20],[20,18],[23,19],[26,21],[29,20],[31,16],[33,15],[35,17],[33,22],[30,25],[25,25],[21,23],[18,23]],Color("bb7c4e"))
	b.poly([[19,20],[21,19],[25,21],[29,22],[31,19],[33,17],[34,18],[32,22],[29,24],[25,23],[21,22]],Color("f1c78c"))
	b.box(31,16,1,3,Color("f7d9a2"))
	b.box(33,16,1,2,Color("f7d9a2"))
	# 膝部在身体右侧抬起，胫部向右下延伸。
	b.poly([[25,31],[27,28],[29,25],[32,24],[35,26],[36,29],[35,33],[38,35],[39,38],[36,39],[32,36],[30,33],[27,35]],Color("cf915b"))
	b.poly([[28,29],[30,26],[32,25],[34,27],[34,30],[32,33],[31,35],[29,32],[27,32]],Color("f5d39a"))
	b.poly([[33,33],[35,34],[38,37],[37,38],[34,37],[31,35]],Color("e8b77c"))
	var body: Image = b.im
	# 卷发与低头面部，暗轮廓不超过一层。
	b.im = b.blank()
	b.poly([[20,12],[21,10],[24,10],[25,11],[27,11],[28,13],[27,15],[25,15],[24,13],[22,14],[21,16],[19,15]],Color("674231"))
	b.box(21,11,2,2,Color("a86732"))
	b.box(24,12,2,1,Color("c3833c"))
	b.box(20,13,2,1,Color("a86732"))
	b.box(25,15,2,1,Color("674231"))
	b.box(25,16,1,1,Color("423d3c"))
	var hair: Image = b.im
	# 深蓝布料包住腰腿，蓝天与布料以明度区分。
	b.im = b.blank()
	b.poly([[18,29],[21,30],[25,30],[28,32],[29,35],[31,38],[28,40],[23,41],[19,39],[17,35]],Color("183d81"))
	b.poly([[18,30],[20,31],[20,35],[22,39],[20,38],[18,35]],Color("4674b9"))
	b.poly([[22,31],[24,31],[23,35],[25,39],[23,40],[21,36]],Color("315da8"))
	b.poly([[25,32],[27,33],[27,36],[29,38],[27,39],[25,36]],Color("6088c5"))
	b.poly([[23,32],[24,32],[23,35],[24,38],[23,39],[22,35]],Color("11295e"))
	var cloth: Image = b.im
	# 下方白云托住人物，保留足够蓝天负空间。
	b.im = b.blank()
	b.poly([[6,34],[9,32],[12,33],[14,35],[17,35],[19,38],[19,40],[14,42],[10,40],[7,38]],Color("f5fcff"))
	b.poly([[7,37],[10,36],[13,37],[16,37],[19,39],[17,41],[13,42],[9,39]],Color("bcdfee"))
	b.poly([[29,40],[32,38],[35,39],[36,37],[39,37],[41,39],[38,42],[32,44],[28,43]],Color("f5fcff"))
	b.poly([[29,42],[33,41],[36,42],[40,40],[38,43],[32,44],[28,43]],Color("bcdfee"))
	var lower_clouds: Image = b.im
	var layers := [["蔚蓝天空",base],["圆盘明暗边_原结构换色",rim],["背后白云_冷蓝暗面",clouds],["天使_深色羽翼",wing],["天使_侧坐身体与抬臂",body],["天使_头发与面部",hair],["天使_深蓝布料",cloth],["下方白云",lower_clouds]]
	# 所有画面层裁切到原圆盘内，并保留原包边，禁止脏出透明轮廓。
	for i in range(2,layers.size()):
		for y in range(48):
			for x in range(48):
				if base.get_pixel(x,y).a == 0 or rim.get_pixel(x,y).a > 0:
					layers[i][1].set_pixel(x,y,Color.TRANSPARENT)
	var project = b.project_from_layers("天空纹章_蓝天白云天使_待审",layers)
	assert(OpenSave.save_pxo_file(out+"crest_sky_color.pxo",false,project))
	var images := []
	for layer in layers: images.append(layer[1])
	var flat: Image = maps.composite(images)
	assert(flat.save_png(out+"crest_sky_color.png") == OK)
	flat.resize(480,480,Image.INTERPOLATE_NEAREST)
	assert(flat.save_png(out+"crest_sky_review.png") == OK)
	print("SKY_V2_SAVED: 8 editable layers; static art review only")
