extends RefCounted
## Pixelorama native authoring: quartz cluster motif and directional badge rim.
const OUT = "/Users/a488/Documents/ChatGPT/16days/docs/art/crests/common-v4/"

func run() -> void:
	var b = load("res://author_pins.gd").new()
	DirAccess.make_dir_recursive_absolute(OUT)
	b.im = b.blank()
	b.disc(23.5,23.5,22.3,Color("8fa9a6"))
	var body = b.im
	b.im = b.blank()
	for y in range(48):
		for x in range(48):
			var dist = Vector2(x-23.5,y-23.5).length()
			if dist > 20.7 and dist <= 22.3:
				var c = Color("9db5ae")
				if y < 15: c = Color("c3d3c5")
				elif y > 32: c = Color("5c7779")
				elif y > 24: c = Color("78938f")
				b.im.set_pixel(x,y,c)
	var rim = b.im
	b.im = b.blank()
	# Three uneven crystal points; new drawing, not copied Minecraft pixels.
	b.poly([[19,35],[12,27],[10,16],[15,14],[22,23],[25,12],[31,8],[34,10],[31,27],[36,23],[39,25],[36,34],[27,40]],Color("536f70"))
	b.poly([[19,32],[14,26],[12,17],[15,16],[23,26],[23,35]],Color("bbc9ba"))
	b.poly([[12,17],[15,16],[20,23],[17,25]],Color("dce2cf"))
	b.poly([[24,34],[31,28],[36,25],[37,26],[34,33],[27,37]],Color("b3c3b5"))
	b.poly([[31,28],[36,25],[37,26],[33,30],[28,32]],Color("dce2cf"))
	b.poly([[20,34],[24,19],[26,13],[31,10],[32,11],[29,29],[25,37]],Color("cbd5c3"))
	b.poly([[24,19],[26,13],[31,10],[29,19],[24,32],[21,34]],Color("e3e6d4"))
	b.poly([[29,19],[32,11],[29,29],[25,37],[24,32]],Color("a4b7aa"))
	var motif = b.im
	var layers = [["灰青平色底盘",body],["上沿高光_下沿阴影",rim],["石英晶簇",motif]]
	var project = b.project_from_layers("crest_common_v4",layers)
	assert(OpenSave.save_pxo_file(OUT+"crest_common.pxo",false,project))
	var flat = b.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(OUT+"crest_common.png") == OK)
	print("COMMON_V4_SAVED")
