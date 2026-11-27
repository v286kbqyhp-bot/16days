extends Control
## 独立审阅窗口；不修改游戏主场景和商店。
var interactive: Control

func _ready() -> void:
	get_window().title = "普通纹章 · 悬停与扫光对比"
	get_window().size = Vector2i(960,560)
	RenderingServer.set_default_clear_color(Color("242c32"))
	var font = SystemFont.new()
	font.font_names = PackedStringArray(["Hiragino Sans GB","PingFang SC"])
	for i in range(2):
		var label = Label.new()
		label.text = "原图" if i == 0 else "悬停倾斜 + 轻晃 + 扫光"
		label.add_theme_font_override("font",font)
		label.add_theme_font_size_override("font_size",24)
		label.position = Vector2(90+i*450,25)
		add_child(label)
		if i == 1:
			interactive = load("res://art/crests/crest_hover_view.gd").new()
			interactive.position = Vector2(532,107)
			interactive.size = Vector2(336,336)
			add_child(interactive)
			continue
		var sprite = Sprite2D.new()
		sprite.texture = load("res://art/crests/crest_common_color.png")
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = Vector2(250+i*450,275)
		sprite.scale = Vector2(7,7)
		add_child(sprite)
	var hint = Label.new()
	hint.text = "鼠标移到右侧纹章上试试    空格：暂停 / 继续    R：重播"
	hint.add_theme_font_override("font",font)
	hint.add_theme_font_size_override("font_size",18)
	hint.position = Vector2(150,500)
	add_child(hint)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE: interactive.paused = not interactive.paused
		if event.keycode == KEY_R: interactive.restart()
