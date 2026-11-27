extends SceneTree
## 在实际 Godot 渲染器中输出素材审阅帧。需要有图形显示，不能 --headless。
## 输出目录通过 CREST_CAPTURE_DIR 指定；未指定时使用项目 user://。
var target: SubViewport
var sprite: Sprite2D
var material: ShaderMaterial
var capture_dir: String
var failure_count := 0

func _initialize() -> void:
	call_deferred("run")

func render_image() -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	return target.get_texture().get_image()

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("此检查需要实际 GPU 渲染；请去掉 --headless")
		quit(1)
		return
	capture_dir = OS.get_environment("CREST_CAPTURE_DIR")
	if capture_dir.is_empty(): capture_dir = "user://crest-preview"
	DirAccess.make_dir_recursive_absolute(capture_dir)
	root.size = Vector2i(480,480)
	root.title = "普通纹章 · 法线扫光检查"
	target = SubViewport.new()
	target.size = Vector2i(48,48)
	target.transparent_bg = true
	target.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(target)
	sprite = Sprite2D.new()
	sprite.texture = load("res://art/crests/crest_common_color.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(24,24)
	target.add_child(sprite)
	var view = TextureRect.new()
	view.texture = target.get_texture()
	view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	view.position = Vector2(48,48)
	view.size = Vector2(384,384)
	root.add_child(view)
	var baseline = await render_image()
	baseline.save_png(capture_dir+"/color_render.png")
	material = load("res://art/crests/crest_common_glint.tres").duplicate()
	sprite.material = material
	material.set_shader_parameter("highlight_strength",0.0)
	var zero = await render_image()
	if zero.get_data() != baseline.get_data():
		push_error("关闭高光后不等于原图渲染")
		failure_count += 1
	material.set_shader_parameter("highlight_strength",0.85)
	material.set_shader_parameter("sweep_phase",0.5)
	var black_mask = Image.create(48,48,false,Image.FORMAT_RGBA8)
	material.set_shader_parameter("highlight_mask",ImageTexture.create_from_image(black_mask))
	var masked_off = await render_image()
	if masked_off.get_data() != baseline.get_data():
		push_error("全黑高光遮罩未能关闭扫光")
		failure_count += 1
	material.set_shader_parameter("highlight_mask",load("res://art/crests/crest_common_highlight_mask.png"))
	var changed_frames = 0
	for i in range(31):
		material.set_shader_parameter("sweep_phase",float(i)/30.0)
		var frame = await render_image()
		if frame.get_data() != baseline.get_data(): changed_frames += 1
		for y in range(48):
			for x in range(48):
				if abs(frame.get_pixel(x,y).a-baseline.get_pixel(x,y).a) > 0.01:
					failure_count += 1
		frame.save_png(capture_dir+"/glint_%02d.png" % i)
	if changed_frames < 8:
		push_error("扫光有效帧不足")
		failure_count += 1
	# 用同一张法线在四个方向做单独受光检查，不改动正式材质。
	var inspection = Shader.new()
	inspection.code = """shader_type canvas_item;
render_mode unshaded;
uniform sampler2D normals : hint_normal, filter_nearest;
uniform vec3 light_direction;
void fragment() {
 vec3 n = normalize(texture(normals, UV).rgb * 2.0 - 1.0);
 float diffuse = max(dot(n, normalize(light_direction)), 0.0);
 COLOR = vec4(vec3(0.12 + 0.88 * diffuse), COLOR.a);
}"""
	var inspect_material = ShaderMaterial.new()
	inspect_material.shader = inspection
	inspect_material.set_shader_parameter("normals",load("res://art/crests/crest_common_normal.png"))
	sprite.material = inspect_material
	var directions = {"top":Vector3(0,0.8,0.6),"bottom":Vector3(0,-0.8,0.6),"left":Vector3(-0.8,0,0.6),"right":Vector3(0.8,0,0.6)}
	for key in directions:
		inspect_material.set_shader_parameter("light_direction",directions[key])
		var frame = await render_image()
		frame.save_png(capture_dir+"/light_"+key+".png")
	print("CREST_RENDER_TEST failures=%d changed_frames=%d renderer=%s" % [failure_count,changed_frames,RenderingServer.get_current_rendering_method()])
	quit(failure_count)
