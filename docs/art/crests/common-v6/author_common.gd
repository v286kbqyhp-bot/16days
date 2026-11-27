extends RefCounted
## Pixelorama native authoring: quartz cluster motif and directional badge rim.
const OUT = "/Users/a488/Documents/ChatGPT/16days/docs/art/crests/common-v6/"

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
	b.box(18,46,12,1,Color("5c7779"))
	var rim = b.im
	b.im = b.blank()
	# Closely follow the compact, staggered, blunt-ended Nether Quartz silhouette.
	# Rear upper-left crystal: broad cap and straight faces, no leaf point.
	b.poly([[12,12],[19,12],[19,14],[22,14],[22,20],[24,20],[24,26],[19,28],[14,23],[12,22]],Color("83958c"))
	b.poly([[14,14],[19,14],[19,16],[21,16],[21,22],[16,22],[14,20]],Color("e4e6d8"))
	b.poly([[16,22],[21,22],[22,26],[19,28],[16,26]],Color("b2beab"))
	# Rear right crystal.
	b.poly([[29,20],[36,20],[38,22],[38,26],[35,31],[29,32]],Color("7a8d83"))
	b.poly([[30,22],[35,22],[36,23],[36,25],[30,25]],Color("e4e6d8"))
	b.poly([[30,25],[36,25],[34,29],[30,29]],Color("b9c4b2"))
	# Short front-left crystal, a distinct staggered termination.
	b.poly([[12,25],[17,25],[20,28],[23,29],[23,35],[20,39],[16,39],[13,36],[12,34]],Color("73867e"))
	b.poly([[13,27],[16,27],[19,30],[21,30],[21,33],[16,33],[13,30]],Color("e4e6d8"))
	b.poly([[14,31],[17,33],[21,33],[20,36],[17,37],[14,34]],Color("c2cbbb"))
	# Short front-right crystal, projecting only a little from the main mass.
	b.poly([[29,28],[38,28],[40,30],[40,34],[37,39],[32,40],[29,37]],Color("73867e"))
	b.poly([[31,30],[37,30],[38,31],[36,33],[31,33]],Color("e4e6d8"))
	b.poly([[31,33],[36,33],[35,37],[32,38]],Color("bcc6b4"))
	# Long central crystal leans slightly right and overlaps the short crystals.
	b.poly([[21,35],[21,24],[23,17],[25,12],[28,10],[28,8],[33,8],[33,14],[31,20],[31,29],[29,36],[27,40],[23,39]],Color("7a8d83"))
	b.poly([[23,32],[23,25],[25,19],[26,14],[29,11],[31,10],[31,14],[29,21],[27,29],[26,36],[24,37]],Color("e4e6d8"))
	b.poly([[29,21],[31,14],[30,28],[28,35],[27,38],[24,37],[26,30]],Color("b2beab"))
	var source = b.im
	var facets = b.blank()
	var outline = b.blank()
	for y in range(1,47):
		for x in range(1,47):
			var c = source.get_pixel(x,y)
			if c.a == 0: continue
			# Remove broad dark framing inside the silhouette; retain distinct cut faces.
			if c == Color("83958c") or c == Color("7a8d83") or c == Color("73867e"):
				c = Color("99aa96")
			if y >= 34:
				c = c.darkened(0.13)
			elif y >= 29:
				c = c.darkened(0.05)
			facets.set_pixel(x,y,c)
			# Exactly one 4-connected inner boundary layer, no dilation of the silhouette.
			var edge = false
			for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
				if source.get_pixel(x+d.x,y+d.y).a == 0: edge = true
			if edge:
				var edge_color = Color("789285")
				if y >= 34: edge_color = Color("425e54")
				elif y >= 24: edge_color = Color("627d70")
				outline.set_pixel(x,y,edge_color)
	# Bottom-facing cuts, kept within the existing approved silhouette.
	b.im = b.blank()
	b.poly([[14,34],[17,36],[20,35],[20,37],[18,39],[16,38]],Color("879780"))
	b.poly([[22,34],[25,36],[28,34],[28,37],[26,40],[23,39]],Color("879780"))
	b.poly([[31,35],[34,36],[38,34],[36,38],[33,40],[31,38]],Color("879780"))
	for y in range(48):
		for x in range(48):
			if source.get_pixel(x,y).a > 0 and b.im.get_pixel(x,y).a > 0:
				facets.set_pixel(x,y,b.im.get_pixel(x,y))
	var layers = [["灰青平色底盘",body],["上沿高光_下沿阴影",rim],["石英切面_下部暗面",facets],["石英一像素描边",outline]]
	var project = b.project_from_layers("crest_common_v6",layers)
	assert(OpenSave.save_pxo_file(OUT+"crest_common.pxo",false,project))
	var flat = b.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(OUT+"crest_common.png") == OK)
	print("COMMON_V6_SAVED")
