extends SceneTree
## 验证正式贴图与作者原件对齐；直接读取 PNG 避免把缓存导入成功误当作内容正确。
var failures := 0
const DIR = "res://art/crests/"

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var color = Image.load_from_file(ProjectSettings.globalize_path(DIR+"crest_common_color.png"))
	var normal = Image.load_from_file(ProjectSettings.globalize_path(DIR+"crest_common_normal.png"))
	var mask = Image.load_from_file(ProjectSettings.globalize_path(DIR+"crest_common_highlight_mask.png"))
	var base = Image.load_from_file(ProjectSettings.globalize_path(DIR+"template_disc_color.png"))
	var base_normal = Image.load_from_file(ProjectSettings.globalize_path(DIR+"template_disc_normal.png"))
	var zip = ZIPReader.new()
	check(zip.open(ProjectSettings.globalize_path("res://../docs/art/crests/source/crest_common_color.pxo")) == OK,"作者源件可读")
	var data = JSON.parse_string(zip.read_file("data.json").get_string_from_utf8())
	var expected = Image.create(48,48,false,Image.FORMAT_RGBA8)
	var expected_base = Image.create(48,48,false,Image.FORMAT_RGBA8)
	for i in range(4):
		var cel = data.frames[0].cels[i]
		var size: Vector2i = str_to_var(cel.image_size)
		var offset: Vector2 = str_to_var("Vector2"+cel.offset)
		var layer = Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGBA8,zip.read_file("image_data/frames/1/layer_%d" % (i+1)))
		expected.blend_rect(layer,Rect2i(Vector2i.ZERO,size),Vector2i(offset))
		if i < 2: expected_base.blend_rect(layer,Rect2i(Vector2i.ZERO,size),Vector2i(offset))
	zip.close()
	check(color.get_data() == expected.get_data(),"彩图逐像素保留作者最终版本")
	check(base.get_data() == expected_base.get_data(),"公共圆盘模板来自作者前两层")
	for im in [color,normal,mask,base,base_normal]:
		check(im.get_size() == Vector2i(48,48),"全部贴图同为 48×48")
	var worst_length_error = 0.0
	for y in range(48):
		for x in range(48):
			var a = color.get_pixel(x,y).a
			check(a == normal.get_pixel(x,y).a and a == mask.get_pixel(x,y).a,"彩图/法线/遮罩轮廓对齐")
			check(base.get_pixel(x,y).a == base_normal.get_pixel(x,y).a,"模板法线轮廓对齐")
			if a == 0: continue
			var c = normal.get_pixel(x,y)
			var n = Vector3(c.r,c.g,c.b)*2.0-Vector3.ONE
			worst_length_error = max(worst_length_error,abs(n.length()-1.0))
			check(n.z > 0.0,"法线朝向观察者")
			var m = mask.get_pixel(x,y)
			check(m.r == m.g and m.g == m.b,"高光遮罩是灰度强度")
	check(worst_length_error < 0.012,"8 位法线量化后仍接近单位向量")
	check(base_normal.get_pixel(24,2).g > 0.7,"顶部法线 +Y")
	check(base_normal.get_pixel(24,46).g < 0.3,"作者底部补点法线 -Y")
	check(base_normal.get_pixel(2,24).r < 0.3,"左侧法线 -X")
	check(base_normal.get_pixel(45,24).r > 0.7,"右侧法线 +X")
	for x in range(20,28): check(color.get_pixel(x,46).a == 1.0,"作者底部八个像素保留")
	var facet_ids = {}
	for y in range(48):
		for x in range(48):
			if color.get_pixel(x,y).a > 0: facet_ids[normal.get_pixel(x,y).to_html()] = true
	check(facet_ids.size() > 4,"同时具有圆盘弧面和晶体切面法线")
	print("CREST_MAPS_TEST failures=%d normal_length_error=%.6f" % [failures,worst_length_error])
	quit(failures)
