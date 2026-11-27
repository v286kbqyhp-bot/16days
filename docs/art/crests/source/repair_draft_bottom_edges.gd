extends RefCounted
## 在 Pixelorama 原生项目中修复模板补齐的底端八像素，不改变轮廓。
func run() -> void:
	var root := OS.get_environment("CREST_REPO_ROOT") + "/docs/art/crests/"
	for item in [["clear-eye-v1", "clear_eye", "294c46"], ["up-v3", "up", "76512a"], ["warden-v4", "warden", "747a7d"], ["sky-v4", "sky", "07539d"]]:
		var stem: String = root + item[0] + "/crest_" + item[1]
		OpenSave.open_pxo_file(stem + "_color.pxo")
		var project = Global.current_project
		var cels = project.frames[0].cels
		var rim_index := -1
		for i in range(project.layers.size()):
			var layer_name: String = project.layers[i].name
			if layer_name.contains("阴影") or layer_name.contains("明暗边"):
				assert(rim_index == -1)
				rim_index = i
		assert(rim_index > 0)
		for x in range(20, 28):
			var point := Vector2i(x, 46)
			var local = cels[rim_index].ensure_canvas_point_in_bounds(point)
			cels[rim_index].get_image().set_pixelv(local, Color(item[2]))
			for i in range(1, cels.size()):
				if i == rim_index: continue
				var p = point - cels[i].offset
				if Rect2i(Vector2i.ZERO, cels[i].get_image().get_size()).has_point(p):
					cels[i].get_image().set_pixelv(p, Color.TRANSPARENT)
		assert(OpenSave.save_pxo_file(stem + "_color.pxo", false, project))
		var flat := Image.create(48, 48, false, Image.FORMAT_RGBA8)
		for cel in cels:
			flat.blend_rect(cel.get_image(), Rect2i(Vector2i.ZERO, cel.get_image().get_size()), cel.offset)
		assert(flat.save_png(stem + "_color.png") == OK)
		flat.resize(480, 480, Image.INTERPOLATE_NEAREST)
		assert(flat.save_png(stem + "_review.png") == OK)
		print("BOTTOM_EDGE_FIXED: ", item[0])
