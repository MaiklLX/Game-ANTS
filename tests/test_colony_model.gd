extends SceneTree

const BoardModelScript = preload("res://scripts/core/board_model.gd")
const ColonyModelScript = preload("res://scripts/core/colony_model.gd")


var _failures: Array[String] = []


func _initialize() -> void:
	var board = BoardModelScript.new()
	var sample_text := FileAccess.get_file_as_string("res://levels/level_001.json")
	var sample_data: Variant = JSON.parse_string(sample_text)
	_check(typeof(sample_data) == TYPE_DICTIONARY, "sample level should parse")
	sample_data["tiles"].append({"x": 3, "y": 2, "type": "resource", "color": "amber"})
	_check(board.load_level(sample_data)["valid"], "sample level with two resources should load")

	var colony = ColonyModelScript.new()
	colony.configure(2)
	_check(colony.register_squad("amber_a", "amber", 1)["valid"], "amber squad should register")
	_check(colony.register_squad("teal_b", "teal", 2)["valid"], "teal squad should register")
	_check(colony.register_squad("amber_c", "amber", 1)["valid"], "third squad should register")
	_check(not colony.register_squad("amber_a", "amber", 1)["valid"], "duplicate squad ID should fail")
	_check(not colony.register_squad("bad_color", "ultraviolet", 1)["valid"], "unsupported squad color should fail")
	_check(not colony.register_squad("zero_capacity", "amber", 0)["valid"], "zero capacity should fail")

	var first_deploy: Dictionary = colony.deploy_squad("amber_a")
	var second_deploy: Dictionary = colony.deploy_squad("teal_b")
	_check(first_deploy["valid"] and first_deploy["slot_index"] == 0, "first squad should occupy slot zero")
	_check(second_deploy["valid"] and second_deploy["slot_index"] == 1, "second squad should occupy slot one")
	_check(colony.get_active_slot_count() == 2, "both deployment slots should be occupied")
	_check(not colony.deploy_squad("amber_c")["valid"], "third squad should not deploy into full slots")

	_check(not colony.collect_resource("teal_b", board.start, Vector2i(3, 2), board)["valid"], "wrong-color squad must not collect")
	_check(not colony.collect_resource("amber_a", board.start, Vector2i(1, 2), board)["valid"], "empty target must not collect")

	board.set_blocked_cells([Vector2i(1, 2), Vector2i(0, 1), Vector2i(0, 3)])
	_check(not colony.collect_resource("amber_a", board.start, Vector2i(3, 2), board)["valid"], "unreachable resource must not collect")
	_check(board.has_resource(Vector2i(3, 2)), "failed collection must preserve resource")
	_check(board.load_level(sample_data)["valid"], "reload should restore the sample board")

	var collected: Dictionary = colony.collect_resource("amber_a", board.start, Vector2i(3, 2), board)
	_check(collected["valid"] and collected["carried"] == 1, "matching reachable resource should be collected")
	_check(not colony.collect_resource("amber_a", board.start, Vector2i(4, 2), board)["valid"], "full squad must not exceed carrying capacity")
	_check(board.has_resource(Vector2i(4, 2)), "resource should remain when squad capacity is full")

	var returned: Dictionary = colony.return_squad("amber_a")
	_check(returned["valid"] and returned["delivered"] == 1, "partial load should be delivered on return")
	_check(colony.get_active_slot_count() == 1, "returning squad should release its slot")
	_check(colony.delivered_resources == 1, "delivered total should update")
	_check(colony.deploy_squad("amber_c")["valid"], "waiting squad should use the released slot")

	if _failures.is_empty():
		print("ColonyModel tests passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error("ColonyModel test failed: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
