extends Control
## 普通纹章的独立悬停展示。参数依据本机 Balatro 1.0.1o 盲注收藏实现。
## 图像与材质在每个实例内独立；不改写作者贴图或其他纹章的状态。

const CREST_TEXTURE = preload("res://art/crests/crest_common_color.png")
const CREST_MATERIAL = preload("res://art/crests/crest_common_glint.tres")

## 纹章彩图与扫光材质；每枚纹章可绑定独立资源，交互参数共享。
@export var crest_texture: Texture2D = CREST_TEXTURE
@export var crest_material: ShaderMaterial = CREST_MATERIAL

## 悬停增加的缩放比例：0.05 表示 5%。
@export var hover_scale_add := 0.05
## 透视方向项倍率，非角度。局部固定中心适配值；原作盲注 hover_tilt 为 3。
@export var hover_tilt := 12.0
## 常驻旋转幅度，单位弧度；0.02 约为 1.15°。
@export var idle_rotation := 0.02
## 常驻旋转角速度，单位弧度／秒；2 对应约 3.14 秒一轮。
@export var idle_speed := 2.0
## 每个实例的轻晃相位，单位弧度。
@export var idle_phase := 0.0
## 原作 shadow_height，按 1.3 游戏单位宽的盲注换算。
@export var shadow_height := 0.05
## 悬停浮起位移，占纹章宽度的比例；X 正为右，Y 负为上。
@export var hover_lift_ratio := Vector2(0.04, -0.04)
## 圆形热区半径，占纹章宽度比例；0.38 表示直径为宽度的 76%。
@export var hotspot_radius_ratio := 0.38
## Card:hover 的 0.05 经过 Card:juice_up 的 0.4 倍后，实际缩放弹动幅度为 0.02。
@export var bounce_scale := 0.02
## Card:hover 的 0.03 经过 0.4 倍后，实际平面旋转幅度为正负 0.012 弧度。
@export var bounce_rotation := 0.012

var paused := false
var hovered := false
var elapsed := 0.0
var body: Sprite2D
var shadow: Sprite2D
var glint: ShaderMaterial
var _juice_age := 1.0
var _visual_scale := 1.0
var _scale_velocity := 0.0
var _visual_rotation := 0.0
var _accumulator := 0.0
var _body_offset := Vector2.ZERO
var _offset_velocity := Vector2.ZERO
var _bounce_sign := 1.0
var _pointer_viewport := Vector2(-10000,-10000)
var _pointer_active := false
var _hit_image: Image

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	shadow = Sprite2D.new()
	body = Sprite2D.new()
	for sprite in [shadow, body]:
		sprite.texture = crest_texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.material = crest_material.duplicate()
		add_child(sprite)
	glint = body.material
	_hit_image = crest_texture.get_image()
	glint.set_shader_parameter("local_tilt", true)
	shadow.material.set_shader_parameter("shadow_pass", true)
	get_window().mouse_exited.connect(func(): _pointer_active = false)
	get_window().focus_exited.connect(func(): _pointer_active = false)
	_update_visuals(Vector2.ZERO)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		# 使用事件自带的 viewport 坐标，避免全局轮询与实际事件位置不同步。
		_pointer_viewport = event.position
		_pointer_active = true

func _process(delta: float) -> void:
	if paused: return
	var pointer := get_global_transform_with_canvas().affine_inverse() * _pointer_viewport
	advance_motion(delta, pointer, _pointer_active and get_window().has_focus())

func advance_motion(delta: float, pointer: Vector2, pointer_active := true) -> void:
	var radius := minf(size.x,size.y) * hotspot_radius_ratio
	var inside := contains_raised_crest(pointer) if hovered else pointer.distance_to(size * 0.5) <= radius
	var next_hover := pointer_active and inside
	if next_hover and not hovered:
		_juice_age = 0.0
		_visual_scale = 1.0 - 0.6 * bounce_scale
		_scale_velocity = 0.0
		_bounce_sign = -1.0 if randf() < 0.5 else 1.0
	hovered = next_hover
	# 以 60 Hz 运行原作 exp(-60*dt) 速度递推，保留越过目标后的小回弹。
	_accumulator += minf(delta, 0.1)
	while _accumulator >= 1.0 / 60.0:
		_step_motion(1.0 / 60.0)
		_accumulator -= 1.0 / 60.0
	_update_visuals(pointer)

func contains_raised_crest(pointer: Vector2) -> bool:
	# 反投影当前显示的平面，再读取彩图 alpha。覆盖浮起、缩放、旋转及透视后的
	# 完整轮廓，而不是把拿起前的小圆扩大，也不把透明四角算作纹章。
	var screen_point := get_global_transform_with_canvas() * pointer
	# 覆盖屏幕像素的半像素采样范围，避免 GPU 与 CPU 在像素边界舍入不同。
	for offset in [Vector2.ZERO,Vector2(-0.5,-0.5),Vector2(0.5,-0.5),Vector2(-0.5,0.5),Vector2(0.5,0.5)]:
		if _contains_raised_sample(screen_point+offset): return true
	return false

