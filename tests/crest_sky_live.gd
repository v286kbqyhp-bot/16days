extends "res://../tests/crest_glint_live.gd"
## 天空纹章审阅稿复用已确认交互，资源暂留 docs/art，尚未正式接入商店。

func _ready() -> void:
	# 在父级预览创建节点时提供天空纹章资源；其余布局及输入保持一致。
	super._ready()
	get_window().title = "天空纹章 · 样稿审阅"
	var sky_texture := ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path("res://../docs/art/crests/sky-v1/crest_sky_color.png")))
	var sky_material: ShaderMaterial = preload("res://art/crests/crest_common_glint.tres").duplicate()
	for binding in [["crest_normal","crest_sky_normal.png"],["highlight_mask","crest_sky_highlight_mask.png"]]:
		var data := Image.load_from_file(ProjectSettings.globalize_path("res://../docs/art/crests/sky-v1/"+binding[1]))
		sky_material.set_shader_parameter(binding[0],ImageTexture.create_from_image(data))
	for node in get_children():
		if node is Sprite2D: node.texture = sky_texture
	var replacement = load("res://art/crests/crest_hover_view.gd").new()
	replacement.position = interactive.position
	replacement.size = interactive.size
	replacement.crest_texture = sky_texture
	replacement.crest_material = sky_material
	remove_child(interactive)
	interactive.queue_free()
	interactive = replacement
	add_child(interactive)
