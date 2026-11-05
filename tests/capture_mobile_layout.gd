extends SceneTree
## Captures real rendered gameplay frames at representative portrait viewport sizes.
## Run with a desktop display server (CI uses Xvfb + software OpenGL), not --headless.

const MAIN_SCENE := preload("res://scenes/main.tscn")
const VIEWPORT_CASES := [
	{"name": "320x568", "size": Vector2i(320, 568)},
	{"name": "360x800", "size": Vector2i(360, 800)},
	{"name": "390x844", "size": Vector2i(390, 844)},
	{"name": "412x915", "size": Vector2i(412, 915)},
	{"name": "720x1280", "size": Vector2i(720, 1280)},
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

	for viewport_case in VIEWPORT_CASES:
		var viewport_size: Vector2i = viewport_case["size"]
		var render_viewport := SubViewport.new()
		render_viewport.size = viewport_size
		render_viewport.disable_3d = true
		render_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(render_viewport)

		var scene := MAIN_SCENE.instantiate()
		render_viewport.add_child(scene)
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
