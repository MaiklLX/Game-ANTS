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

	print("BoardModel tests passed.")
	quit(0)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("BoardModel test failed: " + message)
	quit(1)