func _contains_raised_sample(screen_point: Vector2) -> bool:
	var center: Vector2 = glint.get_shader_parameter("tilt_center_screen")
	var screen_unit: float = maxf(float(glint.get_shader_parameter("screen_scale")),1.0)
	var amount: float = glint.get_shader_parameter("hovering")
	if amount > 0.0:
		var viewport_size: Vector2 = glint.get_shader_parameter("viewport_size")
		var mouse: Vector2 = glint.get_shader_parameter("mouse_screen_pos")
		var center_dist := (center - 0.5 * viewport_size).length() / viewport_size.length()
		var a := 0.2 * (0.03 + 0.3 * maxf(0.0,0.3-center_dist)) * amount / maxf(2.0-center_dist,0.1)
		var q := (screen_point-center) / screen_unit
		var m := (mouse-center) / screen_unit
		# shader: q=p/max(1+2a*dot(p,m),0.5)。同时处理 w 下限分支。
		var denominator := 1.0 - 2.0*a*q.dot(m)
		if denominator <= 0.0: return false
		screen_point = center + q * screen_unit * maxf(1.0/denominator,0.5)
	var texel := body.get_global_transform_with_canvas().affine_inverse() * screen_point + Vector2(_hit_image.get_size())*0.5
	var pixel := Vector2i(floori(texel.x),floori(texel.y))
	if pixel.x < 0 or pixel.y < 0 or pixel.x >= _hit_image.get_width() or pixel.y >= _hit_image.get_height(): return false
	return _hit_image.get_pixelv(pixel).a > 0.0

func _step_motion(dt: float) -> void:
	elapsed += dt
	_juice_age += dt
	var envelope := maxf(0.0, 1.0 - _juice_age / 0.4)
	var juice_scale := bounce_scale * sin(50.8 * _juice_age) * pow(envelope, 3.0)
	var juice_rotation := _bounce_sign * bounce_rotation * sin(40.8 * _juice_age) * pow(envelope, 2.0)
	var desired_scale := 1.0 + (hover_scale_add if hovered else 0.0) + juice_scale
	# 盲注收藏经 UIElement 进入 r_bond=Strong：直接相加，非 move_r 的 Weak 分支。
	_visual_rotation = idle_rotation * sin(idle_speed * elapsed + idle_phase) + juice_rotation
	_scale_velocity = exp(-60.0 * dt) * _scale_velocity + (1.0 - exp(-60.0 * dt)) * (desired_scale - _visual_scale)
	_visual_scale += _scale_velocity
	# 浮起只在进入／离开时发生；鼠标方向只进入 shader，不推动纹章中心。
	var desired_offset := hover_lift_ratio * minf(size.x,size.y) if hovered else Vector2.ZERO
	_offset_velocity = exp(-60.0 * dt) * _offset_velocity + (1.0 - exp(-60.0 * dt)) * (desired_offset - _body_offset)
	_body_offset += _offset_velocity

func _update_visuals(pointer: Vector2) -> void:
	var base_scale := minf(size.x, size.y) / 48.0
	var unit_pixels := minf(size.x, size.y) / 1.3
	var viewport_size := get_viewport_rect().size
	# 保留当前右侧预览的左下阴影方向，控件移到屏幕左侧也不会翻转。
	var parallax := Vector2(0.6875, -1.5)
	body.position = size * 0.5 + _body_offset
	body.scale = Vector2.ONE * base_scale * _visual_scale
	body.rotation = _visual_rotation
	# 作者要求底面稳定：仅同步缩放，位置和朝向不继承上层的浮起／轻晃／透视。
	shadow.position = size * 0.5 - parallax * shadow_height * unit_pixels
	shadow.scale = Vector2.ONE * base_scale * _visual_scale * (1.0 - 0.2 * shadow_height)
	shadow.rotation = 0.0
	glint.set_shader_parameter("hovering", hover_tilt if hovered else 0.0)
	glint.set_shader_parameter("mouse_screen_pos", get_global_transform_with_canvas() * pointer)
	glint.set_shader_parameter("viewport_size", viewport_size)
	glint.set_shader_parameter("tilt_center_screen", get_global_transform_with_canvas() * body.position)
	glint.set_shader_parameter("screen_scale", unit_pixels * get_global_transform_with_canvas().get_scale().x)
	glint.set_shader_parameter("sweep_phase", fmod(elapsed, 3.0) / 3.0)

func restart() -> void:
	elapsed = 0.0
	_juice_age = 1.0
	_accumulator = 0.0
