extends Control
var view: SubViewport
var display: TextureRect
func _ready() -> void:
	view = SubViewport.new()
	view.disable_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(view)
	view.add_child(load("res://battle/boundary_cc0_trial/landscape.tscn").instantiate())
	display = TextureRect.new()
	display.texture = view.get_texture()
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(display)
	resized.connect(_fit)
	_fit()
func _fit() -> void:
	var factor := maxf(1.0,floorf(minf(size.x/384.0,size.y/216.0)))
	view.size = Vector2i(ceil(size/factor))
	view.canvas_transform = Transform2D(0.0,(Vector2(view.size)*0.5-Vector2(320,164)).floor())
	display.size = Vector2(view.size)*factor
