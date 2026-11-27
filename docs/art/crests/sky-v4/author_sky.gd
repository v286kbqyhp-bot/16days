extends RefCounted
## 作者授权试画的长袍圣天使。通过 Pixelorama 原生图层与保存接口制作待审稿。

func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	assert(not root.is_empty())
	var out := root+"/docs/art/crests/sky-v4/"
	var old = load("res://sky_previous.gd").new().read_layers(root+"/docs/art/crests/sky-v2/crest_sky_color.pxo")
	# 底端补齐像素属于下缘暗部，不能随底色重染。
	for x in range(20,28): old[1].set_pixel(x,46,Color("07539d"))
	var b = load("res://author_pins.gd").new()
	# 羽翼外轮廓是一像素冷灰，长羽从肩背向上外侧伸展。
	b.im = b.blank()
	b.poly([[23,23],[20,18],[16,15],[12,11],[9,8],[8,9],[8,14],[10,18],[7,15],[7,19],[10,23],[8,22],[10,26],[14,29],[19,30],[23,27]],Color("6c8d9f"))
	b.poly([[22,23],[19,19],[15,16],[11,12],[9,10],[9,14],[12,20],[8,17],[9,20],[13,25],[10,24],[12,27],[17,29],[20,28],[22,26]],Color("c6d6d5"))
	b.poly([[9,11],[12,14],[16,17],[19,20],[21,24],[18,23],[14,19],[11,16]],Color("fff6dc"))
	b.poly([[9,18],[12,21],[16,24],[19,25],[18,27],[14,25],[11,22]],Color("f3eedc"))
	b.poly([[12,25],[16,27],[20,28],[17,29],[14,27]],Color("fff6dc"))
	b.stroke([[12,16],[16,20],[19,22]],Color("e5dfc5"),1)
	b.poly([[18,20],[21,22],[23,25],[21,28],[19,28],[20,25]],Color("e5dfc5"))
	var left: Image = b.im
	b.im = b.blank()
	# 远侧翼稍高、略窄，避免完全镜像的僵硬姿态。
	b.poly([[26,23],[29,17],[33,13],[37,10],[40,7],[41,8],[40,14],[37,19],[41,15],[40,20],[37,24],[39,22],[38,26],[34,29],[29,29],[26,27]],Color("6c8d9f"))
	b.poly([[27,24],[30,18],[34,14],[38,11],[40,9],[39,14],[35,21],[40,17],[39,20],[35,25],[38,24],[36,27],[32,29],[28,27]],Color("b7cbce"))
	b.poly([[29,22],[32,17],[36,14],[39,11],[38,15],[34,21],[31,24]],Color("fff6dc"))
	b.poly([[30,25],[34,23],[38,19],[36,23],[33,26],[30,27]],Color("f3eedc"))
	b.poly([[29,27],[33,27],[36,25],[34,28],[31,29]],Color("e5dfc5"))
	b.stroke([[33,20],[36,16]],Color("e5dfc5"),1)
	var wings: Image = left
	wings.blend_rect(b.im,Rect2i(0,0,48,48),Vector2i.ZERO)
	# 宗教画的实心圆光，独立于人物和羽翼，方便作者修改。
	b.im = b.blank()
	b.disc(24.5,12.5,5.1,Color("a17839"))
	b.disc(24.5,12.5,4.2,Color("ebc65f"))
	b.disc(24.5,12.5,3.2,Color("ffe5a0"))
	b.stroke([[21,10],[22,9],[26,9]],Color("fff2c7"),1)
	var halo: Image = b.im
	# 躯干收窄，衣袍沿曲线向下飘，衣褶用连续色块表达。
	b.im = b.blank()
	b.poly([[23,18],[27,18],[29,21],[33,23],[33,27],[29,25],[27,27],[28,31],[30,35],[32,37],[28,39],[24,38],[20,40],[15,39],[18,36],[20,31],[21,27],[19,25],[16,27],[14,24],[19,21]],Color("708b9e"))
	b.poly([[23,19],[26,19],[28,22],[32,24],[32,26],[28,24],[26,26],[27,31],[29,35],[31,37],[28,38],[24,37],[20,39],[17,39],[20,35],[21,30],[22,26],[19,24],[16,26],[15,24],[20,22]],Color("eeeadd"))
	b.poly([[23,19],[25,20],[24,25],[23,28],[23,32],[20,37],[18,38],[20,34],[22,28],[21,25],[20,23]],Color("fff9e9"))
	b.poly([[25,21],[27,23],[26,27],[27,32],[29,36],[27,36],[25,32],[24,28]],Color("b4c5cd"))
	b.poly([[24,28],[25,32],[26,36],[28,38],[24,37],[23,38],[22,38],[23,34]],Color("fff9e9"))
	b.poly([[21,31],[22,29],[21,35],[19,38],[18,38]],Color("a1b8c6"))
	b.poly([[27,22],[30,24],[31,25],[28,24],[26,24]],Color("fff9e9"))
	b.poly([[18,23],[20,23],[19,24],[16,25]],Color("fff9e9"))
	var robe: Image = b.im
	# 小面积肤色：侧转的脸、颈部与向外舒展的手。
	b.im = b.blank()
	b.poly([[23,12],[26,12],[27,14],[28,15],[27,16],[26,18],[24,17],[23,15]],Color("bd8e66"))
	b.poly([[24,12],[26,13],[26,14],[27,15],[26,17],[24,16]],Color("f6dbad"))
	b.box(24,17,2,2,Color("dfb889"))
	b.box(24,18,1,1,Color("f6dbad"))
	b.poly([[14,23],[16,24],[16,25],[13,24],[12,22],[13,21],[13,23]],Color("d6a87a"))
	b.box(12,21,1,2,Color("f6dbad"))
	b.poly([[32,23],[34,22],[35,20],[36,20],[35,23],[33,25],[32,25]],Color("d6a87a"))
	b.stroke([[33,23],[34,22],[35,20]],Color("f6dbad"),1)
	var skin: Image = b.im
	# 赭金色卷发只保留几块明暗，面部不堆黑像素。
	b.im = b.blank()
	b.poly([[22,12],[23,10],[26,10],[27,12],[25,12],[24,13],[24,16],[23,18],[22,17],[22,15],[21,14]],Color("83603b"))
	b.box(23,11,3,1,Color("d2a55b"))
	b.box(22,12,2,2,Color("b88a49"))
	b.box(22,15,1,2,Color("b88a49"))
	b.box(26,14,1,1,Color("8c7056"))
	var hair: Image = b.im
	# 衣领与腰带的少量金色对应圆光，不增加武器、饰品或文字。
	b.im = b.blank()
	b.stroke([[23,19],[24,20],[26,19]],Color("c4a15c"),1)
	b.stroke([[22,27],[25,28],[26,27]],Color("c4a15c"),1)
	b.box(23,27,2,1,Color("ead29a"))
	var trim: Image = b.im
	var layers := [["蔚蓝天空_保留v2",old[0]],["圆盘明暗边_保留v2",old[1]],["背后白云_保留v2",old[2]],["圣天使_象牙白双翼",wings],["圣天使_金色圆光",halo],["圣天使_飘动长袍",robe],["圣天使_面部与手",skin],["圣天使_赭金头发",hair],["圣天使_衣领与腰带",trim],["下方白云_保留v2",old[7]]]
	for i in range(3,9):
		for y in range(48):
			for x in range(48):
				if old[0].get_pixel(x,y).a == 0 or old[1].get_pixel(x,y).a > 0:
					layers[i][1].set_pixel(x,y,Color.TRANSPARENT)
	var project = b.project_from_layers("天空纹章_长袍圣天使_待审",layers)
	assert(OpenSave.save_pxo_file(out+"crest_sky_color.pxo",false,project))
	var flat: Image = b.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(out+"crest_sky_color.png") == OK)
	flat.resize(480,480,Image.INTERPOLATE_NEAREST)
	assert(flat.save_png(out+"crest_sky_review.png") == OK)
	print("SKY_V4_SAVED: holy angel draft; 4 approved background layers preserved")
