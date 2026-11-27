extends RefCounted
## 在 Pixelorama 1.2.4 内执行，仅制作普通纹章的新草稿。
const OUT = "/Users/a488/Documents/ChatGPT/16days/docs/art/crests/common-v3/"

func run() -> void:
	var brush = load("res://author_pins.gd").new()
	DirAccess.make_dir_recursive_absolute(OUT)
	brush.im = brush.blank()
	brush.disc(23.5,23.5,22.5,Color("435f65"))
	var backing = brush.im
	brush.im = brush.blank()
	brush.disc(23.5,23.5,21.3,Color("b2c6be"))
	var rim = brush.im
	brush.im = brush.blank()
	brush.disc(23.5,23.5,19.8,Color("8fa9a6"))
	var face = brush.im
	brush.im = brush.blank()
	brush.poly([[24,7],[29,19],[41,24],[29,29],[24,41],[19,29],[7,24],[19,19]],Color("435f65"))
	brush.poly([[24,14],[27,21],[34,24],[27,27],[24,34],[21,27],[14,24],[21,21]],Color("8fa9a6"))
	var symbol = brush.im
	var layers = [["同色系底盘",backing],["细包边",rim],["纯色印刷底",face],["四角星记号",symbol]]
	var project = brush.project_from_layers("crest_common_v3",layers)
	assert(OpenSave.save_pxo_file(OUT+"crest_common.pxo",false,project))
	var flat = brush.blank()
	for layer in layers: flat.blend_rect(layer[1],Rect2i(0,0,48,48),Vector2i.ZERO)
	assert(flat.save_png(OUT+"crest_common.png") == OK)
	print("COMMON_V3_SAVED")
