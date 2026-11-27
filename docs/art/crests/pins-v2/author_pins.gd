extends RefCounted
## AI-assisted draft authoring, executed inside Pixelorama 1.2.4.
const OUT = "/Users/a488/Documents/ChatGPT/16days/docs/art/crests/pins-v2/"
const ITEMS = [
	["common", "普通", "69777d", "ddd8c6", "a4b9b6"],
	["sky", "天空", "397ba4", "f8efce", "a9dce4"],
	["warden", "守望者", "28686b", "e9deb0", "7bd1c2"],
	["veteran", "老兵", "795047", "e7c48a", "b89167"],
	["clear_eye", "清风", "598d7e", "edf1c6", "b2dfba"],
	["vanguard", "先锋", "b25d36", "fff0bd", "e7ab5c"],
	["ambush", "奇袭", "574364", "f2d6aa", "c78c9e"],
	["hit_and_run", "游击", "417049", "f0e1ab", "a3c875"],
	["phantom", "疾影", "61528b", "e7dcfa", "ad9ede"],
	["turret", "重炮", "715443", "e7c995", "bd9670"],
	["armor", "重甲", "405c75", "c4d9d7", "819fb6"],
	["pulse_heal", "震荡", "297c7b", "e4efcb", "93d3b9"],
	["claw", "狂猎", "943d3f", "f5d5a4", "e79b75"],
	["ember_body", "熔岩", "713735", "f9b352", "f06a3e"],
	["arrogance", "狂傲", "84476d", "f8d887", "d47b85"],
	["mender", "抚慰", "5e8866", "f6e9c1", "b4d995"],
	["bloodlust", "嗜血", "653747", "ed716b", "ffd098"]
]
var im: Image
var ink: Color
var accent: Color

func blank(w = 48, h = 48) -> Image:
	return Image.create(w, h, false, Image.FORMAT_RGBA8)

func box(x: int, y: int, w: int, h: int, c: Color) -> void:
	im.fill_rect(Rect2i(x, y, w, h), c)

func poly(points: Array, c: Color) -> void:
	var p = PackedVector2Array()
	for v in points: p.append(Vector2(v[0], v[1]))
	for y in range(im.get_height()):
		for x in range(im.get_width()):
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), p): im.set_pixel(x, y, c)

func disc(cx: float, cy: float, r: float, c: Color) -> void:
	for y in range(im.get_height()):
		for x in range(im.get_width()):
			if Vector2(x - cx, y - cy).length_squared() <= r*r: im.set_pixel(x, y, c)

func stroke(points: Array, c: Color, width = 2) -> void:
	for i in range(points.size()-1):
		var a = Vector2(points[i][0], points[i][1])
		var b = Vector2(points[i+1][0], points[i+1][1])
		var steps = int(max(abs(b.x-a.x), abs(b.y-a.y)))
		for n in range(steps+1):
			var v = a.lerp(b, float(n)/max(1, steps)).round()
			box(int(v.x), int(v.y), width, width, c)

