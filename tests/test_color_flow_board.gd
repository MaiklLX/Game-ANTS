extends SceneTree

const BoardScript = preload("res://scripts/core/color_flow_board.gd")
var failures: Array[String] = []

func _initialize() -> void:
	var board = BoardScript.new()
	board.configure_default()
	_check(board.width == 18, "mosaic width should be 18 cells")
	_check(board.height == 13, "mosaic height should be 13 cells")
	_check(board.get_remaining_count() > 0, "default mosaic should contain pixels")
	_check(board.get_remaining_count("teal") > 0, "mosaic should contain teal pixels")
	_check(board.get_remaining_count("coral") > 0, "mosaic should contain coral pixels")
	_check(board.get_remaining_count("gold") > 0, "mosaic should contain gold pixels")
	var teal_cells := board.get_cells_for_color("teal")
	_check(not teal_cells.is_empty(), "teal target list should not be empty")
	if not teal_cells.is_empty():
		var first: Vector2i = teal_cells[0]
		_check(not board.clear_pixel(first, "coral"), "wrong-color ant must not clear a pixel")
		_check(board.clear_pixel(first, "teal"), "matching ant should clear a pixel")
		_check(not board.clear_pixel(first, "teal"), "cleared pixel cannot be cleared twice")
	_check(board.get_remaining_count() == int(board.initial_counts.values().reduce(func(a, b): return int(a) + int(b), 0)) - 1, "remaining count should decrease exactly once")
	for cell in board.get_cells_for_color("teal").duplicate():
		_check(board.clear_pixel(cell, "teal"), "all remaining teal pixels should be clearable by matching ants")
	for cell in board.get_cells_for_color("coral").duplicate():
		_check(board.clear_pixel(cell, "coral"), "all coral pixels should be clearable by matching ants")
	for cell in board.get_cells_for_color("gold").duplicate():
		_check(board.clear_pixel(cell, "gold"), "all gold pixels should be clearable by matching ants")
	_check(board.is_complete(), "board should complete after every matching pixel is cleared")
	if failures.is_empty():
		print("ColorFlowBoard tests passed.")
		quit(0)
	else:
		for failure in failures:
			push_error("ColorFlowBoard test failed: " + failure)
		quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
