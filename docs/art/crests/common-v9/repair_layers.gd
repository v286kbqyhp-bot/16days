extends RefCounted
const ROOT = "/Users/a488/Documents/ChatGPT/16days/docs/art/crests/"
const OUT = ROOT + "common-v9/"

func run() -> void:
	var helper = load("res://author_pins.gd").new()
	DirAccess.make_dir_recursive_absolute(OUT)
	var body = Image.load_from_file(ROOT+"layer-review-20261127/before-layer-1.png")
	var rim = Image.load_from_file(ROOT+"layer-review-20261127/before-layer-2.png")
	var facets = Image.load_from_file(ROOT+"layer-review-20261127/before-layer-3.png")
	body.set_pixel(19,27,Color("8fa9a6"))
	# Fill the accidental enclosed one-pixel hole; preserve the exterior contour.
	facets.set_pixel(20,27,Color("99aa96"))
	for y in range(48):
		for x in range(48):
			var c = facets.get_pixel(x,y)
			if c.a == 0: continue
			var value = c.r8+c.g8+c.b8
			var clean = Color("879780")
			if value >= 620: clean = Color("e4e6d8")
			elif value >= 530: clean = Color("bec8b3")
			elif value >= 440: clean = Color("99aa96")
			facets.set_pixel(x,y,clean)
	var outline = helper.blank()
	for y in range(1,47):
		for x in range(1,47):
			if facets.get_pixel(x,y).a == 0: continue
			var edge = false
			for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
				if facets.get_pixel(x+d.x,y+d.y).a == 0: edge = true
			if edge:
				var c = Color("789285")
				if y >= 34: c = Color("425e54")
				elif y >= 24: c = Color("627d70")
				outline.set_pixel(x,y,c)
	var layers = [["底盘_单一底色",body],["圆盘边缘_高光阴影",rim],["石英切面_四阶色",facets],["石英外描边_一像素",outline]]
	var project = helper.project_from_layers("crest_common",layers)
	project.current_layer = 2
	project.selected_cels = [[0,2]]
	assert(OpenSave.save_pxo_file(OUT+"crest_common.pxo",false,project))
	var flat = helper.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(OUT+"crest_common.png") == OK)
	print("ALL_FOUR_LAYERS_REPAIRED")
