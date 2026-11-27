extends RefCounted
## 仅制作作者指定的红色 UP 字母。背景候选等待作者选择。
func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	var out := root+"/docs/art/crests/up-v1/"
	var b = load("res://author_pins.gd").new()
	b.im = b.blank()
	var red := Color("e73840")
	b.poly([[10,16],[13,16],[13,28],[15,30],[18,30],[20,28],[20,16],[23,16],[23,29],[19,33],[14,33],[10,29]],red)
	b.box(27,16,3,17,red)
	b.box(30,16,6,3,red)
	b.box(35,18,3,7,red)
	b.box(30,24,6,3,red)
	var letters: Image = b.im
	var outline: Image = b.blank()
	for y in range(1,47):
		for x in range(1,47):
			if letters.get_pixel(x,y).a > 0:
				for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					if letters.get_pixel(x+d.x,y+d.y).a == 0:
						outline.set_pixel(x+d.x,y+d.y,Color("381926"))
	var layers := [["UP_单像素深色描边",outline],["UP_红色字母",letters]]
	var project = b.project_from_layers("UP纹章_字母待审_背景待选",layers)
	assert(OpenSave.save_pxo_file(out+"crest_up_letters.pxo",false,project))
	var flat: Image = b.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(out+"crest_up_letters.png") == OK)
	flat.resize(480,480,Image.INTERPOLATE_NEAREST)
	assert(flat.save_png(out+"crest_up_letters_review.png") == OK)
	print("UP_LETTERS_SAVED: red UP with 1px outline; background pending author selection")
