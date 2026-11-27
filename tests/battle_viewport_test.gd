extends SceneTree
## 真实图形渲染、变更视口后的 GUI 输入与截图回归。

const PREVIEW = preload("res://battle/battle_preview.tscn")
const Data = preload("res://battle/forest_battle_data.gd")

var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var capture := SubViewport.new()
	capture.size = Vector2i(1280, 720)
	capture.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(capture)
	var preview = PREVIEW.instantiate()
	capture.add_child(preview)
	capture.notify_mouse_entered()
	var folder := OS.get_environment("BATTLE_CAPTURE_DIR")
	if folder.is_empty():
		folder = "user://battle-fog-review"
	DirAccess.make_dir_recursive_absolute(folder)
	for dimensions in [
		Vector2i(1280, 720), Vector2i(1440, 900), Vector2i(1680, 720),
		Vector2i(1366, 768), Vector2i(960, 540), Vector2i(1920, 1080),
	]:
		capture.size = dimensions
		await process_frame
		await process_frame
		for row in range(8):
			for col in range(8):
				var cell := Vector2i(col, row)
				var point = preview.world_to_screen(Data.cell_to_world(cell))
				if preview.screen_to_cell(point) != cell:
					failures += 1
				var motion := InputEventMouseMotion.new()
				motion.position = point
				capture.push_input(motion, true)
				if preview.hovered_cell != cell:
					printerr("GUI hover failed at ", dimensions, " cell ", cell)
					failures += 1
		for corner in [Vector2(320, 68), Vector2(512, 164), Vector2(320, 260), Vector2(128, 164)]:
			if not Rect2(Vector2.ZERO, Vector2(dimensions)).has_point(preview.world_to_screen(corner)):
				printerr("Board corner clipped at ", dimensions)
				failures += 1
		var outside := InputEventMouseMotion.new()
		outside.position = Vector2(dimensions.x / 2, dimensions.y - 2)
		capture.push_input(outside, true)
		if preview.hovered_cell != Vector2i(-1, -1):
			printerr("Outside board accepted at ", dimensions)
			failures += 1
		# 从视口入口投递点选事件，覆盖实际 GUI 分发及缩放后的覆盖层。
		var target := Vector2i(4, 5)
		var event := InputEventMouseButton.new()
		event.position = preview.world_to_screen(Data.cell_to_world(target))
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = true
		capture.push_input(event, true)
		event.pressed = false
		capture.push_input(event, true)
		await process_frame
		if preview.selected_warden_idx != 1:
			printerr("GUI pick failed at ", dimensions)
			failures += 1
		preview.selected_warden_idx = 0
		preview._refresh_hud()
		preview.overlay.queue_redraw()
		await RenderingServer.frame_post_draw
		capture.get_texture().get_image().save_png(folder + "/battle-%dx%d.png" % [dimensions.x, dimensions.y])
		print("viewport=", dimensions," pixel_scale=", preview.pixel_scale," pick_failures=", failures)
	capture.size = Vector2i(1280, 720)
	preview._set_mode(preview.ViewMode.PURE)
	await process_frame
	await RenderingServer.frame_post_draw
	capture.get_texture().get_image().save_png(folder + "/scene-1280x720.png")
	await create_timer(2.0).timeout
	await RenderingServer.frame_post_draw
	capture.get_texture().get_image().save_png(folder + "/scene-after-2s.png")
	print("Fog viewport review failures=", failures)
	quit(1 if failures else 0)