func symbol(key: String) -> Image:
	im = blank()
	match key:
		"common":
			poly([[24,13],[27,20],[34,23],[27,26],[24,34],[21,26],[14,23],[21,20]], ink)
			box(23,21,2,5,accent)
		"sky":
			poly([[22,22],[17,17],[11,14],[12,23],[16,29],[21,31],[23,27]], ink)
			poly([[26,22],[31,17],[37,14],[36,23],[32,29],[27,31],[25,27]], ink)
			stroke([[13,22],[18,25]],accent)
			stroke([[34,22],[29,25]],accent)
			poly([[24,20],[27,25],[24,29],[21,25]],accent)
		"warden":
			poly([[24,11],[35,16],[33,29],[24,37],[15,29],[13,16]],ink)
			poly([[24,15],[31,18],[30,27],[24,32],[18,27],[17,18]],accent)
			poly([[24,18],[27,23],[24,28],[21,23]],ink)
		"veteran":
			poly([[15,25],[15,18],[20,13],[28,13],[33,18],[33,29],[27,29],[27,34],[21,34],[21,27]],ink)
			box(16,21,17,3,Color("302f36"))
			box(23,15,3,17,accent)
			stroke([[12,28],[14,33],[18,36]],accent)
			stroke([[35,28],[33,33],[29,36]],accent)
		"clear_eye":
			stroke([[12,18],[27,18],[30,15],[29,12],[26,12]],ink)
			stroke([[10,24],[34,24],[37,21],[36,18],[33,18]],ink)
			stroke([[14,30],[26,30],[29,33],[28,36],[25,36]],ink)
			box(11,34,2,2,accent)
			box(16,36,2,2,accent)
		"vanguard":
			poly([[24,9],[31,19],[26,18],[26,36],[22,36],[22,18],[17,19]],ink)
			poly([[13,25],[19,20],[19,25],[13,30]],accent)
			poly([[35,25],[29,20],[29,25],[35,30]],accent)
			box(21,31,6,2,accent)
		"ambush":
			poly([[25,11],[35,17],[37,29],[30,34],[18,34],[11,29],[13,17],[21,11]],accent)
			poly([[18,18],[30,18],[32,26],[27,29],[20,29],[16,25]],Color("302333"))
			box(19,22,3,2,ink)
			box(27,22,3,2,ink)
			poly([[30,14],[33,12],[32,25],[24,33],[21,30]],ink)
			stroke([[20,28],[25,33]],accent)
		"hit_and_run":
			poly([[27,11],[33,11],[33,17],[23,27],[20,24]],ink)
			stroke([[18,23],[25,30]],accent)
			stroke([[19,28],[15,32]],ink,3)
			stroke([[32,25],[32,33],[27,36],[21,36]],accent)
			poly([[16,36],[23,32],[23,40]],accent)
		"phantom":
			box(17,13,4,10,accent)
			box(17,29,4,6,accent)
			box(27,13,4,10,accent)
			box(27,29,4,6,accent)
			poly([[11,24],[30,24],[30,19],[38,26],[30,33],[30,28],[11,28]],ink)
			box(8,24,2,4,ink)
		"turret":
			poly([[14,16],[20,14],[24,28],[18,30]],ink)
			poly([[27,14],[33,16],[29,30],[23,28]],ink)
			stroke([[14,16],[19,15]],Color("302f36"),2)
			stroke([[28,15],[32,16]],Color("302f36"),2)
			box(17,28,14,5,accent)
			box(13,33,22,3,ink)
			box(16,36,4,2,accent)
			box(28,36,4,2,accent)
		"armor":
			poly([[17,12],[22,15],[26,15],[31,12],[36,20],[31,23],[31,34],[24,37],[17,34],[17,23],[12,20]],ink)
			poly([[19,21],[24,24],[29,21],[29,27],[24,30],[19,27]],accent)
			poly([[19,29],[24,32],[29,29],[29,33],[24,35],[19,33]],accent)
			box(23,17,2,5,accent)
		"pulse_heal":
			box(21,18,6,14,ink)
			box(17,22,14,6,ink)
			poly([[24,9],[29,15],[19,15]],accent)
			poly([[24,40],[29,34],[19,34]],accent)
			poly([[8,25],[14,20],[14,30]],accent)
			poly([[40,25],[34,20],[34,30]],accent)
		"claw":
			poly([[18,11],[16,21],[13,29],[12,35],[18,30],[22,18]],ink)
			poly([[26,10],[24,20],[21,29],[19,37],[25,31],[30,17]],ink)
			poly([[34,13],[32,23],[29,30],[27,36],[33,31],[37,20]],ink)
		"ember_body":
			poly([[15,14],[27,11],[35,19],[34,31],[25,37],[14,32],[11,22]],Color("332d38"))
			stroke([[22,13],[24,20],[20,25],[25,29],[23,35]],ink,2)
			stroke([[24,20],[32,18]],accent,2)
			stroke([[20,25],[13,24]],accent,2)
			stroke([[25,29],[32,31]],accent,2)
			box(25,28,2,2,Color("ffe2a4"))
		"arrogance":
			poly([[12,16],[19,22],[24,13],[29,22],[36,16],[33,31],[15,31]],ink)
			box(15,33,18,3,ink)
			poly([[24,23],[27,27],[24,31],[21,27]],accent)
			disc(12,14,1.6,ink)
			disc(24,11,1.6,ink)
			disc(36,14,1.6,ink)
		"mender":
			box(22,12,5,13,accent)
			box(18,16,13,5,accent)
			poly([[11,23],[14,23],[17,29],[22,31],[22,35],[16,34],[11,29]],ink)
			poly([[37,23],[34,23],[31,29],[26,31],[26,35],[32,34],[37,29]],ink)
			box(22,33,4,4,ink)
		"bloodlust":
			poly([[23,11],[28,20],[31,27],[29,33],[23,37],[17,34],[14,28],[16,22]],ink)
			poly([[29,24],[35,18],[40,24],[36,24],[36,33],[32,33],[32,24]],accent)
			stroke([[19,26],[19,30],[22,32]],accent)
	# One-pixel outline belongs to the symbol layer, not baked illumination.
	var core = im
	var outlined = blank()
	for y in range(1,47):
		for x in range(1,47):
			if core.get_pixel(x,y).a > 0:
				for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					outlined.set_pixel(x+d.x,y+d.y,Color("292b35"))
	outlined.blend_rect(core,Rect2i(0,0,48,48),Vector2i.ZERO)
	return outlined

func project_from_layers(title: String, layers: Array, size = Vector2i(48,48)) -> Project:
	var project = Project.new([],title,size)
	Global.projects.append(project)
	var frame = Frame.new()
	for n in range(layers.size()):
		var layer = PixelLayer.new(project,layers[n][0])
		layer.index = n
		project.layers.append(layer)
		frame.cels.append(layer.new_cel_from_image(layers[n][1]))
	project.frames.append(frame)
	return project

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var sheet_layers = []
	for n in range(ITEMS.size()):
		var item = ITEMS[n]
		ink = Color(item[3]); accent = Color(item[4])
		im = blank()
		disc(23.5,23.5,22.5,Color("252932"))
		var backing = im
		im = blank()
		disc(23.5,23.5,21.3,Color("a88b61") if n else Color("9aa7a8"))
		disc(23.5,23.5,19.7,Color("38363d"))
		var rim = im
		im = blank()
		disc(23.5,23.5,18.7,Color(item[2]))
		var face = im
		var motif = symbol(item[0])
		var layers = [["底盘轮廓",backing],["金属包边",rim],["纯色印刷底",face],["能力图案",motif]]
		var project = project_from_layers("crest_"+item[0],layers)
		assert(OpenSave.save_pxo_file(OUT+"crest_"+item[0]+".pxo",false,project))
		var flat = blank()
		for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
		assert(flat.save_png(OUT+"crest_"+item[0]+".png") == OK)
		var sheet_im = blank(336,168)
		sheet_im.blit_rect(flat,Rect2i(0,0,48,48),Vector2i((n%6)*56+4,(n/6)*56+4))
		sheet_layers.append(["%02d %s" % [n+1,item[1]],sheet_im])
		print("CREST_SAVED ",item[0])
	var sheet = project_from_layers("全部纹章_静态初稿",sheet_layers,Vector2i(336,168))
	assert(OpenSave.save_pxo_file(OUT+"全部纹章_静态初稿.pxo",false,sheet))
	print("CREST_ALL_DONE 17")
