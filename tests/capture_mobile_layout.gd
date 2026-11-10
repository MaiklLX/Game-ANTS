extends SceneTree
## Captures rendered application shell and gameplay screens at portrait sizes.
## Run with a desktop display server (CI uses Xvfb + software OpenGL), not --headless.

const MAIN_SCENE := preload("res://scenes/main.tscn")
const ResponsiveLayoutScript := preload("res://scripts/ui/responsive_layout.gd")
const VIEWPORT_CASES := [
	{"name": "menu-390x844", "size": Vector2i(390, 844), "screen": "menu"},
	{"name": "chapters-390x844", "size": Vector2i(390, 844), "screen": "chapters"},
	{"name": "settings-390x844", "size": Vector2i(390, 844), "screen": "settings"},
	{"name": "pause-390x844", "size": Vector2i(390, 844), "screen": "pause"},
	{"name": "result-390x844", "size": Vector2i(390, 844), "screen": "result"},
	{"name": "320x568", "size": Vector2i(320, 568), "screen": "game"},
	{"name": "320x568-level100", "size": Vector2i(320, 568), "screen": "game", "level_index": 99},
	{"name": "360x800", "size": Vector2i(360, 800), "screen": "game"},
	{"name": "360x800-level100", "size": Vector2i(360, 800), "screen": "game", "level_index": 99},
	{"name": "390x844", "size": Vector2i(390, 844), "screen": "game"},
	{"name": "412x915", "size": Vector2i(412, 915), "screen": "game"},
	{"name": "720x1280", "size": Vector2i(720, 1280), "screen": "game"},
]


func _initialize() -> void:
	call_deferred("_capture_viewports")


func _capture_viewports() -> void:
	var output_directory := ProjectSettings.globalize_path("res://artifacts/mobile-visual-qa")
	var mkdir_error := DirAccess.make_dir_recursive_absolute(output_directory)
	if mkdir_error != OK and mkdir_error != ERR_ALREADY_EXISTS:
		push_error("Could not create screenshot output directory: %s" % error_string(mkdir_error))
		quit(1)
		return

	var first_size: Vector2i = VIEWPORT_CASES[0]["size"]
	var render_viewport := SubViewport.new()
	render_viewport.size = first_size
	render_viewport.disable_3d = true
	render_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(render_viewport)

	var scene := MAIN_SCENE.instantiate()
	render_viewport.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await process_frame

	for viewport_case in VIEWPORT_CASES:
		var viewport_size: Vector2i = viewport_case["size"]
		render_viewport.size = viewport_size
		scene.size = Vector2(viewport_size)
		await process_frame

		var level_index := int(viewport_case.get("level_index", 0))
		scene.call("_load_level", level_index)
		var screen_name := String(viewport_case.get("screen", "game"))
		scene.set("_app_screen", screen_name)
		if screen_name == "result":
			var engine = scene.get("_strategic_engine")
			var board = scene.get("_board")
			var colony = scene.get("_colony")
			var result_snapshot: Dictionary = engine.create_snapshot(colony, board)
			scene.set("_undo_snapshot", result_snapshot)
			engine.call("_finish", "won")
			colony.set("delivered_resources", board.get("total_resources"))
		if level_index >= 0:
			var scale := float(ResponsiveLayoutScript.calculate(Vector2(viewport_size))["scale"])
			var levels_per_page := ResponsiveLayoutScript.levels_per_page(scale)
			scene.set("_level_page_start", int(level_index / levels_per_page) * levels_per_page)
		scene.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw

		var screenshot: Image = render_viewport.get_texture().get_image()
		if screenshot == null or screenshot.is_empty():
			push_error("Rendered screenshot is empty for %s" % viewport_case["name"])
			quit(1)
			return
		if screenshot.get_width() != viewport_size.x or screenshot.get_height() != viewport_size.y:
			push_error("Unexpected screenshot dimensions for %s: %s" % [viewport_case["name"], screenshot.get_size()])
			quit(1)
			return

		var output_path := output_directory.path_join("%s.png" % viewport_case["name"])
		var save_error := screenshot.save_png(output_path)
		if save_error != OK:
			push_error("Could not save %s: %s" % [output_path, error_string(save_error)])
			quit(1)
			return
		print("Captured rendered viewport: %s" % output_path)

	render_viewport.queue_free()
	await process_frame
	quit(0)
