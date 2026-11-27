extends "res://../tests/crest_glint_live.gd"
## 清风样稿独立审阅；平面法线仅用于预览，未生成或接入正式法线资产。

func _ready() -> void:
	super._ready()
	get_window().title = "清风纹章 · 样稿交互预览（平面法线）"
	var texture := ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path("res://../docs/art/crests/clear-eye-v1/crest_clear_eye_color.png")))
	var material: ShaderMaterial = preload("res://art/crests/crest_common_glint.tres").duplicate()
	var normal := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	normal.fill(Color(0.5, 0.5, 1.0, 1.0))
	var mask := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	mask.fill(Color.WHITE)
	material.set_shader_parameter("crest_normal", ImageTexture.create_from_image(normal))
	material.set_shader_parameter("highlight_mask", ImageTexture.create_from_image(mask))
	for node in get_children():
		if node is Sprite2D:
			node.texture = texture
	var replacement = load("res://art/crests/crest_hover_view.gd").new()
	replacement.position = interactive.position
	replacement.size = interactive.size
	replacement.crest_texture = texture
	replacement.crest_material = material
	remove_child(interactive)
	interactive.queue_free()
	interactive = replacement
	add_child(interactive)
