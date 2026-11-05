extends SceneTree

const BoardModelScript = preload("res://scripts/core/board_model.gd")
const ColonyModelScript = preload("res://scripts/core/colony_model.gd")
const LevelDefinitionScript = preload("res://scripts/core/level_definition.gd")
const LevelLoaderScript = preload("res://scripts/core/level_loader.gd")
const TurnResolverScript = preload("res://scripts/core/turn_resolver.gd")

const LEVEL_PATHS := [
	"res://levels/level_001.json",
	"res://levels/level_002.json",
	"res://levels/level_003.json",
]


var _failures: Array[String] = []


func _initialize() -> void:
	for level_path in LEVEL_PATHS:
		_test_level(level_path)

	if _failures.is_empty():
		print("Campaign level tests passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error("Campaign level test failed: " + failure)
		quit(1)


func _test_level(level_path: String) -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(level_path))
	_check(typeof(parsed) == TYPE_DICTIONARY, "%s should parse as JSON object" % level_path)
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var data: Dictionary = parsed
	var validation: Dictionary = LevelDefinitionScript.validate(data)
	_check(validation["valid"], "%s should validate: %s" % [level_path, str(validation["errors"])])
	if not validation["valid"]:
		return

	var board = BoardModelScript.new()
	var colony = ColonyModelScript.new()
	var loaded: Dictionary = LevelLoaderScript.load_into(data, board, colony)
	_check(loaded["valid"], "%s should load into board and colony" % level_path)
	_check(colony.slot_capacity == int(data["deployment_slots"]), "%s should apply authored slot count" % level_path)
	_check(colony.get_squad_ids().size() == data["squads"].size(), "%s should load every authored squad" % level_path)

	# Solve each authored level deterministically: send each color-matched squad
	# only to its resources, return it when full or when that color is exhausted.
	for squad_id in colony.get_squad_ids():
		var squad: Dictionary = colony.get_squad(squad_id)
		var matching_cells: Array[Vector2i] = []
		for cell in board.get_resource_cells():
			if board.resource_color_at(cell) == squad["color"]:
				matching_cells.append(cell)

		var cell_index := 0
		while cell_index < matching_cells.size():
			var deploy_result: Dictionary = colony.deploy_squad(squad_id)
			_check(deploy_result["valid"], "%s: squad %s should deploy" % [level_path, squad_id])
			if not deploy_result["valid"]:
				return

			var carried_this_trip := 0
			while cell_index < matching_cells.size() and carried_this_trip < squad["capacity"]:
				var target: Vector2i = matching_cells[cell_index]
				var collect_result: Dictionary = TurnResolverScript.apply_collection(
					colony, board, squad_id, board.start, target
				)
				_check(collect_result["valid"], "%s: squad %s should reach matching resource %s" % [level_path, squad_id, str(target)])
				if not collect_result["valid"]:
					return
				cell_index += 1
				carried_this_trip += 1

			var return_result: Dictionary = colony.return_squad(squad_id)
			_check(return_result["valid"], "%s: squad %s should return" % [level_path, squad_id])

	_check(TurnResolverScript.is_level_complete(board, colony), "%s should be completable with its authored roster" % level_path)
	_check(not TurnResolverScript.is_level_blocked(board, colony), "%s should not end in a blocked state" % level_path)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
