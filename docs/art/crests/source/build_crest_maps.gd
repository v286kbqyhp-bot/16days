extends RefCounted
## 在 Pixelorama 1.2.4 中运行。环境变量 CREST_REPO_ROOT 指向仓库根目录。
## 只读取作者彩色原件；不覆盖它，也不从亮度推算几何高度。
var root: String
var output: String
var source: String

func blank() -> Image:
	return Image.create(48,48,false,Image.FORMAT_RGBA8)

func normal_color(direction: Vector3) -> Color:
	var n = direction.normalized()
	return Color(n.x*0.5+0.5,n.y*0.5+0.5,n.z*0.5+0.5,1.0)

func read_color_layers() -> Array:
	var zip = ZIPReader.new()
	assert(zip.open(source+"crest_common_color.pxo") == OK)
	var data = JSON.parse_string(zip.read_file("data.json").get_string_from_utf8())
	assert(data.frames.size() == 1 and data.layers.size() == 4)
	var layers = []
	for i in range(4):
		assert(data.layers[i].visible and data.layers[i].opacity == 1.0 and data.layers[i].blend_mode == 0)
		var cel = data.frames[0].cels[i]
		var size: Vector2i = str_to_var(cel.image_size)
		var offset: Vector2 = str_to_var("Vector2"+cel.offset)
		var im = Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGBA8,zip.read_file("image_data/frames/1/layer_%d" % (i+1)))
		var canvas = blank()
		canvas.blit_rect(im,Rect2i(Vector2i.ZERO,size),Vector2i(offset))
		layers.append(canvas)
	zip.close()
	return layers

func composite(layers: Array) -> Image:
	var result = blank()
	for im in layers: result.blend_rect(im,Rect2i(0,0,48,48),Vector2i.ZERO)
	return result

func write_png(name: String, im: Image) -> void:
	assert(im.save_png(output+name+".png") == OK)

func write_pxo(name: String, layers: Array) -> void:
	var project = Project.new([],name,Vector2i(48,48))
	Global.projects.append(project)
	var frame = Frame.new()
	for i in range(layers.size()):
		var layer = PixelLayer.new(project,layers[i][0])
		layer.index = i
		project.layers.append(layer)
		frame.cels.append(layer.new_cel_from_image(layers[i][1]))
	project.frames.append(frame)
	assert(OpenSave.save_pxo_file(source+name+".pxo",false,project))

func run() -> void:
	root = OS.get_environment("CREST_REPO_ROOT").trim_suffix("/")
	assert(not root.is_empty(),"Set CREST_REPO_ROOT before running Pixelorama")
	output = root+"/game/art/crests/"
	source = root+"/docs/art/crests/source/"
	var colors = read_color_layers()
	var base = composite([colors[0],colors[1]])
	var full_color = composite(colors)
	var dome = blank()
	var bevel = blank()
	var crystal = blank()
	var base_mask = blank()
	var crystal_mask = blank()
	var bevel_mask = blank()
	for y in range(48):
		for x in range(48):
			if base.get_pixel(x,y).a == 0: continue
			# OpenGL: +X right, +Y up, +Z toward the viewer.
			var radial = Vector2(x-23.5,23.5-y)
			var r = radial.length()
			var gentle = radial/22.5*0.18
			dome.set_pixel(x,y,normal_color(Vector3(gentle.x,gentle.y,1.0)))
			base_mask.set_pixel(x,y,Color(0.18,0.18,0.18,1.0))
			# The outer two-pixel bevel also follows author-added bottom pixels.
			if colors[1].get_pixel(x,y).a > 0 or r > 20.7:
				var direction = radial.normalized()
				bevel.set_pixel(x,y,normal_color(Vector3(direction.x*0.72,direction.y*0.72,0.70)))
				bevel_mask.set_pixel(x,y,Color(0.90,0.90,0.90,1.0))
			if colors[2].get_pixel(x,y).a == 0: continue
			# Explicit four-facet assignment, not a color-to-height filter.
			var facet_color = colors[2].get_pixel(x,y).to_html(false)
			var n = Vector3.ZERO
			match facet_color:
				"e4e6d8": n = Vector3(-0.34,0.36,0.87) # upward/left facing broad cut
				"bec8b3": n = Vector3(-0.12,0.12,0.98) # nearly frontal transition cut
				"99aa96": n = Vector3(0.48,-0.12,0.87) # right side of crystal shaft
				"879780": n = Vector3(0.05,-0.60,0.80) # downward facing termination
				_: assert(false,"Unexpected facet color: "+facet_color)
			# A narrow bevel around the outer silhouette only.
			if colors[3].get_pixel(x,y).a > 0:
				var outward = Vector2.ZERO
				for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					if colors[2].get_pixel(x+d.x,y+d.y).a == 0:
						outward += Vector2(d.x,-d.y)
				if outward.length_squared() > 0:
					outward = outward.normalized()
					n = Vector3(outward.x*0.60,outward.y*0.60,0.80)
			crystal.set_pixel(x,y,normal_color(n))
			var reflectivity = 0.72 if colors[3].get_pixel(x,y).a == 0 else 0.45
			crystal_mask.set_pixel(x,y,Color(reflectivity,reflectivity,reflectivity,1.0))
	var base_normal = composite([dome,bevel])
	var normal = composite([dome,bevel,crystal])
	var common_mask = composite([base_mask,bevel_mask,crystal_mask])
	write_png("crest_common_color",full_color)
	write_png("crest_common_normal",normal)
	write_png("crest_common_highlight_mask",common_mask)
	write_png("template_disc_color",base)
	write_png("template_disc_normal",base_normal)
	write_png("template_disc_highlight_mask",composite([base_mask,bevel_mask]))
	write_pxo("crest_common_normal",[["圆盘浅弧面",dome],["包边倒角",bevel],["石英切面与外缘",crystal]])
	write_pxo("crest_common_highlight_mask",[["底盘弱反光",base_mask],["包边强反光",bevel_mask],["石英反光",crystal_mask]])
	write_pxo("template_disc_color",[["底盘_作者定稿",colors[0]],["高光阴影_作者定稿",colors[1]]])
	write_pxo("template_disc_normal",[["圆盘浅弧面",dome],["包边倒角",bevel]])
	print("CREST_MAPS_SAVED: color, OpenGL normals, highlight masks, reusable disc templates")
