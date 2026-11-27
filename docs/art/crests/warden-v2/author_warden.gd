extends RefCounted
## 作者指定：盾加宽、背景提亮、盾面压深。Pixelorama 原生分层样稿，待人工审核。
func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	assert(not root.is_empty())
	var out := root+"/docs/art/crests/warden-v2/"
	var maps = load("res://author_common.gd").new()
	maps.source = root+"/docs/art/crests/source/"
	var original: Array = maps.read_color_layers()
	var b = load("res://author_pins.gd").new()
	var base: Image = original[0].duplicate()
	var rim: Image = original[1].duplicate()
	# 只换颜色，圆盘及作者亲修底边的像素形状完全沿用。
	for y in range(48):
		for x in range(48):
			if base.get_pixel(x,y).a > 0: base.set_pixel(x,y,Color("1b1d24"))
			if rim.get_pixel(x,y).a > 0:
				match rim.get_pixel(x,y).to_html(false):
					"c3d3c5": rim.set_pixel(x,y,Color("636671"))
					"9db5ae": rim.set_pixel(x,y,Color("434650"))
					"78938f": rim.set_pixel(x,y,Color("2b2e37"))
					_: rim.set_pixel(x,y,Color("11131a"))
	# 沿用旧稿的尖底盾牌主轮廓，扩大为黑曜石完整块面。
	b.im = b.blank()
	b.poly([[24,10],[37,15],[35,28],[31,33],[24,39],[17,33],[13,28],[11,15]],Color("100f18"))
	var body: Image = b.im
	# 主切面保持接近黑色，仅用少量冷紫灰区分朝向。
	b.im = b.blank()
	b.poly([[24,11],[36,16],[33,28],[30,32],[24,37],[15,28],[12,16]],Color("191721"))
	b.poly([[24,11],[24,23],[19,30],[15,28],[12,16]],Color("272333"))
	b.poly([[24,11],[36,16],[31,24],[24,23]],Color("14121d"))
	b.poly([[31,24],[36,16],[33,28],[30,32],[24,37],[24,29]],Color("0a0a11"))
	b.poly([[24,23],[31,24],[24,29],[24,37],[19,30]],Color("1b1827"))
	b.poly([[15,28],[19,30],[24,37],[19,33]],Color("10101a"))
	var facets: Image = b.im
	# 贝壳状断面的斜切边；连续块面，不添加符号、宝石或金属装饰。
	b.im = b.blank()
	b.poly([[13,16],[23,12],[20,15],[16,18],[17,24],[16,26]],Color("373044"))
	b.poly([[17,17],[23,14],[22,18],[19,22],[17,25],[17,22],[19,18]],Color("221c30"))
	b.poly([[22,22],[24,20],[24,24],[20,29],[19,29]],Color("2f273e"))
	b.poly([[25,25],[31,24],[28,26],[25,29]],Color("241d31"))
	var cuts: Image = b.im
	# 一像素边缘，左上较亮，右下压暗；没有多圈描边。
	b.im = b.blank()
	b.stroke([[12,15],[23,11]],Color("5c536b"),1)
	b.stroke([[24,11],[35,15]],Color("3b314b"),1)
	b.stroke([[12,16],[15,27],[18,32]],Color("40364e"),1)
	b.stroke([[18,33],[24,38]],Color("26202f"),1)
	b.stroke([[36,16],[33,27]],Color("2b233a"),1)
	b.stroke([[33,28],[30,33],[25,37]],Color("1d1928"),1)
	var edge: Image = b.im
	# 玻璃质断口的局部亮面，留作独立可编辑层；动态扫光另行制作。
	b.im = b.blank()
	b.stroke([[16,15],[19,14]],Color("86798f"),1)
	b.box(13,17,1,2,Color("6a5e7a"))
	b.box(22,23,1,2,Color("51435f"))
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
	print("WARDEN_V2_SAVED: black background and obsidian shield; 7 editable layers")
