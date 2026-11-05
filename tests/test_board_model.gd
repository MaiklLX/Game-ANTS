extends SceneTree

const BoardModelScript = preload("res://scripts/core/board_model.gd")


func _initialize() -> void:
	var board = BoardModelScript.new()
	board.configure(5, 5)

	_check(board.is_inside(Vector2i(0, 0)), "origin should be inside")
	_check(not board.is_inside(Vector2i(5, 0)), "right edge should be outside")
	_check(board.is_walkable(Vector2i(4, 4)), "open cell should be walkable")

	var direct_path: Array[Vector2i] = board.find_path(Vector2i(0, 0), Vector2i(2, 0))
	_check(direct_path == [Vector2i(1, 0), Vector2i(2, 0)], "path should be shortest and deterministic")

	board.set_blocked_cells([Vector2i(1, 0)])
	var detour: Array[Vector2i] = board.find_path(Vector2i(0, 0), Vector2i(2, 0))
	_check(not detour.is_empty(), "detour should exist around one obstacle")
	_check(not detour.has(Vector2i(1, 0)), "path must not cross blocked cell")
	_check(detour.size() == 4, "detour should have four steps")

	board.set_blocked_cells([Vector2i(1, 0), Vector2i(0, 1)])
	var unreachable: Array[Vector2i] = board.find_path(Vector2i(0, 0), Vector2i(2, 2))
	_check(unreachable.is_empty(), "blocked start exits should make goal unreachable")

	board.set_blocked_cells([])
	_check(board.find_path(Vector2i(-1, 0), Vector2i(2, 2)).is_empty(), "outside start should fail safely")
	_check(board.find_path(Vector2i(2, 2), Vector2i(2, 2)).is_empty(), "same-cell route should have no movement steps")

	var sample_text := FileAccess.get_file_as_string("res://levels/level_001.json")
	var sample_data: Variant = JSON.parse_string(sample_text)
	_check(typeof(sample_data) == TYPE_DICTIONARY, "sample level should parse as an object")
	var load_result: Dictionary = board.load_level(sample_data)
	_check(load_result["valid"], "sample level should load")
	_check(board.level_id == "meadow_001", "loaded level id should be retained")
	_check(board.width == 5 and board.height == 5, "loaded dimensions should configure the board")
	_check(board.start == Vector2i(0, 2), "loaded start should match level data")
	_check(board.goal == Vector2i(4, 2), "loaded goal should match level data")
	_check(not board.is_walkable(Vector2i(2, 1)), "loaded obstacle should block movement")
	_check(not board.is_walkable(Vector2i(2, 3)), "second loaded obstacle should block movement")
	_check(board.find_path(board.start, board.goal).size() == 4, "loaded board should produce a deterministic route around obstacles")
	_check(board.remaining_resources == 1, "loaded resource count should be one")
	_check(board.has_resource(Vector2i(4, 2)), "resource cell should be available")
	_check(board.resource_color_at(Vector2i(4, 2)) == "amber", "resource color should be loaded")
	_check(not board.collect_resource(Vector2i(4, 2), "teal"), "wrong-color squad should not collect resource")
	_check(board.collect_resource(Vector2i(4, 2)), "resource should be collected once")
	_check(not board.collect_resource(Vector2i(4, 2)), "collected resource should not be collected twice")
	_check(board.remaining_resources == 0, "remaining resource count should reach zero")
	_check(not board.collect_resource(Vector2i(-1, 0)), "outside resource collection should fail safely")

	var invalid_data: Dictionary = sample_data.duplicate(true)
	invalid_data["width"] = 0
	var invalid_result: Dictionary = board.load_level(invalid_data)
	_check(not invalid_result["valid"], "invalid level should be rejected")
	_check(board.level_id == "meadow_001", "failed load must preserve the previously loaded level")
	_check(board.width == 5 and board.remaining_resources == 0, "failed load must preserve board state")

	print("BoardModel tests passed.")
	quit(0)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("BoardModel test failed: " + message)
	quit(1)
