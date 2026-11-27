extends RefCounted
## Pixelorama 原生静态样稿。作者认可 v2 背景，本版只替换天使为展翼飞翔姿态。

func read_layers(path: String) -> Array:
	var zip := ZIPReader.new()
	assert(zip.open(path) == OK)
	var data = JSON.parse_string(zip.read_file("data.json").get_string_from_utf8())
	var result := []
	for i in range(data.layers.size()):
		var cel = data.frames[0].cels[i]
		var size: Vector2i = str_to_var(cel.image_size)
		var offset: Vector2 = str_to_var("Vector2"+cel.offset)
		var im := Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGBA8,zip.read_file("image_data/frames/1/layer_%d" % (i+1)))
		var canvas := Image.create(48,48,false,Image.FORMAT_RGBA8)
		canvas.blit_rect(im,Rect2i(Vector2i.ZERO,size),Vector2i(offset))
		result.append(canvas)
	zip.close()
	return result

func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	assert(not root.is_empty())
	var out := root+"/docs/art/crests/sky-v3/"
	var old := read_layers(root+"/docs/art/crests/sky-v2/crest_sky_color.pxo")
	var b = load("res://author_pins.gd").new()
	# 双翼从肩背向左右张开，分开的长羽保持轮廓可读。
	b.im = b.blank()
	b.poly([[23,21],[19,17],[15,14],[10,11],[6,11],[7,15],[10,19],[6,17],[7,21],[11,24],[8,23],[10,27],[15,30],[20,29],[23,25]],Color("1e344c"))
	b.poly([[7,12],[10,12],[15,15],[19,19],[21,23],[19,25],[16,22],[12,19],[9,15]],Color("527c91"))
	b.poly([[8,13],[10,13],[14,16],[18,20],[19,22],[16,20],[12,17]],Color("83a8b5"))
	b.poly([[8,19],[12,21],[16,23],[19,25],[18,27],[14,25],[10,23]],Color("527c91"))
	b.poly([[11,25],[15,27],[19,28],[16,29],[13,27]],Color("355e78"))
	b.poly([[18,19],[21,21],[22,24],[21,27],[18,27],[19,24]],Color("355e78"))
	var half: Image = b.im
	var wing: Image = b.blank()
	for y in range(48):
		for x in range(24):
			if half.get_pixel(x,y).a > 0:
				wing.set_pixel(x,y,half.get_pixel(x,y))
				wing.set_pixel(47-x,y,half.get_pixel(x,y))
	# 身体悬在两翼中间；双臂向外伸展，腿部一伸一屈以显示腾空。
	b.im = b.blank()
	b.poly([[22,13],[26,13],[27,15],[26,18],[25,19],[22,18],[21,16]],Color("cc8c58"))
	b.poly([[22,14],[25,14],[26,15],[25,18],[23,18],[22,16]],Color("f5d39a"))
	b.box(23,18,2,2,Color("e8b77c"))
	b.poly([[21,19],[26,19],[28,22],[27,26],[26,29],[22,29],[20,25],[20,21]],Color("cc8c58"))
	b.poly([[21,20],[24,20],[25,23],[24,27],[22,27],[21,24]],Color("f1c78c"))
	b.poly([[25,21],[27,21],[26,25],[25,28],[24,27],[25,24]],Color("e8b77c"))
	# 左右手位于羽翼前方，肤色与羽片明显区分。
	b.poly([[21,20],[22,23],[19,25],[16,25],[13,23],[13,21],[15,21],[17,23],[19,23]],Color("cc8c58"))
	b.poly([[20,21],[21,22],[18,24],[16,24],[14,22],[15,22],[17,23]],Color("f5d39a"))
	b.poly([[26,20],[28,21],[30,23],[32,22],[33,20],[35,20],[35,23],[32,25],[29,25],[27,23]],Color("cc8c58"))
	b.poly([[27,21],[28,22],[30,24],[32,23],[33,21],[34,21],[33,24],[30,25]],Color("f1c78c"))
	# 长腿向下，另一腿后屈；脚与下方云层间保留蓝天空隙。
	b.poly([[23,32],[26,32],[26,35],[25,38],[25,40],[22,41],[21,40],[23,38],[23,35]],Color("cc8c58"))
	b.poly([[24,33],[25,33],[25,36],[24,38],[23,39],[23,37]],Color("f5d39a"))
	b.poly([[21,31],[23,33],[21,36],[18,37],[16,36],[16,34],[18,35],[20,34]],Color("cc8c58"))
	b.poly([[21,32],[22,33],[20,35],[18,36],[17,35],[19,35]],Color("f1c78c"))
	var body: Image = b.im
	b.im = b.blank()
	b.poly([[21,12],[22,11],[25,11],[27,12],[27,15],[26,16],[25,13],[23,13],[22,15],[21,16],[20,14]],Color("674231"))
	b.box(22,12,2,1,Color("c3833c"))
	b.box(25,12,1,1,Color("a86732"))
	b.box(21,13,1,1,Color("a86732"))
	b.box(25,15,1,1,Color("674231"))
	var hair: Image = b.im
	# 沿用深蓝布料，衣摆随飞行向左下偏出。
	b.im = b.blank()
	b.poly([[21,27],[26,27],[27,30],[26,33],[24,35],[21,34],[18,33],[20,31]],Color("183d81"))
	b.poly([[21,28],[23,28],[22,31],[21,33],[19,32]],Color("4674b9"))
	b.poly([[24,28],[26,28],[26,31],[24,34],[23,33]],Color("6088c5"))
	b.poly([[23,28],[24,28],[23,31],[23,34],[22,33]],Color("11295e"))
	var cloth: Image = b.im
	var layers := [["蔚蓝天空_保留v2",old[0]],["圆盘明暗边_保留v2",old[1]],["背后白云_保留v2",old[2]],["天使_展开双翼",wing],["天使_飞翔身体与四肢",body],["天使_头发与面部",hair],["天使_飘动蓝布",cloth],["下方白云_保留v2",old[7]]]
	for i in range(3,7):
		for y in range(48):
			for x in range(48):
				if old[0].get_pixel(x,y).a == 0 or old[1].get_pixel(x,y).a > 0:
					layers[i][1].set_pixel(x,y,Color.TRANSPARENT)
	var project = b.project_from_layers("天空纹章_展翼飞翔_待审",layers)
	assert(OpenSave.save_pxo_file(out+"crest_sky_color.pxo",false,project))
	var flat: Image = b.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(out+"crest_sky_color.png") == OK)
	flat.resize(480,480,Image.INTERPOLATE_NEAREST)
	assert(flat.save_png(out+"crest_sky_review.png") == OK)
	print("SKY_V3_SAVED: spread-wing flying angel; 4 background layers preserved")
