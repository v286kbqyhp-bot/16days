extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(1280,720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var packed := load("res://battle/boundary_cc0_trial/preview.tscn") as PackedScene
	if packed == null:
		quit(1)
		return
	var scene = packed.instantiate()
	vp.add_child(scene)
	await process_frame
	var world: Node2D = scene.view.get_child(0)
	var rear := world.get_node_or_null("LaserBoundaryRear")
	var front := world.get_node_or_null("LaserBoundaryFront")
	if rear == null or front == null or rear.get_child_count()!=4 or front.get_child_count()!=4:
		push_error("Boundary scene failed to initialize")
		quit(1)
		return
	assert(world.boundary_front_strength < world.boundary_rear_strength)
	assert(world.boundary_front_height < world.boundary_rear_height)
	assert(world.get_node("ExteriorGrass").get_child_count()==0)
	var folder := ProjectSettings.globalize_path("res://../docs/art/battle/boundary-cc0/laser-v11")
	DirAccess.make_dir_recursive_absolute(folder)
	var animate := "--animate" in OS.get_cmdline_user_args()
	var frame_count := 24 if animate else 1
	for frame in range(frame_count):
		for layer in [rear,front]:
			for polygon in layer.get_children():
				polygon.material.set_shader_parameter("preview_time",float(frame)/12.0)
		await process_frame
		await RenderingServer.frame_post_draw
		var file := "/frame-%02d.png" % frame if animate else "/landscape.png"
		var error := vp.get_texture().get_image().save_png(folder+file)
		if error != OK:
			quit(error)
			return
	print("Boundary capture passed: ",frame_count," frame(s), rear/front and empty grass verified")
	quit(0)
