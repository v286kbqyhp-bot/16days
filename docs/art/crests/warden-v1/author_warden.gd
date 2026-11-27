extends RefCounted
## 作者指定：黑色背景、黑曜石盾。Pixelorama 原生分层样稿，待人工审核。
func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	assert(not root.is_empty())
	var out := root+"/docs/art/crests/warden-v1/"
	var maps = load("res://author_common.gd").new()
	maps.source = root+"/docs/art/crests/source/"
	var original: Array = maps.read_color_layers()
	var b = load("res://author_pins.gd").new()
	var base: Image = original[0].duplicate()
	var rim: Image = original[1].duplicate()
	# 只换颜色，圆盘及作者亲修底边的像素形状完全沿用。
	for y in range(48):
		for x in range(48):
			if base.get_pixel(x,y).a > 0: base.set_pixel(x,y,Color("07080b"))
			if rim.get_pixel(x,y).a > 0:
				match rim.get_pixel(x,y).to_html(false):
					"c3d3c5": rim.set_pixel(x,y,Color("535762"))
					"9db5ae": rim.set_pixel(x,y,Color("363a44"))
					"78938f": rim.set_pixel(x,y,Color("20232b"))
					_: rim.set_pixel(x,y,Color("11131a"))
	# 沿用旧稿的尖底盾牌主轮廓，扩大为黑曜石完整块面。
	b.im = b.blank()
	b.poly([[24,10],[35,15],[33,28],[30,33],[24,39],[18,33],[15,28],[13,15]],Color("171722"))
	var body: Image = b.im
	# 主切面保持接近黑色，仅用少量冷紫灰区分朝向。
	b.im = b.blank()
	b.poly([[24,11],[34,16],[32,28],[29,32],[24,37],[16,28],[14,16]],Color("252331"))
	b.poly([[24,11],[24,23],[20,30],[16,28],[14,16]],Color("383346"))
	b.poly([[24,11],[34,16],[30,24],[24,23]],Color("211e2c"))
	b.poly([[30,24],[34,16],[32,28],[29,32],[24,37],[24,29]],Color("14141e"))
	b.poly([[24,23],[30,24],[24,29],[24,37],[20,30]],Color("2b2839"))
	b.poly([[16,28],[20,30],[24,37],[20,33]],Color("1a1925"))
	var facets: Image = b.im
	# 贝壳状断面的斜切边；连续块面，不添加符号、宝石或金属装饰。
	b.im = b.blank()
	b.poly([[15,16],[23,12],[21,15],[17,18],[18,24],[17,26]],Color("4a4359"))
	b.poly([[18,17],[23,14],[22,18],[20,22],[18,25],[18,22],[20,18]],Color("302b3f"))
	b.poly([[22,22],[24,20],[24,24],[21,29],[20,29]],Color("423b53"))
	b.poly([[25,25],[30,24],[27,26],[25,29]],Color("353043"))
	var cuts: Image = b.im
	# 一像素边缘，左上较亮，右下压暗；没有多圈描边。
	b.im = b.blank()
	b.stroke([[14,15],[23,11]],Color("777082"),1)
	b.stroke([[24,11],[33,15]],Color("4f485f"),1)
	b.stroke([[14,16],[16,27],[19,32]],Color("555064"),1)
	b.stroke([[19,33],[24,38]],Color("35323f"),1)
	b.stroke([[34,16],[32,27]],Color("3f3a4f"),1)
	b.stroke([[32,28],[29,33],[25,37]],Color("292633"),1)
	var edge: Image = b.im
	# 玻璃质断口的局部亮面，留作独立可编辑层；动态扫光另行制作。
	b.im = b.blank()
	b.stroke([[17,15],[20,14]],Color("a49aaa"),1)
	b.box(15,17,1,2,Color("8a8095"))
	b.box(22,23,1,2,Color("736781"))
	var glints: Image = b.im
	# 斜向描线按盾牌轮廓裁切，避免转角多出孤立像素。
	for detail in [facets,cuts,edge,glints]:
		for y in range(48):
			for x in range(48):
				if body.get_pixel(x,y).a == 0: detail.set_pixel(x,y,Color.TRANSPARENT)
	var layers := [["黑色背景_原圆盘结构",base],["圆盘明暗边_原结构换色",rim],["黑曜石盾_轮廓底色",body],["黑曜石盾_主切面",facets],["黑曜石盾_断面",cuts],["黑曜石盾_单像素边缘",edge],["黑曜石盾_局部亮面",glints]]
	var project = b.project_from_layers("守望者纹章_黑曜石盾_待审",layers)
	assert(OpenSave.save_pxo_file(out+"crest_warden_color.pxo",false,project))
	var images := []
	for layer in layers: images.append(layer[1])
	var flat: Image = maps.composite(images)
	assert(flat.save_png(out+"crest_warden_color.png") == OK)
	flat.resize(480,480,Image.INTERPOLATE_NEAREST)
	assert(flat.save_png(out+"crest_warden_review.png") == OK)
	print("WARDEN_V1_SAVED: black background and obsidian shield; 7 editable layers")
