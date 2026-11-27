extends Control
## 独立审阅窗口；不修改游戏主场景和商店。
var elapsed := 0.0
var paused := false
var glint: ShaderMaterial

func _ready() -> void:
	get_window().title = "普通纹章 · 扫光对比"
	get_window().size = Vector2i(960,560)
	RenderingServer.set_default_clear_color(Color("242c32"))
	var font = SystemFont.new()
	font.font_names = PackedStringArray(["Hiragino Sans GB","PingFang SC"])
	for i in range(2):
		var label = Label.new()
		label.text = "原图" if i == 0 else "程序化扫光"
		label.add_theme_font_override("font",font)
		label.add_theme_font_size_override("font_size",24)
		label.position = Vector2(90+i*450,25)
		add_child(label)
		var sprite = Sprite2D.new()
		sprite.texture = load("res://art/crests/crest_common_color.png")
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = Vector2(250+i*450,275)
		sprite.scale = Vector2(7,7)
		if i == 1:
			glint = load("res://art/crests/crest_common_glint.tres").duplicate()
			sprite.material = glint
		add_child(sprite)
	var hint = Label.new()
	hint.text = "空格：暂停 / 继续    R：重播"
	hint.add_theme_font_override("font",font)
	hint.add_theme_font_size_override("font_size",18)
	hint.position = Vector2(290,500)
	add_child(hint)

func _process(delta: float) -> void:
	if not paused: elapsed += delta
	glint.set_shader_parameter("sweep_phase",fmod(elapsed,3.0)/3.0)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE: paused = not paused
		if event.keycode == KEY_R: elapsed = 0.0
