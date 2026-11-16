extends SceneTree

const BoardModelScript = preload("res://scripts/core/board_model.gd")
const ColonyModelScript = preload("res://scripts/core/colony_model.gd")
const TurnResolverScript = preload("res://scripts/core/turn_resolver.gd")


var _failures: Array[String] = []


func _initialize() -> void:
	var board = BoardModelScript.new()
	var sample_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_001.json"))
	_check(typeof(sample_data) == TYPE_DICTIONARY, "sample level should parse")
	_check(board.load_level(sample_data)["valid"], "sample level should load")

	var colony = ColonyModelScript.new()
	colony.configure(1)
	_check(colony.register_squad("amber_worker", "amber", 1)["valid"], "amber squad should register")
	_check(colony.register_squad("teal_worker", "teal", 1)["valid"], "teal squad should register")
	_check(TurnResolverScript.is_level_blocked(board, colony) == false, "reachable matching squad should prevent blocked state")

	var preview: Dictionary = TurnResolverScript.preview_collection(
		colony, board, "amber_worker", board.start, Vector2i(4, 2)
	)
	_check(not preview["valid"], "collection preview should require deployment")
	_check(board.has_resource(Vector2i(4, 2)), "invalid preview must not mutate board")

	_check(colony.deploy_squad("amber_worker")["valid"], "amber squad should deploy")
	preview = TurnResolverScript.preview_collection(
		colony, board, "amber_worker", board.start, Vector2i(4, 2)
	)
	_check(preview["valid"], "valid collection should produce a preview")
	_check(preview["path"].size() == 4, "preview should include the deterministic route")
	_check(preview["remaining_capacity_after"] == 0, "preview should report remaining capacity")
	_check(board.has_resource(Vector2i(4, 2)), "preview must not collect the resource")
	_check(colony.get_squad("amber_worker")["carried"] == 0, "preview must not change squad load")

	var applied: Dictionary = TurnResolverScript.apply_collection(
		colony, board, "amber_worker", board.start, Vector2i(4, 2)
	)
	_check(applied["valid"] and applied["carried"] == 1, "valid action should collect resource")
	_check(not board.has_resource(Vector2i(4, 2)), "applied action should remove resource")
	_check(not TurnResolverScript.is_level_complete(board, colony), "level should wait for squad return")
	_check(not TurnResolverScript.is_level_blocked(board, colony), "active squad can still return")

	_check(colony.return_squad("amber_worker")["valid"], "squad should return")
	_check(TurnResolverScript.is_level_complete(board, colony), "delivered final resource should complete level")
	_check(not TurnResolverScript.is_level_blocked(board, colony), "completed level is not blocked")

	var blocked_board = BoardModelScript.new()
	_check(blocked_board.load_level(sample_data)["valid"], "blocked test board should load")
	var wrong_color_colony = ColonyModelScript.new()
	wrong_color_colony.configure(1)
	_check(wrong_color_colony.register_squad("teal_only", "teal", 2)["valid"], "teal squad should register")
	_check(TurnResolverScript.is_level_blocked(blocked_board, wrong_color_colony), "no matching squad should be a blocked state")

	blocked_board.set_blocked_cells([Vector2i(1, 2), Vector2i(0, 1), Vector2i(0, 3)])
	var amber_only_colony = ColonyModelScript.new()
	amber_only_colony.configure(1)
	_check(amber_only_colony.register_squad("amber_only", "amber", 2)["valid"], "amber squad should register")
	_check(TurnResolverScript.is_level_blocked(blocked_board, amber_only_colony), "unreachable resources should be a blocked state")

	if _failures.is_empty():
		print("TurnResolver tests passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error("TurnResolver test failed: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
