extends RefCounted
## 依据作者选定的枪尖回望骑士冲锋图，在 Pixelorama 中绘制待审样稿。
func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	var out := root + "/docs/art/crests/vanguard-v2/"
	var b = load("res://author_pins.gd").new()
	var maps = load("res://author_common.gd").new()
	maps.source = root + "/docs/art/crests/source/"
	var original: Array = maps.read_color_layers()
	var base: Image = original[0].duplicate()
	var rim: Image = original[1].duplicate()
	for y in range(48):
		for x in range(48):
			if base.get_pixel(x,y).a > 0: base.set_pixel(x,y,Color("6e91b7"))
			if rim.get_pixel(x,y).a > 0:
				match rim.get_pixel(x,y).to_html(false):
					"c3d3c5": rim.set_pixel(x,y,Color("dce5df"))
					"9db5ae": rim.set_pixel(x,y,Color("a6bec8"))
					"78938f": rim.set_pixel(x,y,Color("657d8e"))
					_: rim.set_pixel(x,y,Color("354956"))
	# 作者补齐的底端八像素归属圆盘阴影层，不能放入背景或主体层。
	for x in range(20,28): rim.set_pixel(x,46,Color("354956"))
	# 鱼眼视野的弧形云带与地平线。
	b.im = b.blank()
	b.poly([[5,18],[8,12],[13,8],[20,6],[29,6],[36,9],[40,14],[38,12],[33,9],[28,8],[20,8],[14,10],[10,14],[8,18]],Color("bdd1d9"))
	b.poly([[7,14],[10,10],[15,7],[20,6],[18,8],[13,10],[10,13]],Color("f1eddb"))
	b.poly([[29,6],[34,7],[38,10],[40,14],[37,12],[34,10],[30,9]],Color("f1eddb"))
	var clouds: Image = b.im
	b.im = b.blank()
	b.poly([[3,30],[8,26],[14,24],[24,23],[34,25],[42,30],[46,36],[43,44],[24,47],[6,42]],Color("9b947b"))
	b.poly([[4,33],[9,29],[15,27],[23,26],[34,28],[43,34],[40,43],[25,46],[8,41]],Color("c2af87"))
	var ground: Image = b.im
	# 披风与盔顶红缨沿后方展开，保持参考图的红银配色。
	b.im = b.blank()
	b.poly([[22,16],[16,13],[10,13],[7,16],[4,18],[10,17],[8,21],[15,19],[12,23],[21,21],[25,19]],Color("542e3a"))
	b.poly([[20,16],[15,14],[10,14],[7,16],[13,15],[11,18],[18,17],[15,20],[22,18]],Color("a34e4d"))
	b.stroke([[11,14],[15,14],[19,16]],Color("d58b6f"),1)
	b.poly([[23,10],[24,7],[21,5],[17,5],[14,7],[11,7],[14,9],[19,7],[22,8],[22,10]],Color("73383f"))
	b.stroke([[15,6],[19,5],[22,6],[23,7]],Color("bd6356"),1)
	var cloth: Image = b.im
	# 马胸、前腿与鞍布；前腿向镜头伸出而非静立。
	b.im = b.blank()
	b.poly([[27,23],[35,22],[39,28],[40,36],[37,42],[34,44],[30,43],[30,38],[26,35],[24,29]],Color("505761"))
	b.poly([[29,25],[34,24],[37,29],[38,36],[35,40],[32,40],[33,35],[29,33]],Color("c2c4b7"))
	b.poly([[34,32],[37,33],[37,37],[34,41],[30,43],[28,41],[32,37]],Color("e4dfc8"))
	b.poly([[30,40],[32,42],[30,44],[27,43]],Color("303b46"))
	b.poly([[27,30],[30,34],[28,38],[25,40],[23,38],[26,35]],Color("9aabaf"))
	b.poly([[24,37],[27,39],[25,41],[22,40]],Color("303b46"))
	var horse_body: Image = b.im
	b.im = b.blank()
	b.poly([[24,24],[29,26],[30,31],[28,35],[25,34],[22,37],[20,33],[22,28]],Color("652f3b"))
	b.poly([[24,26],[27,27],[28,30],[26,33],[23,35],[23,30]],Color("aa514d"))
	b.stroke([[23,35],[26,33],[28,34]],Color("c9a16d"),1)
	var saddle: Image = b.im
	# 骑士前倾的胸甲与持枪手臂。
	b.im = b.blank()
	b.poly([[20,15],[25,15],[29,18],[30,23],[27,27],[23,28],[20,26],[17,22],[16,18]],Color("293946"))
	b.poly([[21,17],[25,17],[28,19],[28,23],[25,26],[22,25],[20,22]],Color("7d3d45"))
	b.poly([[22,18],[24,18],[24,22],[27,22],[26,24],[23,24]],Color("bd8b65"))
	b.poly([[18,16],[21,17],[21,20],[18,22],[15,23],[13,21],[14,18]],Color("687e8d"))
	b.poly([[17,17],[19,17],[20,18],[17,19],[15,21],[14,20],[15,18]],Color("dce1d7"))
	b.stroke([[16,20],[18,19],[20,19]],Color("a7bac0"),1)
	b.poly([[26,17],[29,18],[31,22],[29,24],[28,21],[26,20]],Color("778b95"))
	b.stroke([[28,18],[29,20]],Color("dce1d7"),1)
	b.poly([[22,25],[25,26],[24,30],[21,34],[18,34],[19,30]],Color("384b5a"))
	b.poly([[22,27],[23,27],[22,30],[20,32],[19,32]],Color("9cabb1"))
	var armor: Image = b.im
	# 加大头盔明暗面与完整眼缝，删掉细碎装饰。
	b.im = b.blank()
	b.poly([[22,8],[26,8],[28,11],[29,15],[27,18],[24,20],[21,18],[19,14],[20,10]],Color("263a4a"))
	b.poly([[22,9],[25,9],[27,12],[27,14],[24,15],[21,13],[21,11]],Color("c3d1d2"))
	b.poly([[22,10],[24,9],[24,13],[22,13]],Color("f2f0dc"))
	b.poly([[21,15],[24,16],[27,15],[26,18],[24,19],[22,17]],Color("839baa"))
	b.stroke([[20,14],[23,15],[27,14]],Color("20313e"),1)
	b.stroke([[24,16],[24,18]],Color("c3d1d2"),1)
	var helmet: Image = b.im
	# 马鬃归并成连续大块，让白马与银甲之间留出暗色分界。
	b.im = b.blank()
	b.poly([[34,18],[31,15],[28,14],[29,18],[27,17],[28,22],[26,21],[28,28],[32,30],[35,25],[37,19]],Color("4f6572"))
	b.poly([[29,17],[32,19],[33,22],[31,25],[30,28],[29,25],[29,21]],Color("aabebf"))
	var mane: Image = b.im
	# 马耳、斜长的面部和前伸口鼻，保持白马特征。
	b.im = b.blank()
	b.poly([[32,20],[31,15],[32,13],[35,17],[36,17],[39,14],[39,20],[41,23],[40,27],[42,32],[41,35],[38,37],[35,35],[34,31],[31,27],[30,23]],Color("364652"))
	b.poly([[32,15],[34,18],[33,20]],Color("b5c1bd"))
	b.poly([[38,16],[38,20],[36,20]],Color("e3e2ce"))
	b.poly([[34,19],[37,19],[40,23],[38,27],[40,32],[40,34],[38,35],[36,32],[35,28],[32,25],[32,22]],Color("c4cbc4"))
	b.poly([[35,20],[37,20],[39,23],[37,27],[39,32],[38,33],[36,29],[35,26],[33,23]],Color("ede8d2"))
	b.poly([[32,24],[34,26],[35,30],[37,34],[38,35],[36,34],[35,31],[32,28]],Color("85999f"))
	b.poly([[38,31],[40,32],[40,34],[38,35],[36,33]],Color("9ba9a6"))
	var horse_head: Image = b.im
	# 去掉棋盘状面铠碎色，眼睛和缰绳成为马脸仅有的深色标记。
	b.im = b.blank()
	b.box(32,24,2,1,Color("233743"))
	b.stroke([[32,26],[35,28],[37,31],[40,32]],Color("625147"),1)
	b.stroke([[36,33],[39,34],[41,33]],Color("30434e"),1)
	b.box(38,32,1,1,Color("30434e"))
	b.stroke([[32,27],[30,27],[28,23]],Color("625147"),1)
	var horse_tack: Image = b.im
	# 骑士骑枪：握持处护手盘，连续长锥枪身，近处只有短小金属枪尖。
	# 取消 v1 的宽刃银色矛头，红白漆面沿枪身连续延伸。
	b.im = b.blank()
	b.poly([[17,23],[21,24],[24,28],[21,32],[7,43],[10,36],[13,30]],Color("4c3440"))
	b.poly([[17,25],[20,25],[22,28],[20,31],[9,40],[12,34],[14,30]],Color("f1e4c7"))
	b.poly([[20,26],[22,28],[20,31],[9,41],[13,36],[18,31]],Color("b8a99b"))
	b.poly([[15,28],[17,26],[21,28],[21,30],[19,31],[17,29]],Color("c2574b"))
	b.poly([[12,34],[14,31],[17,33],[15,35]],Color("c2574b"))
	b.poly([[10,37],[11,35],[13,36],[11,38]],Color("c2574b"))
	var lance: Image = b.im
	b.im = b.blank()
	b.poly([[15,20],[18,20],[20,22],[18,24],[15,24],[14,22]],Color("2d4352"))
	b.poly([[15,21],[17,21],[18,22],[17,23],[15,22]],Color("dce3d7"))
	var gauntlet: Image = b.im
	b.im = b.blank()
	b.poly([[17,23],[19,22],[23,25],[25,28],[24,30],[22,29],[20,26]],Color("2d4352"))
	b.poly([[18,23],[19,23],[22,25],[24,28],[23,28],[21,26]],Color("aebfc5"))
	b.stroke([[19,23],[21,24],[23,26]],Color("ecebd7"),1)
	var guard: Image = b.im
	b.im = b.blank()
	b.poly([[9,38],[12,39],[7,43]],Color("526b7c"))
	b.poly([[9,39],[10,39],[7,43]],Color("e4e9d9"))
	var lance_head: Image = b.im
	var layers := [["圆盘_蓝天底色",base],["圆盘_高光阴影",rim],["背景_弧形云带",clouds],["背景_弧形地面",ground],["骑士_披风与红缨",cloth],["战马_胸与前腿",horse_body],["战马_红色鞍布",saddle],["骑士_胸甲与持枪臂",armor],["骑士_银盔与面甲",helmet],["战马_飞扬鬃毛",mane],["战马_白马头部",horse_head],["战马_眼睛与缰绳",horse_tack],["骑枪_红白长锥枪身",lance],["骑士_握枪手甲",gauntlet],["骑枪_金属护手盘",guard],["骑枪_短金属枪尖",lance_head]]
	# 通过名称定位边框；所有背景和主体均须避开边框与圆盘外透明区。
	var rim_index := -1
	for i in range(layers.size()):
		if layers[i][0] == "圆盘_高光阴影": rim_index = i
	assert(rim_index >= 0)
	for i in range(1,layers.size()):
		if i == rim_index: continue
		for y in range(48):
			for x in range(48):
				if base.get_pixel(x,y).a == 0 or layers[rim_index][1].get_pixel(x,y).a > 0:
					layers[i][1].set_pixel(x,y,Color.TRANSPARENT)
	var project = b.project_from_layers("先锋纹章_枪尖回望骑士冲锋_待审",layers)
	assert(OpenSave.save_pxo_file(out+"crest_vanguard_color.pxo",false,project))
	var flat: Image = b.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(out+"crest_vanguard_color.png") == OK)
	flat.resize(480,480,Image.INTERPOLATE_NEAREST)
	assert(flat.save_png(out+"crest_vanguard_review.png") == OK)
	print("VANGUARD_V2_SAVED")
